import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Ollama Generate Embeddings API tests',
      skip: Platform.environment.containsKey('CI'), () {
    late OllamaClient client;
    const defaultModel = 'mxbai-embed-large:335m';

    setUp(() async {
      client = OllamaClient();
      // Check that the model exists
      final res = await client.listModels();
      expect(
        res.models?.firstWhere((final m) => m.model!.startsWith(defaultModel)),
        isNotNull,
      );
    });

    tearDown(() {
      client.endSession();
    });

    test('Test call embeddings API', () async {
      const testPrompt = 'Here is an article about llamas...';

      final response = await client.generateEmbedding(
        request: const GenerateEmbeddingRequest(
          model: defaultModel,
          prompt: testPrompt,
        ),
      );
      expect(response.embedding, isNotEmpty);
    });
  });
}
