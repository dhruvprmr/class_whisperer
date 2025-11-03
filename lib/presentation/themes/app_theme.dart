import 'package:flutter/material.dart';
ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);
