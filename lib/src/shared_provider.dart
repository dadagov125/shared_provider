import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'shared_instance.dart';

/// Creates a value, store it, and expose it to its descendants.
/// Will also share it with other providers by value type or instanceKey.
///
/// The value can be optionally disposed using [dispose] callback.
/// This callback that will be called when the last [Provider]
/// using the shared instance is unmounted from the widget tree.
class SharedProvider<T> extends Provider<T> {
  SharedProvider({
    required Create<T> acquire,
    required String instanceKey,
    Dispose<T>? dispose,
    Key? key,
    Widget? child,
    TransitionBuilder? builder,
    bool? lazy,
  }) : super(
          key: key,
          child: child,
          builder: builder,
          lazy: lazy,
          create: (context) {
            return SharedInstance.acquire(
              createValue: () => acquire(context),
              acquirer: context,
              instanceKey: instanceKey,
            ).value;
          },
          dispose: (context, value) {
            SharedInstance.releaseIfAcquired(instanceKey, context);
            if (!SharedInstance.hasAcquirer(instanceKey)) {
              dispose?.call(context, value);
            }
          },
        );
}
