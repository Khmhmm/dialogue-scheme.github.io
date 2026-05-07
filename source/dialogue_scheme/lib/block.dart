import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

enum ColorTag { def, red, yellow, green, blue, pink }

class DataBlock extends StatefulWidget {
  DataBlock({
    required this.x,
    required this.y,
    required this.i,
    required this.deleteCallback,
    required this.setIdOnMouseCallback,
    required this.takeIdOnMouseCallback,
    this.isDarkTheme=false
  });

  double x;
  double y;
  int i;
  bool isDarkTheme;
  void Function(int) deleteCallback;
  void Function(String) setIdOnMouseCallback;
  String? Function() takeIdOnMouseCallback;

  // values
  String id = "";
  int ty = 0;
  String speaker = "";
  String text = "";
  String next = "";

  final double defaultBlockWidth = 180.0;
  final double wideBlockWidth = 220.0;
  final double veryWideBlockWidth = 270.0;
  final double ultraWideBlockWidth = 330.0;
  final double elementHeight = 10.0;
  final double fontSize = 8.0;

  List<Setter> setters = [];
  List<IfSelector> ifs = [];
  List<OptionSelector> options = [];

  // appearance
  ColorTag colorTag = ColorTag.def;
  double blockWidth = 180.0; // same as defaultBlockWidth

  @override
  State<DataBlock> createState() => _DataBlockState();
}

class _DataBlockState extends State<DataBlock> {
  _DataBlockState();

  final TextEditingController _tyTextCtrl = TextEditingController();
  final TextEditingController _speakerTextCtrl = TextEditingController();
  final TextEditingController _textTextCtrl = TextEditingController();
  final TextEditingController _nextTextCtrl = TextEditingController();
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

