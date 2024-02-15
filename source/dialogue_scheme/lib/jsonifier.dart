import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      buf += "\n {";
      buf += "\n  \"id\": \"${b.id}\"";
      buf += "\n  \"ty\": \"${b.ty}\"";
      buf += "\n  \"msg\": {";
      buf += "\n    \"speaker\": \"${b.speaker}\"";
      buf += "\n    \"text\": \"${b.text}\"";
      buf += "\n    \"next\": \"${b.next}\"";
      buf += "\n  }";
      buf += "\n }\n";
    }
    buf += "]";

    return buf;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          child: IconButton(
            hoverColor: Theme.of(context).colorScheme.onSecondary,
            onPressed: () { Clipboard.setData(ClipboardData(text: this.json)).then((_){}); },
            icon: Icon(
              Icons.content_copy,
              size: 24,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(json),
              ),
            ),
          ),
        ),
      ]
    );
  }
}
