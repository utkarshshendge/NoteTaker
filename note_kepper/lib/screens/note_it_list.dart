import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/map_data.dart';

import 'package:flutter_app/models/database_query_file.dart';
import 'package:flutter_app/screens/note_it_detail.dart';
import 'package:sqflite/sqflite.dart';

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
  String noteDisplay = 'Notes';

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<NoteData>();
      updateListView();
    }

    return Scaffold(
      body: Container(
          color: Color(0xFFeff4ff),
          child: Column(
            children: <Widget>[
              Container(
                  height: MediaQuery.of(context).size.height - 500,
                  width: double.infinity,
                  color: Color(0xFFeff4ff),
                  child: SafeArea(
                      child: ListView(
                    padding: EdgeInsets.only(top: 80, left: 5, right: 5),
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      Center(
                          child:
                              (noteDisplay == 'null' || noteDisplay == 'Notes')
                                  ? Text("Notes",
                                      style: TextStyle(
                                          fontSize: 70, color: Colors.black))
                                  : Text(noteDisplay,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 30,
                                          color: Colors.black,
                                          fontFamily: 'CM Sans Serif')))
                    ],
                  ))),
              Expanded(
                child: getNoteListView(), //get the list view of our notes
              )
            ],
          )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          navigateToDetail(
            NoteData('None', 'None', 2),
          ); //navigates to details page
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
              color: Colors.white,
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
                  color: Color(0xFFeff4ff),
                ),
                onTap: () {
                  _delete(context, noteList[position], position);
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
      _showSnackBar(context, 'Note Deleted', note, position);
      updateListView();
    }
  }

  void _showSnackBar(
      BuildContext context, String message, NoteData note, int position) {
    final snackBar = SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () {
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
      updateListView();
    }
  }

  void updateListView() {
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
}
