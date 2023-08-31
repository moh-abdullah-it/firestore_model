import 'package:firestore_model/firestore_model.dart';

class Post extends SubCollectionModel<Post> {
  String? title;
  String? description;

  Post({this.title, this.description});

  Post.fromMap(Map<String, dynamic> map) {
    title = map['title'];
    description = map['description'];
  }

  @override
  ResponseBuilder<Post> get responseBuilder => (map) => Post.fromMap(map);

  @override
  Map<String, dynamic> get toMap => {
        'title': title,
        'description': description,
      };
}
