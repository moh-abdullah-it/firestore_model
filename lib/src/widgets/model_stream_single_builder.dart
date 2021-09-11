import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import '../firestore_model.dart';

class ModelStreamSingleBuilder<M extends FirestoreModel<M>>
    extends StatelessWidget {
  const ModelStreamSingleBuilder({
    Key? key,
    required this.builder,
    this.query,
    this.docId,
  }) : super(key: key);

  /// The build strategy currently used by this builder.
  ///
  /// This builder must only return a widget and should not have any side
  /// effects as it may be called multiple times.
  final AsyncWidgetBuilder<M?> builder;

  /// Represents a [Query] over the data at a particular location.
  ///
  /// Can construct refined [Query] objects by adding filters and ordering.
  final Query Function(Query query)? query;

  /// id of document
  final String? docId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<M?>(
        stream: this.docId != null
            ? FirestoreModel.use<M>().streamFind(this.docId!)
            : FirestoreModel.use<M>().streamFirst(queryBuilder: query),
        builder: builder);
  }
}
