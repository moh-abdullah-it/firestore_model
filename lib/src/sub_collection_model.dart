import 'package:firestore_model/firestore_model.dart';

import 'utils/plural_converter.dart';

abstract class SubCollectionModel<T extends Model> extends FirestoreModel<T> {
  String get subCollectionName {
    String className = runtimeType.toString();
    return PluralConverter().convert(className.toLowerCase());
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
