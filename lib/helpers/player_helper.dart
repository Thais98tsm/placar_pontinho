import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String playersTable = "playersTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String pointColumn = "pointColumn";
final String playingColumn = "playingColumn";
final String victoriesColumn = "victoriesColumn";

class PlayerHelper {
  PlayerHelper.internal();
  static final PlayerHelper _instance = PlayerHelper.internal();
  factory PlayerHelper() => _instance;
  Database _db;

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "players.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute("CREATE TABLE $playersTable ("
          "$idColumn INTEGER PRIMARY KEY, "
          "$nameColumn TEXT, "
          "$pointColumn INTEGER, "
          "$playingColumn BOOLEAN,"
          "$victoriesColumn INTEGER)"
      );
    });
  }

  Future<Database> get db async {
    if (_db != null)
      return _db;
    else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Player> savePlayer(Player player) async {
    Database playerDb = await db;
    player.id = await playerDb.insert(playersTable, player.toMap());
    return player;
  }

  Future<Player> getPlayer(int id) async {
    Database playerDb = await db;
    List<Map> maps = await playerDb.query(playersTable,
        columns: [idColumn, nameColumn, pointColumn, playingColumn, victoriesColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return Player.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deletePlayer(int id) async {
    Database playerDb = await db;
    return await playerDb.delete(playersTable,
        where: "$idColumn = ?",
        whereArgs: [id]);
  }

  Future<int> updatePlayer(Player player) async {
    Database playerDb = await db;
    return await playerDb.update(playersTable, player.toMap(),
        where: "$idColumn = ?",
        whereArgs: [player.id]);
  }

  Future<List> getAllPlayers() async {
    Database playerDb = await db;
    List listMap = await playerDb.rawQuery("SELECT * FROM $playersTable");
    List<Player> listPlayers = List();
    for(Map m in listMap){
      listPlayers.add(Player.fromMap(m));
    }
    return listPlayers;
  }

  Future closeDb() async{
    Database playerDb = await db;
    playerDb.close();
  }
}

class Player {
  int id;
  String name;
  int point;
  bool playing;
  int victories;

  Player();

  Player.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    point = map[pointColumn];
    playing = map[playingColumn];
    victories = map[victoriesColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      pointColumn: point,
      playingColumn: playing,
      victoriesColumn: victories
    };
    if (id != null) map[idColumn] = id;
    return map;
  }

  @override
  String toString() {
    return "Player: (id: $id, name: $name, point: $point, playing: $playing, victories: $victories)";
  }
}
