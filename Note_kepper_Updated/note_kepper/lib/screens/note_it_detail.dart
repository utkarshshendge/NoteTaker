import 'package:flutter/material.dart';
import 'package:flutter_app/models/map_data.dart';
import 'package:flutter_app/models/database_query_file.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final NoteData note;

  NoteDetail(this.note);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note);
  }
}

class NoteDetailState extends State<NoteDetail> {
  List<bool> isSelected = [
    false,
    false,
  ];
  var _importance = ['High', 'Low'];
  String priorityValue;
  DatabaseHelper helper = DatabaseHelper();

  
  NoteData note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
         // backgroundColor: Color(0xFFeff4ff),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.orange,
              ),
              onPressed: () {
                popScreen();
              }),
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
        //  color: Color(0xFFeff4ff),
          child: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: titleController,
                    style: textStyle,
                    onChanged: (value) {
                      refreshListTitle();
                    },
                    decoration: InputDecoration(
                        hintText: "Title ",
                        hintStyle: TextStyle(fontFamily: 'CM Sans Serif')),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    maxLines: 15,
                    controller: descriptionController,
                    style: textStyle,
                    onChanged: (value) {
                      updateDescription();
                    },
                    decoration: InputDecoration(
                        hintText: "Description",
                        hintStyle: TextStyle(fontFamily: 'CM Sans Serif'),
                        border: InputBorder.none),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.all(15),
                    child: ToggleButtons(
                      renderBorder: false,
                      selectedColor: Colors.white,
                      fillColor: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                      children: <Widget>[
                        Text(
                          'Low Priority',
                          style: TextStyle(fontFamily: 'CM Sans Serif'),
                        ),
                        Text(
                          'High Priority',
                          style: TextStyle(fontFamily: 'CM Sans Serif'),
                        )
                      ],
                      isSelected: isSelected,
                      onPressed: (int index) {
                        setState(() {
                          isSelected[index] = !isSelected[index];
                          if (index == 0) {
                            priorityValue = getPriorityAsString(index);
                            updatePriorityAsInt(priorityValue);
                            isSelected[1] = false;
                          }
                          if (index == 1) {
                            priorityValue = getPriorityAsString(index);
                            updatePriorityAsInt(priorityValue);
                            isSelected[0] = false;
                          }
                        });
                      },
                    )),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: OutlineButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20),
                        ),
                        child: Text(
                          " Save",
                          style: TextStyle(fontFamily: 'CM Sans Serif'),
                        ),
                        onPressed: () {
                          setState(() {
                            print("OPEN NEXT PAGE");
                            _save();
                          });
                        },
                        highlightElevation: 6.0,
                        splashColor: Colors.white,
                        borderSide: BorderSide(
                            color: Colors.white,
                            style: BorderStyle.solid,
                            width: 4.0),
                      )),
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                          child: OutlineButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20),
                        ),
                        child: Text(
                          " Discard",
                          style: TextStyle(fontFamily: 'CM Sans Serif'),
                        ),
                        onPressed: () {
                          setState(() {
                            print("OPEN NEXT PAGE");
                            _delete();
                          });
                        },
                        highlightElevation: 6.0,
                        splashColor: Colors.white,
                        borderSide: BorderSide(
                            color: Colors.white,
                            style: BorderStyle.solid,
                            width: 4.0),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void popScreen() {
    Navigator.pop(context, true);
  }

  // Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 0;
        break;
      case 'Low':
        note.priority = 1;
        break;
    }
  }

  // Convert int priority to String priority and display it to user in DropDown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 0:
        priority = _importance[0]; // 'High'
        break;
      case 1:
        priority = _importance[1]; // 'Low'
        break;
    }
    return priority;
  }

  // Update the title of Note object
  void refreshListTitle() {
    note.title = titleController.text;
  }

  // Update the description of Note object
  void updateDescription() {
    note.description = descriptionController.text;
  }

  // Save data to database
  void _save() async {
    popScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.primaryKey != null) {
      //  Update
      result = await helper.updateNote(note);
    } else {
      //  Insert
      result = await helper.insertNote(note);
    }

    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {
    popScreen();

    // Case 1: If user is trying to delete the NEW NOTE i.e.
    if (note.primaryKey == null) {
      _showAlertDialog('Status', ' Note not deleted');
      return;
    }

    // Case 2: User is trying to delete the old note .
    int result = await helper.deleteNote(note.primaryKey);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted ');
    } else {
      _showAlertDialog('Status', 'Error Deleting Note');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
