import 'package:flutter/material.dart';
import 'package:dialogue_scheme/grid.dart';
import 'package:dialogue_scheme/jsonifier.dart';
import 'package:dialogue_scheme/block.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dialogue scheme',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Dialogue scheme'),
    );
  }
}



class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});
  final String title;

  bool showJson = false;
  List<DataBlock> blocks = [];

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late GridWidget gridWidget;
  double zoom = 1.0;

  AppBar constructAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(widget.title),
      actions: [
        Flexible(
          child: Row(children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  widget.showJson = false;
                });
              },
              child: Icon(
                widget.showJson? Icons.grid_off : Icons.grid_on,
                color: widget.showJson? Colors.black : Colors.white,
                size: 32,
              ),
            ),
            SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  widget.showJson = true;
                });
              },
              child: Icon(
                widget.showJson? Icons.document_scanner : Icons.document_scanner_outlined,
                color: widget.showJson? Colors.white : Colors.black,
                size: 32,
              ),
            ),
          ]),
        ),
        Flexible(child: SizedBox()),
      ],
    );
  }

  bool isBlockLinked() {
    // return widget.blocks.where((b) => b.linkedToMouse).toList().length != 0;
    return false;
  }

  void addDataBlock() {
    if (isBlockLinked()) {
      return;
    }
    setState(() {
      Offset off = gridWidget.getCurrentTopLeftOffset();
      widget.blocks.add(DataBlock(x: off.dx + 25, y: off.dy + 25, i: widget.blocks.length));
    });
  }

  void updBlocks(List<DataBlock> blocks) {
    setState(() {
      widget.blocks = blocks;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // print("Page blocks: ${widget.blocks.length}; first is: ${(widget.blocks.length > 0)? widget.blocks[0]?.x : widget.blocks.length}, ${(widget.blocks.length > 0)? widget.blocks[0]?.y : widget.blocks.length}");
    gridWidget = GridWidget(blocks: widget.blocks, updBlocksCb: updBlocks);

    return Scaffold(
      appBar: constructAppBar(context),
      body: widget.showJson? Jsonifier(widget.blocks): gridWidget,
      floatingActionButton: (!widget.showJson)? FloatingActionButton(
        onPressed: addDataBlock,
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ) : null,
    );
  }
}
