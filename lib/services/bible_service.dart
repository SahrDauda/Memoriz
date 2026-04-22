import 'dart:convert';
import 'package:http/http.dart' as http;

class BibleService {
  static const String _baseUrl = 'https://rest.api.bible/v1';
  static const String _apiKey = 'Xi0vUbwow5tuTeQWq7hMC';

  Map<String, String> get _headers => {
    'api-key': _apiKey,
    'accept': 'application/json',
  };

  Future<List<Map<String, dynamic>>> getBibles() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/bibles?language=eng'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return List<Map<String, dynamic>>.from(jsonResponse['data']);
    } else {
      throw Exception('Failed to load translations');
    }
  }

  Future<List<Map<String, dynamic>>> getBooks(String bibleId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/bibles/$bibleId/books'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return List<Map<String, dynamic>>.from(jsonResponse['data']);
    } else {
      throw Exception('Failed to load books');
    }
  }

  Future<List<Map<String, dynamic>>> getChapters(String bibleId, String bookId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/bibles/$bibleId/books/$bookId/chapters'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return List<Map<String, dynamic>>.from(jsonResponse['data']);
    } else {
      throw Exception('Failed to load chapters');
    }
  }

  Future<List<Map<String, dynamic>>> getVerses(String bibleId, String chapterId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/bibles/$bibleId/chapters/$chapterId/verses'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return List<Map<String, dynamic>>.from(jsonResponse['data']);
    } else {
      throw Exception('Failed to load verses');
    }
  }

  Future<Map<String, dynamic>> getVerseContent(String bibleId, String verseId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/bibles/$bibleId/verses/$verseId?content-type=text&include-notes=false&include-titles=true'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['data'];
    } else {
      throw Exception('Failed to load verse content');
    }
  }

  Future<Map<String, dynamic>> getChapterContent(String bibleId, String chapterId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/bibles/$bibleId/chapters/$chapterId?content-type=html&include-notes=false&include-titles=true&include-chapter-numbers=false&include-verse-numbers=true'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['data'];
    } else {
      throw Exception('Failed to load chapter content');
    }
  }
}