  List<Widget> constructSetterInnerWidgets(BuildContext context) {
    List<Widget> setterInnerWidgets = [];
    for(int i=0; i<widget.setters.length; i++) {
      TextEditingController nameCtrl = TextEditingController(text: widget.setters[i].name)..text = widget.setters[i].name
        ..selection =  TextSelection.collapsed(offset: widget.setters[i].name.length);
      TextEditingController valueCtrl = TextEditingController(text: widget.setters[i].value)..text = widget.setters[i].value
        ..selection = TextSelection.collapsed(offset: widget.setters[i].value.length);

      Widget inner = buildInnerFields(
        [" name", " value"],
        [nameCtrl, valueCtrl],
        [
          (String? _) => setState(() { widget.setters[i].name = nameCtrl.value.text; }),
          (String? _) => setState(() { widget.setters[i].value = valueCtrl.value.text; }),
        ],
        MediaQuery.of(context).textScaler.scale(14)
      );
      setterInnerWidgets.add(inner);
    }

    return setterInnerWidgets;
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
        [" condition", " next"],
        [conditionCtrl, idNextCtrl],
        [
          (String? _) => setState(() { widget.ifs[i].condition = conditionCtrl.value.text; }),
          (String? _) => setState(() { widget.ifs[i].idNext = idNextCtrl.value.text; }),
        ],
        MediaQuery.of(context).textScaler.scale(14)
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
        [" text", " action", " next"],
        [textCtrl, actionCtrl, idNextCtrl],
        [
          (String? _) => setState(() { widget.options[i].text = textCtrl.value.text; }),
          (String? _) => setState(() { widget.options[i].action = actionCtrl.value.text; }),
          (String? _) => setState(() { widget.options[i].idNext = idNextCtrl.value.text; }),
        ],
        MediaQuery.of(context).textScaler.scale(1)
      );
      optionsInnerWidgets.add(inner);
    }
    return optionsInnerWidgets;
  }

  Color getColor(BuildContext context) {
    switch (widget.colorTag) {
      case ColorTag.def:
        return const Color.fromARGB(255, 64, 55, 73);
      case ColorTag.red:
        return const Color(0xff992424);
      case ColorTag.yellow:
        return const Color(0xff674300);
      case ColorTag.green:
        return const Color(0xff73723a);
      case ColorTag.blue:
        return const Color(0xff2e607b);
      case ColorTag.pink:
        return const Color(0xff966e96);
    }
  }

  void reselectColor(BuildContext context) {
    switch (widget.colorTag) {
      case ColorTag.def:
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
          widget.colorTag = ColorTag.def;
        });
        break;
    }
  }

  void reselectWidth(BuildContext context) {
    if (widget.blockWidth == widget.defaultBlockWidth) {
      // default -> wide
      setState(() => widget.blockWidth = widget.wideBlockWidth);
    } else if (widget.blockWidth == widget.wideBlockWidth) {
      // wide -> very wide
      setState(() => widget.blockWidth = widget.veryWideBlockWidth);
    } else if (widget.blockWidth == widget.veryWideBlockWidth) {
      // very wide -> ultra wide
      setState(() => widget.blockWidth = widget.ultraWideBlockWidth);
    } else {
      // default | ultra wide -> default
      setState(() => widget.blockWidth = widget.defaultBlockWidth);
    }
  }

  String selectTyDescription(String tyId) {
    switch(tyId) {
      case "-1":
        return "final replics";
      case "0":
        return "base replics";
      case "1":
        return "if-then replics";
      case "2":
        return "select option";
      default:
        return "base replics";
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
    stl = TextStyle(fontSize: widget.fontSize, color: Colors.white);

    List<Widget> setterInnerWidgets = constructSetterInnerWidgets(context);
    List<Widget> ifsInnerWidgets = constructIfsInnerWidgets(context);
    List<Widget> optionsInnerWidgets = consctructOptionsInnerWidgets(context);

    void defaultOnEdit(String? _) {
      setState(() {
        updateFields();
      });
    }

    return Positioned(
      left: widget.x,
      top: widget.y,
      child: GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          updateCoords(widget.x + details.delta.dx, widget.y + details.delta.dy);
        },
        onTap: () {
          String? takenId = widget.takeIdOnMouseCallback();
          if(takenId != null) {
            setState(() {
              _nextTextCtrl.text = takenId;
              updateFields();
            });
          }
        },
        child: Opacity(
          opacity: widget.isDarkTheme? 0.9 : 0.7,
          child: Container(
            width: widget.blockWidth,
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              color: clr,
            ),
            child: Column(
              children: [
                buildToButton(),
                buildStaticRow("id", widget.id, () { Clipboard.setData(ClipboardData(text: widget.id)).then((_){}); }),
                const SizedBox(height: 2.0),
                buildDropTyRow("ty", _tyTextCtrl, ["-1", "0", "1", "2"], selectTyDescription),
                const SizedBox(height: 2.0),
                buildResizableRow(
                  "setters",
                  () => setState(() { widget.setters.add(Setter(name: "", value: "")); }),
                  () => setState(() { if(widget.setters.length > 0) widget.setters.removeAt(widget.setters.length - 1); })
                ),
                ...setterInnerWidgets,
                const SizedBox(height: 2.0),
                buildPropertyRow("speaker", _speakerTextCtrl, MediaQuery.of(context).textScaler.scale(1), defaultOnEdit),
                const SizedBox(height: 2.0),
                buildPropertyRow("text", _textTextCtrl, MediaQuery.of(context).textScaler.scale(1), defaultOnEdit),
                const SizedBox(height: 2.0),

                (widget.ty == 1)? buildResizableRow(
                  "if",
                  () => setState(() { widget.ifs.add(IfSelector(condition: "", idNext: "")); }),
                  () => setState(() { if(widget.ifs.length > 0) widget.ifs.removeAt(widget.ifs.length - 1); }),
                ) : Container(),
                ...ifsInnerWidgets,

                (widget.ty == 2)? buildResizableRow(
                  "options",
                  () => setState(() { widget.options.add(OptionSelector(text: "", action: "", idNext: "")); }),
                  () => setState(() { if(widget.options.length > 0) widget.options.removeAt(widget.options.length - 1); }),
                ) : Container(),
                ...optionsInnerWidgets,

                buildPropertyRow("next", _nextTextCtrl, MediaQuery.of(context).textScaler.scale(1), defaultOnEdit),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => reselectColor(context),
                      child: Icon(
                        Icons.blur_circular,
                        color: Colors.white,
                        size: widget.elementHeight,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => reselectWidth(context),
                      child: Icon(
                        Icons.pinch_outlined,
                        color: Colors.white,
                        size: widget.elementHeight,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => widget.deleteCallback(widget.i),
                      child: Icon(
                        Icons.highlight_remove,
                        color: Colors.white,
                        size: widget.elementHeight,
                      ),
                    ),
                  ],
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
      width: widget.blockWidth - 14,
      // height: 7 * factor,
      child: Row(children: [
        Align(alignment: Alignment.centerLeft, child: Text(fieldName, style: stl, textAlign: TextAlign.left),),
        const SizedBox(height: 4),
        Align(alignment: Alignment.centerLeft, child: SizedBox(
            width: 4,
            height: widget.elementHeight,
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
        const Spacer(),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: widget.blockWidth - fieldName.length * 2.0 - 42 - widget.elementHeight * 2.0,
            child: RichText(
              text: TextSpan(
                children: textSpansWithCursor(textCtrl.value.text, textCtrl.selection.baseOffset),
                style: stl,
              ),
            ),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => Clipboard.setData(ClipboardData(text: textCtrl.value.text)).then((_){}),
          child: Icon(
            Icons.content_copy,
            size: widget.elementHeight,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 2),
        GestureDetector(
          onTap: () => Clipboard.getData("text/plain").then(
            (data) => setState(() { 
              textCtrl.text = data?.text ?? "";
              onEdit(data?.text);
            }),
          ),
          child: Icon(
            Icons.content_paste_go,
            size: widget.elementHeight,
            color: Colors.white,
          ),
        ),
      ]),
    );
  }

  Widget buildToButton() {
    return GestureDetector(
      onTap: () {
        setState((){
          widget.setIdOnMouseCallback(widget.id);
        });
      },
      child: Container(
        alignment: Alignment.centerLeft,
        child: Icon(Icons.arrow_circle_left_outlined, size: widget.elementHeight, color: Colors.white),
      )
    );
  }

  Widget buildStaticRow(String fieldName, String value, VoidCallback cb) {
    return Row(children: [
      Align(alignment: Alignment.centerLeft, child: Text(fieldName, style: stl, textAlign: TextAlign.left),),
      const Spacer(),
      Align(alignment: Alignment.centerLeft, child: Text(value, style: stl, textAlign: TextAlign.left, overflow: TextOverflow.clip),),
      const Spacer(),
      GestureDetector(
        onTap: cb,
        child: Icon(
          Icons.content_copy,
          size: widget.elementHeight,
          color: Colors.white,
        ),
      ),
    ]);
  }

  Widget buildDropTyRow(String fieldName, TextEditingController textCtrl, List<String> items, String Function(String) converter) {
    return SizedBox(
      width: widget.blockWidth - 14,
      height: widget.elementHeight,
      child: Row(children: [
        Align(alignment: Alignment.centerLeft, child: Text(fieldName, style: stl, textAlign: TextAlign.left),),
        const SizedBox(width: 8),
        Align(alignment: Alignment.centerLeft, child: Text(textCtrl.value.text, style: stl, textAlign: TextAlign.left, overflow: TextOverflow.clip),),
        const Spacer(),
        Container(
          width: 30,
          alignment: Alignment.centerRight,
          child: DropdownButton<String>(
            value: textCtrl.value.text,
            icon: Icon(Icons.arrow_downward, color: Colors.white, size: widget.elementHeight),
            style: stl,
            isExpanded: true,
            elevation: 24,
            onChanged: (String? value) {
              setState(() {
                textCtrl.value = TextEditingValue(text: value!);
                updateFields();
              });
            },
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(converter(value), style: const TextStyle(fontSize: 12, color: Colors.black)),
              );
            }).toList(),
            selectedItemBuilder: (BuildContext context) {
              return List.generate(items.length, (index) {
                final item = items[index];
                return Container();
              });
            },
          ),
        ),
      ]),
    );
  }

  Widget buildResizableRow(String fieldName, VoidCallback addCb, VoidCallback removeCb) {
    return SizedBox(
      width: widget.blockWidth - 14,
      height: widget.elementHeight,
      child: Row(children: [
        Align(alignment: Alignment.centerLeft, child: Text(fieldName, style: stl, textAlign: TextAlign.left),),
        Spacer(),
        GestureDetector(
          onTap: addCb,
          child: Icon(Icons.add_circle_outline, size: widget.elementHeight, color: Colors.blueGrey[100]),
        ),
        SizedBox(width: 2),
        GestureDetector(
          onTap: removeCb,
          child: Icon(Icons.remove_circle_outline, size: widget.elementHeight, color: Colors.blueGrey[100]),
        )
      ]),
    );
  }

  Widget buildInnerFields(List<String> fieldNames, List<TextEditingController> controllers, List<void Function(String?)> onEdits, double factor) {
    List<Widget> rows = [];
    for(int i=0; i<controllers.length; i++) {
      rows.add(buildPropertyRow(fieldNames[i], controllers[i], factor, onEdits[i]));
    }
    rows.add(SizedBox(width: widget.blockWidth - 14, height: 2, child: Divider(color: Colors.black, height: 2)));

    return SizedBox(
      width: widget.blockWidth - 14,
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

class Setter {
  Setter({required this.name, required this.value});

  String name;
  String value;
}