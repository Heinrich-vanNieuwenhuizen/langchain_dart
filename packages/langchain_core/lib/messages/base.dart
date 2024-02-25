import 'dart:convert';

import 'package:serializable/serializable.dart';



class BaseMessage extends Serializable {
  dynamic content;
  Map<String, dynamic> additionalKwargs;
  String type;
  String? name;

  BaseMessage(this.content, {this.additionalKwargs = const {}, required this.type, this.name});

  Map<String, dynamic> toJson() => {
    'content': content,
    'additionalKwargs': additionalKwargs,
    'type': type,
    'name': name,
  };

  static bool isLcSerializable() => true;

  static List<String> getLcNamespace() => ["langchain", "schema", "messages"];

  BaseMessage operator +(BaseMessage other) {
    // Assuming content merging logic is implemented in mergeContent function
    return BaseMessage(
      mergeContent(content, other.content),
      additionalKwargs: _mergeKwargsDict(additionalKwargs, other.additionalKwargs),
      type: type,
    );
  }

  String prettyPrint({bool html = false}) {
    var title = getMsgTitleRepr('${type[0].toUpperCase()}${type.substring(1)} Message', bold: html);
    if (name != null) {
      title += '\nName: $name';
    }
    return '$title\n\n$content';
  }

  Map<String, dynamic> _mergeKwargsDict(Map<String, dynamic> left, Map<String, dynamic> right) {
    final merged = Map<String, dynamic>.from(left);
    right.forEach((key, value) {
      if (!merged.containsKey(key) || merged[key] == null && value != null) {
        merged[key] = value;
      } else if (value != null && merged[key] != null) {
        // Handle merging logic based on your requirements, e.g., appending strings, merging lists, etc.
        if (merged[key] is String && value is String) {
          merged[key] = merged[key] + value;
        } else if (merged[key] is Map<String, dynamic> && value is Map<String, dynamic>) {
          merged[key] = _mergeKwargsDict(merged[key], value);
        } // Add more conditions as necessary for your use case
      }
    });
    return merged;
  }
}


String getMsgTitleRepr(String title, {bool bold = false}) {
  var padded = ' $title ';
  var sepLen = (80 - padded.length) ~/ 2;
  var sep = '=' * sepLen;
  var secondSep = sep + (padded.length % 2 != 0 ? '=' : '');
  return bold ? '<b>$sep$padded$secondSep</b>' : '$sep$padded$secondSep';
}

// Implement `mergeContent` function to merge dynamic content types (String and List)

dynamic mergeContent(dynamic firstContent, dynamic secondContent) {
  if (firstContent is String) {
    if (secondContent is String) {
      return firstContent + secondContent;
    } else if (secondContent is List) {
      return [firstContent, ...secondContent];
    }
  } else if (firstContent is List) {
    if (secondContent is String) {
      return [...firstContent, secondContent];
    } else if (secondContent is List) {
      return [...firstContent, ...secondContent];
    }
  }
  throw ArgumentError('Unsupported content types for merging');
}
