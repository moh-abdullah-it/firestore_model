import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/types.dart' as types;
import '../firestore_model.dart';

class ModelGetRefreshBuilder<M extends FirestoreModel<M>>
    extends StatefulWidget {
  const ModelGetRefreshBuilder(
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
  State<ModelGetRefreshBuilder<M>> createState() =>
      _ModelGetRefreshBuilderState<M>();
}

class _ModelGetRefreshBuilderState<M extends FirestoreModel<M>>
    extends State<ModelGetRefreshBuilder<M>> {
  List<M?>? data = [];
  bool isLoading = true;
  bool hasError = false;
  Error? error;
  @override
  void initState() {
    loadData();
    super.initState();
  }

  Future loadData() async {
    (widget.parentModel != null
            ? widget.parentModel?.subCollection<M>()
            : FirestoreModel.use<M>())
        ?.get(
      queryBuilder: widget.query,
    )
        .then((list) {
      setState(() {
        data = list;
        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        hasError = true;
        error = e;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: loadData,
      child: _buildWidget(),
    );
  }

  _buildWidget() {
    if (isLoading) {
      return widget.onLoading != null ? widget.onLoading!() : SizedBox();
    }
    if (hasError) {
      print("Error $error");
      return widget.onError != null ? widget.onError!(error) : SizedBox();
    }
    if (data!.length > 0) {
      return widget.onSuccess!(data);
    }
    return widget.onEmpty != null ? widget.onEmpty!() : SizedBox();
  }
}
