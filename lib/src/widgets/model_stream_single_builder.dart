import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../core/types.dart' as types;
import '../firestore_model.dart';

class ModelStreamSingleBuilder<M extends FirestoreModel<M>>
    extends StatelessWidget {
  const ModelStreamSingleBuilder(
      {Key? key,
      this.builder,
      this.query,
      this.docId,
      this.parentModel,
      this.initialData,
      this.onLoading,
      this.onError,
      this.onSuccess,
      this.onEmpty,
      this.onChange})
      : super(key: key);

  /// The build strategy currently used by this builder.
  ///
  /// This builder must only return a widget and should not have any side
  /// effects as it may be called multiple times.
  final AsyncWidgetBuilder<M?>? builder;

  /// Represents a [Query] over the data at a particular location.
  ///
  /// Can construct refined [Query] objects by adding filters and ordering.
  final Query Function(Query query)? query;

  /// id of document
  final String? docId;

  /// [parentModel] for this [subCollection]
  final FirestoreModel? parentModel;

  final M? initialData;

  final types.LoadingWidget? onLoading;

  final types.EmptyWidget? onEmpty;

  final Function(M? dataChnage)? onChange;

  final types.ErrorWidget? onError;

  final types.SuccessWidget<M>? onSuccess;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<M?>(
        stream: this.docId != null
            ? (parentModel != null
                    ? parentModel?.subCollection<M>()
                    : FirestoreModel.use<M>())
                ?.streamFind(this.docId!)
            : (parentModel != null
                    ? parentModel?.subCollection<M>()
                    : FirestoreModel.use<M>())
                ?.streamFirst(queryBuilder: query, onChange: onChange),
        initialData: initialData,
        builder: builder ??
            (context, snapshot) {
              assert(onSuccess != null, "onSuccess can't be null");
              if (snapshot.connectionState == ConnectionState.waiting) {
                return onLoading != null ? onLoading!() : SizedBox();
              }
              if (snapshot.hasError) {
                print("Error ${snapshot.error}");
                return onError != null ? onError!(snapshot.error) : SizedBox();
              }
              if (snapshot.hasData && snapshot.data != null) {
                return onSuccess!(snapshot.data);
              }
              return onEmpty != null ? onEmpty!() : SizedBox();
            });
  }
}
