// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('App loads with buttons', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    //await tester.tap(find.byIcon(Icons.add));

    expect(find.byType(ElevatedButton), findsNWidgets(3));
  });

  testWidgets('New Game loads NewGame screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(Key('New Game')));
    await tester.pumpAndSettle();

    expect(find.byType(NewGame), findsOneWidget);
  });

  testWidgets('About Project loads NewGame screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(Key('About the Project')));
    await tester.pumpAndSettle();

    expect(find.byType(AboutPage), findsOneWidget);
  });

    testWidgets('How To Play loads HowToScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(Key('How To Play')));
    await tester.pumpAndSettle();

    expect(find.byType(HowToScreen), findsOneWidget);
  });

  testWidgets('About Project allows return to Main Screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(Key('About the Project')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('Main Menu')));
    await tester.pumpAndSettle();

    expect(find.byType(MainScreen), findsOneWidget);
  });
}
