import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:dialogue_scheme/block.dart';
import 'package:shared_preferences/shared_preferences.dart';


class GridWidget extends StatefulWidget {
  GridWidget({required this.blocks, required this.updBlocksCb});

  List<DataBlock> blocks;
  Offset mousePos = const Offset(0.0, 0.0);
  Offset getMousePos() { return mousePos; }

  Offset currentOffsetFromTopLeftConner = const Offset(0.0, 0.0);
  Offset getCurrentTopLeftOffset() { return currentOffsetFromTopLeftConner; }

  // only for adding blocks, causes bugs when used in grid things
  double zoom = 1.0;

  void Function(List<DataBlock>) updBlocksCb;

  void addBlock([bool isDarkTheme=false]) {
    print(currentOffsetFromTopLeftConner);
    this.blocks.add(
      DataBlock(
        x: math.min(currentOffsetFromTopLeftConner.dx / 1.5, 1800) + 5,
        y: math.min(currentOffsetFromTopLeftConner.dy / (zoom * 2), 1000) + 5,
        i: DateTime.now().difference(DateTime.fromMicrosecondsSinceEpoch(0)).inMilliseconds,
        deleteCallback: this.removeBlock,
        isDarkTheme: isDarkTheme,
      )
    );
  }

  void removeBlock(int innerId) {
    List<DataBlock> matchingBlock = this.blocks.where((block) => block.i == innerId).toList();
    if (matchingBlock.length > 0) {
      this.blocks.remove(matchingBlock[0]);
    }
  }

  void setBlocks(List<DataBlock> blocks) { this.blocks = blocks; }

  @override
  State<GridWidget> createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> {
  double zoom = 1.0;
  TransformationController transformationController = TransformationController();

  void _updateLocation(PointerEvent details) {
    setState(() {
      widget.mousePos = (widget.currentOffsetFromTopLeftConner + details.position) / zoom;
    });
  }

  Widget drawLine(Offset p1, Offset p2, Size screenSize, [bool isDarkTheme=false]) {
    return Center(
      child: CustomPaint(
        size: Size(screenSize.height * 5, screenSize.width * 5),
        painter: LinePainter(p1: p1, p2: p2, isDarkTheme: isDarkTheme),
      ),
    );
  }

  Widget buildInner(BuildContext context, bool isDarkTheme) {
    final Size screenSize = MediaQuery.of(context).size;

    List<Widget> lines = [];
    if (widget.blocks.length >= 2) {
      for(int i=0; i<widget.blocks.length; i++) {
        if (widget.blocks[i].next == "") {
          continue;
        }
        var matchingNextBlock = widget.blocks.where((b) => b.id == widget.blocks[i].next).toList();
        if (widget.blocks[i].ty == 1) {
          // print("Search for ${widget.blocks[i].ifs.length}");
          for(final selector in widget.blocks[i].ifs) {
            // print("Search for ${selector.idNext}");
            if (selector.idNext != "") {
              final additionalBlocks = widget.blocks.where((b) => b.id == selector.idNext).toList();
              matchingNextBlock = [...matchingNextBlock, ...additionalBlocks];
            }
          }
        } else if (widget.blocks[i].ty == 2) {
          for(final selector in widget.blocks[i].options) {
            if (selector.idNext != "") {
              final additionalBlocks = widget.blocks.where((b) => b.id == selector.idNext).toList();
              matchingNextBlock = [...matchingNextBlock, ...additionalBlocks];
            }
          }
        }
        for(final mblock in matchingNextBlock) {
          lines.add(
            drawLine(
              Offset(widget.blocks[i].x + widget.blocks[i].blockWidth, widget.blocks[i].y + 12),
              Offset(mblock.x, mblock.y + 12),
              screenSize,
              isDarkTheme
            )
          );
        }
      }
    }

    return MouseRegion(
      onHover: _updateLocation,
      child: Column(children: [
        Expanded(
          child: InteractiveViewer(
            trackpadScrollCausesScale: true,
            minScale: 1.0,
            maxScale: 2.5,
            transformationController: transformationController,
            onInteractionEnd: (details) {
              setState(() {
                widget.currentOffsetFromTopLeftConner = Offset(
                  double.parse(transformationController.value.row0[3].toStringAsFixed(0)).abs(),
                  double.parse(transformationController.value.row1[3].toStringAsFixed(0)).abs()
                );
              });
            },
            onInteractionUpdate: (details) {
              setState(() {
                zoom = transformationController.value[0];
                widget.updBlocksCb(widget.blocks);
                widget.zoom = zoom;
              });
            },
            child: Stack(
              children: [
                Center(
                  child: CustomPaint(
                    size: Size(screenSize.height * 5, screenSize.width * 5), //Specify the size of the canvas
                    painter: GridPainter(isDarkTheme),
                  ),
                ),
                ...lines,
                ...widget.blocks,
              ],
            ),
          ),
        ),
        Opacity(
          opacity: 0.8,
          child: Container(
            color: isDarkTheme? Colors.black : Colors.white,
            child: Row(children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "  x${zoom.toStringAsPrecision(2)} (${widget.mousePos.dx.toInt()}; ${widget.mousePos.dy.toInt()})",
                  style: TextStyle(color: isDarkTheme? Colors.white : Colors.black),)
              ),
              const Spacer(),
              FloatingActionButton(
                onPressed: () => widget.addBlock(isDarkTheme),
                tooltip: 'Add',
                backgroundColor: isDarkTheme? Theme.of(context).colorScheme.inversePrimary : Theme.of(context).colorScheme.primary,
                child: Icon(
                  Icons.add,
                  color: isDarkTheme? Colors.white : Colors.black,
                ),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.475),
            ]),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = SharedPreferences.getInstance();

    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // TODO: move to prefs_utils.dart
          return buildInner(context, snapshot.data!.getBool("darkTheme") ?? false);
        } else {
          return Container(color: Color.fromARGB(255, 58, 58, 58));
        }
      },
    );
  }
}



class GridPainter extends CustomPainter {
  GridPainter(bool? darkTheme) {
    isDarkTheme = darkTheme ?? false;
  }

  bool isDarkTheme = false;
  @override
  void paint(Canvas canvas, Size size) {
    double eWidth = size.width / 60;
    double eHeight = size.height / 90;

    //Grid background
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill //filling
      ..color = isDarkTheme? const Color.fromARGB(255, 58, 58, 58) : const Color.fromARGB(255, 255, 255, 255); //Background of yellow paper
    canvas.drawRect(Offset.zero & size, paint);

    //Grid style
    paint
      ..style = PaintingStyle.stroke //line
      ..color = isDarkTheme? const Color.fromARGB(255, 44, 44, 44) : const Color(0xffe1e9f0)
      ..strokeWidth = 1.1;

    for (int i = 0; i <= 150; ++i) {
      double dy = eHeight * i;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }

    for (int i = 0; i <= 150; ++i) {
      double dx = eWidth * i;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
    }



  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class LinePainter extends CustomPainter {
  LinePainter({required this.p1, required this.p2, this.isDarkTheme=false});

  Offset p1;
  Offset p2;
  bool isDarkTheme;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDarkTheme? const Color.fromARGB(143, 179, 178, 178) : const Color(0x55000000)
      ..strokeWidth = 2;
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
