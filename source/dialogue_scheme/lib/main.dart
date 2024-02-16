import 'package:flutter/material.dart';
import 'package:dialogue_scheme/grid.dart';
import 'package:dialogue_scheme/jsonifier.dart';
import 'package:dialogue_scheme/about.dart';
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


enum Page {grid, json, about}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});
  final String title;

  List<DataBlock> blocks = [];
  Page page = Page.grid;

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
      // centerTitle: true,
      actions: [
        Row(children: [
          GestureDetector(
            onTap: () {
              setState(() {
                widget.page = Page.grid;
              });
            },
            child: Icon(
              (widget.page == Page.grid)? Icons.grid_on : Icons.grid_off,
              color: (widget.page == Page.grid)? Colors.white : Colors.black,
              size: 32,
            ),
          ),
          SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              setState(() {
                widget.page = Page.json;
              });
            },
            child: Icon(
              (widget.page == Page.json)? Icons.document_scanner : Icons.document_scanner_outlined,
              color: (widget.page == Page.json)? Colors.white : Colors.black,
              size: 32,
            ),
          ),
          SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              setState(() {
                widget.page = Page.about;
              });
            },
            child: Icon(
              (widget.page == Page.about)? Icons.info_rounded : Icons.info_outline,
              color: (widget.page == Page.about)? Colors.white : Colors.black,
              size: 32,
            ),
          ),
        ]),
        SizedBox(width: MediaQuery.of(context).size.width * 0.05),
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
      gridWidget.addBlock();
    });
  }

  void updBlocks(List<DataBlock> blocks) {
    setState(() {
      widget.blocks = blocks;
    });
  }

  Widget getBody(GridWidget gridWidget) {
    switch(widget.page) {
      case Page.grid:
        return gridWidget;
        break;
      case Page.json:
        return Jsonifier(widget.blocks);
        break;
      case Page.about:
        return AboutWidget();
        break;
      default:
        return gridWidget;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    gridWidget = GridWidget(blocks: widget.blocks, updBlocksCb: updBlocks);

    return Scaffold(
      appBar: constructAppBar(context),
      // body: widget.showJson? Jsonifier(widget.blocks): gridWidget,
      body: getBody(gridWidget),
    );
  }
}
