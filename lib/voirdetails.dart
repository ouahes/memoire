

import 'package:academyx/Prof/affichecour.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfessorDetailsPage extends StatefulWidget {
  final String nomProfesseur;
  final String prenomProfesseur;

  const ProfessorDetailsPage({
    Key? key,
    required this.nomProfesseur,
    required this.prenomProfesseur,
  }) : super(key: key);

  @override
  State<ProfessorDetailsPage> createState() => _ProfessorDetailsPageState();
}

class _ProfessorDetailsPageState extends State<ProfessorDetailsPage> {
  List<QueryDocumentSnapshot> data = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("groupes").get();
      setState(() {
        data = querySnapshot.docs.where((doc) =>
            doc['nomProfesseur'] == widget.nomProfesseur &&
            doc['prenomProfesseur'] == widget.prenomProfesseur).toList();
      });
    } catch (e) {
      print('Erreur lors de la récupération des données: $e');
    }
  }

  Future<void> requestEnrollment(String groupId, String groupName) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        String userId = user.uid;
        String userEmail = user.email ?? '';
        DocumentSnapshot userData = await FirebaseFirestore.instance.collection("etudiant").doc(userId).get();
        String userName = userData['nom'];
        String userSurname = userData['prenom'];

        await FirebaseFirestore.instance.collection("requests").add({
          'userId': userId,
          'userName': userName,
          'userSurname': userSurname,
          'userEmail': userEmail,
          'groupId': groupId,
          'groupName': groupName,
          'status': 'pending',
          'professorName': widget.nomProfesseur,
          'professorSurname': widget.prenomProfesseur,
          'timestamp': FieldValue.serverTimestamp(),
        });

        print('Demande d\'inscription envoyée pour le groupe $groupId');
      } catch (e) {
        print('Erreur lors de l\'envoi de la demande: $e');
      }
    }
  }

  Future<void> checkEnrollmentAndNavigate(String groupId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      try {
        QuerySnapshot courseQuery = await FirebaseFirestore.instance
            .collection('cours')
            .where('professorName', isEqualTo: widget.nomProfesseur)
            .where('professorSurname', isEqualTo: widget.prenomProfesseur)
            .get();

        print('Documents de cours trouvés: ${courseQuery.docs.length}');
        for (var doc in courseQuery.docs) {
          print('Course document: ${doc.id}, data: ${doc.data()}');
        }

        if (courseQuery.docs.isNotEmpty) {
          String courseId = courseQuery.docs.first['id'];
          print('Course ID trouvé: $courseId');

          QuerySnapshot enrollmentQuery = await FirebaseFirestore.instance
              .collection('requests')
              .where('userId', isEqualTo: userId)
              .where('groupId', isEqualTo: groupId)
              .where('status', isEqualTo: 'accepté')
              .get();

          print('Nombre de requêtes trouvées pour userId, groupId, et status: ${enrollmentQuery.docs.length}');
          for (var doc in enrollmentQuery.docs) {
            print('Request document (userId, groupId, et status): ${doc.id}, data: ${doc.data()}');
          }

          if (enrollmentQuery.docs.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DocumentPage(courseId: courseId),
              ),
            );
            return;
          }
        } else {
          print('Aucun cours trouvé pour ce professeur');
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Non inscrit'),
            content: Text('Vous n\'êtes pas inscrit à ce cours.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        print('Erreur lors de la vérification de l\'inscription: $e');
      }
    }
  }

  Future<bool> checkEnrollmentStatus(String groupId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      QuerySnapshot enrollmentQuery = await FirebaseFirestore.instance
          .collection('requests')
          .where('userId', isEqualTo: userId)
          .where('groupId', isEqualTo: groupId)
          .where('status', isEqualTo: 'accepté')
          .get();
      return enrollmentQuery.docs.isNotEmpty;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.prenomProfesseur} ${widget.nomProfesseur} - Détails'),
      ),
      body: data.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              itemCount: data.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 200, // Ajuster la hauteur selon vos besoins
              ),
              padding: EdgeInsets.all(20.0),
              itemBuilder: (context, i) {
                final groupData = data[i].data() as Map<String, dynamic>;
                return FutureBuilder<bool>(
                  future: checkEnrollmentStatus(data[i].id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    bool isEnrolled = snapshot.data!;
                    return Card(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Groupe: ${groupData['groupName']}"),
                              Text("Nombre de places: ${groupData['availableSeats']}"),
                              Text("Heure: ${groupData['time']}"),
                              Text("Jour: ${groupData['day']}"),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: isEnrolled
                                    ? null
                                    : () {
                                        requestEnrollment(data[i].id, groupData['groupName']);
                                      },
                                child: Text('Demande d\'inscription'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  checkEnrollmentAndNavigate(data[i].id);
                                },
                                child: Text('Consulter cours'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}








