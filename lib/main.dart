import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      routes: {
        "/": (context) => HomeScreen(),
        "/AddNote": (context) => AddNote(),
        "/ShowNote": (context) => ShowNote(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  getNotes() async {
    final notes = await DatabaseProvider.db.getNotes();
    return notes;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.center,
            colors: [Colors.black, Colors.transparent],
          ).createShader(rect),
          blendMode: BlendMode.darken,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/my_notes_screen.jpg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
          ),
        ),
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("My Notes",
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          backgroundColor: Colors.transparent,
          body: FutureBuilder(
            future: getNotes(),
            builder: (context, noteData) {
              switch (noteData.connectionState) {
                case ConnectionState.waiting:
                  {
                    return Center(child: CircularProgressIndicator());
                  }
                case ConnectionState.done:
                  {
                    if (noteData.data == Null) {
                      return Center(
                        child: Text("You don't have any notes yet, create one"),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                            itemCount: noteData.data.length,
                            itemBuilder: (context, index) {
                              String title = noteData.data[index]['title'];
                              String body = noteData.data[index]['body'];
                              String date = noteData.data[index]['date'];
                              int id = noteData.data[index]['id'];
                              return Card(
                                color: Colors.white24,
                                child: ListTile(
                                  textColor: Colors.white,
                                  onTap: () {
                                    Navigator.pushNamed(context, "/ShowNote",
                                        arguments: NoteModel(
                                          title: title,
                                          body: body,
                                          date: DateTime.parse(date),
                                          id: id,
                                        ));
                                  },
                                  title: Text(
                                    title,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25),
                                  ),
                                  subtitle: Text(body),
                                ),
                              );
                            }),
                      );
                    }
                  }
              }
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: MaterialButton(
            elevation: 0,
            minWidth: double.maxFinite,
            height: 50,
            onPressed: () {
              Navigator.pushNamed(context, "/AddNote");
            },
            color: Colors.white24,
            child: const Text('Add Note',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            textColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class ShowNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NoteModel note =
        ModalRoute.of(context).settings.arguments as NoteModel;
    return Stack(
      children: [
        ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.center,
            colors: [Colors.black, Colors.transparent],
          ).createShader(rect),
          blendMode: BlendMode.darken,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/show_note.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Text(note.title),
            actions: [
              IconButton(
                  onPressed: () {
                    DatabaseProvider.db.deleteNode(note.id);
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  },
                  icon: const Icon(Icons.delete))
            ],
          ),
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  note.title,
                  style: const TextStyle(
                      fontSize: 30.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                Text(
                  note.body,
                  style: const TextStyle(fontSize: 20.0),
                ),
                const SizedBox(height: 300),
                Text(
                  note.date.toString(),
                  style: const TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AddNote extends StatefulWidget {
  @override
  _AddNoteState createState() => _AddNoteState();
}

String title;
String body;
DateTime date;
TextEditingController titleController = TextEditingController();
TextEditingController bodyController = TextEditingController();

class _AddNoteState extends State<AddNote> {
  addNote(NoteModel note) {
    DatabaseProvider.db.addNewNote(note);
    print("Note added successfully");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.center,
            colors: [Colors.black, Colors.transparent],
          ).createShader(rect),
          blendMode: BlendMode.darken,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/add_notes.jpg"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
          ),
        ),
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("Add Notes",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          backgroundColor: Colors.transparent,
          body: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Add Title",
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Expanded(
                  child: TextField(
                    controller: bodyController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Add Note",
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                    style: const TextStyle(fontSize: 15.0, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: MaterialButton(
            elevation: 0,
            minWidth: double.maxFinite,
            height: 50,
            onPressed: () {
              setState(() {
                title = titleController.text;
                body = bodyController.text;
                date = DateTime.now();
              });
              NoteModel note = NoteModel(title: title, body: body, date: date);
              addNote(note);
              Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
            },
            color: Colors.white24,
            child: const Text('Save Note',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            textColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class NoteModel {
  int id;
  String title;
  String body;
  DateTime date;

  NoteModel({this.id, this.title, this.body, this.date});

  Map<String, dynamic> toMap() {
    return ({
      "id": id,
      "title": title,
      "body": body,
      "date": date.toString(),
    });
  }
}

class DatabaseProvider {
  DatabaseProvider._();
  static final DatabaseProvider db = DatabaseProvider._();
  Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDB();

    return _database;
  }

  initDB() async {
    return await openDatabase(join(await getDatabasesPath(), "note_app.db"),
        onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        body TEXT,
        date DATE
        )
        ''');
    }, version: 1);
  }

  addNewNote(NoteModel note) async {
    final db = await database;
    db.insert("notes", note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<dynamic> getNotes() async {
    final db = await database;
    var res = await db.query("notes");
    if (res.length == 0) {
      return null;
    } else {
      var resultMap = res.toList();
      return resultMap.isNotEmpty ? resultMap : Null;
    }
  }

  Future<int> deleteNode(int id) async {
    final db = await database;
    int count = await db.rawDelete("DELETE FROM notes Where id = ?", [id]);
    return count;
  }
}
