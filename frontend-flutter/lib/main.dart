import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/bootstrap.dart';

void main() async {
  final container = await bootstrap();
  runApp(SkoposApp(container: container));
}
