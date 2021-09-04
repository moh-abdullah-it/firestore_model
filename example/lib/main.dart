import 'package:example/models/user.dart';
import 'package:firestore_model/firestore_model.dart';
import 'package:flutter/material.dart';

void main() async {
  await FirebaseApp.initializeApp(
      settings: FirestoreModelSettings(
          //persistenceEnabled: true,
          ));
  FirestoreModel.inject(User());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  User _user = User(firstName: "mohamed 3", lastName: "Abdullah 3");
  List<User?> users = <User?>[];

  @override
  void initState() {
    super.initState();
    FirestoreModel.use<User>().first(
        queryBuilder: (query) => query
            .where('score', isGreaterThan: 100)
            .orderBy('score', descending: true));
    FirestoreModel.use<User>()
        .paginate()
        .then((values) => users.addAll(values));
  }

  void loadMore() {
    FirestoreModel.use<User>().paginate().then((values) {
      setState(() {
        users.addAll(values);
      });
    });
  }

  void checkDoc() async {
    print(
        "doc exists ${await FirestoreModel.use<User>().exists("4P1LfnSycMEDaTP5yvEF")}");
  }

  void _addUser() async {
    await _user.create(docId: 'hdoihvnoirejiu9345j');
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
          child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (_, index) {
                return ListTile(
                  title: Text(
                      "${users[index]?.firstName} ${users[index]?.lastName}"),
                  subtitle: Text(users[index]?.docId ?? ''),
                );
              })
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          /*child: StreamBuilder<List<User?>>(
          stream: FirestoreModel.use<User>().streamAll(),
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              List<User?>? users = snapshot.data;
              return ListView.builder(
                  itemCount: users?.length,
                  itemBuilder: (_, index) {
                    return ListTile(
                      title: Text(
                          "${users?[index]?.firstName} ${users?[index]?.lastName}"),
                      subtitle: Text(users?[index]?.docId ?? ''),
                      leading: IconButton(
                        onPressed: () {
                          User? user = users?[index];
                          */ /*user?.firstName = 'new firstname';
                          user?.save();*/ /*
                          user?.update(data: {
                            "first_name": "Mohamed",
                            "last_name": "Abdullah"
                          });
                        },
                        icon: Icon(Icons.edit),
                      ),
                      trailing: IconButton(
                        onPressed: () => users?[index]?.delete(),
                        icon: Icon(Icons.delete),
                      ),
                    );
                  });
            }
            return CircularProgressIndicator();
          },
        ),*/
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => loadMore(),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
