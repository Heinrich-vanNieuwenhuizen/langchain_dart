
import 'package:langchain/src/agents/models/models.dart';
import 'package:langchain_core/callbacks/base.dart';

///Callback manager for chain run.
class CallbackManagerForChainRun /*extends ParentRunManager with ChainManagerMixin*/{
  ///Run when agent action is received.
  void onAgentAction(/*AgentAction*/ final dynamic agentAction, final String s) {}
  ///Run when agent finish is received.
  ///   Args:
  ///      finish (AgentFinish): The agent finish.
  ///   Returns:
  ///      Any: The result of the callback.
  dynamic onAgentFinish(AgentFinish output, {required String color, required bool verbose}) {
    // handleEvent(
    //   self.handlers,
    //   "on_agent_finish",
    //   "ignore_agent",
    //   finish,
    //   run_id=self.run_id,
    //   parent_run_id=self.parent_run_id,
    //   tags=self.tags,
    //   **kwargs,
    // )
  }

  void handleEvent(
      List<BaseCallbackHandler> handlers,
      String eventName,
      String? ignoreConditionName,
      List<dynamic> args,
      Map<String, dynamic> kwargs,
      ) {
    // Dart does not support *args and **kwargs syntax, so we pass them as List and Map
    List<Future> futures = [];

    // try {
    //   List<String>? messageStrings;
    //   for (var handler in handlers) {
    //     try {
    //       if (ignoreConditionName == null || !handler.getIgnoreCondition(ignoreConditionName)) {
    //         var event = Function.apply(handler.getEvent(eventName), args, kwargs);
    //         if (event is Future) {
    //           futures.add(event);
    //         }
    //       }
    //     } catch (e) {
    //       if (eventName == "on_chat_model_start") {
    //         if (messageStrings == null) {
    //           // Assuming getBufferString is a function you have that converts messages to strings
    //           // messageStrings = args[1].map((m) => getBufferString(m)).toList();
    //         }
    //         handleEvent([handler], "on_llm_start", "ignore_llm", [args[0], messageStrings, ...args.sublist(2)], kwargs);
    //       } else {
    //         var handlerName = handler.runtimeType.toString();
    //         print("NotImplementedError in $handlerName.$eventName callback: $e");
    //       }
    //     } catch (e) {
    //       var handlerName = handler.runtimeType.toString();
    //       print("Error in $handlerName.$eventName callback: $e");
    //       if (handler.raiseError) {
    //         throw e;
    //       }
    //     }
    //   }
    // } finally {
    //   if (futures.isNotEmpty) {
    //     runFutures(futures);
    //   }
    // }
  }

  void runFutures(List<Future> futures) {
    // Dart does not require creating a new loop for futures; they can be awaited directly.
    Future.wait(futures).then((_) {
      // Handle completion
    }).catchError((e) {
      print("Error in callback coroutine: $e");
    });
  }

}
// """Callback manager for chain run."""

// def on_chain_end(self, outputs: Union[Dict[str, Any], Any], **kwargs: Any) -> None:
// """Run when chain ends running.
//
//         Args:
//             outputs (Union[Dict[str, Any], Any]): The outputs of the chain.
//         """
// handle_event(
// self.handlers,
// "on_chain_end",
// "ignore_chain",
// outputs,
// run_id=self.run_id,
// parent_run_id=self.parent_run_id,
// tags=self.tags,
// **kwargs,
// )
//
// def on_chain_error(
// self,
// error: BaseException,
// **kwargs: Any,
// ) -> None:
// """Run when chain errors.
//
//         Args:
//             error (Exception or KeyboardInterrupt): The error.
//         """
// handle_event(
// self.handlers,
// "on_chain_error",
// "ignore_chain",
// error,
// run_id=self.run_id,
// parent_run_id=self.parent_run_id,
// tags=self.tags,
// **kwargs,
// )
//
// def on_agent_action(self, action: AgentAction, **kwargs: Any) -> Any:
// """Run when agent action is received.
//
//         Args:
//             action (AgentAction): The agent action.
//
//         Returns:
//             Any: The result of the callback.
//         """
// handle_event(
// self.handlers,
// "on_agent_action",
// "ignore_agent",
// action,
// run_id=self.run_id,
// parent_run_id=self.parent_run_id,
// tags=self.tags,
// **kwargs,
// )
//
// def on_agent_finish(self, finish: AgentFinish, **kwargs: Any) -> Any:
// """Run when agent finish is received.
//
//         Args:
//             finish (AgentFinish): The agent finish.
//
//         Returns:
//             Any: The result of the callback.
//         """
// handle_event(
// self.handlers,
// "on_agent_finish",
// "ignore_agent",
// finish,
// run_id=self.run_id,
// parent_run_id=self.parent_run_id,
// tags=self.tags,
// **kwargs,
// )backManagerForChainRun