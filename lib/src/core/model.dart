import 'package:firestore_model/firestore_model.dart';

import '../utils/plural_converter.dart';

typedef ResponseBuilder<T> = T Function(dynamic);

mixin Model<T> {
  /// default true set timestamps
  bool get withTimestamps => true;

  /// DateTime when document is created
  DateTime? createdAt;

  /// DateTime when document is updated
  DateTime? updatedAt;

  /// default items in page
  int get perPage => 20;

  /// document id [FirestoreModel] will get it for your model
  String? docId;

  /// A string representing the path of the referenced document (relative to the
  /// root of the database).
  String? path;

  /// we will fill it if model is SubCollection
  String? parentPath;

  /// model mapping to write in collection
  Map<String, dynamic> get toMap;

  /// model mapping to read  collection
  ResponseBuilder<T> get responseBuilder;

  /// collection name [FirestoreModel] use your [Model] name
  String get collectionName {
    String className = runtimeType.toString();
    return PluralConverter().convert(className.toLowerCase());
  }

  static T instance<T extends Object>() {
    return FirestoreModel.use<T>();
  }
}
