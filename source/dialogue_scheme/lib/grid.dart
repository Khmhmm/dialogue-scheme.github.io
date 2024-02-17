import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:dialogue_scheme/block.dart';


class GridWidget extends StatefulWidget {
  GridWidget({required this.blocks, required this.updBlocksCb});

  List<DataBlock> blocks;
  Offset mousePos = Offset(0.0, 0.0);
  Offset getMousePos() { return mousePos; }

  Offset currentOffsetFromTopLeftConner = Offset(0.0, 0.0);
  Offset getCurrentTopLeftOffset() { return currentOffsetFromTopLeftConner; }

  // only for adding blocks, causes bugs when used in grid things
  double zoom = 1.0;

  void Function(List<DataBlock>) updBlocksCb;

  void addBlock() {
    print(currentOffsetFromTopLeftConner);
    this.blocks.add(
      DataBlock(
        x: math.min(currentOffsetFromTopLeftConner.dx / 1.5, 1800) + 5,
        y: math.min(currentOffsetFromTopLeftConner.dy / (zoom * 2), 1000) + 5,
        i: this.blocks.length
      )
    );
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

  Widget drawLine(Offset p1, Offset p2, Size screenSize) {
    return Center(
      child: CustomPaint(
        size: Size(screenSize.height * 5, screenSize.width * 5),
        painter: LinePainter(p1: p1, p2: p2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    List<Widget> lines = [];
    if (widget.blocks.length >= 2) {
      for(int i=0; i<widget.blocks.length; i++) {
        if (widget.blocks[i].next == "") {
          continue;
        }
        var matchingNextBlock = widget.blocks.where((b) => b.id == widget.blocks[i].next).toList();
        if (widget.blocks[i].ty == 1) {
          print("Search for ${widget.blocks[i].ifs.length}");
          for(final selector in widget.blocks[i].ifs) {
            print("Search for ${selector.idNext}");
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
              Offset(widget.blocks[i].x + 130, widget.blocks[i].y + 12),
              Offset(mblock.x, mblock.y + 12),
              screenSize,
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
                    painter: GridPainter(),
                  ),
                ),
                ...lines,
                ...widget.blocks,
              ],
            ),
          ),
        ),
        Row(children: [
          Align(alignment: Alignment.bottomLeft, child: Text("  x${zoom.toInt()} (${widget.mousePos.dx.toInt()}; ${widget.mousePos.dy.toInt()})")),
          Spacer(),
          FloatingActionButton(
            onPressed: widget.addBlock,
            tooltip: 'Add',
            child: const Icon(Icons.add),
          ),
          SizedBox(width: 16),
        ]),
      ]),
    );
  }
}



class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double eWidth = size.width / 60;
    double eHeight = size.height / 90;

    //Grid background
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill //filling
      ..color = Color(0xfff6f6f6); //Background of yellow paper
    canvas.drawRect(Offset.zero & size, paint);

    //Grid style
    paint
      ..style = PaintingStyle.stroke //line
      ..color = Color(0xffe1e9f0)
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
  LinePainter({required this.p1, required this.p2});

  Offset p1;
  Offset p2;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0x55000000)
      ..strokeWidth = 2;
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
