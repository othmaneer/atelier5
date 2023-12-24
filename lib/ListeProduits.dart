import 'dart:io';

import 'package:atelier4_o_erraouidate_iir5g2/login_ecran.dart';
import 'package:atelier4_o_erraouidate_iir5g2/produit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ListProduit extends StatefulWidget {
  const ListProduit({Key? key}):super(key: key);
  

  @override
  State<ListProduit> createState() => _ListProduitState();
}

/*

class ProduitItem extends StatelessWidget {
        ProduitItem({Key? key, required this.produit}) : super(key: key);
        final Produit produit;
        @override
        Widget build(BuildContext context) {
          return ListTile(
            title: Text(produit.designation),
            subtitle: Text(produit.marque),
            trailing: Text('${produit.prix} €'),
          );
        }
}
*/
/*
class _ListProduitState extends State<ListProduit> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des produits'),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('produits').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            if (snapshot.hasError) {
              return const Center(child: Text('Une erreur est survenue'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              ); // Center
            }
          }
          List<Produit> produits = snapshot.data!.docs.map((doc) {
            return Produit.fromFirestore(doc);
          }).toList();
          return ListView.builder(
            itemCount: produits.length,
            itemBuilder: (context, index) => ProduitItem(
              produit: produits[index],
            ), // ProduitItem
          ); // ListView.builder
        },
      ), // StreamBuilder
    ); // Scaffold
  }
}
*/


