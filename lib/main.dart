import 'dart:core';

import 'package:flutter/material.dart';

import 'StringBuffer.dart';
import 'httprequests.dart';

void main() => runApp(MaterialApp(home: SplitScreenApp()));
const double padding = 10;
const double textHeight = 150;
const int? lines = null;
const boxbgcolor = Color.fromARGB(240, 255, 255, 255);
const defaultStyle = TextStyle(
  color: Colors.black,
  fontSize: 18,
  fontFamily: "Open Sans",
  fontWeight: FontWeight.w300,
);

class SplitScreenApp extends StatefulWidget {
  const SplitScreenApp({super.key});

  @override
  State<SplitScreenApp> createState() => _SplitScreenAppState();
}

class _SplitScreenAppState extends State<SplitScreenApp> {
  SBV srcLang = SBV("Auto"), destLang = SBV("English");
  final TextEditingController _srcController = TextEditingController(),
      _destController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return /*MaterialApp(
      home:*/
        Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(children: [
        Column(
          children: [
            //Input text goes here
            Expanded(
              child: Container(
                alignment: Alignment.topCenter,
                color: Colors.blue,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          padding, padding + 15, padding, padding),
                      child: ScrollableDropdownButtonApp(
                        t: Screen.bottom,
                        buffer: srcLang,
                        langCallback: (SBV sbv) {
                          srcLang.rewrite(sbv.toString());
                        },
                        controller: _srcController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(padding),
                      child: TextHolder(
                        controller: _srcController,
                        stringCallback: (String s) => setState(() {
                          //want to avoid redundancy as making http requests to frequently could be expensive
                          //only let a translation request go through if at least .5 seconds have passed and text didn't change
                          String before = _srcController.text;
                          Future.delayed(const Duration(milliseconds: 1000))
                              .then((value) {
                            if (before == _srcController.text) {
                              Future<String> translation =
                                  Http.translationRequest(context, s,
                                      srcLang.toString(), destLang.toString());
                              translation.then((String s) {
                                if (s == "") {
                                  //translation failed
                                  _destController.text =
                                      "Error occurred while translating text!";
                                }
                                _destController.text = s;
                              });
                            }
                          });
                        }),
                      ),
                    )
                  ],
                ),
              ),
            ),
            //Output text goes here
            Expanded(
              child: RotatedBox(
                quarterTurns: 2,
                child: Container(
                  color: Colors.red,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            padding, padding + 10, padding, padding),
                        child: ScrollableDropdownButtonApp(
                          t: Screen.top,
                          buffer: destLang,
                          langCallback: (SBV sbv) {
                            setState(() {
                              destLang.rewrite(sbv.toString());
                              Http.translationRequest(
                                      context,
                                      _destController.text,
                                      srcLang.toString(),
                                      destLang.toString())
                                  .then((String s) {
                                if (s == "") {
                                  //translation failed
                                  _destController.text =
                                      "Error occurred while translating text!";
                                }
                                _destController.text = s;
                              });
                            });
                          },
                          controller: _destController,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(padding),
                        child: TextShower(
                          controller: _destController,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Center(
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 200, 200, 200),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 3),
            ),
            alignment: Alignment.center,
            child: IconButton(
              padding: EdgeInsets.all(0),
              onPressed: () {
                //swap top and bottom
                setState(() {
                  String temp = _srcController.text;
                  _srcController.text = _destController.text;
                  _destController.text = temp;
                  temp = srcLang.toString();
                  srcLang.rewrite(destLang.toString());
                  if (temp != "Auto") {
                    destLang.rewrite(temp);
                  } else {
                    destLang.rewrite("English");
                  }
                });
              },
              icon: const Icon(
                Icons.screen_rotation_alt_rounded,
                size: 25,
              ),
            ),
          ),
        )
      ]),
      //),
    );
  }
}

class TextShower extends StatelessWidget {
  final TextEditingController controller;

