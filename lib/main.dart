import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:tonic/tonic.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Flutter Piano"),
          centerTitle: true,
        ),
        drawer: Drawer(
          child: SafeArea(
            child: ListView(
              children: <Widget>[
                Container(height: 20.0),
                ListTile(title: Text("Change Width")),
                Slider(
                    activeColor: Colors.redAccent,
                    inactiveColor: Colors.white,
                    value: _widthRatio,
                    onChanged: (double value) =>
                        setState(() => _widthRatio = value)),
                Divider(),
                ListTile(
                    title: Text("Show Labels"),
                    trailing: Switch(
                        value: _showLabels,
                        onChanged: (bool value) =>
                            setState(() => _showLabels = value))),
                Divider(),
                ListTile(
                    title: Text("Invert colors"),
                    trailing: Switch(
                        value: _invertColors,
                        onChanged: (bool value) =>
                            setState(() => _invertColors = value))),
              ],
            ),
          ),
        ),
        body: ListView.builder(
            itemCount: 7,
            controller: ScrollController(initialScrollOffset: 1500),
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext buildContext, int index) {
              final int i = index * 12;
              return SafeArea(
                child: Stack(children: <Widget>[
                  Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    _buildKey(24 + i, false),
                    _buildKey(26 + i, false),
                    _buildKey(28 + i, false),
                    _buildKey(29 + i, false),
                    _buildKey(31 + i, false),
                    _buildKey(33 + i, false),
                    _buildKey(35 + i, false)
                  ]),
                  Positioned(
                      left: 0.0,
                      right: 0.0,
                      bottom: 100,
                      top: 0.0,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(width: keyWidth * .5),
                            _buildKey(25 + i, true),
                            _buildKey(27 + i, true),
                            Container(width: keyWidth),
                            _buildKey(30 + i, true),
                            _buildKey(32 + i, true),
                            _buildKey(34 + i, true),
                            Container(width: keyWidth * .5)
                          ])),
                ]),
              );
            }),
      ),
    );
  }

  Widget _buildKey(int midiNote, bool accidental) {
    final pitchName = Pitch.fromMidiNumber(midiNote).toString();
    final pianoKey = Stack(
      children: <Widget>[
        Semantics(
            button: true,
            hint: pitchName,
            child: Material(
                borderRadius: borderRadius,
                color:
                    (accidental != _invertColors) ? Colors.black : Colors.white,
                child: InkWell(
                  borderRadius: borderRadius,
                  highlightColor: Colors.grey,
                  onTap: () {},
                  onTapDown: (_) => FlutterMidi.playMidiNote(midi: midiNote),
                ))),
        Positioned(
          left: 0.0,
          right: 0.0,
          bottom: 20.0,
          child: _showLabels
              ? FlatButton(
                  onPressed: () => FlutterMidi.playMidiNote(midi: midiNote),
                  child: Text(pitchName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: !(_invertColors != accidental)
                              ? Colors.black
                              : Colors.white)))
              : Container(),
        )
      ],
    );
    if (accidental) {
      return Container(
        width: keyWidth,
        margin: EdgeInsets.symmetric(horizontal: 2.0),
        padding: EdgeInsets.symmetric(horizontal: keyWidth * .1),
        child: Material(
          elevation: 6.0,
          borderRadius: borderRadius,
          shadowColor: Color(0x802196F3),
          child: pianoKey,
        ),
      );
    }
    return Container(
      width: keyWidth,
      child: pianoKey,
      margin: EdgeInsets.symmetric(horizontal: 2.0),
    );
  }

  @override
  void initState() {
    rootBundle.load("assets/sounds/Piano.sf2").then((sf2) {
      FlutterMidi.prepare(sf2: sf2, name: "Piano.sf2").then((value) {
        debugPrint(value);
      });
    });
    super.initState();
  }

  double get keyWidth => 80 + (80 * _widthRatio);
  double _widthRatio = 0.0;
  bool _showLabels = true;
  bool _invertColors = false;

  static const BorderRadiusGeometry borderRadius = BorderRadius.only(
      bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0));
}
