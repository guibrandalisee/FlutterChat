import 'package:Projeto7CursoFlutter/chatScreen.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chat Flutter',
        theme: ThemeData(
            primarySwatch: Colors.purple,
            iconTheme: IconThemeData(color: Colors.purple)),
        home: ChatScreen());
  }
}
