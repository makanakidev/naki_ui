import 'dart:async';
import 'package:jaspr/jaspr.dart' hide Element;
import 'package:universal_web/js_interop.dart'
    show FunctionToJSExportedDartFunction, JSArray, JSArrayToList, JSFunction;
import 'package:universal_web/web.dart';

import '../models/styling.dart';
import '../utilities/constants.dart';
import '../utilities/debounce.dart';
import '../utilities/enums.dart';
import '../utilities/extensions.dart';
import '../utilities/helpers.dart';

typedef LifecycleCallback = void Function();

typedef LifecycleValueCallback<T> = void Function(T value);

typedef LifecycleResizeCallback =
    void Function(
      Dim height,
      Dim width,
      Orientation orientation,
    );

/// {@template BrowserLifecycle}
/// Client-side utility for observing browser and component
/// lifecycle events.
///
/// Provides callbacks and overridable lifecycle hooks for page
/// visibility, theme changes, tab closures, component or tab resizing,
/// and more.
///
/// Call [register] to attach event listeners to the browser window
/// or a specific component, and call [dispose] when done to clean up
/// subscriptions to prevent memory leaks.
///
/// **NOTE: The [dispose] method MUST be called in the [StatefulComponent]'s
/// `dispose` method to prevent memory leaks.**
///
/// ### Usage:
/// ```dart
/// class MyComponentState extends State<MyComponent> {
///   final _lifecycle = BrowserLifecycleListeners();
///   final _containerKey = GlobalNodeKey<HTMLElement>();
///
///   @override
///   void initState() {
///     super.initState();
///
///     _lifecycle.whenVisible = () {
///       print('Browser tab active');
///     };
///
///     _lifecycle.whenResized = (height, width, orientation) {
///       print('Window size: ${width.cssText} x ${height.cssText}');
///     };
///
///     _lifecycle.observeComponentSize((height, width, orientation) {
///       print('Container size: ${width.cssText} x ${height.cssText}');
///     }, key: _containerKey);
///
///     _lifecycle.register();
///   }
///
///   @override
///   void dispose() {
///     _lifecycle.dispose();
///     super.dispose();
///   }
/// }
/// ```
/// {@endtemplate}
class BrowserLifecycleListeners {
  // Public APIs //

  LifecycleCallback? _whenVisible;

  /// {@macro BrowserLifecycle}
  /// - Callback fired when the page becomes visible.
  LifecycleCallback? get whenVisible => _whenVisible;
  set whenVisible(LifecycleCallback? callback) {
    _whenVisible = callback;
    _syncVisibilityListener();
  }

  LifecycleCallback? _whenInactive;

  /// {@macro BrowserLifecycle}
  /// - Callback fired when the page loses focus (e.g. user switched
  /// to another browser tab, minimized the window, or switched to
  /// another app).
  LifecycleCallback? get whenInactive => _whenInactive;
  set whenInactive(LifecycleCallback? callback) {
    _whenInactive = callback;
    _syncVisibilityListener();
  }

  LifecycleCallback? _whenClosed;

  /// {@macro BrowserLifecycle}
  /// - Callback fired when the page is closed, reloaded
  /// or navigated away from.
  LifecycleCallback? get whenClosed => _whenClosed;
  set whenClosed(LifecycleCallback? callback) {
    _whenClosed = callback;
    _syncClosedListener();
  }

  LifecycleResizeCallback? _whenResized;

  /// {@macro BrowserLifecycle}
  /// - Callback fired when the page is resized.
  LifecycleResizeCallback? get whenResized => _whenResized;
  set whenResized(LifecycleResizeCallback? callback) {
    _whenResized = callback;
    _syncResizeListener();
  }

  LifecycleValueCallback<ThemeMode>? _whenSystemThemeChanged;

  /// {@macro BrowserLifecycle}
  /// - Callback fired when the device's system theme changes.
  LifecycleValueCallback<ThemeMode>? get whenSystemThemeChanged =>
      _whenSystemThemeChanged;
  set whenSystemThemeChanged(
    LifecycleValueCallback<ThemeMode>? callback,
  ) {
    _whenSystemThemeChanged = callback;
    _syncThemeListener();
  }

