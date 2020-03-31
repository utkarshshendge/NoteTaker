//Here we map the data ,as sqflite supports mapped data
class NoteData {
  int _primaryKey;

  int _priority;
  String _title;
  String _description;
  String _date;

  NoteData(this._title, this._date, this._priority, [this._description]);

  NoteData.withId(this._primaryKey, this._title, this._date, this._priority,
      [this._description]);

  int get primaryKey => _primaryKey;
  int get priority => _priority;
  String get title => _title;
  String get description => _description;
  String get date => _date;

  set title(String newTitle) {
    if (newTitle.length <= 300) {
      this._title = newTitle;
    }
  }

  set priority(int newPriority) {
    if (newPriority >= 1 && newPriority <= 2) {
      this._priority = newPriority;
    }
  }

  set description(String newDescription) {
    if (newDescription.length <= 1000) {
      this._description = newDescription;
    }
  }

  set date(String newDate) {
    this._date = newDate;
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> dataToMap() {
    var map = Map<String, dynamic>();
    if (primaryKey != null) {
      map['primaryKey'] = _primaryKey;
    }
    map['title'] = _title;
    map['description'] = _description;
    map['priority'] = _priority;
    map['date'] = _date;

    return map;
  }

  // Extract a Note object from a Map object
  NoteData.mapToData(Map<String, dynamic> map) {
    this._primaryKey = map['primaryKey'];
    this._title = map['title'];
    this._description = map['description'];
    this._priority = map['priority'];
    this._date = map['date'];
  }
}
