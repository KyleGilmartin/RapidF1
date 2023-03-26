import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? userId;
  final String name;
  final String tier;
  final String pending;
  final String accepted;
  final String baned;

  UserModel({
    required this.userId,
    required this.name,
    required this.tier,
    required this.pending,
    required this.accepted,
    required this.baned,
  });

  UserModel.fromJson(Map<String, Object?> json)
      : this(
          userId: json['userId']! as String,
          name: json['name']! as String,
          tier: json['tier']! as String,
          pending: json['pending']! as String,
          accepted: json['accepted']! as String,
          baned: json['baned']! as String,
        );

  Map<String, Object?> toJson() {
    return {
      'userId': userId,
      'name': name,
      'tier': tier,
      'pending': pending,
      'accepted': accepted,
      'baned': baned,
    };
  }
}
