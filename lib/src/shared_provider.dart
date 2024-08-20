import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'shared_instance.dart';

/// Creates a value, store it, and expose it to its descendants.
/// Will also share it with other providers by value type or instanceKey.
///
/// The value can be optionally disposed using [dispose] callback.
/// This callback that will be called when the last [Provider]
/// using the shared instance is unmounted from the widget tree.
class SharedProvider<T> extends SingleChildStatelessWidget {
  SharedProvider({
    Create<T>? create,
    required String instanceKey,
    Dispose<T>? dispose,
    Key? key,
    Widget? child,
    TransitionBuilder? builder,
    bool? lazy,
    StartListening<T>? startListening,
    bool Function(T, T)? updateShouldNotify,
    T Function(BuildContext, T?)? update,
  })  : _updateShouldNotify = updateShouldNotify,
        _update = update,
        _startListening = startListening,
        create = create,
        _instanceKey = instanceKey,
        _dispose = dispose,
        _lazy = lazy,
        _builder = builder,
        super(key: key, child: child);

  final TransitionBuilder? _builder;
  final bool? _lazy;
  final Dispose<T>? _dispose;
  final String _instanceKey;
  final Create<T>? create;
  final StartListening<T>? _startListening;
  final T Function(BuildContext context, T? value)? _update;
  final UpdateShouldNotify<T>? _updateShouldNotify;

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(
      child != null,
      '$runtimeType used outside of MultiProvider must specify a child',
    );
    return InheritedProvider<T>(
      create: create != null
          ? (context) {
              return SharedInstance.acquire(
                createValue: () => create!.call(context),
                acquirer: context,
                instanceKey: _instanceKey,
              ).value;
            }
          : null,
      update: _update != null
          ? (context, value) {
              final newValue = _update!.call(context, value);
              if (value == newValue) {
                return newValue;
              }
              SharedInstance.releaseIfAcquired(_instanceKey, context);
              return SharedInstance.acquire(
                createValue: () => newValue,
                acquirer: context,
                instanceKey: _instanceKey,
              ).value;
            }
          : null,
      updateShouldNotify: _updateShouldNotify,
      dispose: (context, value) {
        SharedInstance.releaseIfAcquired(_instanceKey, context);
        if (!SharedInstance.hasAcquirer(_instanceKey)) {
          _dispose?.call(context, value);
        }
      },
      startListening: _startListening,
      lazy: _lazy,
      builder: _builder,
      child: child,
    );
  }
}

class SharedProxyProvider<T, R> extends SharedProvider<R> {
  SharedProxyProvider({
    required String instanceKey,
    Key? key,
    Create<R>? create,
    required ProxyProviderBuilder<T, R> update,
    UpdateShouldNotify<R>? updateShouldNotify,
    Dispose<R>? dispose,
    bool? lazy,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          instanceKey: instanceKey,
          key: key,
          lazy: lazy,
          builder: builder,
          create: create,
          update: (context, value) => update(
            context,
            Provider.of(context),
            value,
          ),
          updateShouldNotify: updateShouldNotify,
          dispose: dispose,
          child: child,
        );
}