  LifecycleValueCallback<bool>? _whenConnectivityChanged;

  /// {@macro BrowserLifecycle}
  /// - Callback fired when the browser gains or loses internet connectivity.
  LifecycleValueCallback<bool>? get whenConnectivityChanged =>
      _whenConnectivityChanged;
  set whenConnectivityChanged(
    LifecycleValueCallback<bool>? callback,
  ) {
    _whenConnectivityChanged = callback;
    _syncConnectivityListener();
  }

  LifecycleValueCallback<Orientation>? _whenOrientationChanged;

  /// {@macro BrowserLifecycle}
  /// - Callback fired when the device screen orientation changes.
  LifecycleValueCallback<Orientation>? get whenOrientationChanged =>
      _whenOrientationChanged;
  set whenOrientationChanged(
    LifecycleValueCallback<Orientation>? callback,
  ) {
    _whenOrientationChanged = callback;
    _syncOrientationListener();
  }

  LifecycleCallback? _whenFrozen;

  /// {@macro BrowserLifecycle}
  /// - Callback fired when the browser tab is frozen by the OS/browser.
  LifecycleCallback? get whenFrozen => _whenFrozen;
  set whenFrozen(LifecycleCallback? callback) {
    _whenFrozen = callback;
    _syncFreezeListener();
  }

  LifecycleCallback? _whenResumed;

  /// {@macro BrowserLifecycle}
  /// - Callback fired when the browser tab is resumed from frozen state.
  LifecycleCallback? get whenResumed => _whenResumed;
  set whenResumed(LifecycleCallback? callback) {
    _whenResumed = callback;
    _syncResumeListener();
  }

  /// {@macro BrowserLifecycle}
  /// - Observes user idle state and triggers [onIdle] callback
  /// after [timeout] duration of inactivity.
  void observeIdleState(
    LifecycleCallback? onIdle, {
    Duration timeout = const Duration(seconds: 30),
  }) {
    _idleCallback = onIdle;
    _idleTimeout = timeout;
    _syncIdleListeners();
  }

  /// {@macro BrowserLifecycle}
  /// - Stops observing user idle state.
  void unobserveIdleState() {
    _idleCallback = null;
    _unlistenIdle();
  }

  /// {@macro BrowserLifecycle}
  /// - Observes size changes of a component.
  void observeComponentSize(
    LifecycleResizeCallback onResize, {
    GlobalNodeKey<HTMLElement>? key,
    String? id,
  }) {
    if (id.isNullOrEmpty && key == null) {
      debugPrint(
        'Component key or id must be provided',
        true,
      );
      return;
    }

    onComponentRendered(() {
      final element = id.isNotNullAndEmpty
          ? document.getElementById(id!)
          : key?.currentNode;

      if (element == null) {
        debugPrint(
          'The component to observe for size change is not found.'
          'Ensure a global node key or unique id assigned to the component '
          'is provided.',
          true,
        );
        return;
      }

      _elementResizeCallbacks[element] = onResize;

      if (_isRegistered) {
        _ensureResizeObserver();
        _resizeObserver?.observe(element);
      }
    });
  }

  /// {@macro BrowserLifecycle}
  /// - Stops observing size changes of a component.
  void unobserveComponentSize({
    GlobalNodeKey<HTMLElement>? key,
    String? id,
  }) {
    if (id.isNullOrEmpty && key == null) {
      debugPrint(
        'Component key or id must be provided',
        true,
      );
      return;
    }

    final element = id.isNotNullAndEmpty
        ? document.getElementById(id!)
        : key?.currentNode;

    if (element != null) {
      _elementResizeCallbacks.remove(element);
      _lastElementSizes.remove(element);
      _resizeObserver?.unobserve(element);

      if (_elementResizeCallbacks.isEmpty) {
        _unlistenResizeObserver();
      }
    }
  }

