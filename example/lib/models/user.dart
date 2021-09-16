import 'package:firestore_model/firestore_model.dart';

import 'post.dart';

class User extends FirestoreModel<User> {
  String? firstName;
  String? lastName;
  List<String>? languages;
  Post? post;

  User({this.firstName, this.lastName, this.languages});

  // use to read
  User.formMap(Map<String, dynamic> map) {
    this.firstName = map['first_name'];
    this.lastName = map['last_name'];
    this.languages =
        map['languages'] is List ? map['languages'].cast<String>() : [];
  }

  // use to write
  @override
  Map<String, dynamic> get toMap => {
        'first_name': this.firstName,
        'last_name': this.lastName,
        'languages': this.languages
      };

  @override
  ResponseBuilder<User> get responseBuilder => (map) => User.formMap(map);

  @override
  int get perPage => 1;

  @override
  String get collectionName => 'users';
}
