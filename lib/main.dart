import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:placar_pontinho/helpers/player_helper.dart';

void main() {
  runApp(MaterialApp(
    title: "Placar do Pontinho",
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        primaryColor: Colors.blue,
        cursorColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          hintStyle: TextStyle(color: Colors.white),
        )),
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Player> _playersList = List<Player>();
  final _playerController = TextEditingController();
  int _losers = 0;

  void _addPlayer() {
    Player newPlayer = Player();
    newPlayer.name = _playerController.text;
    newPlayer.point = 0;
    newPlayer.playing = true;
    newPlayer.victories = 0;
    _playerController.text = "";
    _playersList.add(newPlayer);
    setState(() {});
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Placar"),
        centerTitle: true,
        backgroundColor: Colors.black12,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Reiniciar partida?"),
                      content:
                          Text("O placar de todos os jogadores será zerado."),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("Reiniciar",
                              style: TextStyle(color: Colors.black)),
                          onPressed: () {
                            Navigator.pop(context);
                            for (var i = 0; i < _playersList.length; i++) {
                              _playersList[i].point = 0;
                              _playersList[i].playing = true;
                            }
                            _losers = 0;
                            setState(() {});
                          },
                        ),
                        FlatButton(
                          child: Text("Continuar",
                              style: TextStyle(color: Colors.black)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  });
            },
          )
        ],
      ),
      backgroundColor: Colors.white30,
      body: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(10),
              child: Row(children: <Widget>[
                Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              labelText: "Novo Jogador",
                              labelStyle: TextStyle(color: Colors.white)),
                          controller: _playerController,
                        ))),
                RaisedButton(
                  color: Colors.white,
                  child: Text("ADD"),
                  textColor: Colors.black,
                  onPressed: _addPlayer,
                )
              ])),
          Expanded(
            child: RefreshIndicator(
                child: ListView.builder(
                    itemCount: _playersList.length, itemBuilder: playerBuilder),
                onRefresh: _refresh),
          )
        ],
      ),
    );
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _playersList.sort((x, y) {
        if (x.point > y.point)
          return 1;
        else if (x.point < y.point)
          return -1;
        else
          return 0;
      });
      return null;
    });
  }

  Widget playerBuilder(BuildContext context, int index) {
    return GestureDetector(
      child: Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(-0.9, 0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
        direction: DismissDirection.startToEnd,
        child: Padding(
            padding: EdgeInsets.only(left: 5, right: 5),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    _playersList[index].playing ? Icons.mood : Icons.mood_bad,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
                title: Text(_playersList[index].name,
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                subtitle: Text("Vitórias (${_playersList[index].victories})",
                    style: TextStyle(fontSize: 14, color: Colors.black45)),
                trailing: Text("${_playersList[index].point}",
                    style: TextStyle(fontSize: 24)),
              ),
            )),
        onDismissed: (direction) {
          setState(() {
            _playersList.removeAt(index);
          });
        },
      ),
      onTap: () {
        if (_playersList[index].playing)
          _markPoints(context, index);
        else
          _showDialog(index);
      },
    );
  }

  void _markPoints(BuildContext context, int index) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return BottomSheet(
              backgroundColor: Colors.black45,
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    padding: EdgeInsets.only(
                        right: 10,
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: TextField(
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  labelText: "Pontos",
                                  labelStyle: TextStyle(color: Colors.white)),
                              controller: _playerController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                        RaisedButton(
                            color: Colors.white,
                            onPressed: () {
                              _playersList[index].point =
                                  _playersList[index].point +
                                      int.parse(_playerController.text);
                              setState(() {
                                _playerController.text = "";
                                Navigator.pop(context);
                                if (_playersList[index].point >= 100) {
                                  _playersList[index].playing = false;
                                  _showDialog(index);
                                  _losers++;
                                }
                                if(_losers == _playersList.length - 1){
                                  for(var i = 0; i < _playersList.length; i++){
                                    if(_playersList[i].playing)
                                      _playersList[i].victories = _playersList[i].victories + 1;
                                  }
                                }
                              });
                            },
                            child: Text("Salvar")),
                      ],
                    ),
                  ),
                );
              });
        });
  }

  Future<bool> _showDialog(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Perdedor"),
            content: Text("${_playersList[index].name} fez BOOOM!!!"),
            actions: <Widget>[
              FlatButton(
                child: Text("Continuar", style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
    return Future.value(true);
  }
}
