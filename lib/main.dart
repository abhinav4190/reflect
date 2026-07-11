import 'package:flutter/material.dart';

void main(){
  runApp(const ReflectApp());
}

class ReflectApp extends StatelessWidget{
  const ReflectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reflect',
      home: Scaffold(
        body: Center(
          child: Text('Reflect.. just starting out'),
        ),
      ),
    );
  }
}