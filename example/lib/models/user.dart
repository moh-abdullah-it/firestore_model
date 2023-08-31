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
    firstName = map['first_name'];
    lastName = map['last_name'];
    languages = map['languages'] is List ? map['languages'].cast<String>() : [];
  }

  // use to write
  @override
  Map<String, dynamic> get toMap =>
      {'first_name': firstName, 'last_name': lastName, 'languages': languages};

  @override
  ResponseBuilder<User> get responseBuilder => (map) => User.formMap(map);

  @override
  int get perPage => 1;
}
