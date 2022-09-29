import 'package:flutter/material.dart';
import 'package:keuangan_drift/data/database.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Aplikasi Duit'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  TextEditingController titleTEC = new TextEditingController();
  TextEditingController detailTEC = new TextEditingController();
  final database = MyDatabase();

  @override
  void initState() {
    super.initState();
  }

  Future<void> addTodo(String title, String detail) async {
    final database = MyDatabase();

    // Simple insert:
    await database
        .into(database.todos)
        .insert(TodosCompanion.insert(title: title, detail: detail));
  }

  Future<List<Todo>>? getAllTodo() {
    final database = MyDatabase();
    return database.select(database.todos).get();
  }

  Future updateTodo(Todo todo, title, detail) async {
    try {
      await database
          .update(database.todos)
          .replace(Todo(id: todo.id, title: title, detail: detail));
    } catch (err) {
      print("AUFAR " + err.toString());
    }
  }

  Future deleteTodo(Todo todo) async {
    await database.delete(database.todos).delete(todo);
  }

  void addOrDetailransaksi(Todo? todo) {
    if (todo != null) {
      titleTEC.text = todo.title.toString();
      detailTEC.text = todo.detail.toString();
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
                child: Center(
              child: Column(
                children: [
                  Text(todo != null ? "Detail " : "Tambah " + "Todo"),
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
                    maxLines: 3,
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
                        style: ElevatedButton.styleFrom(primary: Colors.red),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            if (todo == null) {
                              await addTodo(titleTEC.text, detailTEC.text);
                            } else {
                              await updateTodo(
                                  todo, titleTEC.text, detailTEC.text);
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
                ],
              ),
            )),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      backgroundColor: Colors.grey[400],
      body: SafeArea(
          child: FutureBuilder<List<Todo>>(
              future: getAllTodo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.waiting) {
                  return Expanded(
                    child: ListView.builder(
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              onTap: () {
                                addOrDetailransaksi(snapshot.data![index]);
                              },
                              title: Text(snapshot.data![index].title),
                              subtitle: Text(snapshot.data![index].detail),
                              trailing: ElevatedButton(
                                child: Icon(Icons.delete),
                                onPressed: () {
                                  deleteTodo(snapshot.data![index]);
                                  setState(() {});
                                },
                              ),
                            ),
                          );
                        }),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              })),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // await main();
          addOrDetailransaksi(null);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
