import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import '../components/custombuttonauth.dart';
import '../components/customtextfieladd.dart';

class AddProf extends StatefulWidget {
  const AddProf({super.key});

  @override
  State<AddProf> createState() => _AddProfState();
}

class _AddProfState extends State<AddProf> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  TextEditingController nom = TextEditingController();
  TextEditingController prenom = TextEditingController();
  TextEditingController matiere = TextEditingController();
  TextEditingController niveau = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController telephone = TextEditingController();
  String? selectedVille;

  List<String> villes = [
    'Adrar',
    'Chlef',
    'Laghouat',
    'Oum El Bouaghi',
    'Batna',
    'Béjaïa',
    'Biskra',
    'Béchar',
    'Blida',
    'Bouira',
    'Tamanghasset',
    'Tébessa',
    'Tlemcen',
    'Tiaret',
    'Tizi Ouzou',
    'Alger (Wilaya d\'Alger)',
    'Djelfa',
    'Jijel',
    'Sétif',
    'Saïda',
    'Skikda',
    'Sidi Bel Abbès',
    'Annaba',
    'Guelma',
    'Constantine',
    'Médéa',
    'Mostaganem',
    'M\'Sila',
    'Mascara',
    'Ouargla',
    'Oran',
    'El Bayadh',
    'Illizi',
    'Bordj Bou Arréridj',
    'Boumerdès',
    'El Tarf',
    'Tindouf',
    'Tissemsilt',
    'El Oued',
    'Khenchela',
    'Souk Ahras',
    'Tipaza',
    'Mila',
    'Aïn Defla',
    'Naâma',
    'Aïn Témouchent',
    'Ghardaïa',
    'Relizane',
    'El M\'Ghair',
    'El Menia',
    'Ouargla',
    'Béchar',
    'Tindouf',
    'Illizi',
    'El Bayadh',
    'Tamanrasset',
    'Djanet',
    'In Salah'
  ];

  CollectionReference prof = FirebaseFirestore.instance.collection('prof');
  Future<void> addUser() {
    // Call the user's CollectionReference to add a new user
    return prof
        .add({
      'name': nom.text,
      'prenom': prenom.text,
      'matiere': matiere.text,
      'niveau': niveau.text,
      'email': email.text,
      'telephone': telephone.text,
      'ville': selectedVille,
      
    })
        .then((value) => print("Prof Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Prof'),
      ),
      body: Form(
        key: formState,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
              child: CustomTextFormAdd(
                  hinttext: "Enter Name",
                  mycontroller: nom,
                  validator: (val) {
                    if (val == "") {
                      return "Name can't be empty";
                    }
                  }),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
              child: CustomTextFormAdd(
                  hinttext: "Enter Prenom",
                  mycontroller: prenom,
                  validator: (val) {
                    if (val == "") {
                      return "Prenom can't be empty";
                    }
                  }),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
              child: CustomTextFormAdd(
                  hinttext: "Enter Matiere",
                  mycontroller: matiere,
                  validator: (val) {
                    if (val == "") {
                      return "Matiere can't be empty";
                    }
                  }),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
              child: CustomTextFormAdd(
                  hinttext: "Enter Niveau",
                  mycontroller: niveau,
                  validator: (val) {
                    if (val == "") {
                      return "Niveau can't be empty";
                    }
                  }),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
              child: DropdownButtonFormField<String>(
                value: selectedVille,
                decoration: InputDecoration(
                  labelText: 'Select Ville',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedVille = value;
                  });
                },
                items: villes.map((ville) {
                  return DropdownMenuItem<String>(
                    value: ville,
                    child: Text(ville),
                  );
                }).toList(),
                validator: (val) {
                  if (val == null) {
                    return "Please select a ville";
                  }
                  return null;
                },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
              child: CustomTextFormAdd(
                  hinttext: "Enter Email",
                  mycontroller: email,
                  validator: (val) {
                    if (val == "") {
                      return "Email can't be empty";
                    }
                  }),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
              child: CustomTextFormAdd(
                  hinttext: "Enter Telephone",
                  mycontroller: telephone,
                  validator: (val) {
                    if (val == "") {
                      return "Telephone can't be empty";
                    }
                  }),
            ),
            CustomButtonAuth(
              title: "Add",
              onPressed: () {
                if (formState.currentState!.validate()) {
                  addUser();
                  // Afficher une boîte de dialogue pour confirmer l'ajout
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Success"),
                        content: Text("Prof Added Successfully"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
