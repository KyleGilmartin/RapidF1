import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../tier_details.dart';

class TiersList extends StatefulWidget {
  @override
  State<TiersList> createState() => _TiersListState();
}

class _TiersListState extends State<TiersList> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  String username =
      FirebaseAuth.instance.currentUser!.email.toString().split('@')[0];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateOrCreateUser(List<String> tier) async {
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    try {
      final userDocSnapshot = await userDocRef.get();

      if (userDocSnapshot.exists) {
        await userDocRef.update({
          'tier': FieldValue.arrayUnion(tier),
        });
      } else {
        await userDocRef.set({
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'name': username,
          'tier': tier,
          'pending': 'yes',
          'accepted': 'no',
          'banned': 'no',
        });
      }
    } catch (e) {
      print('Error updating or creating user: $e');
    }
  }

  Stream<bool> isAcceptedStream(String docId) {
    final yesDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    return yesDocRef.snapshots().map((docSnapshot) {
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data['accepted'] == 'yes') {
          return true;
        }
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, bool> isSubmitting = {};
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tiers').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return Text('Loading...');
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            final doc = snapshot.data!.docs[index];
            final cardId = doc['title'];
            if (!isSubmitting.containsKey([cardId])) {
              isSubmitting[cardId] = false;
            }
            return Card(
              key: Key(cardId),
              color: Colors.white,
              child: Column(
                children: [
                  Text(doc['title']),
                  StreamBuilder<DocumentSnapshot>(
                    stream: users
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (userSnapshot.hasError) {
                        return Text('Error: ${userSnapshot.error}');
                      }
                      bool isDisabled = userSnapshot.hasData &&
                          userSnapshot.data!.exists &&
                          userSnapshot.data!.get('pending') == 'yes';
                      bool isAccepted = userSnapshot.hasData &&
                          userSnapshot.data!.exists &&
                          userSnapshot.data!.get('accepted') == 'yes';
                      return ElevatedButton(
                        onPressed: isDisabled || isSubmitting[cardId]!
                            ? null
                            : () async {
                                setState(() {
                                  isSubmitting[cardId] = true;
                                });
                                if (isAccepted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TierDetails(
                                            title: doc['title'],
                                            description: doc['description'])),
                                  );
                                  setState(() {
                                    isSubmitting[cardId] = false;
                                  });
                                } else {
                                  await updateOrCreateUser([cardId]);
                                  setState(() {
                                    isSubmitting[cardId] = false;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDisabled
                              ? Colors.grey
                              : isAccepted
                                  ? Colors.green
                                  : Colors.red,
                        ),
                        child: Text(
                          isDisabled
                              ? 'Pending'
                              : isSubmitting[cardId] == true
                                  ? 'Signing up...'
                                  : isAccepted
                                      ? 'View'
                                      : 'Sign up',
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