class _ListProduitState extends State<ListProduit> {
  FirebaseFirestore db = FirebaseFirestore.instance;
   final FirebaseStorage _storage = FirebaseStorage.instance;
    File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des produits'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(44, 124, 21, 234)           ),
              child: Text(''),
            ),
            ListTile(
              title: Text('se deconnecter'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          login_ecran()), // Assurez-vous d'ajuster le nom de votre écran de connexion
                );
              },
            ),

            // Add more ListTiles for additional options
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('produits').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Une erreur est survenue'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List<Produit> produits = snapshot.data!.docs.map((doc) {
            return Produit.fromFirestore(doc);
          }).toList();

          return ListView.builder(
            itemCount: produits.length,
            itemBuilder: (context, index) => Slidable(
              endActionPane: ActionPane(
                motion: StretchMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      _supprimerProduit(produits[index].id);
                    },
                    icon: Icons.delete,
                    backgroundColor: Colors.black,
                  ),
                  SlidableAction(
                    onPressed: (context) {
                      _modifierProduit(context, produits[index]);
                    },
                    icon: Icons.edit,
                    backgroundColor: Color.fromARGB(213, 234, 33, 23),
                  ),
                ],
              ),
              child: ProduitCard(
                produit: produits[index],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _ajouterProduit(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _supprimerProduit(String produitId) async {
    bool confirmation = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Voulez-vous vraiment supprimer ce produit ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Annuler
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirmer
              child: Text('Confirmer'),
            ),
          ],
        );
      },
    );

    // Si l'utilisateur a confirmé, supprime le produit
    if (confirmation == true) {
      try {
        await db.collection('produits').doc(produitId).delete();
      } catch (e) {
        print('Erreur lors de la suppression du produit : $e');
      }
    }
  }

  Future<void> _modifierProduit(BuildContext context, Produit produit) async {
    TextEditingController categorieController =
        TextEditingController(text: produit.categorie);
    TextEditingController designationController =
        TextEditingController(text: produit.designation);
    TextEditingController marqueController =
        TextEditingController(text: produit.marque);
    TextEditingController photoController =
        TextEditingController(text: produit.photo);
    TextEditingController prixController =
        TextEditingController(text: produit.prix.toString());
    TextEditingController quantiteController =
        TextEditingController(text: produit.quantite.toString());

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier le produit'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: categorieController,
                  decoration: InputDecoration(labelText: 'Catégorie'),
                ),
                TextField(
                  controller: designationController,
                  decoration: InputDecoration(labelText: 'Désignation'),
                ),
                TextField(
                  controller: marqueController,
                  decoration: InputDecoration(labelText: 'Marque'),
                ),
                TextField(
                  controller: photoController,
                  decoration: InputDecoration(labelText: 'URL de la photo'),
                ),
                TextField(
                  controller: prixController,
                  decoration: InputDecoration(labelText: 'Prix'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: quantiteController,
                  decoration: InputDecoration(labelText: 'Quantité'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _modifierProduitFirebase(
                  produit.id,
                  categorieController.text,
                  designationController.text,
                  marqueController.text,
                  photoController.text,
                  prixController.text,
                  quantiteController.text,
                );
                Navigator.of(context).pop();
              },
              child: Text('Modifier'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _modifierProduitFirebase(
    String produitId,
    String categorie,
    String designation,
    String marque,
    String photo,
    String prix,
    String quantite,
  ) async {
    try {
      double prixValue = double.parse(prix);
      int quantiteValue = int.parse(quantite);

      await db.collection('produits').doc(produitId).update({
        'categorie': categorie,
        'designation': designation,
        'marque': marque,
        'photo': photo,
        'prix': prixValue,
        'quantite': quantiteValue,
      });
    } catch (e) {
      print('Erreur lors de la modification du produit : $e');
    }
  }

  Future<void> _ajouterProduit(BuildContext context) async {
    TextEditingController categorieController = TextEditingController();
    TextEditingController designationController = TextEditingController();
    TextEditingController marqueController = TextEditingController();
    TextEditingController photoController = TextEditingController();
    TextEditingController prixController = TextEditingController();
    TextEditingController quantiteController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter un produit'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: categorieController,
                  decoration: InputDecoration(labelText: 'Catégorie'),
                ),
                TextField(
                  controller: designationController,
                  decoration: InputDecoration(labelText: 'Désignation'),
                ),
                TextField(
                  controller: marqueController,
                  decoration: InputDecoration(labelText: 'Marque'),
                ),
                 GestureDetector(
                  onTap: _selectImage,
                  child: AbsorbPointer(
                    child: TextField(
                      // Utilisez l'URL de l'image sélectionnée
                      readOnly: true,
                      controller: TextEditingController(text: imageUrl ?? ''),
                      decoration: InputDecoration(labelText: 'Image'),
                    ),
                  ),
                ),
                TextField(
                  controller: prixController,
                  decoration: InputDecoration(labelText: 'Prix'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: quantiteController,
                  decoration: InputDecoration(labelText: 'Quantité'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _ajouterProduitFirebase(
                  categorieController.text,
                  designationController.text,
                  marqueController.text,
                  photoController.text,
                  prixController.text,
                  quantiteController.text,
                );
                Navigator.of(context).pop();
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _ajouterProduitFirebase(
    String categorie,
    String designation,
    String marque,
    String photo,
    String prix,
    String quantite,
  ) async {
    try {
      double prixValue = double.parse(prix);
      int quantiteValue = int.parse(quantite);

      await db.collection('produits').add({
        'categorie': categorie,
        'designation': designation,
        'marque': marque,
        'photo': photo,
        'prix': prixValue,
        'quantite': quantiteValue,
      });
    } catch (e) {
      print('Erreur lors de l\'ajout du produit : $e');
    }
  }

    // Fonction pour sélectionner une photo depuis la galerie
  // Future<void> _pickImage() async {
  //   final ImagePicker picker = ImagePicker();
  //   final XFile? pickedFile =
  //       await picker.pickImage(source: ImageSource.gallery);
  //   String assetImagePath =
  //       'assets/images/placeholder.jpg'; // Chemin de l'image par défaut
  //   File im = await getImageFileFromAssets("assets/images/placeholder.jpg");

  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //     });
  //   } else {
  //     setState(() {
  //       _image = im;
  //     });
  //   }
  // }

  //  Future<File> getImageFileFromAssets(String assetPath) async {
  //   final ByteData data = await rootBundle.load(assetPath);
  //   final List<int> bytes = data.buffer.asUint8List();
  //   final tempDir = await getTemporaryDirectory();
  //   final File file = File('${tempDir.path}/temp_image.jpg');
  //   await file.writeAsBytes(bytes);
  //   return file;
  // }
   XFile? pickedFile;
  String? imageUrl;

  Future<void> _selectImage() async {
    pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageUrl = pickedFile!.path; // Utilisez le chemin de l'image sélectionnée
      // Rafraîchit l'interface pour afficher le chemin de l'image sélectionnée
      setState(
          () {}); // Assurez-vous que l'interface utilisateur est mise à jour
    }
  }

  

}


class ProduitCard extends StatelessWidget {
  const ProduitCard({Key? key, required this.produit}) : super(key: key);
  final Produit produit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      color: Color.fromARGB(255, 200, 123, 100), // Set your desired background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          backgroundImage: NetworkImage(produit.photo),
        ),
        title: Text(
          produit.designation,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        subtitle: Text(
          produit.marque,
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        trailing: Text(
          '${produit.prix} €',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}