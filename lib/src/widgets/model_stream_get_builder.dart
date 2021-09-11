import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import '../firestore_model.dart';

class ModelStreamGetBuilder<M extends FirestoreModel<M>>
    extends StatelessWidget {
  const ModelStreamGetBuilder({Key? key, required this.builder, this.query})
      : super(key: key);

  /// The build strategy currently used by this builder.
  ///
  /// This builder must only return a widget and should not have any side
  /// effects as it may be called multiple times.
  final AsyncWidgetBuilder<List<M?>> builder;

  /// Represents a [Query] over the data at a particular location.
  ///
  /// Can construct refined [Query] objects by adding filters and ordering.
  final Query Function(Query query)? query;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<M?>>(
        stream: FirestoreModel.use<M>().streamGet(
          queryBuilder: query,
        ),
        initialData: <M>[],
        builder: builder);
  }
}