  /// {@macro BrowserLifecycle}
  /// - Observes viewport visibility state of a component.
  void observeComponentVisibility<T extends HTMLElement>(
    LifecycleValueCallback<bool> onVisible, {
    GlobalNodeKey<T>? key,
    String? id,
  }) {
    if (id.isNullOrEmpty && key == null) {
      debugPrint(
        'Component key or id must be provided',
        true,
      );
      return;
    }

    onComponentRendered(() {
      final element = id.isNotNullAndEmpty
          ? document.getElementById(id!)
          : key?.currentNode;

      if (element == null) {
        debugPrint(
          'The component to observe for viewport visibility is not found.'
          'Ensure a global node key or unique id assigned to the component '
          'is provided.',
          true,
        );
        return;
      }

      _elementVisibilityCallbacks[element] = onVisible;

      if (_isRegistered) {
        _ensureIntersectionObserver();
        _intersectionObserver?.observe(element);
      }
    });
  }

  /// {@macro BrowserLifecycle}
  /// - Stops observing viewport visibility state of a component.
  void unobserveComponentVisibility<T extends HTMLElement>({
    GlobalNodeKey<T>? key,
    String? id,
  }) {
    if (id.isNullOrEmpty && key == null) {
      debugPrint(
        'Component key or id must be provided',
        true,
      );
      return;
    }

    final element = id.isNotNullAndEmpty
        ? document.getElementById(id!)
        : key?.currentNode;

    if (element != null) {
      _elementVisibilityCallbacks.remove(element);
      _lastElementVisibility.remove(element);
      _intersectionObserver?.unobserve(element);

      if (_elementVisibilityCallbacks.isEmpty) {
        _unlistenIntersectionObserver();
      }
    }
  }

  // Subclass APIs //

  /// Called when the page is visible on screen
  /// (e.g. user switch back to the tab).
  @protected
  void handleVisible() => whenVisible?.call();

  /// Called when the page is minimized or hidden from screen
  /// (e.g. user switch to another tab).
  @protected
  void handleInactive() => whenInactive?.call();

  /// Called when the page is closed,
  /// reloaded or navigated away from.
  @protected
  void handleClosed() => whenClosed?.call();

  /// Called when the page is resized.
  @protected
  void handleResize(
    Dim height,
    Dim width,
    Orientation orientation,
  ) => whenResized?.call(height, width, orientation);

  /// Called when the system theme changes.
  @protected
  void handleSystemThemeChange(ThemeMode mode) =>
      whenSystemThemeChanged?.call(mode);

  /// Called when the device comes online or offline.
  @protected
  void handleConnectivityChanged(bool isOnline) =>
      whenConnectivityChanged?.call(isOnline);

  /// Called when the device screen orientation changes.
  @protected
  void handleOrientationChange(Orientation orientation) =>
      whenOrientationChanged?.call(orientation);

  /// Called when the page is frozen by the OS/browser.
  @protected
  void handleFrozen() => whenFrozen?.call();

  /// Called when the page is resumed from a frozen state.
  @protected
  void handleResumed() => whenResumed?.call();

  // Private Fields //

  final List<void Function()> _cleanups = [];
  final List<StreamSubscription<Event>> _subscriptions = [];

  ResizeObserver? _resizeObserver;
  final Map<Element, LifecycleResizeCallback> _elementResizeCallbacks = {};
  final Map<Element, (double, double)> _lastElementSizes = {};

  IntersectionObserver? _intersectionObserver;
  final Map<Element, bool> _lastElementVisibility = {};
  final Map<Element, LifecycleValueCallback<bool>> _elementVisibilityCallbacks =
      {};

  double? _lastWindowWidth;
  double? _lastWindowHeight;

  Timer? _idleTimer;
  LifecycleCallback? _idleCallback;
  Duration _idleTimeout = const Duration(seconds: 30);

  bool _isRegistered = false;

  JSFunction? _visibilityListener;
  StreamSubscription<BeforeUnloadEvent>? _beforeUnloadSub;
  StreamSubscription<Event>? _resizeSub;
  MediaQueryList? _themeQuery;
  JSFunction? _themeListener;
  StreamSubscription<Event>? _onlineSub;
  StreamSubscription<Event>? _offlineSub;
  MediaQueryList? _orientationQuery;
  JSFunction? _orientationListener;
  JSFunction? _freezeListener;
  JSFunction? _resumeListener;
  JSFunction? _resetIdleListener;

  static const _userEvents = [
    'mousemove',
    'keydown',
    'scroll',
    'touchstart',
    'click',
  ];

