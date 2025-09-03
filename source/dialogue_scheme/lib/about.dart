import 'package:flutter/material.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:flutter_highlighter/themes/dark.dart';
import 'package:flutter_highlighter/themes/dracula.dart';
import 'package:flutter_highlighter/themes/idea.dart';
import 'package:flutter_highlighter/themes/monokai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AboutWidget extends StatelessWidget {
  AboutWidget();

  Widget buildInner(BuildContext context, bool isDarkTheme) {
    return Container(
      color: isDarkTheme? Color.fromARGB(255, 95, 95, 95) : Colors.white,
      child: Column(
        children: [
          SizedBox(height: 8),
          Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.87,
              width: MediaQuery.of(context).size.width * 0.5,
              child: Markdown(
                data: README,
                styleSheet: isDarkTheme? 
                  MarkdownStyleSheet.fromTheme(Theme.of(context)) :
                  MarkdownStyleSheet.fromTheme(Theme.of(context)),
                extensionSet: md.ExtensionSet(
                  md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                  <md.InlineSyntax>[
                    md.EmojiSyntax(),
                    ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
                  ],
                ),
                builders: {
                  'code': CodeElementBuilder(isDarkTheme),
                }
              ),
            ),
          ),
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return buildInner(context, snapshot.data!.getBool("darkTheme") ?? false);
        } else {
          return const Center(child: Text('Error while loading preferences...')); 
        }
      },
    );
  }
    
}



class CodeElementBuilder extends MarkdownElementBuilder {
  CodeElementBuilder(bool darkTheme) {
    isDarkTheme = darkTheme;
  }

  bool isDarkTheme = false;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = 'json';

    if (element.attributes['class'] != null) {
      String lg = element.attributes['class'] as String;
      language = lg.substring(9);
    }

    return SizedBox(
      width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width,
      child: HighlightView(
        element.textContent,
        language: language,
        theme: isDarkTheme? darkTheme : githubTheme,
        padding: const EdgeInsets.all(8),
        textStyle: preferredStyle,
      ),
    );
  }
}

const String README = r'''
## Dialogues system

### Base info

Replics file should contain json object in format like:
```
[
  { ... }, <- replics object, see examples below
  { ... },
  ...
]
```
Naming of replics file should match the structure:
```
1 00 00 00
^ just a number, means nothing but allow to keep other decimals
  ^ act id, may be used when you have more than 99 replics for single character
     ^ character id
        ^ replics order number
```

### Replics types

#### Commons
Replics file should start with the first replics in order.
All the replics MUST have fields: "id", "ty", "msg". Also in field "msg" MUST exist fields "speaker", which contains speaker name or blank ("") if
speaker is a player, "next",
which equals to id of the next replics or null if it is not points anywhere.

#### Final replics, type -1
Finishes dialogue. The next time you will try to talk with it, id from "next" of final replics will be shown.
```
{
 "id": "fjfsjefisej",
 "ty": -1,
 "msg": {
  "speaker": "Someone",
  "text": "how are you?",
  "next": "fjsejfisej"
 }
}
```

#### Base replics, type 0
Contains just text and pointer to next replics id
```
{
 "id": "fjsejfisej",
 "ty": 0,
 "msg": {
  "speaker": "",
  "text": "hello man",
  "next": "fjfsjefisej"
 }
}
```

#### If-then replics, type 1
Contains text and additional field "if". This field contains list with tuples. First element of tuple is predicate in ONE OF THESE FORMATS: {$pred1 and $pred2}, {$pred1 or $pred2}, {$pred}.
Other formats may cause error.
```
{
 "id": "fjsejfisejf",
 "ty": 1,
 "msg": {
  "speaker": "Someone",
  "text": "how are you",
  "if": [
   ["charIsGreat and charHasWeapon", "fjfjf"],
   ["charIsGreat or charIsHero", "fffswaejfjf"],
   ["charIsGreat", "fjfjfqeqeasdzj"]
  ],
  "next": "fjseijfsiefjies"
 }
}
```

#### Replics with select, type 2
Contains text and additional field "options". This field contains list with tuples. First element of tuple is a text to show, the second is consequences in ONE OF THESE FORMATS: {$var=$value}, {$var+$value}, {$var-$value}.
Other formats may cause error.
```
{
 "id": "fjsejfisejfa",
 "ty": 2,
 "msg": {
  "speaker": "Someone",
  "text": "So what?",
  "options": [
   ["i am fine", "charIsFine=true", "eiqweiaw"],
   ["give me money", "charMoney+10", "eqpweqpdsofo"],
   ["nothing", "", "fjseijiku"]
  ],
  "next": "fjseijiku"
 }
}
```
''';
