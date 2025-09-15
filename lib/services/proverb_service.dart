import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class ProverbService {

  static const String _apiKey = "d9b815a0c06343044328459269921da184994761";
  static const String _apiUrl = "https://api.esv.org/v3/passage/text/";

  // Length of each chapter in Proverbs (index 0 = chapter 1)
  static const List<int> _chapterLengths = [
    33, 22, 35, 27, 23, 35, 27, 36, 18, 32,
    31, 28, 25, 35, 33, 33, 28, 24, 29, 30,
    31, 29, 35, 34, 28, 28, 27, 28, 27, 33,
    31
  ];

  final Random _random = Random();

  /// Picks a random "Proverbs X:Y"
  String _getRandomPassage() {
    final chapter = _random.nextInt(_chapterLengths.length) + 1;
    final verse = _random.nextInt(_chapterLengths[chapter - 1]) + 1;
    return "Proverbs $chapter:$verse";
  }

  /// Calls the ESV API and returns the verse text + reference
  Future<String> getRandomProverb() async {
    final passage = _getRandomPassage();

    final response = await http.get(
      Uri.parse("$_apiUrl?q=$passage&indent-poetry=false&include-headings=false&include-footnotes=false&include-verse-numbers=false&include-short-copyright=false&include-passage-references=false"),
      headers: {"Authorization": "Token $_apiKey"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final passages = data['passages'] as List<dynamic>;
      final canonical = data['canonical'] ?? passage;

      if (passages.isNotEmpty) {
        final text = passages[0].replaceAll(RegExp(r'\s+'), ' ').trim();
        return "$text – $canonical";
      }
    }

    throw Exception("Failed to fetch proverb");
  }
}
