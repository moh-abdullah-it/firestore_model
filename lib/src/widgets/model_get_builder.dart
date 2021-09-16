import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import '../firestore_model.dart';

class ModelGetBuilder<M extends FirestoreModel<M>> extends StatelessWidget {
  const ModelGetBuilder({
    Key? key,
    required this.builder,
    this.query,
    this.parentModel,
  }) : super(key: key);

  /// The build strategy currently used by this builder.
  ///
  /// This builder must only return a widget and should not have any side
  /// effects as it may be called multiple times.
  final AsyncWidgetBuilder<List<M?>> builder;

  /// Represents a [Query] over the data at a particular location.
  ///
  /// Can construct refined [Query] objects by adding filters and ordering.
  final Query Function(Query query)? query;

  /// [parentModel] for this [subCollection]
  final FirestoreModel? parentModel;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<M?>>(
        future: (parentModel != null
                ? parentModel?.subCollection<M>()
                : FirestoreModel.use<M>())
            ?.get(
          queryBuilder: query,
        ),
        initialData: <M>[],
        builder: builder);
  }
}
