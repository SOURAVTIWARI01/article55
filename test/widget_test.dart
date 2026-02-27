import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:article_55/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const Article55App());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
