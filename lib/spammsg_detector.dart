import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class NaiveBayesClassifier {
  late List<String> classes;
  late List<double> classLogPrior;
  late List<List<double>> featureLogProb;
  late Map<String, int> vocabulary;

  Future<void> loadModel(String path) async {
    final jsonString = await rootBundle.loadString(path);
    final jsonData = json.decode(jsonString);

    classes = List<String>.from(jsonData['classes']);
    classLogPrior = List<double>.from(jsonData['class_log_prior']);
    featureLogProb = (jsonData['feature_log_prob'] as List)
        .map<List<double>>((row) => List<double>.from(row))
        .toList();
    vocabulary = Map<String, int>.from(jsonData['vocabulary']);
  }

  String predict(String text) {
    final tokens = _tokenize(text);

    // If all words are unknown, return fallback
    if (tokens.isEmpty || tokens.every((t) => !vocabulary.containsKey(t))) {
      return "unknown";
    }

    final input = List.filled(vocabulary.length, 0);
    for (final token in tokens) {
      final index = vocabulary[token];
      if (index != null && index < input.length) {
        input[index] += 1;
      }
    }

    final scores = List<double>.filled(classLogPrior.length, 0.0);
    for (int i = 0; i < scores.length; i++) {
      scores[i] = classLogPrior[i];
      for (int j = 0; j < input.length; j++) {
        scores[i] += input[j] * featureLogProb[i][j];
      }
    }

    // Get class with highest score
    int maxIndex = scores.indexWhere((score) => score == scores.reduce((a, b) => a > b ? a : b));
    if (maxIndex == -1 || maxIndex >= classes.length) {
      return "unknown";
    }

    return classes[maxIndex];
  }

  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }
}

class SpamDetector {
  final _classifier = NaiveBayesClassifier();

  Future<void> loadModel(String path) async {
    await _classifier.loadModel(path);
  }

  Future<bool> isSpam(String text) async {
    final prediction = _classifier.predict(text);
    return prediction == "spam";
  }
}