  void _resetIdleTimer() {
    _idleTimer?.cancel();

    if (_idleCallback != null) {
      _idleTimer = Timer(
        _idleTimeout,
        () => _idleCallback?.call(),
      );
    }
  }

  void _syncVisibilityListener() {
    if (!_isRegistered) return;

    final needsListener = _whenVisible != null || _whenInactive != null;

    if (needsListener && _visibilityListener == null) {
      _visibilityListener = (() {
        if (document.visibilityState == 'visible') {
          handleVisible();
        } else {
          handleInactive();
        }
      }).toJS;

      document.addEventListener(
        'visibilitychange',
        _visibilityListener!,
      );
      _cleanups.add(_unlistenVisibility);
    } else if (!needsListener && _visibilityListener != null) {
      _unlistenVisibility();
    }
  }

  void _unlistenVisibility() {
    if (_visibilityListener != null) {
      document.removeEventListener(
        'visibilitychange',
        _visibilityListener!,
      );
      _cleanups.remove(_unlistenVisibility);
      _visibilityListener = null;
    }
  }

  void _syncClosedListener() {
    if (!_isRegistered) return;

    if (_whenClosed != null && _beforeUnloadSub == null) {
      _beforeUnloadSub = EventStreamProviders.beforeUnloadEvent
          .forTarget(window)
          .listen((_) => handleClosed());

      _subscriptions.add(_beforeUnloadSub!);
    } else if (_whenClosed == null && _beforeUnloadSub != null) {
      _beforeUnloadSub?.cancel();
      _subscriptions.remove(_beforeUnloadSub);
      _beforeUnloadSub = null;
    }
  }

  void _dispatchWindowResize() {
    final width = window.innerWidth.roundDown * 1.0;
    final height = window.innerHeight.roundDown * 1.0;

    if (_lastWindowWidth == width && _lastWindowHeight == height) return;

    _lastWindowWidth = width;
    _lastWindowHeight = height;

    final orientation = width >= height
        ? Orientation.landscape
        : Orientation.portrait;

    handleResize(
      Dim.px(height),
      Dim.px(width),
      orientation,
    );
  }

  void _syncResizeListener() {
    if (!_isRegistered) return;

    if (_whenResized != null && _resizeSub == null) {
      _dispatchWindowResize();

      _resizeSub = EventStreamProviders.resizeEvent.forTarget(window).listen((
        _,
      ) {
        NakiDebounce.run(
          'window_resize_debounce_$hashCode',
          const Duration(milliseconds: 250),
          () => onComponentRendered(
            _dispatchWindowResize,
          ),
        );
      });

      _subscriptions.add(_resizeSub!);
    } else if (_whenResized == null && _resizeSub != null) {
      _resizeSub?.cancel();
      _subscriptions.remove(_resizeSub);
      _resizeSub = null;
    }
  }

  void _syncThemeListener() {
    if (!_isRegistered) return;

    if (_whenSystemThemeChanged != null && _themeListener == null) {
      _themeQuery = window.matchMedia(
        '(prefers-color-scheme: dark)',
      );

      handleSystemThemeChange(
        _themeQuery!.matches ? ThemeMode.dark : ThemeMode.light,
      );

      _themeListener = ((MediaQueryList event) {
        handleSystemThemeChange(
          event.matches ? ThemeMode.dark : ThemeMode.light,
        );
      }).toJS;

      _themeQuery!.addEventListener(
        'change',
        _themeListener!,
      );
      _cleanups.add(_unlistenTheme);
    } else if (_whenSystemThemeChanged == null && _themeListener != null) {
      _unlistenTheme();
    }
  }

  void _unlistenTheme() {
    if (_themeQuery != null && _themeListener != null) {
      _themeQuery!.removeEventListener(
        'change',
        _themeListener!,
      );
      _cleanups.remove(_unlistenTheme);

      _themeQuery = null;
      _themeListener = null;
    }
  }

