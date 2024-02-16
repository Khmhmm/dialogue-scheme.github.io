import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';

import 'package:dialogue_scheme/block.dart';

class Jsonifier extends StatelessWidget {
  Jsonifier(this.blocks) {
    this.json = Jsonifier.blocksToJson(this.blocks);
  }

  List<DataBlock> blocks;
  late String json;

  static String blocksToJson(List<DataBlock> blocks) {
    String buf = "[";
    for(final b in blocks) {
      if (b.speaker == "" && b.text == "" && b.next == "") {
        continue;
      }
      buf += "\n {";
      buf += "\n  \"id\": \"${b.id}\",";
      buf += "\n  \"ty\": ${b.ty},";
      buf += "\n  \"msg\": {";
      buf += "\n    \"speaker\": \"${b.speaker}\",";
      buf += "\n    \"text\": \"${b.text}\",";
      buf += (b.ty == 1)? "\n    \"if\": \"${b.ifs}\"," : "";
      buf += (b.ty == 2)? "\n    \"options\": \"${b.options}\"," : "";
      buf += "\n    \"next\": \"${b.next}\"";
      buf += "\n  }";
      buf += "\n }\n";
    }
    buf += "]";

    return buf;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: MediaQuery.of(context).size.width * 0.25),
        Container(
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.height * 0.87,
          child: SingleChildScrollView(
            child: HighlightView(
              json,
              language: 'json',
              theme: githubTheme,
              padding: const EdgeInsets.all(8),
              textStyle: TextStyle(fontSize: 20),
            ),
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(top: 32, left: 16),
          color: Colors.transparent,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(left: 1, top: 1, bottom: 1, right: 1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Color(0x33D3BBFF),
                ),
                child: IconButton(
                  color: Colors.transparent,
                  hoverColor: Theme.of(context).colorScheme.inversePrimary,
                  tooltip: "Copy",
                  onPressed: () { Clipboard.setData(ClipboardData(text: this.json)).then((_){}); },
                  icon: Icon(
                    Icons.content_copy,
                    size: 32,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ]
    );
  }
}
