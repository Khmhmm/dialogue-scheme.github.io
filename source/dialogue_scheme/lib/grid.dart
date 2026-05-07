import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:dialogue_scheme/block.dart';
import 'package:shared_preferences/shared_preferences.dart';


class GridWidget extends StatefulWidget {
  GridWidget({required this.blocks, required this.updBlocksCb});

  List<DataBlock> blocks;
  void Function(List<DataBlock>) updBlocksCb;

  Offset mousePos = const Offset(0.0, 0.0);
  Offset getMousePos() { return mousePos; }

  Offset currentOffsetFromTopLeftConner = const Offset(0.0, 0.0);
  Offset getCurrentTopLeftOffset() { return currentOffsetFromTopLeftConner; }

  // only for adding blocks, causes bugs when used in grid things
  double zoom = 1.0;

  @override
  State<GridWidget> createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> {
  double zoom = 1.0;
  TransformationController transformationController = TransformationController();

  List<DataBlock> blocks = [];
  String? idOnMouse;

  @override
  void initState() {
    super.initState();
    this.blocks = widget.blocks;

    for(int i=0; i < this.blocks.length; i++) {
      this.blocks[i].setIdOnMouseCallback = setIdOnMouse;
      this.blocks[i].takeIdOnMouseCallback = takeIdOnMouse;
    }
  }

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
    if (this.blocks.length >= 2) {
      for(int i=0; i<this.blocks.length; i++) {
        if (this.blocks[i].next == "") {
          continue;
        }
        var matchingNextBlock = this.blocks.where((b) => b.id == this.blocks[i].next).toList();
        if (this.blocks[i].ty == 1) {
          for(final selector in this.blocks[i].ifs) {
            if (selector.idNext != "") {
              final additionalBlocks = this.blocks.where((b) => b.id == selector.idNext).toList();
              matchingNextBlock = [...matchingNextBlock, ...additionalBlocks];
            }
          }
        } else if (this.blocks[i].ty == 2) {
          for(final selector in this.blocks[i].options) {
            if (selector.idNext != "") {
              final additionalBlocks = this.blocks.where((b) => b.id == selector.idNext).toList();
              matchingNextBlock = [...matchingNextBlock, ...additionalBlocks];
            }
          }
        }
        for(final mblock in matchingNextBlock) {
          lines.add(
            drawLine(
              Offset(this.blocks[i].x + this.blocks[i].blockWidth, this.blocks[i].y + 12),
              Offset(mblock.x, mblock.y + 12),
              screenSize,
              isDarkTheme
            )
          );
        }
      }

      if(this.idOnMouse != null) {
        List<DataBlock> selectedBlock = this.blocks.where((b) => b.id == this.idOnMouse).toList();
        if(selectedBlock.length > 0) {
          lines.add(
            drawLine(
              Offset(selectedBlock[0].x, selectedBlock[0].y + 12),
              Offset(widget.mousePos.dx, widget.mousePos.dy - 55 / zoom),
              screenSize,
              isDarkTheme
            )
          );
        }
      }
    }

    return MouseRegion(
      onHover: _updateLocation,
      child: GestureDetector(onTap: resetIdOnMouse, child: Column(children: [
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
                widget.blocks = this.blocks;
                widget.updBlocksCb(this.blocks);
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
                ...this.blocks,
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
                  "  x${zoom.toStringAsPrecision(2)} (${widget.mousePos.dx.toInt().toString().padLeft(4, '0')}; ${widget.mousePos.dy.toInt().toString().padLeft(4, '0')})",
                  style: TextStyle(color: isDarkTheme? Colors.white : Colors.black),)
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.415),
              FloatingActionButton(
                onPressed: () => this.addBlock(isDarkTheme),
                tooltip: 'Add',
                backgroundColor: isDarkTheme? Theme.of(context).colorScheme.inversePrimary : Theme.of(context).colorScheme.primary,
                child: Icon(
                  Icons.add,
                  color: isDarkTheme? Colors.white : Colors.black,
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: (this.idOnMouse != null)? Row( children: [
                  Icon(Icons.assignment_rounded, size: 18, color: isDarkTheme? Colors.white : Colors.black),
                  SizedBox(width: 2),
                  Text(
                      "${this.idOnMouse ?? ''} ",
                      style: TextStyle(fontSize: 18, color: isDarkTheme? Colors.white : Colors.black),
                  )
                ]) : Container()
              ),
              // SizedBox(width: MediaQuery.of(context).size.width * 0.475),
            ]),
          ),
        ),
      ]),
      ),
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

   void addBlock([bool isDarkTheme=false]) {
    this.blocks.add(
      DataBlock(
        x: math.min(widget.currentOffsetFromTopLeftConner.dx / 1.5, 1800) + 5,
        y: math.min(widget.currentOffsetFromTopLeftConner.dy / (zoom * 2), 1000) + 5,
        i: DateTime.now().difference(DateTime.fromMicrosecondsSinceEpoch(0)).inMilliseconds,
        deleteCallback: this.removeBlock,
        setIdOnMouseCallback: this.setIdOnMouse,
        takeIdOnMouseCallback: this.takeIdOnMouse,
        isDarkTheme: isDarkTheme,
      )
    );
    widget.updBlocksCb(this.blocks);
  }

  void removeBlock(int innerId) {
    List<DataBlock> matchingBlock = this.blocks.where((block) => block.i == innerId).toList();
    if (matchingBlock.length > 0) {
      this.blocks.remove(matchingBlock[0]);
      widget.updBlocksCb(this.blocks);
    }
  }

  void setBlocks(List<DataBlock> blocks) { this.blocks = blocks; }

  void resetIdOnMouse() {
    this.idOnMouse = null;
  }

  void setIdOnMouse(String id) {
    this.idOnMouse = id;
  }

  String? takeIdOnMouse() {
    String? takenId = this.idOnMouse;

    setState(() {
      resetIdOnMouse();
    });

    return takenId;
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
