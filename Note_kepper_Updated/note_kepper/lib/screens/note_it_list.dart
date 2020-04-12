import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/map_data.dart';

import 'package:flutter_app/models/database_query_file.dart';
import 'package:flutter_app/screens/note_it_detail.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_app/Bloc/theme.dart';

class NoteList extends StatefulWidget {
  //this page has list of notes
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<NoteData> noteList;

  int count = 0;
  bool isCancelled = true;
  String themeToSelect = 'Change Theme';
  String noteDisplay = 'Notes';

  @override
  Widget build(BuildContext context) {
    DynamicTheme _dynamicTheme = Provider.of<DynamicTheme>(context);
    if (noteList == null) {
      noteList = List<NoteData>();
      updateNoteListView();
    }

    return Scaffold(
      body: Container(
          child: Column(
        children: <Widget>[
          SizedBox(height: 20),
          Align(
              alignment: Alignment.topRight,
              child: Container(
                  child: FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(20),
                ),
                child: Text(
                  themeToSelect,
                  style: TextStyle(fontFamily: 'CM Sans Serif'),
                ),
                onPressed: () {
                  setState(() {
                    if (themeToSelect == 'Dark theme') {
                      themeToSelect = "Light theme";
                      _dynamicTheme.setTheme(ThemeData.dark());
                    } else {
                      themeToSelect = "Dark theme";
                      _dynamicTheme.setTheme(ThemeData.light());
                    }
                  });
                },
                splashColor: Colors.white,
              ))),
          Container(
              height: MediaQuery.of(context).size.height - 500,
              width: double.infinity,
              child: SafeArea(
                  child: ListView(
                padding: EdgeInsets.only(top: 80, left: 5, right: 5),
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  Center(
                      child: (noteDisplay == 'null' || noteDisplay == 'Notes')
                          ? Text("Notes",
                              style:
                                  TextStyle(fontSize: 70, color: Colors.black))
                          : Text(noteDisplay,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 30, fontFamily: 'CM Sans Serif')))
                ],
              ))),
          Expanded(
            child: getNoteListView(), //get the list view of our notes
          )
        ],
      )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          navigateToDetail(
            NoteData('None', 'None', 2),
          );
        },
        tooltip: 'Press to add note',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    return ListView.separated(
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(
          height: 10,
        );
      },
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Align(
          child: Container(
            width: MediaQuery.of(context).size.width - 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            child: ListTile(
              leading: Icon(
                Icons.star,
                color: getPriorityColor(this.noteList[position].priority),
              ),
              title: Text(
                this.noteList[position].title,
                style: TextStyle(fontFamily: 'CM Sans Serif'),
              ),
              subtitle: Text(this.noteList[position].date),
              trailing: GestureDetector(
                child: Icon(
                  Icons.delete,
                  color: Colors.orange[100],
                ),
                onTap: () {
                  _showSnackBar(context, 'Deleting.. ', position);
                  timing(context, noteList[position], position);
                },
              ),
              onLongPress: () {
                setState(() {
                  navigateToDetail(
                    this.noteList[position],
                  ); //navigated to details page
                });
              },
              onTap: () {
                setState(() {
                  noteDisplay = noteList[position].description.toString();
                });
              },
            ),
          ),
        );
      },
    );
  }

  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.yellow;
        break;
      case 2:
        return Color(0xFFeff4ff);
        break;

      default:
        return Color(0xFFeff4ff);
    }
  }

  void _delete(BuildContext context, NoteData note, int position) async {
    int result = await databaseHelper.deleteNote(note.primaryKey);
    if (result != 0) {
      updateNoteListView();
    }
  }

  void _showSnackBar(BuildContext context, String message, int position) {
    final snackBar = SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () {
            isCancelled = false;

            print(noteList.length);
            print(position);
          },
        ));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(
    NoteData note,
  ) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note);
    }));

    if (result == true) {
      updateNoteListView();
    }
  }

  void updateNoteListView() {
    final Future<Database> dbFuture = databaseHelper.setPath();
    dbFuture.then((database) {
      Future<List<NoteData>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }

  void timing(BuildContext context, NoteData note, int position) {
    Timer t = Timer(Duration(seconds: 5), () {
      print('WON');
      if (isCancelled) {
        _delete(context, noteList[position], position);
      } else {
        isCancelled = true;
      }
    });
  }
}
