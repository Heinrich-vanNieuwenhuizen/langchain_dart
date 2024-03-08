import 'package:meta/meta.dart';

import '../../langchain.dart';
import 'agents.dart';
import 'tools/exception.dart';
import 'tools/invalid.dart';

/// {@template agent_executor}
/// A chain responsible for executing the actions of an agent using tools.
/// It receives user input and passes it to the agent, which then decides which
/// tool/s to use and what action/s to take.
///
/// The [AgentExecutor] calls the specified tool with the generated input,
/// retrieves the output, and passes it back to the agent to determine the next
/// action. This process continues until the agent determines it can directly
/// respond to the user or completes its task.
///
/// If you add [memory] to the [AgentExecutor], it will save the
/// [AgentExecutor]'s inputs and outputs. It won't save the agent's
/// intermediate inputs and outputs. If you want to save the agent's
/// intermediate inputs and outputs, you should add [memory] to the agent
/// instead.
/// {@endtemplate}
class AgentExecutor extends BaseChain {
  /// {@macro agent_executor}
  AgentExecutor({
    required this.agent,
    super.memory,
    this.returnIntermediateSteps = false,
    this.maxIterations = 15,
    this.maxExecutionTime,
    this.earlyStoppingMethod = AgentEarlyStoppingMethod.force,
    this.handleParsingErrors,
  }) : _internalTools = [...agent.tools, ExceptionTool()] {
    assert(
      _validateMultiActionAgentTools(),
      'Tools that have `returnDirect=true` are not allowed in multi-action agents',
    );
  }

  /// The agent to run for creating a plan and determining actions to take at
  /// each step of the execution loop.
  final BaseActionAgent agent;

  /// The valid tools the agent can call plus some internal tools used by the
  /// executor.
  final List<BaseTool> _internalTools;

  /// Whether to return the agent's trajectory of intermediate steps at the
  /// end in addition to the final output.
  final bool returnIntermediateSteps;

  /// The maximum number of steps to take before ending the execution loop.
  /// Setting to null could lead to an infinite loop.
  final int? maxIterations;

  /// The maximum amount of wall clock time to spend in the execution loop.
  final Duration? maxExecutionTime;

  /// The method to use for early stopping if the agent never returns
  /// [AgentFinish].
  final AgentEarlyStoppingMethod earlyStoppingMethod;

  /// Handles errors raised by the agent's output parser.
  /// The response from this handlers is passed to the agent as the observation
  /// resulting from the step.
  final dynamic handleParsingErrors;

  /// Output key for the agent's intermediate steps output.
  static const intermediateStepsOutputKey = 'intermediate_steps';

  @override
  Set<String> get inputKeys => agent.inputKeys;

  @override
  Set<String> get outputKeys => {
        ...agent.returnValues,
        if (returnIntermediateSteps) intermediateStepsOutputKey,
      };