  void _syncConnectivityListener() {
    if (!_isRegistered) return;

    if (_whenConnectivityChanged != null && _onlineSub == null) {
      _onlineSub = EventStreamProviders.onlineEvent
          .forTarget(window)
          .listen((_) => handleConnectivityChanged(true));

      _offlineSub = EventStreamProviders.offlineEvent
          .forTarget(window)
          .listen((_) => handleConnectivityChanged(false));

      _subscriptions.add(_onlineSub!);
      _subscriptions.add(_offlineSub!);
    } else if (_whenConnectivityChanged == null && _onlineSub != null) {
      _onlineSub?.cancel();
      _offlineSub?.cancel();

      _subscriptions.remove(_onlineSub);
      _subscriptions.remove(_offlineSub);

      _onlineSub = null;
      _offlineSub = null;
    }
  }

  void _syncOrientationListener() {
    if (!_isRegistered) return;

    if (_whenOrientationChanged != null && _orientationListener == null) {
      _orientationQuery = window.matchMedia(
        '(orientation: landscape)',
      );

      handleOrientationChange(
        _orientationQuery!.matches
            ? Orientation.landscape
            : Orientation.portrait,
      );

      _orientationListener = ((MediaQueryList event) {
        handleOrientationChange(
          event.matches ? Orientation.landscape : Orientation.portrait,
        );
      }).toJS;

      _orientationQuery!.addEventListener(
        'change',
        _orientationListener!,
      );
      _cleanups.add(_unlistenOrientation);
    } else if (_whenOrientationChanged == null &&
        _orientationListener != null) {
      _unlistenOrientation();
    }
  }

  void _unlistenOrientation() {
    if (_orientationQuery != null && _orientationListener != null) {
      _orientationQuery!.removeEventListener(
        'change',
        _orientationListener!,
      );
      _cleanups.remove(_unlistenOrientation);

      _orientationQuery = null;
      _orientationListener = null;
    }
  }

  void _syncFreezeListener() {
    if (!_isRegistered) return;

    if (_whenFrozen != null && _freezeListener == null) {
      _freezeListener = (() => handleFrozen()).toJS;
      document.addEventListener('freeze', _freezeListener!);
      _cleanups.add(_unlistenFreeze);
    } else if (_whenFrozen == null && _freezeListener != null) {
      _unlistenFreeze();
    }
  }

  void _unlistenFreeze() {
    if (_freezeListener != null) {
      document.removeEventListener(
        'freeze',
        _freezeListener!,
      );
      _cleanups.remove(_unlistenFreeze);
      _freezeListener = null;
    }
  }

  void _syncResumeListener() {
    if (!_isRegistered) return;

    if (_whenResumed != null && _resumeListener == null) {
      _resumeListener = (() => handleResumed()).toJS;
      document.addEventListener('resume', _resumeListener!);
      _cleanups.add(_unlistenResume);
    } else if (_whenResumed == null && _resumeListener != null) {
      _unlistenResume();
    }
  }

  void _unlistenResume() {
    if (_resumeListener != null) {
      document.removeEventListener(
        'resume',
        _resumeListener!,
      );
      _cleanups.remove(_unlistenResume);
      _resumeListener = null;
    }
  }

  void _syncIdleListeners() {
    if (!_isRegistered) return;

    if (_idleCallback != null && _resetIdleListener == null) {
      _resetIdleTimer();

      _resetIdleListener = (() => _resetIdleTimer()).toJS;

      for (final evt in _userEvents) {
        window.addEventListener(evt, _resetIdleListener!);
      }

      _cleanups.add(_unlistenIdle);
    } else if (_idleCallback == null && _resetIdleListener != null) {
      _unlistenIdle();
    }
  }

  void _unlistenIdle() {
    if (_resetIdleListener != null) {
      for (final evt in _userEvents) {
        window.removeEventListener(
          evt,
          _resetIdleListener!,
        );
      }

      _cleanups.remove(_unlistenIdle);
      _resetIdleListener = null;
      _idleTimer?.cancel();
      _idleTimer = null;
    }
  }

