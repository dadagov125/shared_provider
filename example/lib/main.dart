import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_provider/shared_provider.dart';

const sharedInstanceKey = 'shared_value';

void main() {
  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MyHomePage(),
    ),
    GoRoute(
      path: '/a',
      builder: (context, state) => const ScreenA(),
    ),
    GoRoute(
      path: '/b',
      builder: (context, state) => const ScreenB(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Home'),
      ),
      body: const Placeholder(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/a'),
        tooltip: 'to Screeb A',
        child: const Text('to A'),
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
        title: const Text('ScreenA'),
      ),
      body: Center(
        child: SharedProvider(
          create: (_) => 'This text was created on screen [A]',
          dispose: (context, value) {
            print('dispose on screen A:\nshared value => $value');
          },
          instanceKey: sharedInstanceKey,
          child: Consumer<String>(builder: (context, value, child) {
            return Text(value);
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/b'),
        tooltip: 'to Screen B',
        child: const Text('to B'),
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
        title: const Text('ScreenB'),
      ),
      body: Center(
        child: SharedProvider(
          create: (_) => 'This text was created on screen [B]',
          dispose: (context, value) {
            print('dispose on screen B:\nshared value => $value');
          },
          instanceKey: sharedInstanceKey,
          child: Consumer<String>(builder: (context, value, child) {
            return Text(value);
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/'),
        tooltip: 'to Screen A',
        child: const Text('to Home'),
      ),
    );
  }
}
