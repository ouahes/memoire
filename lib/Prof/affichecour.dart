import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DocumentPage extends StatefulWidget {
  final String courseId;

  DocumentPage({required this.courseId});

  @override
  _DocumentPageState createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  late Future<FirebaseApp> _initialization;
  late Future<List<String>> _futureUrls;

  @override
  void initState() {
    super.initState();
    _initialization = Firebase.initializeApp();
    _futureUrls = _getDownloadUrls();
  }

  Future<List<String>> _getDownloadUrls() async {
    List<String> urls = [];
    try {
      // Utilisation de l'identifiant du cours pour récupérer le fichier depuis Firebase Storage
      String url = await FirebaseStorage.instance.ref(widget.courseId).getDownloadURL();
      urls.add(url);
      print('URL du document ${widget.courseId} : $url');
    } catch (e) {
      print('Erreur en récupérant lURL de téléchargement du document: $e');
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Consulter les cours'),
            ),
            body: FutureBuilder<List<String>>(
              future: _futureUrls,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    print('Erreur en obtenant les URLs de téléchargement: ${snapshot.error}');
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }

                  if (snapshot.data == null || snapshot.data!.isEmpty) {
                    print('Aucun document trouvé');
                    return Center(child: Text('Aucun document trouvé.'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.all(8.0),
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: snapshot.data![index],
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      );
                    },
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          );
        }

        if (snapshot.hasError) {
          print('Erreur lors de l\'initialisation de Firebase: ${snapshot.error}');
          return Scaffold(
            body: Center(
              child: Text('Erreur d\'initialisation de Firebase: ${snapshot.error}'),
            ),
          );
        }

        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
