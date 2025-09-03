import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

enum ColorTag { theme, red, yellow, green, blue, pink }

class DataBlock extends StatefulWidget {
  DataBlock({required this.x, required this.y, required this.i, this.isDarkTheme=false});

  double x;
  double y;
  int i;
  bool isDarkTheme;

  // values
  String id = "";
  int ty = 0;
  String speaker = "";
  String text = "";
  String next = "";

  List<IfSelector> ifs = [];
  List<OptionSelector> options = [];

  // appearance
  ColorTag colorTag = ColorTag.theme;

  @override
  State<DataBlock> createState() => _DataBlockState();
}

class _DataBlockState extends State<DataBlock> {
  _DataBlockState();

  TextEditingController _tyTextCtrl = TextEditingController();
  TextEditingController _speakerTextCtrl = TextEditingController();
  TextEditingController _textTextCtrl = TextEditingController();
  TextEditingController _nextTextCtrl = TextEditingController();
  // TextEditingController _optionsTextCtrl = TextEditingController();

  String dropdownValue = "";
  late Color clr;
  late TextStyle stl;

  @override
  void initState() {
    super.initState();
    _tyTextCtrl.value = TextEditingValue(text: widget.ty.toString());

    _speakerTextCtrl.value = TextEditingValue(text: widget.speaker);
    _speakerTextCtrl.addListener(() => _handleTextSelection(_speakerTextCtrl));

    _textTextCtrl.value = TextEditingValue(text: widget.text);
    _textTextCtrl.addListener(() => _handleTextSelection(_textTextCtrl));

    _nextTextCtrl.value = TextEditingValue(text: widget.next);
    _nextTextCtrl.addListener(() => _handleTextSelection(_nextTextCtrl));
  }

