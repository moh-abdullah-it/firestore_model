import 'package:firestore_model/firestore_model.dart';

class User extends FirestoreModel<User> {
  String? firstName;
  String? lastName;

  User({this.firstName, this.lastName});

  // use to read
  User.formMap(Map<String, dynamic> map) {
    this.firstName = map['first_name'];
    this.lastName = map['last_name'];
  }

  // use to write
  @override
  Map<String, dynamic> get toMap => {
        'first_name': this.firstName,
        'last_name': this.lastName,
      };

  @override
  ResponseBuilder<User> get responseBuilder => (map) => User.formMap(map);

  @override
  int get perPage => 1;

  @override
  String get collectionName => 'users';
}
