import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../core/types.dart' as types;
import '../firestore_model.dart';

class ModelSingleRefreshBuilder<M extends FirestoreModel<M>>
    extends StatefulWidget {
  const ModelSingleRefreshBuilder(
      {Key? key,
      this.builder,
      this.query,
      this.docId,
      this.parentModel,
      this.initialData,
      this.onLoading,
      this.onEmpty,
      this.onError,
      this.onSuccess})
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

  final types.ErrorWidget? onError;

  final types.SuccessWidget<M>? onSuccess;

  @override
  State<ModelSingleRefreshBuilder<M>> createState() =>
      _ModelSingleRefreshBuilderState<M>();
}

class _ModelSingleRefreshBuilderState<M extends FirestoreModel<M>>
    extends State<ModelSingleRefreshBuilder<M>> {
  M? model;
  bool isLoading = true;
  bool hasError = false;
  Error? error;
  @override
  void initState() {
    loadData();
    super.initState();
  }

  Future loadData() async {
    modelMethod()?.then((list) {
      setState(() {
        model = list;
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

  Future<M?>? modelMethod() async {
    return widget.docId != null
        ? ((widget.parentModel != null
                ? widget.parentModel?.subCollection<M>()
                : FirestoreModel.use<M>())
            ?.find(widget.docId!))
        : ((widget.parentModel != null
                ? widget.parentModel?.subCollection<M>()
                : FirestoreModel.use<M>())
            ?.first(queryBuilder: widget.query));
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
    if (model != null) {
      return widget.onSuccess!(model);
    }
    return widget.onEmpty != null ? widget.onEmpty!() : SizedBox();
  }
}
