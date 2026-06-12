import 'dart:math';
import '../features/marketplace/models/item_model.dart';

// The BM25 ranking algorithm is applied to improve item search relevance in
// the marketplace. Before ranking, item name, description, and category are
// preprocessed through lowercasing, punctuation removal, tokenization, and
// stop-word removal. The processed query is compared against item records,
// and each item receives a relevance score. Items with higher BM25 scores
// are displayed first in the search results.

// Simple BM25 implementation for ranking items based on search query
class BM25Service {
  static const double k1 = 1.5;
  static const double b = 0.75;
  // Preprocess text by lowercasing, removing punctuation, tokenizing, and removing stop words
  static List<String> preprocess(String text) {
    final stopWords = {
      'the',
      'is',
      'a',
      'an',
      'and',
      'or',
      'for',
      'to',
      'with',
      'in',
      'on',
      'of',
      'this',
      'that',
      'very',
    };

    return text
        // lowercase the text
        .toLowerCase()
        // remove punctuation
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        // split into words and remove stop words
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty && !stopWords.contains(word))
        .toList();
  }

  static List<Item> rankItems(String query, List<Item> items) {
    if (items.isEmpty) return [];

    final queryTerms = preprocess(query);
    if (queryTerms.isEmpty) return items;

    final documents = items.map((item) {
      final text = '${item.itemName} ${item.description} ${item.category}';
      return preprocess(text);
    }).toList();

    final totalDocLength = documents.fold<int>(
      0,
      (sum, doc) => sum + doc.length,
    );

    final double avgDocLength = totalDocLength / documents.length;

    final List<MapEntry<Item, double>> scoredItems = [];

    for (int i = 0; i < items.length; i++) {
      final doc = documents[i];
      double score = 0.0;

      for (final term in queryTerms) {
        final int termFrequency = doc.where((word) => word == term).length;

        if (termFrequency == 0) continue;

        final int docsWithTerm = documents
            .where((document) => document.contains(term))
            .length;

        final double idf = log(
          (documents.length - docsWithTerm + 0.5) / (docsWithTerm + 0.5) + 1,
        );

        final double numerator = termFrequency * (k1 + 1);
        final double denominator =
            termFrequency + k1 * (1 - b + b * (doc.length / avgDocLength));

        score += idf * (numerator / denominator);
      }

      if (score > 0) {
        scoredItems.add(MapEntry(items[i], score));
      }
    }

    scoredItems.sort((a, b) => b.value.compareTo(a.value));

    return scoredItems.map((entry) => entry.key).toList();
  }
}
