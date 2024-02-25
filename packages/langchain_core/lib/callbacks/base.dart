import 'dart:async';
import 'dart:convert';
import 'package:langchain/langchain.dart';
import 'package:langchain_core/messages/base.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../outputs/generation_chunk.dart';
// Note: You'll need appropriate imports for 'Document', 'BaseMessage',
// 'ChatGenerationChunk', and 'GenerationChunk' based on your LangChain setup.
/// Mixin for Retriever callbacks.
mixin RetrieverManagerMixin {
  /// Run when Retriever errors.
  @mustBeOverridden
  @mustCallSuper
  void onRetrieverError(
      final Exception error, {
        required final String runId,
        String? parentRunId,
        // Add other kwargs if needed
      });

  void onRetrieverEnd(
      List<Document> documents, {
        required String runId,
        String? parentRunId,
        // Add other kwargs if needed
      });
}

mixin LLMManagerMixin {
  void onLlmNewToken(
      String token, {
        required GenerationChunk  chunk, // Or ChatGenerationChunk
        required String runId,
        String? parentRunId,
        // Add other kwargs if needed
      }){
    parentRunId ??= const Uuid().v4();
  }

  void onLlmEnd(
      LLMResult response, {
        required String runId,
        String? parentRunId,
        // Add other kwargs if needed
      });

  void onLlmError(
      Exception error, {
        required String runId,
        String? parentRunId,
        // Add other kwargs if needed
      });
}


mixin ChainManagerMixin {
  void onChainEnd(
      Map<String, dynamic> outputs, {
        required String runId,
        String? parentRunId,
        // Add other kwargs if needed
      });

  void onChainError(
      Exception error, {
        required String runId,
        String? parentRunId,
        // Add other kwargs if needed
      });

  void onAgentAction(
      AgentAction action, {
        required String runId,
        String? parentRunId,
        // Add other kwargs if needed
      });

  void onAgentFinish(
      AgentFinish finish, {
        required String runId,
        String? parentRunId,
        // Add other kwargs if needed
      });
}

///"""Mixin for tool callbacks."""
mixin ToolManagerMixin {
  ///"""Run when tool ends running."""
  void onToolEnd(
      String output, {
        required String runId,
        String? parentRunId,
        // Add other kwargs if needed
      });

  ///"""Run when tool errors."""
  void onToolError(
      Exception error, {
        required String runId,
        String? parentRunId,
        // Add other kwargs if needed
      });
}

mixin CallbackManagerMixin {
  void onLlmStart(
      Map<String, dynamic> serialized,
      List<String> prompts, {
        required String runId,
        String? parentRunId,
        List<String>? tags,
        Map<String, dynamic>? metadata,
        // Add other kwargs if needed
      });

  void onChatModelStart(
      Map<String, dynamic> serialized,
      List<List<BaseMessage>> messages, {
        required String runId,
        String? parentRunId,
        List<String>? tags,
        Map<String, dynamic>? metadata,
        // Add other kwargs if needed
      });

  /// """Run when Retriever starts running."""
  dynamic onRetrieverStart(
      Map<String, dynamic> serialized,
      String query, {
        required String runId,
        String? parentRunId,
        List<String>? tags,
        Map<String, dynamic>? metadata,
        // Add other kwargs if needed
      });

  /// """Run when chain starts running."""
  dynamic onChainStart(
      Map<String, dynamic> serialized,
      Map<String, dynamic> inputs, {
        required String runId,
        String? parentRunId,
        List<String>? tags,
        Map<String, dynamic>? metadata,
        // Add other kwargs if needed
      });


  /// """Run when tool starts running."""
  dynamic onToolStart(
      Map<String, dynamic> serialized,
      String inputStr, {
        required String runId,
        String? parentRunId,
        List<String>? tags,
        Map<String, dynamic>? metadata,
        Map<String, dynamic>? inputs,
        // Add other kwargs if needed
      });
}

/// """Mixin for run manager."""
mixin RunManagerMixin {
  /// """Run on arbitrary text."""
  void onText(
      String text, {
        required String runId,
        String? parentRunId,
        // Add other kwargs if needed
      });
  /// """Run on a retry event."""
  void onRetry(
      RetryCallState retryState, {
        required String runId,
        String? parentRunId,
        // Add other kwargs if needed
      });
}

class RetryCallState {
}
abstract class BaseCallbackHandler
    with
        LLMManagerMixin,
        ChainManagerMixin,
        ToolManagerMixin,
        RetrieverManagerMixin,
        CallbackManagerMixin,
        RunManagerMixin {
  bool raiseError = false;
  bool runInline = false;

// Implementation of handler methods
}

// Consider using an AsyncCallbackHandler (similar structure but with async methods)
// if you need asynchronous operations within your callbacks.
