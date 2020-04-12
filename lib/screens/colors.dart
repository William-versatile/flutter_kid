import 'dart:convert';
import 'dart:async' show Future;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_sound/flutter_sound_player.dart';
import 'package:flutterkutkit/entities/color.dart';
import 'package:flutterkutkit/widgets/base_app_bar.dart';
import 'package:flutterkutkit/widgets/colorGrid.dart';

Future<List<ColorEntity>> _fetchColors() async {
  String jsonString = await rootBundle.loadString('assets/data/colors.json');
  final jsonParsed = json.decode(jsonString);

  return jsonParsed
      .map<ColorEntity>((json) => new ColorEntity.fromJson(json))
      .toList();
}

class ColorsScreen extends StatefulWidget {
  ColorsScreen();

  @override
  _ColorsScreenState createState() => _ColorsScreenState();
}

class _ColorsScreenState extends State<ColorsScreen> {
  Future<List<ColorEntity>> _colorsFuture;
  FlutterSoundPlayer _soundPlayer;

  @override
  void initState() {
    super.initState();

    _colorsFuture = _fetchColors();
    _soundPlayer = new FlutterSoundPlayer();
  }

  void _playAudio(String audioPath) async {
    // Load a local audio file and get it as a buffer
    Uint8List buffer = (await rootBundle.load(audioPath)).buffer.asUint8List();
    await _soundPlayer.startPlayerFromBuffer(buffer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BaseAppBar(
          title: 'Colors',
          backgroundColor: Colors.teal[100],
        ),
        body: new FutureBuilder(
          future: _colorsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return ColorGrid(
                    code: int.parse(snapshot.data[index].code),
                    name: snapshot.data[index].name,
                    onTap: () {
                      _playAudio(snapshot.data[index].audio);
                    },
                  );
                },
              );
            } else {
              return Center(
                child: Text('Loading...'),
              );
            }
          },
        ));
  }

  @override
  void dispose() {
    _soundPlayer.release();
    super.dispose();
  }
}