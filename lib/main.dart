import 'package:flutter/material.dart';
import 'package:todolist_youtube/data/database.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final database = MyDatabase();
  TextEditingController titleTEC = new TextEditingController();
  TextEditingController detailTEC = new TextEditingController();

  Future insert(String title, String detail) async {
    await database
        .into(database.todos)
        .insert(TodosCompanion.insert(title: title, detail: detail));
  }

  Future<List<Todo>> getAll() {
    return database.select(database.todos).get();
  }

  Future update(Todo todo, String newTitle, String newDetail) async {
    await database
        .update(database.todos)
        .replace(Todo(id: todo.id, title: newTitle, detail: newDetail));
  }

  Future delete(Todo todo) async {
    await database.delete(database.todos).delete(todo);
  }

  void todoDialog(Todo? todo) {
    if (todo != null) {
      titleTEC.text = todo.title;
      detailTEC.text = todo.detail;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
                child: Center(
              child: Column(children: [
                Text((todo != null ? "Detail " : "Tambah ") + " Todo"),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: titleTEC,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "Judul"),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: detailTEC,
                  maxLines: 4,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: "Detail"),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true)
                              .pop('dialog');
                        },
                        child: Text("Batal"),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (todo != null) {
                            update(todo, titleTEC.text, detailTEC.text);
                          } else {
                            insert(titleTEC.text, detailTEC.text);
                          }

                          setState(() {});
                          Navigator.of(context, rootNavigator: true)
                              .pop('dialog');
                          titleTEC.clear();
                          detailTEC.clear();
                        },
                        child: Text("Simpan"))
                  ],
                )
              ]),
            )),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      body: SafeArea(
        child: FutureBuilder<List<Todo>>(
            future: getAll(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                print(snapshot.data.toString());
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        return Card(
                            child: ListTile(
                                onTap: () {
                                  todoDialog(snapshot.data![index]);
                                },
                                title: Text(snapshot.data![index].title),
                                subtitle: Text(snapshot.data![index].detail),
                                trailing: ElevatedButton(
                                  child: Icon(Icons.delete),
                                  onPressed: () {
                                    delete(snapshot.data![index]);
                                    setState(() {});
                                  },
                                )));
                      });
                } else {
                  return Center(
                    child: Text("Belum ada data"),
                  );
                }
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          titleTEC.clear();
          detailTEC.clear();
          todoDialog(null);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
