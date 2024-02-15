import 'package:flutter/material.dart';
import 'package:dialogue_scheme/block.dart';


class GridWidget extends StatefulWidget {
  GridWidget({required this.blocks, required this.updBlocksCb});

  List<DataBlock> blocks;
  Offset mousePos = Offset(0.0, 0.0);
  Offset getMousePos() { return mousePos; }

  Offset currentOffsetFromTopLeftConner = Offset(0.0, 0.0);
  Offset getCurrentTopLeftOffset() { return currentOffsetFromTopLeftConner; }

  void Function(List<DataBlock>) updBlocksCb;

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
      final ids = getAllIds();
      widget.blocks = widget.blocks.map((b) {
        b.setIds(ids);
        return b;
      }).toList();
      widget.updBlocksCb(widget.blocks);
    });
  }

  List<String> getAllIds() {
    return widget.blocks.map((b) => b.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return MouseRegion(
      onHover: _updateLocation,
      child: Column(children: [
        Expanded(
          child: InteractiveViewer(
            trackpadScrollCausesScale: true,
            minScale: 1.0,
            maxScale: 15.0,
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
                final ids = widget.blocks.map((b) => b.id).toList();
                widget.blocks = widget.blocks.map((b) {
                  b.setZoom(zoom);
                  b.setIds(ids);
                  return b;
                }).toList();
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
                ...widget.blocks,
              ],
            ),
          ),
        ),
        Align(alignment: Alignment.bottomLeft, child: Text("(${widget.mousePos.dx.toInt()}; ${widget.mousePos.dy.toInt()})")),
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
