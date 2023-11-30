import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/book.dart';
import '../repository/book_repository.dart';
import '../viewmodels/home_viewmodel.dart';

class MyHomePage extends StatefulWidget {
  final BookRepository bookRepository;

  MyHomePage({required this.bookRepository});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final HomeViewModel _viewModel =
      HomeViewModel(bookRepository: BookRepository(dio: Dio()));

  List<Book> books = [];
  List<Book> favoriteBooks = [];
  List<File> downloadedBookCovers = [];

  Future<void> fetchBooks() async {
    try {
      List<Book> data = await _viewModel.fetchBooks();
      setState(() {
        books = data;
      });
    } catch (error) {
      print('Erro ao buscar livros: $error');
    }
  }

  String _safeConvertToString(dynamic value) {
    if (value is String) {
      return value;
    } else if (value == null) {
      return 'Informação não disponível';
    } else {
      return value.toString();
    }
  }

  Future<void> _downloadBook(String downloadUrl, String title) async {
    try {
      Response<List<int>> response = await Dio().get<List<int>>(
        downloadUrl,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      Directory dir = await getApplicationDocumentsDirectory();
      File file = File('${dir.path}/$title.epub');
      await file.writeAsBytes(response.data!, flush: true);

      downloadedBookCovers.add(file);

      print('Livro baixado com sucesso: ${file.path}');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Download Concluído'),
            content: Text('O livro foi baixado com sucesso!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      print('Erro ao baixar o livro: $error');
    }
  }

  void _toggleFavorite(int id) {
    setState(() {
      int index = books.indexWhere((book) => book.id == id);
      if (index != -1) {
        books[index].isFavorite = !books[index].isFavorite;

        if (books[index].isFavorite) {
          favoriteBooks.add(books[index]);
        } else {
          favoriteBooks.removeWhere((book) => book.id == id);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  void _navigateToBookshelf() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Livros'),
          actions: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: _navigateToBookshelf,
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Todos'),
              Tab(text: 'Favoritos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBooksList(books),
            _buildBooksList(favoriteBooks),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksList(List<Book> bookList) {
    double screenWidth = MediaQuery.of(context).size.width;
    int columns = (screenWidth / 160.0).floor(); 

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: bookList.map((book) {
            return Card(
              child: Container(
                width: screenWidth / columns - 16.0, 
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _downloadBook(book.downloadUrl, book.title);
                      },
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.network(
                            book.coverUrl,
                            height: 120.0,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          IconButton(
                            icon: book.isFavorite
                                ? Icon(Icons.favorite, color: Colors.red) 
                                : Icon(Icons.favorite_border),
                            onPressed: () {
                              _toggleFavorite(book.id);
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Título: ${book.title}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Autor: ${book.author}'),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class VocsyEpubViewer {
  static openBook(String bookPath) {}
}

class EpubReader extends StatelessWidget {
  final String bookPath;

  EpubReader({required this.bookPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leitor de Livro EPUB'),
      ),
      body: FutureBuilder(
        future: VocsyEpubViewer.openBook(bookPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Erro ao abrir o livro: ${snapshot.error}'),
              );
            }
            return snapshot.data as Widget;
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
