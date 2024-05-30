import 'package:academyx/Prof/groupe.dart';
import 'package:academyx/Prof/groupeajout.dart';
import 'package:academyx/Prof/test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Ontapinkwell2 extends StatefulWidget {
  const Ontapinkwell2({Key? key}) : super(key: key);

  @override
  State<Ontapinkwell2> createState() => _Ontapinkwell2State();
}

class _Ontapinkwell2State extends State<Ontapinkwell2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  floatingActionButton: FloatingActionButton(
      //  onPressed: () {
      //  Navigator.of(context).pushNamed("addprof");
      //  },
      //  child: Icon(Icons.add),
      //  ),
      appBar: AppBar(
        title: Text('Page d\'acceuil Professeur'),
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
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TestPage(),
                  ),
                );
              //  Navigator.of(context)
                  //  .pushNamedAndRemoveUntil("cour", (route) => false);
              },
              child: Text('Gérer les cours '),
            ),
          //  SizedBox(height: 10),
            //ElevatedButton(
            //  onPressed: () {
              //  Navigator.of(context)
                //    .pushNamedAndRemoveUntil("test", (route) => false);
            //  },
            //  child: Text('Gérer les tests'),
          //  ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupePage(),
                  ),
                );
                //Navigator.of(context)
                  //  .pushNamedAndRemoveUntil("groupe", (route) => false);
              },
              child: Text('Gérer les listes des étudiants'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupeAjoutPage(),
                  ),
                );
                //.pushNamedAndRemoveUntil("groupeAjout", (route) => false);
              },
              child: Text('Groupe enseignées'),
            ),
          ],
        ),
      ),
    );
  }
}
