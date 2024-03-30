# SharedProvider

## Description

`SharedProvider` is an extension of the provider functionality in Flutter that allows managing shared instances, such as state objects or services. It solves the problem of efficient reuse of instances between screens without unnecessary memory load and complicating navigation logic.

## Solution

`SharedProvider` offers the following capabilities:

- **Centralized Repository**: Implements a repository for shared instances so that providers can facilitate access to them.
- **Instance Reuse**: Providers check for the presence of a required instance in the repository and reuse it if available. If the instance is absent, the provider creates a new one and adds it to the repository.
- **Lifecycle Management**: Providers automatically remove instances from the repository when they are no longer in use.

These improvements allow for more efficient resource use and simplify working with shared instances in the application.

## Usage

Here is an example of how to use `SharedProvider` in your Flutter application. In this example, we have two screens, `ScreenA` and `ScreenB`, and we are sharing a string instance between them.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_provider/shared_provider.dart';

void main() {
  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => MyHomePage(title: 'Home'),
    ),
    GoRoute(
      path: '/a',
      builder: (context, state) => ScreenA(),
    ),
    GoRoute(
      path: '/b',
      builder: (context, state) => ScreenB(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _router.delegate,
      routeInformationParser: _router.defaultRouteParser(),
      title: 'Home',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _router.go('/a'),
              child: Text('Go to Screen A'),
            ),
          ],
        ),
      ),
    );
  }
}

class ScreenA extends StatelessWidget {
  const ScreenA({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen A'),
      ),
      body: SharedProvider<String>(
        acquire: (_) => 'This text was created on screen A',
        instanceKey: 'sharedString',
        child: Consumer<String>(
          builder: (context, value, child) {
            return Text(value);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _router.go('/b'),
        tooltip: 'Go to Screen B',
        child: Icon(Icons.navigate_next),
      ),
    );
  }
}

class ScreenB extends StatelessWidget {
  const ScreenB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen B'),
      ),
      body: SharedProvider<String>(
        acquire: (_) => 'This text was created on screen B',
        instanceKey: 'sharedString',
        child: Consumer<String>(
          builder: (context, value, child) {
            return Text(value);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _router.go('/'),
        tooltip: 'Go to Home',
        child: Icon(Icons.home),
      ),
    );
  }
}
```

In this example, `ScreenA` and `ScreenB` both use `SharedProvider` to create a shared string instance. When you navigate from `ScreenA` to `ScreenB`, the string instance created in `ScreenA` is reused in `ScreenB`.