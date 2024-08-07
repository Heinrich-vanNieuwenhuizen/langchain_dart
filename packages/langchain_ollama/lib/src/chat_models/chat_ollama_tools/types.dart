import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/tools.dart';

import '../chat_ollama/types.dart';
import 'chat_ollama_tools.dart';

export '../chat_ollama/types.dart';

/// {@template chat_ollama_tools_options}
/// Options to pass into [ChatOllamaTools].
/// {@endtemplate}
class ChatOllamaToolsOptions extends ChatModelOptions {
  /// {@macro chat_ollama_tools_options}
  const ChatOllamaToolsOptions({
    this.options,
    super.tools,
    super.toolChoice,
    this.toolsSystemPromptTemplate,
  });

  /// [ChatOllamaOptions] to pass into Ollama.
  final ChatOllamaOptions? options;

  /// Prompt template for the system message where the model is instructed to
  /// use the tools.
  ///
  /// The following placeholders can be used:
  /// - `{tools}`: The list of tools available to the model.
  /// - `{tool_choice}`: the tool choice the model must always select.
  ///
  /// If not provided, [defaultToolsSystemPromtTemplate] will be used.
  final String? toolsSystemPromptTemplate;

  /// Default [toolsSystemPromptTemplate].
  static const String defaultToolsSystemPromtTemplate = '''
You have access to these tools: 
{tools}

Based on the user input, select {tool_choice} from the available tools.

Respond with a JSON containing a list of tool call objects. 
The tool call objects should have two properties:
- "tool_name": The name of the selected tool (string)
- "tool_input": A JSON string with the input for the tool matching the tool's input schema

Example response format:
```json
{{
  "tool_calls": [
    {{
      "tool_name": "tool_name",
      "tool_input": "{{"param1":"value1","param2":"value2"}}"
    }}
  ]
}}
```

Ensure your response is valid JSON and follows this exact format.
''';
}

/// Default tool called if model decides no other tools should be called
/// for a given query.
final conversationalResponseTool = StringTool.fromFunction(
  name: '_conversational_response',
  description:
      'Respond conversationally if no other tools should be called for a given query.',
  inputDescription: 'Conversational response to the user',
  func: (input) => input,
);
