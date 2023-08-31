import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../core/types.dart' as types;
import '../firestore_model.dart';

class ModelGetBuilder<M extends FirestoreModel<M>> extends StatelessWidget {
  const ModelGetBuilder(
      {Key? key,
      this.builder,
      this.query,
      this.parentModel,
      this.initialData,
      this.onLoading,
      this.onError,
      this.onSuccess,
      this.onEmpty})
      : super(key: key);

  /// The build strategy currently used by this builder.
  ///
  /// This builder must only return a widget and should not have any side
  /// effects as it may be called multiple times.
  final AsyncWidgetBuilder<List<M?>?>? builder;

  /// Represents a [Query] over the data at a particular location.
  ///
  /// Can construct refined [Query] objects by adding filters and ordering.
  final Query Function(Query query)? query;

  /// [parentModel] for this [subCollection]
  final FirestoreModel? parentModel;

  final List<M>? initialData;

  final types.LoadingWidget? onLoading;

  final types.EmptyWidget? onEmpty;

  final types.ErrorWidget? onError;

  final types.SuccessWidget<List<M?>>? onSuccess;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<M?>?>(
        future: (parentModel != null
                ? parentModel?.subCollection<M>()
                : FirestoreModel.use<M>())
            ?.get(
          queryBuilder: query,
        ),
        initialData: initialData ?? <M?>[],
        builder: builder ??
            (context, snapshot) {
              assert(onSuccess != null, "onSuccess can't be null");
              if (snapshot.connectionState == ConnectionState.waiting) {
                return onLoading != null ? onLoading!() : const SizedBox();
              }
              if (snapshot.hasError) {
                log("Error ${snapshot.error}");
                return onError != null
                    ? onError!(snapshot.error)
                    : const SizedBox();
              }
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return onSuccess!(snapshot.data);
              }
              return onEmpty != null ? onEmpty!() : const SizedBox();
            });
  }
}
