import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

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

  Future<void> fetchBooks() async {
    try {
      Response response = await Dio().get('https://escribo.com/books.json');
      List<dynamic> data = response.data;
      setState(() {
        books = data.map<Map<String, dynamic>>((book) => {
          'title': _safeConvertToString(book['title']),
          'author': _safeConvertToString(book['author']),
          'cover_url': _safeConvertToString(book['cover_url']),
          'download_url': _safeConvertToString(book['download_url']),
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

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livros'),
      ),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text('Título: ${books[index]['title']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Autor: ${books[index]['author']}'),
                  Image.network(
                    books[index]['cover_url'],
                    height: 100.0,
                    width: 100.0,
                  ),
                  SizedBox(height: 8.0),
                  Text('Download URL: ${books[index]['download_url']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
