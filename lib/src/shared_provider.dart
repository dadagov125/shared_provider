import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
    required Create<T> acquire,
    required String instanceKey,
    Dispose<T>? dispose,
    Key? key,
    Widget? child,
    TransitionBuilder? builder,
    bool? lazy,
    StartListening<T>? startListening,
  })  : _startListening = startListening,
        _acquire = acquire,
        _instanceKey = instanceKey,
        _dispose = dispose,
        _lazy = lazy,
        _builder = builder,
        super(key: key, child: child);

  final TransitionBuilder? _builder;
  final bool? _lazy;
  final Dispose<T>? _dispose;
  final String _instanceKey;
  final Create<T> _acquire;
  final StartListening<T>? _startListening;

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(
      child != null,
      '$runtimeType used outside of MultiBlocProvider must specify a child',
    );
    return InheritedProvider<T>(
      create: (context) {
        return SharedInstance.acquire(
          createValue: () => _acquire(context),
          acquirer: context,
          instanceKey: _instanceKey,
        ).value;
      },
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