  @override
  void dispose() {
    super.dispose();
    _speakerTextCtrl.removeListener(() => _handleTextSelection(_speakerTextCtrl));
    _speakerTextCtrl.dispose();
    
    _textTextCtrl.removeListener(() => _handleTextSelection(_textTextCtrl));
    _textTextCtrl.dispose();
    
    _nextTextCtrl.removeListener(() => _handleTextSelection(_nextTextCtrl));
    _nextTextCtrl.dispose();
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

  List<Widget> constructIfsInnerWidgets(BuildContext context) {
    List<Widget> ifsInnerWidgets = [];
    for(int i=0; i<widget.ifs.length; i++) {
      if (widget.ty != 1) { break; }

      TextEditingController conditionCtrl = TextEditingController(text: widget.ifs[i].condition)..text = widget.ifs[i].condition
        ..selection =  TextSelection.collapsed(offset: widget.ifs[i].condition.length);
      TextEditingController idNextCtrl = TextEditingController(text: widget.ifs[i].idNext)..text = widget.ifs[i].idNext
        ..selection = TextSelection.collapsed(offset: widget.ifs[i].idNext.length);

      Widget inner = buildInnerFields(
        ["condition", "next"],
        [conditionCtrl, idNextCtrl],
        [
          (String? _) => setState(() { widget.ifs[i].condition = conditionCtrl.value.text; }),
          (String? _) => setState(() { widget.ifs[i].idNext = idNextCtrl.value.text; }),
        ],
        MediaQuery.of(context).textScaleFactor
      );
      ifsInnerWidgets.add(inner);
    }
    return ifsInnerWidgets;
  }

  List<Widget> consctructOptionsInnerWidgets(BuildContext context) {
    List<Widget> optionsInnerWidgets = [];
    for(int i=0; i<widget.options.length; i++) {
      if (widget.ty != 2) { break; }

      TextEditingController textCtrl = TextEditingController(text: widget.options[i].text)..text = widget.options[i].text
        ..selection = TextSelection.collapsed(offset: widget.options[i].text.length);
      TextEditingController actionCtrl = TextEditingController(text: widget.options[i].action)..text = widget.options[i].action
        ..selection = TextSelection.collapsed(offset: widget.options[i].action.length);
      TextEditingController idNextCtrl = TextEditingController(text: widget.options[i].idNext)..text = widget.options[i].idNext
        ..selection = TextSelection.collapsed(offset: widget.options[i].idNext.length);

      Widget inner = buildInnerFields(
        ["text", "action", "next"],
        [textCtrl, actionCtrl, idNextCtrl],
        [
          (String? _) => setState(() { widget.options[i].text = textCtrl.value.text; }),
          (String? _) => setState(() { widget.options[i].action = actionCtrl.value.text; }),
          (String? _) => setState(() { widget.options[i].idNext = idNextCtrl.value.text; }),
        ],
        MediaQuery.of(context).textScaleFactor
      );
      optionsInnerWidgets.add(inner);
    }
    return optionsInnerWidgets;
  }

  Color getColor(BuildContext context) {
    switch (widget.colorTag) {
      case ColorTag.theme:
        return Theme.of(context).colorScheme.inversePrimary;
        break;
      case ColorTag.red:
        return Color(0xffE4717A);
        break;
      case ColorTag.yellow:
        return Color(0xffEFA94A);
        break;
      case ColorTag.green:
        return Color(0xffBEBD7F);
        break;
      case ColorTag.blue:
        return Color(0xff9ACEEB);
        break;
      case ColorTag.pink:
        return Color(0xffD8BFD8);
        break;
      default:
        return Theme.of(context).colorScheme.inversePrimary;
        break;
    }
  }

  void reselectColor(BuildContext context) {
    switch (widget.colorTag) {
      case ColorTag.theme:
        setState(() {
          widget.colorTag = ColorTag.red;
        });
        break;
      case ColorTag.red:
        setState(() {
          widget.colorTag = ColorTag.yellow;
        });
        break;
      case ColorTag.yellow:
        setState(() {
          widget.colorTag = ColorTag.green;
        });
        break;
      case ColorTag.green:
        setState(() {
          widget.colorTag = ColorTag.blue;
        });
        break;
      case ColorTag.blue:
        setState(() {
          widget.colorTag = ColorTag.pink;
        });
        break;
      case ColorTag.pink:
        setState(() {
          widget.colorTag = ColorTag.theme;
        });
        break;
      default:
        setState(() {
          widget.colorTag = ColorTag.green;
        });
        break;
    }
  }

  String selectTyDescription(String tyId) {
    switch(tyId) {
      case "-1":
        return "final replics";
        break;
      case "0":
        return "base replics";
        break;
      case "1":
        return "if-then replics";
        break;
      case "2":
        return "select option";
        break;
      default:
        return "base replics";
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.id == "") {
      setState(() {
        widget.id = generateId().substring(5);
      });
    }

    clr = getColor(context);
    stl = TextStyle(fontSize: 5, color: Colors.white);

    List<Widget> ifsInnerWidgets = constructIfsInnerWidgets(context);
    List<Widget> optionsInnerWidgets = consctructOptionsInnerWidgets(context);

    void Function(String?) defaultOnEdit = (String? _) {
      setState(() {
        updateFields();
      });
    };

    return Positioned(
      left: widget.x,
      top: widget.y,
      child: GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          updateCoords(widget.x + details.delta.dx, widget.y + details.delta.dy);
        },
        child: Opacity(
          opacity: widget.isDarkTheme? 0.9 : 0.7,
          child: Container(
            width: 130,
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              // color: Theme.of(context).colorScheme.primaryContainer,
              color: clr,
            ),
            child: Column(
              children: [
                buildStaticRow("id", widget.id, () { Clipboard.setData(ClipboardData(text: widget.id)).then((_){}); }),
                buildDropTyRow("ty", _tyTextCtrl, ["-1", "0", "1", "2"], selectTyDescription),
                buildPropertyRow("speaker", _speakerTextCtrl, MediaQuery.of(context).textScaleFactor, defaultOnEdit),
                buildPropertyRow("text", _textTextCtrl, MediaQuery.of(context).textScaleFactor, defaultOnEdit),

                (widget.ty == 1)? buildResizableRow(
                  "if", () => setState(() { widget.ifs.add(IfSelector(condition: "", idNext: "")); }),
                ) : Container(),
                ...ifsInnerWidgets,

                (widget.ty == 2)? buildResizableRow(
                  "options", () => setState(() { widget.options.add(OptionSelector(text: "", action: "", idNext: "")); }),
                ) : Container(),
                ...optionsInnerWidgets,

                buildPropertyRow("next", _nextTextCtrl, MediaQuery.of(context).textScaleFactor, defaultOnEdit),
                SizedBox(height: 4),
                GestureDetector(
                  onTap: () => reselectColor(context),
                  child: Icon(
                    Icons.blur_circular,
                    color: Colors.white,
                    size: 7,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateFields() {
    try {
      widget.ty = int.parse(_tyTextCtrl.value.text);
    } catch(_e) {
      widget.ty = 0;
    }
    widget.speaker = _speakerTextCtrl.value.text;
    widget.text = _textTextCtrl.value.text;
    widget.next = _nextTextCtrl.value.text;
  }

  Widget buildPropertyRow(String fieldName, TextEditingController textCtrl, double factor, void Function(String?) onEdit) {
    return SizedBox(
      width: 130 - 14,
      // height: 7 * factor,
      child: Row(children: [
        Align(alignment: Alignment.centerLeft, child: Text(fieldName, style: stl, textAlign: TextAlign.left),),
        Align(alignment: Alignment.centerLeft, child: SizedBox(
            width: 4,
            height: 7 * factor,
            child: TextField(
              controller: textCtrl,
              onChanged: onEdit,
              onTap: () => setState((){}),
              maxLines: 1,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  gapPadding: 1.0,
                ),
              ),
              textAlignVertical: const TextAlignVertical(y: 0.6),
              style: stl,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 70,
            child: RichText(
              text: TextSpan(
                children: textSpansWithCursor(textCtrl.value.text, textCtrl.selection.baseOffset),
                style: stl,
              ),
            ),
          ),
        ),
        Spacer(),
        GestureDetector(
          onTap: () => Clipboard.setData(ClipboardData(text: textCtrl.value.text)).then((_){}),
          child: const Icon(
            Icons.content_copy,
            size: 7,
            color: Colors.white,
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
          color: Colors.white,
        ),
      ),
    ]);
  }

  Widget buildDropTyRow(String fieldName, TextEditingController textCtrl, List<String> items, String Function(String) converter) {
    return SizedBox(
      width: 130 - 14,
      height: 7,
      child: Row(children: [
        Align(alignment: Alignment.centerLeft, child: Text(fieldName, style: stl, textAlign: TextAlign.left),),
        SizedBox(width: 8),
        Align(alignment: Alignment.centerLeft, child: Text(textCtrl.value.text ?? "0", style: stl, textAlign: TextAlign.left, overflow: TextOverflow.clip),),
        Spacer(),
        Container(
          width: 20,
          alignment: Alignment.centerRight,
          child: DropdownButton<String>(
            value: textCtrl.value.text,
            icon: Icon(Icons.arrow_downward, color: Colors.white, size: 7),
            style: stl,
            isExpanded: false,
            elevation: 16,
            onChanged: (String? value) {
              setState(() {
                textCtrl.value = TextEditingValue(text: value!);
                updateFields();
              });
            },
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(converter(value), style: TextStyle(fontSize: 10, color: Colors.black)),
              );
            }).toList(),
            selectedItemBuilder: (context) => [],
          ),
        ),
      ]),
    );
  }

  Widget buildResizableRow(String fieldName, VoidCallback resizeCb) {
    return SizedBox(
      width: 130 - 14,
      height: 7,
      child: Row(children: [
        Align(alignment: Alignment.centerLeft, child: Text(fieldName, style: stl, textAlign: TextAlign.left),),
        Spacer(),
        GestureDetector(
          onTap: resizeCb,
          child: Icon(Icons.add, size: 7, color: Colors.white),
        ),
      ]),
    );
  }

  Widget buildInnerFields(List<String> fieldNames, List<TextEditingController> controllers, List<void Function(String?)> onEdits, double factor) {
    List<Widget> rows = [];
    rows.add(SizedBox(width: 125 - 14, height: 2, child: Divider(color: Colors.black, height: 2)));
    for(int i=0; i<controllers.length; i++) {
      rows.add(buildPropertyRow(fieldNames[i], controllers[i], factor, onEdits[i]));
    }

    return SizedBox(
      width: 125 - 14,
      // height: 7.0 * (fieldNames.length + 1),
      child: Column(
        children: rows,
      ),
    );
  }

  List<TextSpan> textSpansWithCursor(String text, int cursorOffset) {
    if (text == "" || cursorOffset < 0 || cursorOffset > text.length) {
      return [TextSpan(text: text)];
    } else if (text.length == 1) {
      return (cursorOffset == 0)?
        [cursorTextSpan, TextSpan(text: text)] :
        [TextSpan(text: text), cursorTextSpan];
    }

    return [
      TextSpan(text: text.substring(0, cursorOffset)),
      cursorTextSpan,
      TextSpan(text: text.substring(cursorOffset)),
    ];
  }

  TextSpan get cursorTextSpan => const TextSpan(text: '|', style: TextStyle(color: Colors.black));

  void _handleTextSelection(TextEditingController controller) {
    final selection = controller.selection;
    if (selection.isValid && selection.baseOffset != 0) {
      setState((){});
    }
  }
}


class IfSelector {
  IfSelector({required this.condition, required this.idNext});

  String condition;
  String idNext;
}

class OptionSelector {
  OptionSelector({required this.text, required this.action, required this.idNext});

  String text;
  String action;
  String idNext;
}
