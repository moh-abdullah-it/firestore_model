import 'package:flutter/widgets.dart';

typedef SuccessWidget<T> = Widget Function(T? data);
typedef ErrorWidget = Widget Function(Object? data);
typedef EmptyWidget = Widget Function();
typedef LoadingWidget = Widget Function();
