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

  uploadToFireStore(String tier) async {
    EasyLoading.show();

    await _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid + tier)
        .set({
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'name': username,
      'tier': tier,
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
    final CollectionReference _usersStream =
        FirebaseFirestore.instance.collection("tiers");
    return StreamBuilder<DocumentSnapshot>(
      stream: _usersStream.doc().snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("loading");
        }

        List<DocumentSnapshot> documents = snapshot.data!.docs;
        List<String> titles = [];
        List<String> colors = [];
        List<String> ABS = [];
        List<String> ManualGears = [];
        List<String> TC = [];
        List<String> RacingLine = [];

        for (int i = 0; i < documents.length; i++) {
          Map<String, dynamic> data =
              documents[i].data() as Map<String, dynamic>;
          titles.add(data['title']);
          colors.add(data['cardColor']);
          ABS.add(data['ABS']);
          ManualGears.add(data['Manual Gears']);
          TC.add(data['Traction Control']);
          RacingLine.add(data['Racing Line']);
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

        UserModel user =
            UserModel.fromJson(snapshot.data!.data()! as Map<String, dynamic>);

        return Center(
          child: ListView.builder(
            itemCount: titles.length,
            itemBuilder: (BuildContext context, int index) {
              Color? cardColor = getColorFromString(colors[index]);
              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: Card(
                  color: cardColor ?? Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: SizedBox(
                    width: double.infinity,
                    height: 153,
                    child: Center(
                      child: user.pending == "no"
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  titles[index],
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text('Tc: ' + TC[index]),
                                      Text('ABS: ' + ABS[index]),
                                      Text('Gears: ' + ManualGears[index]),
                                      Text('Racing Line: ' + RacingLine[index]),
                                    ],
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () {
                                    uploadToFireStore(titles[index]);
                                  },
                                  child: Text(
                                    'Join',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            )
                          : Text('Pending'),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
