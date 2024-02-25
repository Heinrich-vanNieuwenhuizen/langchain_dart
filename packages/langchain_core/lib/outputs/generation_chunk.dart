import 'dart:convert';
import 'package:langchain/langchain.dart';
import 'package:serializable/serializable.dart'; // Assuming you have a LangChain dependency

class Generation implements Serializable {
  String text;
  Map<String, dynamic>? generationInfo;
  final String type = "Generation";

  Generation({required this.text, this.generationInfo});

  @override
  bool get isLcSerializable => true;

  @override
  List<String> get lcNamespace => ["langchain", "schema", "output"];
}

class GenerationChunk extends Generation {
  GenerationChunk({required String text, Map<String, dynamic>? generationInfo})
      : super(text: text, generationInfo: generationInfo);

  @override
  List<String> get lcNamespace => ["langchain", "schema", "output"];

  GenerationChunk operator +(GenerationChunk other) {
    final generationInfo = mergeDicts(this.generationInfo, other.generationInfo);
    return GenerationChunk(
        text: text + other.text, generationInfo: generationInfo);
  }
}

// Helper for merging dictionaries (Assuming a 'mergeDicts' function exists)
Map<String, dynamic>? mergeDicts(
    Map<String, dynamic>? a, Map<String, dynamic>? b) {
  // Implement your dictionary merging logic here
  // A simple option
  return {...?a, ...?b};
}
