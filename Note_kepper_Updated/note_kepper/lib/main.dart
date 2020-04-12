import 'package:flutter/material.dart';
import 'package:flutter_app/Bloc/theme.dart';
import 'package:flutter_app/screens/note_it_list.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DynamicTheme>(
      create: (_)=>DynamicTheme(ThemeData.dark()),
   child: ThemedMaterialApp()
  );
  }
}

class ThemedMaterialApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme=Provider.of<DynamicTheme>(context);
    return   MaterialApp(
      title: 'NoteIt',
      debugShowCheckedModeBanner: false,
      home: NoteList(),
      theme: theme.getTheme(),
    );
  }
}
