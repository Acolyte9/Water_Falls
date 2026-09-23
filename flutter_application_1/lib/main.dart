import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Falls!',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen()
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTemplate(
      title: 'Main Screen',
      color: Colors.blue,
      buttons: [
        buildNavButton(context, 'New Game', const NewGame()),
        buildNavButton(context, 'How To Play', const HowToScreen()),
        buildNavButton(context, 'About the Project', const AboutPage()),
      ],
    );
  }
}

class NewGame extends StatelessWidget {
  const NewGame({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTemplate(
      title: 'Item Select',
      color: Colors.blue,
      buttons: [
        buildNavButton(context, 'Game Grid', const GameGrid()),
        buildNavButton(context, 'Main Menu', const MainScreen()),
      ],
    );
  }
}

class GameGrid extends StatelessWidget {
  const GameGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTemplate(
      title: 'Game Grid',
      color: Colors.blue,
      buttons: [
        buildNavButton(context, 'Block Select', const NewGame()),
      ],
    );
  }
}

class HowToScreen extends StatelessWidget {
  const HowToScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTemplate(
      title: 'How To Play',
      color: Colors.blue,
      buttons: [
        buildNavButton(context, 'Main Menu', const MainScreen()),
      ],
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTemplate(
      title: 'About the Project',
      color: Colors.blue,
      buttons: [
        buildNavButton(context, 'Main Menu', const MainScreen()),
      ],
    );
  }
}

Widget buildNavButton(BuildContext context, String label, Widget destination) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Text(label),
    ),
  );
}

class ScreenTemplate extends StatelessWidget {
  final String title;
  final Color color;
  final List<Widget> buttons;

  const ScreenTemplate({
    super.key,
    required this.title,
    required this.color,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ...buttons,
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}