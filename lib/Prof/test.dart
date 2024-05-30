import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  File? file;
  String? url;

  // Méthode pour sélectionner une image à partir de la galerie
  Future<void> selectImage() async {
    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        file = File(pickedImage.path);
      });
    }
  }

  // Méthode pour ajouter l'image sélectionnée à Firebase Storage
  Future<void> uploadImageToFirebase() async {
    if (file == null) {
      // Vérifier si une image a été sélectionnée
      return;
    }

    String imageName = basename(file!.path);
    Reference refStorage = FirebaseStorage.instance.ref(imageName);

    // Uploader l'image
    await refStorage.putFile(file!);

    // Obtenir l'URL de téléchargement de l'image
    String downloadURL = await refStorage.getDownloadURL();

    setState(() {
      url = downloadURL;
    });

    // Ajouter une nouvelle entrée dans la collection "cours" dans Firestore
    await addCourseToFirestore(imageName);
  }

  // Méthode pour ajouter une nouvelle entrée dans la collection "cours" dans Firestore
  Future<void> addCourseToFirestore(String imageName) async {
    try {
      // Récupérer l'utilisateur actuellement connecté
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // L'utilisateur n'est pas connecté
        return;
      }

      // Récupérer les détails du professeur à partir de la collection "professeur"
      DocumentSnapshot professorSnapshot =
          await FirebaseFirestore.instance.collection("professeur").doc(user.uid).get();
      String? professorName = professorSnapshot['nom'];
      String? professorSurname = professorSnapshot['prenom'];

      // Ajouter une nouvelle entrée dans la collection "cours" dans Firestore
      await FirebaseFirestore.instance.collection("cours").add({
        'id': imageName,
        'professorName': professorName,
        'professorSurname': professorSurname,
      });
    } catch (error) {
      print('Error adding course to Firestore: $error');
    }
  }

  Future<String> _getDownloadUrl(String imageId) async {
    return await FirebaseStorage.instance.ref(imageId).getDownloadURL();
  }

  // Méthode pour supprimer l'image du stockage Firebase et de la collection "cours"
  Future<void> _deleteImage(String imageId) async {
    try {
      // Supprimer l'image du stockage Firebase
      await FirebaseStorage.instance.ref(imageId).delete();

      // Supprimer l'image de la collection "cours"
      var snapshot = await FirebaseFirestore.instance
          .collection('cours')
          .where('id', isEqualTo: imageId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      print('Document supprimé avec succès.');
    } catch (e) {
      print('Erreur lors de la suppression du document: $e');
    }
  }

  void _confirmDelete(BuildContext context, String imageId) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      headerAnimationLoop: false,
      animType: AnimType.rightSlide,
      title: 'Confirmation',
      desc: 'Êtes-vous sûr de vouloir supprimer ce cours?',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        await _deleteImage(imageId);
      },
    )..show();
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gérer les cours'),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: selectImage,
              child: Text('Sélectionner un document'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: uploadImageToFirebase,
              child: Text('Ajouter le document à Firebase Storage'),
            ),
            SizedBox(height: 20.0),
            if (url != null) Text('Le document a été téléchargée avec succès.'),
            SizedBox(height: 20.0),
            Expanded(
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection("professeur").doc(user?.uid).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var professorData = snapshot.data;
                  var professorName = professorData!['nom'];
                  var professorSurname = professorData['prenom'];

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('cours')
                        .where('professorName', isEqualTo: professorName)
                        .where('professorSurname', isEqualTo: professorSurname)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final courses = snapshot.data!.docs;

                      if (courses.isEmpty) {
                        return Center(child: Text('Aucun document trouvé.'));
                      }

                      return ListView.builder(
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          var course = courses[index];
                          var imageId = course['id'];

                          return FutureBuilder<String>(
                            future: _getDownloadUrl(imageId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done) {
                                if (snapshot.hasError) {
                                  return Center(child: Text('Erreur: ${snapshot.error}'));
                                }
                                var imageUrl = snapshot.data;
                                return GestureDetector(
                                  onLongPress: () async {
                                    _confirmDelete(context, imageId);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(8.0),
                                    padding: EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl!,
                                      placeholder: (context, url) => CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                    ),
                                  ),
                                );
                              }
                              return Center(child: CircularProgressIndicator());
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}




