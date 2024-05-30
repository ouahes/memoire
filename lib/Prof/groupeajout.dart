import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:intl/intl.dart';

class GroupeAjoutPage extends StatefulWidget {
  @override
  _GroupeAjoutPageState createState() => _GroupeAjoutPageState();
}

class _GroupeAjoutPageState extends State<GroupeAjoutPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TimeOfDay _selectedTime = TimeOfDay.now();
  File? _attachment;
  final ImagePicker _picker = ImagePicker();
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;

  String? _groupName;
  int? _availableSeats;
  String? _nomProfesseur;
  String? _prenomProfesseur;
  String? _selectedDay;

  final List<String> _daysOfWeek = [
    'Dimanche',
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi'
  ];

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _addAttachment() async {
    await _uploadAttachment();
  }

  Future<void> _uploadAttachment() async {
    if (_attachment != null) {
      try {
        final firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('attachments/${DateTime.now().toString()}');
        await ref.putFile(_attachment!);
      } catch (e) {
        print('Error uploading attachment: $e');
      }
    }
  }

  void _addGroup() async {
    if (_selectedTime == null ||
        _groupName == null ||
        _availableSeats == null ||
        _selectedDay == null) {
      return;
    }

    final time = '${_selectedTime.hour}:${_selectedTime.minute}';
    await _uploadAttachment();

    // Récupérer les informations du professeur connecté depuis Firestore
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final professorDoc = await FirebaseFirestore.instance.collection('professeur').doc(currentUser.uid).get();
      if (professorDoc.exists) {
        setState(() {
          _nomProfesseur = professorDoc.data()?['nom'];
          _prenomProfesseur = professorDoc.data()?['prenom'];
        });
      }
    }

    try {
      await _firestore.collection('groupes').add({
        'day': _selectedDay,
        'time': time,
        'groupName': _groupName,
        'availableSeats': _availableSeats,
        'nomProfesseur': _nomProfesseur,
        'prenomProfesseur': _prenomProfesseur,
      });
    } catch (e) {
      print('Error adding group to Firestore: $e');
    }

    setState(() {
      _attachment = null;
      _groupName = null;
      _availableSeats = null;
      _nomProfesseur = null;
      _prenomProfesseur = null;
      _selectedDay = null;
    });
  }@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajout des groupes'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil("login", (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedDay,
                hint: Text('Sélectionner le jour'),
                items: _daysOfWeek.map((String day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedDay = newValue;
                  });
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _selectTime(context),
                    child: Text('Sélectionner l\'heure'),
                  ),
                  SizedBox(width: 10),
                  Text(
                  'Heure sélectionnée:\n${_selectedTime.hour}:${_selectedTime.minute}',
                  ),

                ],
              ),
              SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  _groupName = value;
                },
                decoration: InputDecoration(
                  labelText: 'Nom du groupe',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  _availableSeats = int.tryParse(value);
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nombre de places disponibles',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addGroup,
                child: Text('Ajouter'),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}