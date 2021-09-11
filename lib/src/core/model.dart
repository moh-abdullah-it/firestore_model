typedef ResponseBuilder<T> = T Function(dynamic);

mixin Model<T> {
  /// default items in page
  int get perPage => 20;

  /// document id [FirestoreModel] will get it for your model
  String? docId;

  /// A string representing the path of the referenced document (relative to the
  /// root of the database).
  String? path;

  /// model mapping to write in collection
  Map<String, dynamic> get toMap;

  /// model mapping to write in collection
  ResponseBuilder<T> get responseBuilder;

  /// collection name [FirestoreModel] use your [Model] name
  String get collectionName {
    return this.runtimeType.toString();
  }
}
