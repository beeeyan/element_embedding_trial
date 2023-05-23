import 'dart:async';

import 'package:flutter/material.dart';
import 'package:js/js.dart' as js;
import 'package:js/js_util.dart' as js_util;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

@js.JSExport()
class _MyAppState extends State<MyApp> {
  // 調査
  final _streamController = StreamController<void>.broadcast();
  int _counterScreenCount = 0;

  @override
  void initState() {
    super.initState();
    final export = js_util.createDartExport(this);
    js_util.setProperty(js_util.globalThis, '_appState', export);
    js_util.callMethod<void>(js_util.globalThis, '_stateSet', []);
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @js.JSExport()
  void increment() {
    setState(() {
      _counterScreenCount++;
      _streamController.add(null);
    });
  }

  @js.JSExport()
  void addHandler(void Function() handler) {
    _streamController.stream.listen((event) {
      handler();
    });
  }

  @js.JSExport()
  int get count => _counterScreenCount;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Element embedding',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: CounterDemo(
        title: 'Flutter Demo Home Page',
        numToDisplay: _counterScreenCount,
        incrementHandler: increment,
      ),
    );
  }
}

class CounterDemo extends StatefulWidget {
  const CounterDemo({
    super.key,
    required this.title,
    required this.numToDisplay,
    required this.incrementHandler,
  });

  final String title;
  final int numToDisplay;
  final VoidCallback incrementHandler;

  @override
  State<CounterDemo> createState() => _CounterDemo();
}

class _CounterDemo extends State<CounterDemo> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '${widget.numToDisplay}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.incrementHandler,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