  void _ensureResizeObserver() {
    if (_resizeObserver != null) return;

    _resizeObserver = ResizeObserver(
      ((JSArray<ResizeObserverEntry> entries) {
        final list = entries.toDart;

        for (final entry in list) {
          final element = entry.target;
          final rect = entry.contentRect;

          final width = rect.width.roundDown * 1.0;
          final height = rect.height.roundDown * 1.0;

          final lastSize = _lastElementSizes[element];

          if (lastSize != null &&
              lastSize.$1 == width &&
              lastSize.$2 == height) {
            continue;
          }

          _lastElementSizes[element] = (width, height);

          final orientation = width >= height
              ? Orientation.landscape
              : Orientation.portrait;

          NakiDebounce.run(
            'element_resize_${element.hashCode}',
            const Duration(milliseconds: 150),
            () {
              final fn = _elementResizeCallbacks[element];
              if (fn == null) return;
              onComponentRendered(() {
                fn(Dim.px(height), Dim.px(width), orientation);
              });
            },
          );
        }
      }).toJS,
    );

    _cleanups.add(_unlistenResizeObserver);
  }

  void _unlistenResizeObserver() {
    if (_resizeObserver != null) {
      _resizeObserver?.disconnect();
      _cleanups.remove(_unlistenResizeObserver);
      _resizeObserver = null;
    }
  }

  void _ensureIntersectionObserver() {
    if (_intersectionObserver != null) return;

    _intersectionObserver = IntersectionObserver(
      ((JSArray<IntersectionObserverEntry> entries) {
        final list = entries.toDart;

        for (final entry in list) {
          final element = entry.target;
          final isVisible = entry.isIntersecting;

          final lastVisibility = _lastElementVisibility[element];
          if (lastVisibility == isVisible) continue;

          _lastElementVisibility[element] = isVisible;
          _elementVisibilityCallbacks[element]?.call(
            isVisible,
          );
        }
      }).toJS,
    );

    _cleanups.add(_unlistenIntersectionObserver);
  }

  void _unlistenIntersectionObserver() {
    if (_intersectionObserver != null) {
      _intersectionObserver?.disconnect();
      _cleanups.remove(_unlistenIntersectionObserver);
      _intersectionObserver = null;
    }
  }

  /// Start listening to browser and component events.
  ///
  /// This must not be called within the builder of a component.
  /// It should be called once in the main entry point of a stateful component
  /// or main entry point of the application.
  ///
  /// #### NOTE: Calling this in server environment will throw an exception.
  void register() {
    if (kIsServer) {
      debugPrint(
        'BrowserLifecycle cannot be registered in server-side',
        true,
      );
      return;
    }

    if (_isRegistered) {
      debugPrint(
        'BrowserLifecycle is already registered',
        true,
      );
      return;
    }

    _isRegistered = true;

    _syncIdleListeners();
    _syncVisibilityListener();
    _syncClosedListener();
    _syncResizeListener();
    _syncThemeListener();
    _syncConnectivityListener();
    _syncOrientationListener();
    _syncFreezeListener();
    _syncResumeListener();

    if (_elementResizeCallbacks.isNotEmpty) {
      _ensureResizeObserver();

      for (final element in _elementResizeCallbacks.keys) {
        _resizeObserver?.observe(element);
      }
    }

    if (_elementVisibilityCallbacks.isNotEmpty) {
      _ensureIntersectionObserver();

      for (final element in _elementVisibilityCallbacks.keys) {
        _intersectionObserver?.observe(element);
      }
    }
  }

  /// Stops listening to page and component lifecycle events
  /// and cleans up resources.
  ///
  /// **NOTE:** This method must be called in the [StatefulComponent]'s
  /// `dispose` method.
  void dispose() {
    if (kIsServer || !_isRegistered) return;

    _isRegistered = false;

    for (final subscription in List.of(_subscriptions)) subscription.cancel();
    for (final cleanup in List.of(_cleanups)) cleanup();

    _elementVisibilityCallbacks.clear();
    _elementResizeCallbacks.clear();
    _lastElementVisibility.clear();
    _lastElementSizes.clear();
    _subscriptions.clear();
    _idleTimer?.cancel();
    _cleanups.clear();

    _idleTimer = null;
    _lastWindowWidth = null;
    _lastWindowHeight = null;
    _beforeUnloadSub = null;
    _resizeSub = null;
    _themeQuery = null;
    _onlineSub = null;
    _offlineSub = null;

    _themeListener = null;
    _visibilityListener = null;
    _orientationListener = null;
    _freezeListener = null;
    _resumeListener = null;
    _resetIdleListener = null;
    _orientationQuery = null;
    _resizeObserver = null;
    _intersectionObserver = null;
  }
}