  ///  How to handle errors raised by the agent's output parser.
  ///   Defaults to `False`, which raises the error.
  ///   If `true`, the error will be sent back to the LLM as an observation.
  ///   If a string, the string itself will be sent to the LLM as an observation.
  ///   If a callable function, the function will be called with the exception
  ///    as an argument, and the result of that function will be passed to the agent
  ///     as an observation.
  (int, List<(AgentStep, String)> Function()?, List<(AgentStep, String)>?) trimIntermediateSteps = (-1,null,null);
  /// Validate that tools are compatible with multi action agent.
  bool _validateMultiActionAgentTools() {
    final agent = this.agent;
    final tools = _internalTools;
    if (agent is BaseMultiActionAgent) {
      for (final BaseTool tool in tools) {
        if (tool.returnDirect) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  Future<ChainValues> callInternal(final ChainValues inputs) async {
    final List<AgentStep> intermediateSteps = [];

    // Construct a mapping of tool name to tool for easy lookup
    final nameToToolMap = {for (final tool in _internalTools) tool.name: tool};

    // Let's start tracking the number of iterations and time elapsed
    int iterations = 0;
    final stopwatch = Stopwatch()..start();

    ChainValues onAgentFinished(final AgentFinish result) {
      return {
        ...result.returnValues,
        if (returnIntermediateSteps)
          intermediateStepsOutputKey: intermediateSteps,
      };
    }

    // We now enter the agent loop (until it returns something).
    while (_shouldContinue(iterations, stopwatch.elapsed)) {
      final (result, nextSteps) = await takeNextStep(
        nameToToolMap,
        inputs,
        intermediateSteps,
      );

      if (result != null) {
        return onAgentFinished(result);
      }

      if (nextSteps != null) {
        intermediateSteps.addAll(nextSteps);

        if (nextSteps.length == 1) {
          final nextStep = nextSteps.first;
          final tool = nameToToolMap[nextStep.action.tool];

          if (tool != null && tool.returnDirect) {
            return onAgentFinished(
              AgentFinish(
                returnValues: {
                  agent.returnValues.first: nextStep.observation,
                },
              ),
            );
          }
        }
      }

      iterations += 1;
    }

    final stopped = agent.returnStoppedResponse(
      earlyStoppingMethod,
      intermediateSteps,
    );
    return onAgentFinished(stopped);
  }

  /// Returns whether the execution loop should continue.
  bool _shouldContinue(final int iterations, final Duration timeElapsed) {
    if (maxIterations != null && iterations >= maxIterations!) {
      return false;
    }
    if (maxExecutionTime != null && timeElapsed >= maxExecutionTime!) {
      return false;
    }
    return true;
  }

  /// Take a single step in the thought-action-observation loop.
  /// Override this to take control of how the agent makes and acts on choices.
  @visibleForOverriding
  Future<(AgentFinish? result, List<AgentStep>? nextSteps)> takeNextStep(
    final Map<String, BaseTool> nameToToolMap,
    final ChainValues inputs,
    final List<AgentStep> intermediateSteps,
  ) async {
    List<BaseAgentAction> actions;

    try {
      // Call the LLM to see what to do
      actions = await agent.plan(AgentPlanInput(inputs, intermediateSteps));
    } on OutputParserException catch (e) {
      if (handleParsingErrors == null) rethrow;
      actions = [
        AgentAction(
          tool: ExceptionTool.toolName,
          toolInput: {Tool.inputVar: handleParsingErrors!(e)},
          log: e.toString(),
        ),
      ];
    }

    final List<AgentStep> result = [];
    for (final action in actions) {
      // If the tool chosen is the finishing tool, then we end and return
      if (action is AgentFinish) {
        return (action, null);
      }
      // Otherwise, we run the tool
      final agentAction = action as AgentAction;
      final tool = nameToToolMap[agentAction.tool];
      final step = AgentStep(
        action: action,
        observation: await (tool != null
            ? tool.run(agentAction.toolInput)
            : InvalidTool().run({Tool.inputVar: agentAction.tool})),
      );
      result.add(step);
    }
    return (null, result);
  }

  /// {@macro chain_type}
  bool shouldContinue(final int iterations, final double timeElapsed) {
    if (maxIterations != null && iterations >= maxIterations!) {
      return false;
    }
    if (maxExecutionTime != null &&
        timeElapsed >= maxExecutionTime!.inSeconds) {
      return false;
    }
    return true;
  }

  // def return(
  // self,
  // output: AgentFinish,
  // intermediate_steps: list,
  // run_manager: Optional[CallbackManagerForChainRun] = None,
  // ) -> Dict[str, Any]:
  // if run_manager:
  // run_manager.on_agent_finish(output, color="green", verbose=self.verbose)
  // final_output = output.return_values
  // if self.return_intermediate_steps:
  // final_output["intermediate_steps"] = intermediate_steps
  // return final_output

  /// Return the final output of the agent.
  ChainValues returnOutput(final AgentFinish output, final List<AgentStep> intermediateSteps,
      /*CallbackManagerForChainRun? runManager*/) {
    // if (runManager != null) {
    //   runManager.onAgentFinish(output, "green");
    // }
    final finalOutput = output.returnValues;
    if (returnIntermediateSteps) {
      finalOutput[intermediateStepsOutputKey] = intermediateSteps;
    }
    return finalOutput;
  }

  /// Check if the tool is a returning tool.
  AgentFinish? getToolReturn(final AgentStep nextStepOutput) {
    final agentAction = nextStepOutput.action;
    final observation = nextStepOutput.observation;

    /// convert list of tools to map using name of said tool
    final nameToToolMap = {for (final tool in agent.tools) tool.name: tool};
    String returnValueKey = 'output';
    if (agent.returnValues.isNotEmpty) {
      returnValueKey = agent.returnValues.first;
    }
    // Invalid tools won't be in the map, so we return null.
    if (nameToToolMap.containsKey(agentAction.tool)) {
      final tool = nameToToolMap[agentAction.tool]!;
      if (tool.returnDirect) {
        return AgentFinish(
          returnValues: {returnValueKey: observation},
          log: '',
        );
      }
    }
    return null;
  }

  // def _prepare_intermediate_steps(
  // self, intermediate_steps: List[Tuple[AgentAction, str]]
  // ) -> List[Tuple[AgentAction, str]]:
  // if (
  // isinstance(self.trim_intermediate_steps, int)
  // and self.trim_intermediate_steps > 0
  // ):
  // return intermediate_steps[-self.trim_intermediate_steps :]
  // elif callable(self.trim_intermediate_steps):
  // return self.trim_intermediate_steps(intermediate_steps)
  // else:
  // return intermediate_steps

  /// Prepare the agent's intermediate steps.
  // List<({AgentAction action, String description})> prepareIntermediateSteps(
  //     final List<(AgentAction,String)> intermediateSteps,) {
  //   if (trimIntermediateSteps is int && trimIntermediateSteps > 0) {
  //     return intermediateSteps.sublist(
  //       intermediateSteps.length - trimIntermediateSteps,
  //     );
  //   } else if (trimIntermediateSteps is Function) {
  //     return trimIntermediateSteps(intermediateSteps);
  //   } else {
  //     return intermediateSteps;
  //   }
  // }

  @override
  String get chainType => 'agent_executor';
}
