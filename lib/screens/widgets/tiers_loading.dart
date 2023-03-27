import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../models/user.dart';

class TiersLoading extends StatefulWidget {
  const TiersLoading({super.key});

  @override
  State<TiersLoading> createState() => _TiersLoadingState();
}

class _TiersLoadingState extends State<TiersLoading> {
  CollectionReference tiers = FirebaseFirestore.instance.collection('tiers');
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String username =
      FirebaseAuth.instance.currentUser!.email.toString().split('@')[0];

  Future<void> uploadToFireStore(String tier) async {
    EasyLoading.show();

    await _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'name': username,
      'tier': tier,
      'clicked': true,
      'pending': "yes",
      'accepted': "no",
      'baned': "no"
    }).whenComplete(() {
      EasyLoading.dismiss();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _usersStream =
        FirebaseFirestore.instance.collection('tiers').snapshots();
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        Color? getColorFromString(String colorString) {
          switch (colorString.toLowerCase()) {
            case 'red':
              return Colors.red;
            case 'blue':
              return Colors.blue;
            case 'green':
              return Colors.green;
            // Add more cases for other color names as needed
            default:
              return null;
          }
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            Color? cardColor = getColorFromString(data['cardColor']);

            bool clicked = data['clicked'] ?? false;
            String buttonText = clicked ? 'Pending' : 'Join';
            bool buttonDisabled = clicked;

            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Card(
                color: cardColor ?? Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 153,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data['title'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          data['description'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: buttonDisabled
                              ? null
                              : () {
                                  uploadToFireStore(data['title']);
                                },
                          child: Text(buttonText),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
