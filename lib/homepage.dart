import 'package:academyx/Prof/affichecour.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'voirdetails.dart';


class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late List<Map<String, dynamic>> data;
  late List<Map<String, dynamic>> filteredData;
  late List<String> villes;
  late List<String> matieres;
  late List<String> niveaux;

  late String? selectedVille;
  late String? selectedMatiere;
  late String? selectedNiveau;

  @override
  void initState() {
    super.initState();
    data = [];
    filteredData = [];
    villes = [];
    matieres = [];
    niveaux = [];
    selectedVille = null;
    selectedMatiere = null;
    selectedNiveau = null;
    getData();
  }

  void getData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("professeur").get();
    List<Map<String, dynamic>> dataList = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    setState(() {
      data = dataList;
      filteredData = data;
      villes = data.map((e) => e['ville'] as String).toSet().toList();
      matieres = data.map((e) => e['matiere'] as String).toSet().toList();
      niveaux = data.map((e) => e['niveau'] as String).toSet().toList();
    });
  }

  void applyFilters() {
    setState(() {
      filteredData = data.where((e) =>
          (selectedVille == null || e['ville'] == selectedVille) &&
          (selectedMatiere == null || e['matiere'] == selectedMatiere) &&
          (selectedNiveau == null || e['niveau'] == selectedNiveau)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page d\'acceuil Elève'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil("login", (route) => false);
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 20),
          FilterDropdown(
            title: 'Ville',
            items: villes,
            onChanged: (value) {
              setState(() {
                selectedVille = value;
              });
            },
          ),
          SizedBox(height: 20),
          FilterDropdown(
            title: 'Matière',
            items: matieres,
            onChanged: (value) {
              setState(() {
                selectedMatiere = value;
              });
            },
          ),
          SizedBox(height: 20),
          FilterDropdown(
            title: 'Niveau',
            items: niveaux,
            onChanged: (value) {
              setState(() {
                selectedNiveau = value;
              });
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: applyFilters,
            child: Text('Filtrer'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text('Matière: ${filteredData[index]['matiere']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nom: ${filteredData[index]['nom']}'),
                        Text('Prénom: ${filteredData[index]['prenom']}'),
                        Text('Email: ${filteredData[index]['email']}'),
                        //Text('Téléphone: ${filteredData[index]['telephone']}'),
                        Text('Niveau: ${filteredData[index]['niveau']}'),
                        Text('Ville: ${filteredData[index]['ville']}'),
                        Text('Matière: ${filteredData[index]['matiere']}'),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfessorDetailsPage(
                            nomProfesseur: filteredData[index]['nom'],
                            prenomProfesseur: filteredData[index]['prenom'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //ElevatedButton(
  //onPressed: () {
  //  Navigator.push(
      //context,
      //MaterialPageRoute(
      //  builder: (context) => DocumentPage(courseId: '',), // Nom de votre page de consultation des cours
      //),
  //  );
  //},
  //child: Text('Consulter les cours'),
//),

            //  SizedBox(height: 10),
              //ElevatedButton(
                //onPressed: () {
                  // Action à effectuer lors de la consultation des résultats des tests
                //},
                //child: Text('Consulter les tests'),
            //  ),
            //  SizedBox(height: 10),
            //  ElevatedButton(
              //  onPressed: () {
              //    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Ontapinkwell2()));
              //  },
              //  child: Text('Go to teacher page'),
            //  ),
            ],
          ),
        ],
      ),
    );
  }
}

class FilterDropdown extends StatelessWidget {
  final String title;
  final List<String> items;
  final Function(String?) onChanged;

  const FilterDropdown({Key? key, required this.title, required this.items, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: title,
        border: OutlineInputBorder(),
      ),
      value: null,
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text('Tous'),
        ),
        ...items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ],
      onChanged: onChanged,
    );
  }
} 
