import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart'; // Import de AwesomeDialog
import 'package:firebase_auth/firebase_auth.dart'; // Import de FirebaseAuth pour obtenir l'email de l'utilisateur actuel

class GroupePage extends StatefulWidget {
  const GroupePage({Key? key}) : super(key: key);

  @override
  _GroupePageState createState() => _GroupePageState();
}

class _GroupePageState extends State<GroupePage> {
  String? nomProfesseur;
  String? prenomProfesseur;

  @override
  void initState() {
    super.initState();
    fetchProfesseurDetails();
  }

  void fetchProfesseurDetails() async {
    // Récupérer l'email de l'utilisateur actuel
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email!;
      // Rechercher le professeur par email
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('professeur')
          .where('email', isEqualTo: email)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        var professeur = querySnapshot.docs.first;
        setState(() {
          nomProfesseur = professeur['nom'];
          prenomProfesseur = professeur['prenom'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des étudiants'),
      ),
      body: nomProfesseur == null || prenomProfesseur == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('requests')
                  .where('professorName', isEqualTo: nomProfesseur)
                  .where('professorSurname', isEqualTo: prenomProfesseur)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var request = snapshot.data!.docs[index];
                    bool accepted = request['status'] == 'accepté'; // Vérifie si l'étudiant est accepté
                    return Card(
                      child: ListTile(
                        title: Text(
                          'Étudiant: ${request['userName']} ${request['userSurname']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Groupe: ${request['groupName']}'),
                        trailing: ElevatedButton(
                          onPressed: accepted ? null : () { // Désactive le bouton si l'étudiant est déjà accepté
                            acceptStudent(request.id, request['groupId']);
                          },
                          child: Text('Accepter l\'étudiant'),
                        ),
                        onLongPress: () {
                          // Afficher un AwesomeDialog pour confirmation avant la suppression
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.info,
                            animType: AnimType.rightSlide,
                            title: 'Confirmation',
                            desc: 'Êtes-vous sûr de vouloir supprimer cet étudiant ?',
                            btnCancelOnPress: () {},
                            btnOkOnPress: () {
                              // Supprimer la demande d'inscription de cet étudiant spécifique pour ce professeur
                              deleteRequest(request.id);
                            },
                          )..show();
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  void acceptStudent(String requestId, String groupId) async {
    // Mise à jour du statut de la demande à "accepté"
    await FirebaseFirestore.instance.collection('requests').doc(requestId).update({
      'status': 'accepté',
    });

    // Décrémentation du nombre de places disponibles dans le groupe
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference groupRef = FirebaseFirestore.instance.collection('groupes').doc(groupId);
      DocumentSnapshot snapshot = await transaction.get(groupRef);

      if (!snapshot.exists) {
        throw Exception("Le groupe n'existe pas !");
      }

      int availableSeats = snapshot['availableSeats'];

      if (availableSeats > 0) {
        transaction.update(groupRef, {'availableSeats': availableSeats - 1});
      } else {
        throw Exception("Aucune place disponible !");
      }
    });

    print('Étudiant accepté, statut de la demande mis à jour et nombre de places disponibles décrémenté');
  }

  void deleteRequest(String requestId) async {
    // Supprimer la demande d'inscription de cet étudiant spécifique
    await FirebaseFirestore.instance.collection('requests').doc(requestId).delete();
    print('Demande d\'inscription supprimée');
  }
}

