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
      return 'Sem título';
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
          return ListTile(
            title: Text('Título: ${books[index]['title']}'),
            subtitle: Text('Autor: ${books[index]['author']}'),
          );
        },
      ),
    );
  }
}
