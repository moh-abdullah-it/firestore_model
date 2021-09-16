import 'package:firestore_model/firestore_model.dart';

abstract class SubCollectionModel<T extends Model> extends FirestoreModel<T> {
  String get subCollectionName {
    return this.runtimeType.toString();
  }

  @override
  String get collectionName {
    if (parentPath != null) {
      if (parentPath!.contains(subCollectionName)) {
        return parentPath!;
      }
    }

    return '$parentPath/$subCollectionName';
  }
}
