import 'package:academyx/ontapinkwell2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Prof/add.dart';
import 'Prof/cour.dart';
import 'Prof/groupe.dart';
import 'Prof/groupeajout.dart';
import 'Prof/test.dart';
import 'auth/login.dart';
import 'auth/signup.dart';
import 'firebase_options.dart';
import 'homepage.dart';
import 'ontapinkwell.dart';

// Importez le package Firebase

void main() async {
  // Vérifiez si l'application s'exécute sur le Web ou non
  //if (!kIsWeb) {
  // Si ce n'est pas le cas, initialisez Firebase
  //await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    FirebaseAuth.instance
  .authStateChanges()
  .listen((User? user) {
    if (user == null) {
      print('===============User is currently signed out!');
    } else {
      print('===============User is signed in!');
    }
  });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue[100],
            titleTextStyle:const TextStyle(color:Color.fromARGB(255, 1, 60, 109), fontSize: 17,fontWeight: FontWeight.bold),
            iconTheme:const IconThemeData(color:  Color.fromARGB(255, 1, 60, 109))
          )
        ),
        debugShowCheckedModeBanner: false,
        home:(FirebaseAuth.instance.currentUser != null && 
        FirebaseAuth.instance.currentUser!.emailVerified) 
        ? const Homepage()
         : const LoginPage(),
        routes: {
          "signup": (context) => const SignUp(),
          "login": (context) => const LoginPage(),
          "homepage": (context) => const Homepage(),
          "addprof": (context) =>const AddProf(),
          "cour": (context) => CourPage(),
          "groupe": (context) =>const GroupePage(),
          "groupeAjout": (context) => GroupeAjoutPage(),
          "test": (context) => TestPage(),
          "homepageprof": (context) =>const Ontapinkwell2(),
          
        });
  }
}
