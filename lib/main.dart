import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:teste_app/app/repository/book_repository.dart';
import 'package:teste_app/app/screens/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final BookRepository bookRepository = BookRepository(dio: Dio());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: MyHomePage(bookRepository: bookRepository),
    );
  }
}
