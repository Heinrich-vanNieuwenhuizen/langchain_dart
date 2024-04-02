import '../exceptions/base.dart';



/// {@template output_parser_exception}
/// Exception that output parsers should raise to signify a parsing error.
///
/// This exists to differentiate parsing errors from other code or execution
/// errors that also may arise inside the output parser. OutputParserExceptions
/// will be available to catch and handle in ways to fix the parsing error,
/// while other errors will be raised.
/// {@endtemplate}
///
///     """Exception that output parsers should raise to signify a parsing error.
final class OutputParserException extends LangChainException {
  /// {@macro output_parser_exception}
  final String? observation;
  ///String model output which is error-ing.
  final String? llmOutput;
  ///Whether to send the observation and llm_output back to an Agent
  ///after an OutputParserException has been raised. This gives the underlying
  ///model driving the agent the context that the previous output was improperly
  ///structured, in the hopes that it will update the output to the correct
  ///format
  final bool sendToLlm;
  ///Exception that output parsers should raise to signify a parsing error
  OutputParserException({
    this.observation,
    this.llmOutput,
    this.sendToLlm = false,
    super.message = '',
  }) : super(code: 'output_parser'){
    if (sendToLlm) {
      if (observation == null || llmOutput == null) {
        throw ArgumentError(
          "Arguments 'observation' & 'llm_output'"
          " are required if 'send_to_llm' is True",
        );
      }
    }
  }
}
