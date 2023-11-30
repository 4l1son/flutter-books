import '../repository/book_repository.dart';
import '../models/book.dart';

class HomeViewModel {
  final BookRepository bookRepository;

  HomeViewModel({required this.bookRepository});

  Future<List<Book>> fetchBooks() async {
    try {
      return await bookRepository.fetchBooks('https://escribo.com/books.json');
    } catch (error) {
      print('Erro ao buscar livros: $error');
      throw error;
    }
  }
}
