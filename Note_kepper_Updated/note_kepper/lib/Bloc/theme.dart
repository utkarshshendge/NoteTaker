import 'package:flutter/material.dart';

class DynamicTheme with ChangeNotifier{
  ThemeData _dynamicTheme;
  DynamicTheme(this._dynamicTheme);
  getTheme()=>_dynamicTheme;
  setTheme(ThemeData theme){
    _dynamicTheme=theme;
    notifyListeners();
  }
}