import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../components/custombuttonauth.dart';
import '../components/customlogoauth.dart';
import '../components/textformfield.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController nom = TextEditingController();
  TextEditingController prenom = TextEditingController();
  TextEditingController niveau = TextEditingController();
  TextEditingController matiere = TextEditingController();
  TextEditingController ville = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  String? role = 'Student'; // Default role

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
                    "Inscription",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Container(height: 10),
                  const Text(
                    "Inscivez-Vous pour continuer à utiliser l'application.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Container(height: 20),
                  const Text(
                    "Nom d'utilisateur",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  CustomTextForm(
                    hinttext: "entrer votre nom d'utulisateur",
                    mycontroller: username,
                    validator: (val) {
                      if (val == '') {
                        return "Can't be Empty";
                      }
                    },
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
                        return "Can't be Empty";
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
                        return "Can't be Empty";
                      }
                    },
                  ),
                  Container(height: 20),
                  const Text(
                    "Rôle",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  DropdownButtonFormField<String>(
                    value: role,
                    items: [
                      DropdownMenuItem(value: 'Student', child: Text('Elève')),
                      DropdownMenuItem(value: 'Teacher', child: Text('Enseignant')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        role = value;
                      });
                    },
                  ),
                  if (role == 'Teacher') ...[
                    Container(height: 20),
                    const Text(
                      "Nom",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    CustomTextForm(
                      hinttext: "entrer votre nom",
                      mycontroller: nom,
                      validator: (val) {
                        if (val == '') {
                          return "Can't be Empty";
                        }
                      },
                    ),
                    Container(height: 20),
                    const Text(
                      "Prénom",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    CustomTextForm(
                      hinttext: "entrer votre prénom",
                      mycontroller: prenom,
                      validator: (val) {
                        if (val == '') {
                          return "Can't be Empty";
                        }
                      },
                    ),
                    Container(height: 20),
                    const Text(
                      "Niveau",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    CustomTextForm(
                      hinttext: "entrer votre niveau enseigné",
                      mycontroller: niveau,
                      validator: (val) {
                        if (val == '') {
                          return "Can't be Empty";
                        }
                      },
                    ),
                    Container(height: 20),
                    const Text(
                      "Matière",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    CustomTextForm(
                      hinttext: "entrer votre matière enseignée",
                      mycontroller: matiere,
                      validator: (val) {
                        if (val == '') {
                          return "Can't be Empty";
                        }
                      },
                    ),
                    Container(height: 20),
                    const Text(
                      "Ville",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    CustomTextForm(
                      hinttext: "entrer votre ville",
                      mycontroller: ville,
                      validator: (val) {
                        if (val == '') {
                          return "Can't be Empty";
                        }
                      },
                    ),
                  ] else if (role == 'Student') ...[
                    Container(height: 20),
                    const Text(
                      "Nom",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    CustomTextForm(
                      hinttext: "enter votre nom",
                      mycontroller: nom,
                      validator: (val) {
                        if (val == '') {
                          return "Can't be Empty";
                        }
                      },
                    ),
                    Container(height: 20),
                    const Text(
                      "Prénom",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    CustomTextForm(
                      hinttext: "enter votre prénom",
                      mycontroller: prenom,
                      validator: (val) {
                        if (val == '') {
                          return "Can't be Empty";
                        }
                      },
                    ),
                  ],
                  Container(margin: const EdgeInsets.only(top: 10, bottom: 20)),
                ],
              ),
            ),
            CustomButtonAuth(
              title: "S'inscrire",
              onPressed: () async {
                if (formState.currentState!.validate()) {
                  try {
                    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: email.text,
                      password: password.text,
                    );
                    await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
                      'username': username.text,
                      'email': email.text,
                      'role': role,
                    });
                    if (role == 'Teacher') {
                      await FirebaseFirestore.instance.collection('professeur').doc(credential.user!.uid).set({
                        'nom': nom.text,
                        'prenom': prenom.text,
                        'niveau': niveau.text,
                        'matiere': matiere.text,
                        'ville': ville.text,
                        'email': email.text,
                      });
                    } else if (role == 'Student') {
                      await FirebaseFirestore.instance.collection('etudiant').doc(credential.user!.uid).set({
                        'nom': nom.text,
                        'prenom': prenom.text,
                        'email': email.text,
                      });
                    }
                    Navigator.of(context).pushReplacementNamed("login");
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'weak-password') {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.info,
                        animType: AnimType.rightSlide,
                        title: 'ERREUR',
                        desc: 'Le mot de passe fourni est trop faible.',
                      //  btnCancelOnPress: () {},
                        btnOkOnPress: () {},
                      ).show();
                    } else if (e.code == 'email-already-in-use') {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.info,
                        animType: AnimType.rightSlide,
                        title: 'ERREUR',
                        desc: 'Le compte existe déjà pour cet email.',
                      //  btnCancelOnPress: () {},
                        btnOkOnPress: () {},
                      ).show();
                    }
                  } catch (e) {
                    print(e);
                  }
                }
              },
            ),
            Container(height: 20),
            InkWell(
              onTap: () {
                Navigator.of(context).pushReplacementNamed("login");
              },
              child: const Center(
                child: Text.rich(TextSpan(children: [
                  TextSpan(text: "Vous avez déjà un compte?  "),
                  TextSpan(
                    text: "Se connecter",
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ])),
              ),
            )
          ],
        ),
      ),
    );
  }
}

