import 'package:firestore_model/firestore_model.dart';

class Post extends SubCollectionModel<Post> {
  String? title;
  String? description;

  Post({this.title, this.description});

  Post.fromMap(Map<String, dynamic> map) {
    this.title = map['title'];
    this.description = map['description'];
  }

  @override
  ResponseBuilder<Post> get responseBuilder => (map) => Post.fromMap(map);

  @override
  Map<String, dynamic> get toMap => {
        'title': this.title,
        'description': this.description,
      };

  @override
  String get subCollectionName => 'posts';
}
