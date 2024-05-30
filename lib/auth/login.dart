import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/custombuttonauth.dart';
import '../components/customlogoauth.dart';
import '../components/textformfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Form(
              key: formState,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 50),
                  const CustomLogoAuth(),
                  Container(height: 20),
                  const Text(
                    "Connexion",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Container(height: 10),
                  const Text(
                    "Connectez-vous pour continuer à utiliser l'application",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Container(height: 20),
                  const Text(
                    "E-mail",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Container(height: 10),
                  CustomTextForm(
                    hinttext: "entrer votre e-mail",
                    mycontroller: email,
                    validator: (val) {
                      if (val == '') {
                        return "Can't To be Empty";
                      }
                    },
                  ),
                  Container(height: 20),
                  const Text(
                    "Mot de passe",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Container(height: 20),
                  CustomTextForm(
                    hinttext: "entrer votre mot de passe",
                    mycontroller: password,
                    validator: (val) {
                      if (val == '') {
                        return "Can't To be Empty";
                      }
                    },
                  ),
                  InkWell(
                    onTap: () async {
                      if (email.text == "") {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.info,
                          animType: AnimType.rightSlide,
                          title: 'ERREUR',
                          desc: 'Veuillez entrer votre e-mail avant de cliquer sur mot de passe oublié',
                        //  btnCancelOnPress: () {},
                          btnOkOnPress: () {},
                        ).show();
                        return;
                      }
                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.info,
                          animType: AnimType.rightSlide,
                          title: 'Info',
                          desc: 'Veuillez aller à votre boite email et entrer votre nouveau mot de passe',
                          //btnCancelOnPress: () {},
                          btnOkOnPress: () {},
                        ).show();
                      } catch (e) {
                        print(e);AwesomeDialog(
                          context: context,
                          dialogType: DialogType.info,
                          animType: AnimType.rightSlide,
                          title: 'ERREUR',
                          desc: 'Veuillez vérifier votre adresse email car elle n\'existe pas',
                        //  btnCancelOnPress: () {},
                          btnOkOnPress: () {},
                        ).show();
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 20),
                      alignment: Alignment.topRight,
                      child: const Text(
                        "Mot de passe oublié?",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CustomButtonAuth(
              title: "Connexion",
              onPressed: () async {
                if (formState.currentState!.validate()) {
                  try {
                    UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email.text,
                      password: password.text,
                    );
                    String? userId = credential.user?.uid;
                    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
                    String role = userSnapshot['role'];

                    if (role == 'Student') {
                      Navigator.of(context).pushReplacementNamed("homepage");
                    } else if (role == 'Teacher') {
                      Navigator.of(context).pushReplacementNamed("homepageprof");
                    }
                  } on FirebaseAuthException catch (e) {
                    String message = '';
                    if (e.code == 'invalid-credential') {
                      message = 'Informations d\'identification invalides';
                    } else if (e.code == 'invalid-credential') {
                      message = 'Informations d\'identification invalides';
                    }
                     print('e.code=${e.code}');
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.info,
                      animType: AnimType.rightSlide,
                      title: 'ERREUR',
                      desc: message,
                      //btnCancelOnPress: () {},
                      btnOkOnPress: () {},
                    ).show();
                  } catch (e) {
                    print(e);
                  }
                }
              },
            ),
            Container(height: 20),
            InkWell(
              onTap: () {
                Navigator.of(context).pushReplacementNamed("signup");
              },
              child: const Center(
                child: Text.rich(TextSpan(children: [
                  TextSpan(text: "Vous n'avez pas un compte?  "),
                  TextSpan(
                    text: "S'inscrire",
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}