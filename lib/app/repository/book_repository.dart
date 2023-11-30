import 'package:dio/dio.dart';
import 'package:teste_app/app/models/book.dart';
class BookRepository {
  final Dio dio;

  BookRepository({required this.dio});

  Future<List<Book>> fetchBooks(String apiUrl) async {
    try {
      Response response = await dio.get(apiUrl);
      List<dynamic> data = response.data;
      return data.map<Book>((bookData) {
        return Book(
          id: bookData['id'],
          title: bookData['title'],
          author: bookData['author'],
          coverUrl: bookData['cover_url'],
          downloadUrl: bookData['download_url'],
        );
      }).toList();
    } catch (error) {
      print('Erro ao buscar livros: $error');
      throw error;
    }
  }
}
