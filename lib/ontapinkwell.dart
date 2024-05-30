import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Ontapinkwell extends StatefulWidget {
  const Ontapinkwell({Key? key}) : super(key: key);

  @override
  State<Ontapinkwell> createState() => _OntapinkwellState();
}

class _OntapinkwellState extends State<Ontapinkwell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("addprof");
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil("login", (route) => false);
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil("cour", (route) => false);
              },
              child: Text('Gérer les cours '),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil("test", (route) => false);
              },
              child: Text('Gérer les tests'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil("groupe", (route) => false);
              },
              child: Text('Gérer les listes des étudiants'),
            ),
          ],
        ),
      ),
    );
  }
}