  const TextShower({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: textHeight,
      child: WrapperWidget(
        w: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: SingleChildScrollView(
            child: TextField(
              expands: false,
              enabled: false,
              maxLines: lines,
              style: defaultStyle,
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Translated Text goes Here',
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TextHolder extends StatefulWidget {
  final Function stringCallback;
  final TextEditingController controller;

  const TextHolder(
      {super.key, required this.stringCallback, required this.controller});

  @override
  State<TextHolder> createState() =>
      _TextHolderState(stringCallback: stringCallback, controller: controller);
}

class _TextHolderState extends State<TextHolder> {
  final Function stringCallback;
  final TextEditingController controller;

  _TextHolderState({required this.stringCallback, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: textHeight,
      child: WrapperWidget(
        w: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: SingleChildScrollView(
            child: TextField(
              onChanged: (s) {
                stringCallback(s);
              },
              maxLines: lines,
              expands: false,
              controller: controller,
              style: defaultStyle,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter text...',
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ScrollableDropdownButtonApp extends StatefulWidget {
  final Screen t;
  final Function langCallback;

  //sbv is a string builder
  final SBV buffer;
  final TextEditingController controller;

  const ScrollableDropdownButtonApp(
      {super.key,
      required this.t,
      required this.langCallback,
      required this.buffer,
      required this.controller});

  @override
  _ScrollableDropdownButtonAppState createState() =>
      _ScrollableDropdownButtonAppState(
          t: t,
          langCallback: langCallback,
          buffer: buffer,
          fieldText: controller);
}

class _ScrollableDropdownButtonAppState
    extends State<ScrollableDropdownButtonApp> {
  late List<SBV> dropdownValues;

  //storing in a string buffer list because you can change them through setstate
  late final SBV buffer;
  late Screen t;
  final Function langCallback;

  //to play audio for it
  late TextEditingController fieldText;

/*
  void readAsLines(String filename) {
    try {
      var asset = rootBundle.loadString("assets/$filename");
      StringBuffer sb = StringBuffer("");
      asset.then((s) {
        s.split("\n").forEach((element) {
          sb.write("\"${element.substring(0, element.indexOf(" "))}\", ");
        });
        print(sb.toString());
      });
      print(sb.toString());

    } catch (e) {
      if (kDebugMode) {
        print("SupportedLanguages.txt can't be opened");
      }
    }
  }
*/
  @override
  void initState() {
    super.initState();
    dropdownValues = [
      "Afrikaans",
      "Albanian",
      "Amharic",
      "Arabic",
      "Armenian",
      "Azerbaijani",
      "Basque",
      "Belarusian",
      "Bengali",
      "Bosnian",
      "Bulgarian",
      "Catalan",
      "Cebuano",
      "Chinese (Simplified)",
      "Chinese (Traditional)",
      "Corsican",
      "Croatian",
      "Czech",
      "Danish",
      "Dutch",
      "English",
      "Esperanto",
      "Estonian",
      "Filipino",
      "Finnish",
      "French",
      "Frisian",
      "Galician",
      "Georgian",
      "German",
      "Greek",
      "Gujarati",
      "Hausa",
      "Hawaiian",
      "Hebrew",
      "Hindi",
      "Hmong",
      "Hungarian",
      "Icelandic",
      "Igbo",
      "Indonesian",
      "Irish",
      "Italian",
      "Japanese",
      "Javanese",
      "Kannada",
      "Kazakh",
      "Khmer",
      "Korean",
      "Kyrgyz",
      "Lao",
      "Latin",
      "Latvian",
      "Lithuanian",
      "Luxembourgish",
      "Macedonian",
      "Malagasy",
      "Malay",
      "Malayalam",
      "Maltese",
      "Maori",
      "Marathi",
      "Mongolian",
      "Nepali",
      "Norwegian",
      "Odia",
      "Pashto",
      "Persian",
      "Polish",
      "Portuguese",
      "Punjabi",
      "Romanian",
      "Russian",
      "Samoan",
      "Serbian",
      "Sesotho",
      "Shona",
      "Sindhi",
      "Sinhala",
      "Slovak",
      "Slovenian",
      "Somali",
      "Spanish",
      "Sundanese",
      "Swahili",
      "Swedish",
      "Tajik",
      "Tamil",
      "Telugu",
      "Thai",
      "Turkish",
      "Ukrainian",
      "Urdu",
      "Uyghur",
      "Uzbek",
      "Vietnamese",
      "Welsh",
      "Xhosa",
      "Yiddish",
      "Yoruba",
      "Zulu"
    ].map((e) => SBV(e)).toList();
    if (t == Screen.bottom) dropdownValues.insert(0, SBV("Auto"));
  }

  void checkWhichLanguagesWork() async {
    List<String> d = [];
    for (var element in dropdownValues) {
      String s = await Http.translationRequest(
          context, "try to translate this", "English", element.toString());
      if (s != "") d.add('"${element.toString()}"');
      //print(s);
    }
    print(d.join(', '));
  }

  @override
  _ScrollableDropdownButtonAppState(
      {required this.t,
      required this.langCallback,
      required this.buffer,
      required this.fieldText});

  @override
  Widget build(BuildContext context) {
    var items = dropdownValues.map((SBV value) {
      return DropdownMenuItem<SBV>(
        value: value,
        child: RotatedBox(
          quarterTurns: (t == Screen.top) ? 2 : 0,
          child: Align(
              alignment: Alignment.centerLeft, child: Text(value.toString())),
        ),
      );
    }).toList();
    return SizedBox(
      child: WrapperWidget(
        w: DropdownButtonHideUnderline(
          child: RotatedBox(
            //rotating dropdown button widget doesn't rotate dropdown options
            //solution: rotate button again so it is upright,
            //          switch icon with upwards arrow
            //          rotate menu item widget
            //this leaves the text on the wrong side
            quarterTurns: (t == Screen.top) ? 2 : 0,
            child: DropdownButton<SBV>(
              style: defaultStyle,
              padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
              isExpanded: true,
              value: buffer,
              icon: Icon((t == Screen.top)
                  ? Icons.arrow_drop_up
                  : Icons.arrow_drop_down),
              hint: const Text('Select an option'),
              onChanged: (SBV? newValue) {
                if (newValue != null) {
                  //String langCode = Intl.shortLocale(newValue);
                  langCallback(newValue);
                  setState(() {
                    //str.clear();
                    //str.write(newValue.toString());
                  });
                }
              },
              items: (t == Screen.bottom) ? items : items.reversed.toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class WrapperWidget extends StatelessWidget {
  final Widget w;

  const WrapperWidget({super.key, required this.w});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: boxbgcolor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: w);
  }
}

enum Screen {
  bottom,
  top;
}
