import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

class CourPage extends StatefulWidget {
  @override
  _CourPageState createState() => _CourPageState();
}

class _CourPageState extends State<CourPage> {
  File? _attachment;
  final ImagePicker _picker = ImagePicker();
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _selectAttachment() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _attachment = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadAttachment() async {
    if (_attachment != null) {
      try {
        final firebase_storage.Reference ref = _storage.ref().child('attachments/${DateTime.now().toString()}');
        await ref.putFile(_attachment!);

        // Récupérer l'URL de la pièce jointe téléchargée
        final String downloadUrl = await ref.getDownloadURL();

        // Ajouter les détails du cours dans Firestore
        await _firestore.collection('cours').add({
          'idCours': ref.fullPath, // Utiliser le chemin complet comme ID du cours
          'nomProfesseur': 'Nom Professeur', // Remplacez par le nom du professeur actuel
          'prenomProfesseur': 'Prenom Professeur', // Remplacez par le prénom du professeur actuel
        });

        // Afficher un message de succès ou effectuer une autre action
        print('Pièce jointe téléchargée avec succès et cours ajouté dans Firestore.');
      } catch (e) {
        print('Error uploading attachment and adding course: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une pièce jointe'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil("login", (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _selectAttachment(),
                  child: Text('Sélectionner une pièce jointe'),
                ),
                SizedBox(width: 10),
                _attachment != null
                    ? Text('Pièce jointe sélectionnée')
                    : Text('Aucune pièce jointe sélectionnée'),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadAttachment,
              child: Text('Ajouter la pièce jointe'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

