import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class DataBlock extends StatefulWidget {
  DataBlock({required this.x, required this.y, required this.i, this.allIds=const [], this.zoom=1.0});

  double x;
  double y;
  int i;
  double zoom;
  List<String> allIds;

  // values
  String id = "";
  int ty = 0;
  String speaker = "";
  String text = "";
  String next = "";

  void setZoom(double zoom) { this.zoom = zoom; }
  void setIds(List<String> allIds) { this.allIds = allIds; if (!this.allIds.contains("")) { this.allIds.insert(0, ""); } }

  @override
  State<DataBlock> createState() => _DataBlockState();
}

class _DataBlockState extends State<DataBlock> {
  _DataBlockState();

  TextEditingController _tyTextCtrl = TextEditingController();
  TextEditingController _speakerTextCtrl = TextEditingController();
  TextEditingController _textTextCtrl = TextEditingController();
  TextEditingController _nextTextCtrl = TextEditingController();

  String dropdownValue = "";
  late Color clr;
  late TextStyle stl;

  @override
  void initState() {
    super.initState();
    _tyTextCtrl.value = TextEditingValue(text: widget.ty.toString());
    _speakerTextCtrl.value = TextEditingValue(text: widget.speaker);
    _textTextCtrl.value = TextEditingValue(text: widget.text);
    _nextTextCtrl.value = TextEditingValue(text: widget.next);
  }


  void updateCoords(double x, double y) {
    setState(() {
      widget.x = x;
      widget.y = y;
    });
  }

  String generateId() {
    return md5.convert(utf8.encode(DateTime.now().toIso8601String())).toString();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.id == "") {
      setState(() {
        widget.id = generateId().substring(5);
      });
    }

    clr = Theme.of(context).colorScheme.onPrimaryContainer;
    stl = TextStyle(fontSize: 5, color: clr);

    return Positioned(
      left: widget.x,
      top: widget.y,
      child: GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          updateCoords(widget.x + details.delta.dx, widget.y + details.delta.dy);
        },
        child: Opacity(
          opacity: 0.7,
          child: Container(
            width: 125,
            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 9),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              children: [
                buildStaticRow("id", widget.id, () { Clipboard.setData(ClipboardData(text: widget.id)).then((_){}); }),
                buildPropertyRow("ty", _tyTextCtrl, MediaQuery.of(context).textScaleFactor),
                buildPropertyRow("speaker", _speakerTextCtrl, MediaQuery.of(context).textScaleFactor),
                buildPropertyRow("text", _textTextCtrl, MediaQuery.of(context).textScaleFactor),
                buildPropertyRow("next", _nextTextCtrl, MediaQuery.of(context).textScaleFactor),
                // buildDropIdRow("next", widget.allIds),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateFields(String? _) {
    setState(() {
      widget.ty = int.parse(_tyTextCtrl.value.text);
      widget.speaker = _speakerTextCtrl.value.text;
      widget.text = _textTextCtrl.value.text;
      widget.next = _nextTextCtrl.value.text;
    });
  }

  Widget buildPropertyRow(String fieldName, TextEditingController textCtrl, double factor) {
    return SizedBox(
      width: 125 - 14,
      height: 7 * factor,
      child: Row(children: [
        Align(alignment: Alignment.centerLeft, child: Text(fieldName, style: stl, textAlign: TextAlign.left),),
        Spacer(),
        Align(alignment: Alignment.centerLeft, child: SizedBox(
            width: 125 - 10 - fieldName.length * 5 * factor,
            height: 7 * factor,
            child: TextField(
              controller: textCtrl,
              onChanged: updateFields,
              maxLines: 1,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  gapPadding: 1.0,
                ),
              ),
              textAlignVertical: TextAlignVertical(y: 0.6),
              style: stl,
            ),
          ),
        ),
      ]),
    );
  }

  Widget buildStaticRow(String fieldName, String value, VoidCallback cb) {
    return Row(children: [
      Align(alignment: Alignment.centerLeft, child: Text(fieldName, style: stl, textAlign: TextAlign.left),),
      Spacer(),
      Align(alignment: Alignment.centerLeft, child: Text(value, style: stl, textAlign: TextAlign.left, overflow: TextOverflow.clip),),
      SizedBox(width: 4),
      GestureDetector(
        onTap: cb,
        child: Icon(
          Icons.content_copy,
          size: 7,
        ),
      ),
    ]);
  }

  Widget buildDropIdRow(String fieldName, List<String> items) {
    return SizedBox(
      width: 125 - 20,
      height: 7,
      child: Row(children: [
        Align(alignment: Alignment.centerLeft, child: Text(fieldName, style: stl, textAlign: TextAlign.left),),
        Spacer(),
        DropdownButton<String>(
          value: dropdownValue,
          icon: Icon(Icons.arrow_downward, color: clr, size: 5),
          style: stl,
          elevation: 9,
          onChanged: (String? value) {
            setState(() {
              dropdownValue = value!;
              widget.next = value!;
            });
          },
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ]),
    );
  }
}
