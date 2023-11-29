import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> books = [];
  List<Map<String, dynamic>> favoriteBooks = [];
  List<File> downloadedBookCovers = [];

  Future<void> fetchBooks() async {
    try {
      Response response = await Dio().get('https://escribo.com/books.json');
      List<dynamic> data = response.data;
      setState(() {
        books = data.map<Map<String, dynamic>>((book) => {
          'id': book['id'],
          'title': _safeConvertToString(book['title']),
          'author': _safeConvertToString(book['author']),
          'cover_url': _safeConvertToString(book['cover_url']),
          'download_url': _safeConvertToString(book['download_url']),
          'isFavorite': false,
        }).toList();
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

      // Adiciona a capa à lista de capas baixadas
      downloadedBookCovers.add(file);

      // Mostrar uma mensagem de sucesso ou navegar para a visualização do livro.
      print('Livro baixado com sucesso: ${file.path}');

      // Exibir um alerta
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
      int index = books.indexWhere((book) => book['id'] == id);
      if (index != -1) {
        books[index]['isFavorite'] = !books[index]['isFavorite'];

        if (books[index]['isFavorite']) {
          favoriteBooks.add(books[index]);
        } else {
          favoriteBooks.removeWhere((book) => book['id'] == id);
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
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

Widget _buildBooksList(List<Map<String, dynamic>> bookList) {
  double screenWidth = MediaQuery.of(context).size.width;
  int columns = (screenWidth / 160.0).floor(); // Adjust 160.0 as needed for the minimum width

  return Container(
    padding: EdgeInsets.all(8.0),
    child: Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      children: bookList.map((book) {
        return Card(
          child: Container(
            width: screenWidth / columns - 16.0, // Adjust spacing
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _downloadBook(
                          book['download_url'],
                          book['title'],
                        );
                      },
                      child: Image.network(
                        book['cover_url'],
                        height: 120.0,
                        width: 120.0,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: book['isFavorite']
                            ? Icon(Icons.favorite)
                            : Icon(Icons.favorite_border),
                        onPressed: () {
                          _toggleFavorite(book['id']);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Text(
                  'Título: ${book['title']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Autor: ${book['author']}'),
              ],
            ),
          ),
        );
      }).toList(),
    ),
  );
}
}
