import 'package:jaspr/dom.dart' hide Padding;
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

import 'showcase.dart';

const _storeProducts = ['Pro Plan (\$19/mo)', 'Team Plan (\$49/mo)'];

/// Showcase tab demonstrating real full-screen [Navigator] flows
/// above [NakiApp] without rendering a [Navigator] inline inside a card.
class NavigatorTab extends StatefulComponent {
  const NavigatorTab({super.key});

  @override
  State<NavigatorTab> createState() => _NavigatorTabState();
}

class _NavigatorTabState extends State<NavigatorTab> {
  final List<String> _events = [
    'Tap "Launch 4-Route Store Flow" to push a full-screen nested Navigator above NakiApp.',
  ];

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  void _log(BuildContext ctx, String message, {bool snackbar = true}) {
    if (!mounted) return;

    setState(() {
      _events.insert(0, message);
      if (_events.length > 5) _events.removeLast();
    });

    if (!snackbar) return;

    showSnackbar(
      ctx,
      Snackbar(
        position: SnackbarPosition.top,
        duration: const Duration(seconds: 3),
        backgroundColor: ctx.primaryColor,
        foregroundColor: Colors.white,
        closeIconColor: Colors.white.withOpacity(80),
        showCloseIcon: true,
        content: NakiText(message),
      ),
    );
  }

  Future<void> _launchStoreFlow(BuildContext ctx) async {
    final result = await Navigator.push<String>(
      ctx,
      NakiPageRoute<String>(
        settings: const NakiRouteSettings(name: '/store-flow'),
        builder: (_) => _StoreNavigatorFlow(
          onEvent: (msg) => _log(ctx, msg, snackbar: false),
        ),
      ),
    );

    _log(ctx, 'Store flow closed with: ${result ?? 'null'}');
  }

  Future<void> _pushStandalonePage(BuildContext ctx) async {
    final result = await Navigator.push<String>(
      ctx,
      NakiPageRoute<String>(
        settings: const NakiRouteSettings(
          name: '/account-settings',
          arguments: 'from NavigatorTab',
        ),
        builder: (routeCtx) => Scaffold(
          appBar: AppBar(
            titleText: 'Account Settings',
            leading: _backButton(
              routeCtx,
              onTap: () => Navigator.pop(routeCtx, 'saved'),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(Dim.px(24)),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: const Dim.percent(100),
                constraints: const SizeConstraints(maxWidth: Dim.px(560)),
                child: Card.outlined(
                  padding: const EdgeInsets.all(Dim.px(20)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      const Heading('Full-screen NakiPageRoute', level: 3),
                      NakiText(
                        'Pushed directly onto NakiApp via Navigator.push(). '
                        'AppShell stays mounted beneath it (canPop: ${Navigator.canPop(routeCtx)}).',
                        style: TextStyle(color: routeCtx.subtitleColor),
                      ),
                      Row(
                        spacing: 8,
                        children: [
                          _showcaseButton(
                            routeCtx,
                            'Save & pop',
                            onTap: () => Navigator.pop(routeCtx, 'saved'),
                          ),
                          _showcaseButton(
                            routeCtx,
                            'Cancel (maybePop)',
                            onTap: () =>
                                Navigator.maybePop(routeCtx, 'cancelled'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    _log(ctx, 'Account Settings returned: ${result ?? 'null'}');
  }

  Future<void> _checkRootCanPop(BuildContext ctx) async {
    final canPop = Navigator.canPop(ctx);
    final didPop = await Navigator.maybePop(ctx);
    _log(ctx, 'Root NakiApp Navigator: canPop=$canPop, maybePop()=$didPop');
  }

  void _tryRootPopWhenEmpty(BuildContext ctx) {
    try {
      Navigator.pop(ctx);
    } on StateError catch (error) {
      _log(ctx, 'Navigator.pop() when !canPop threw: ${error.message}');
    }
  }

  @override
  Component build(BuildContext context) {
    return ShowcaseGroup(
      title: 'Navigator',
      subtitle:
          'Full-screen NakiPageRoutes pushed above NakiApp with nested routing support.',
      demos: [
        Demo(
          name: 'Full-screen routes above NakiApp',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _showcaseButton(
                    context,
                    'Launch 4-Route Store Flow',
                    onTap: () => _launchStoreFlow(context),
                  ),
                  _showcaseButton(
                    context,
                    'Push Full-Screen Route',
                    onTap: () => _pushStandalonePage(context),
                  ),
                  _showcaseButton(
                    context,
                    'Root maybePop (canPop: false)',
                    onTap: () => _checkRootCanPop(context),
                  ),
                  _showcaseButton(
                    context,
                    'Root pop() when !canPop',
                    destructive: true,
                    onTap: () => _tryRootPopWhenEmpty(context),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  border: BorderData(
                    color: context.borderColor,
                    width: const Dim.px(1),
                  ),
                  borderRadius: BorderRadiusData.all(const Dim.px(8)),
                  padding: const EdgeInsets.all(Dim.px(10)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 4,
                  children: [
                    NakiText(
                      'Navigation log',
                      style: TextStyle(
                        fontSize: const Dim.rem(0.78),
                        fontWeight: FontWeight.w600,
                        color: context.textColor,
                      ),
                    ),
                    for (final event in _events)
                      NakiText(
                        event,
                        style: TextStyle(
                          fontSize: const Dim.rem(0.78),
                          color: context.subtitleColor,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Full-screen nested [Navigator] managing 4 [NakiPageRoute]
/// screens above [NakiApp]: `/catalog` -> `/product` -> `/checkout`
/// -> `/receipt`.
class _StoreNavigatorFlow extends StatefulComponent {
  const _StoreNavigatorFlow({required this.onEvent});

  final void Function(String message) onEvent;

  @override
  State<_StoreNavigatorFlow> createState() => _StoreNavigatorFlowState();
}

class _StoreNavigatorFlowState extends State<_StoreNavigatorFlow> {
  final List<String> _trace = [
    'Entered Store Flow on /catalog (nested Navigator canPop=false).',
  ];

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  void _record(BuildContext ctx, String message, {bool notify = true}) {
    component.onEvent(message);

    setState(() {
      _trace.insert(0, message);
      if (_trace.length > 5) _trace.removeLast();
    });

    if (!notify) return;

    showSnackbar(
      ctx,
      Snackbar(
        position: SnackbarPosition.top,
        duration: const Duration(seconds: 2),
        backgroundColor: ctx.primaryColor,
        foregroundColor: Colors.white,
        closeIconColor: Colors.white.withOpacity(80),
        showCloseIcon: true,
        content: NakiText(message),
      ),
    );
  }

  Future<void> _track(
    BuildContext ctx,
    String action,
    Future<String?> future,
  ) async {
    _record(ctx, '$action -> opened', notify: false);
    final result = await future;
    if (!mounted) return;

    _record(
      ctx,
      '$action -> returned (${result ?? 'null'})',
      notify: false,
    );
  }

  NakiRoute<dynamic>? _onGenerateRoute(NakiRouteSettings settings) {
    return switch (settings.name) {
      '/catalog' => NakiPageRoute<String>(
        settings: settings,
        builder: _catalogPage,
      ),
      '/product' => NakiPageRoute<String>(
        settings: settings,
        builder: _productPage,
      ),
      '/checkout' => NakiPageRoute<String>(
        settings: settings,
        builder: _checkoutPage,
      ),
      '/receipt' => NakiPageRoute<String>(
        settings: settings,
        builder: _receiptPage,
      ),
      _ => null,
    };
  }

  void _exitFlow(BuildContext ctx, String reason) {
    Navigator.of(ctx, rootNavigator: true).pop(reason);
  }

  void _openProduct(BuildContext ctx, String product) => _track(
    ctx,
    'push(/product)',
    Navigator.push<String>(
      ctx,
      NakiPageRoute<String>(
        settings: NakiRouteSettings(name: '/product', arguments: product),
        builder: _productPage,
      ),
    ),
  );

  void _openCheckout(
    BuildContext ctx,
    String product, {
    bool replace = false,
  }) {
    final label = replace
        ? 'pushReplacementNamed(/checkout)'
        : 'pushNamed(/checkout)';

    final future = replace
        ? Navigator.pushReplacementNamed<String, String>(
            ctx,
            '/checkout',
            result: 'replaced-by-checkout',
            arguments: product,
          )
        : Navigator.pushNamed<String>(ctx, '/checkout', arguments: product);

    _track(ctx, label, future);
  }

  void _openReceipt(
    BuildContext ctx,
    String product, {
    required bool replace,
  }) {
    if (replace) {
      _track(
        ctx,
        'pushReplacement(/receipt)',
        Navigator.pushReplacement<String, String>(
          ctx,
          NakiPageRoute<String>(
            settings: NakiRouteSettings(name: '/receipt', arguments: product),
            builder: _receiptPage,
          ),
          result: 'order-placed',
        ),
      );

      return;
    }

    _track(
      ctx,
      'pushNamed(/receipt)',
      Navigator.pushNamed<String>(ctx, '/receipt', arguments: product),
    );
  }

  void _tryPop(BuildContext ctx, [String? result]) {
    try {
      Navigator.pop(ctx, result);
      _record(ctx, 'pop(${result ?? 'null'}) -> popped route', notify: false);
    } on StateError catch (error) {
      _record(ctx, 'pop() when !canPop threw: ${error.message}');
    }
  }

  Future<void> _tryMaybePop(BuildContext ctx, [String? result]) async {
    final didPop = await Navigator.maybePop<String>(ctx, result);
    if (mounted) {
      _record(
        ctx,
        'maybePop() -> $didPop (canPop was $didPop)',
        notify: !didPop,
      );
    }
  }

  void _popUntil(BuildContext ctx, String targetRoute) {
    Navigator.popUntil(ctx, Navigator.withName(targetRoute));
    _record(ctx, "popUntil(withName('$targetRoute'))", notify: false);
  }

  void _resetToCatalog(BuildContext ctx) {
    Navigator.pushNamedAndRemoveUntil<String>(ctx, '/catalog', (_) => false);
    _record(
      ctx,
      "pushNamedAndRemoveUntil('/catalog', (_) => false)",
      notify: false,
    );
  }

  Future<void> _confirmLeaveProduct(BuildContext ctx) async {
    final leave = await showDialog<bool>(
      context: ctx,
      title: 'Leave product?',
      subtitle: 'Navigator.pop closes this dialog before popping /product.',
      barrierDismissible: true,
      actions: (dialogCtx) => [
        _showcaseButton(
          dialogCtx,
          'Stay',
          onTap: () => Navigator.pop(dialogCtx, false),
        ),
        _showcaseButton(
          dialogCtx,
          'Leave',
          destructive: true,
          onTap: () => Navigator.pop(dialogCtx, true),
        ),
      ],
    );

    if (!mounted) return;

    if (leave == true && Navigator.canPop(ctx)) {
      Navigator.pop(ctx, 'discarded');
    } else {
      _record(ctx, 'Dialog closed -> stayed on /product', notify: false);
    }
  }

  Component _flowScaffold(
    BuildContext ctx, {
    required String appBarTitle,
    required String stepLabel,
    required String heading,
    required String summary,
    required List<Component> actions,
  }) {
    final canPopLocal = Navigator.canPop(ctx);
    final route = NakiRoute.maybeOf(ctx);

    return Scaffold(
      appBar: AppBar(
        titleText: appBarTitle,
        leading: canPopLocal
            ? _backButton(ctx, onTap: () => Navigator.pop(ctx, 'back'))
            : null,
        actions: [
          _showcaseButton(
            ctx,
            'Close Flow',
            onTap: () => _exitFlow(ctx, 'Closed from ${route?.settings.name}'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dim.px(24)),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: const Dim.percent(100),
            constraints: const SizeConstraints(maxWidth: Dim.px(560)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                Card.outlined(
                  padding: const EdgeInsets.all(Dim.px(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          NakiText(
                            stepLabel,
                            style: TextStyle(
                              fontSize: const Dim.rem(0.85),
                              fontWeight: FontWeight.w600,
                              color: ctx.primaryColor,
                            ),
                          ),
                          NakiText(
                            'canPop: $canPopLocal',
                            style: TextStyle(
                              fontSize: const Dim.rem(0.85),
                              fontWeight: FontWeight.w600,
                              color: canPopLocal
                                  ? ctx.primaryColor
                                  : ctx.subtitleColor,
                            ),
                          ),
                        ],
                      ),
                      Heading(heading, level: 2),
                      NakiText(
                        'route: ${route?.settings.name ?? '/'}  •  '
                        'args: ${route?.settings.arguments ?? 'none'}',
                        style: TextStyle(
                          fontSize: const Dim.rem(0.85),
                          color: ctx.subtitleColor,
                        ),
                      ),
                      NakiText(
                        summary,
                        style: TextStyle(color: ctx.subtitleColor),
                      ),
                      Wrap(spacing: 8, runSpacing: 8, children: actions),
                    ],
                  ),
                ),

                Card.outlined(
                  padding: const EdgeInsets.all(Dim.px(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      NakiText(
                        'Flow activity',
                        style: TextStyle(
                          fontSize: const Dim.rem(0.8),
                          fontWeight: FontWeight.w600,
                          color: ctx.textColor,
                        ),
                      ),
                      for (final item in _trace)
                        NakiText(
                          item,
                          style: TextStyle(
                            fontSize: const Dim.rem(0.8),
                            color: ctx.subtitleColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Route 1 of 4: /catalog
  Component _catalogPage(BuildContext ctx) => _flowScaffold(
    ctx,
    appBarTitle: 'Store Catalog',
    stepLabel: 'NakiPageRoute 1 / 4',
    heading: 'Choose a plan',
    summary:
        'Root route of the nested Navigator. Calling local Navigator.pop() '
        'when canPop is false throws a StateError, whereas rootNavigator: true '
        'exits the entire store flow back to NakiApp.',
    actions: [
      for (final product in _storeProducts)
        _showcaseButton(
          ctx,
          'View $product',
          onTap: () => _openProduct(ctx, product),
        ),
      _showcaseButton(
        ctx,
        'Quick Checkout (pushNamed)',
        onTap: () => _openCheckout(ctx, _storeProducts.first),
      ),
      _showcaseButton(
        ctx,
        'maybePop() when !canPop',
        onTap: () => _tryMaybePop(ctx),
      ),
      _showcaseButton(
        ctx,
        'pop() when !canPop (throws)',
        destructive: true,
        onTap: () => _tryPop(ctx),
      ),
    ],
  );

  // Route 2 of 4: /product
  Component _productPage(BuildContext ctx) {
    final product =
        (NakiRoute.maybeOf(ctx)?.settings.arguments as String?) ??
        _storeProducts.first;

    return _flowScaffold(
      ctx,
      appBarTitle: 'Product Details',
      stepLabel: 'NakiPageRoute 2 / 4',
      heading: product,
      summary:
          'Pushed via Navigator.push(NakiPageRoute). Checkout keeps /product '
          'in history; Buy Now calls pushReplacementNamed so popping from '
          'Checkout returns straight to /catalog.',
      actions: [
        _showcaseButton(
          ctx,
          'Checkout (pushNamed)',
          onTap: () => _openCheckout(ctx, product),
        ),
        _showcaseButton(
          ctx,
          'Buy Now (pushReplacementNamed)',
          onTap: () => _openCheckout(ctx, product, replace: true),
        ),
        _showcaseButton(
          ctx,
          'Leave Dialog + pop',
          onTap: () => _confirmLeaveProduct(ctx),
        ),
        _showcaseButton(
          ctx,
          "pop('viewed')",
          destructive: true,
          onTap: () => _tryPop(ctx, 'viewed'),
        ),
      ],
    );
  }

  // Route 3 of 4: /checkout
  Component _checkoutPage(BuildContext ctx) {
    final product =
        (NakiRoute.maybeOf(ctx)?.settings.arguments as String?) ??
        _storeProducts.first;

    return _flowScaffold(
      ctx,
      appBarTitle: 'Checkout',
      stepLabel: 'NakiPageRoute 3 / 4',
      heading: 'Review $product',
      summary:
          'Place Order uses Navigator.pushReplacement so hitting Back on the '
          'receipt does not revisit payment submission. Preview Receipt keeps '
          '/checkout on the stack so you can test multi-route popUntil.',
      actions: [
        _showcaseButton(
          ctx,
          'Place Order (pushReplacement)',
          onTap: () => _openReceipt(ctx, product, replace: true),
        ),
        _showcaseButton(
          ctx,
          'Preview Receipt (pushNamed)',
          onTap: () => _openReceipt(ctx, product, replace: false),
        ),
        _showcaseButton(
          ctx,
          "maybePop('cancelled')",
          onTap: () => _tryMaybePop(ctx, 'cancelled'),
        ),
        _showcaseButton(
          ctx,
          "popUntil('/catalog')",
          onTap: () => _popUntil(ctx, '/catalog'),
        ),
      ],
    );
  }

  // Route 4 of 4: /receipt
  Component _receiptPage(BuildContext ctx) {
    final product =
        (NakiRoute.maybeOf(ctx)?.settings.arguments as String?) ??
        _storeProducts.first;

    return _flowScaffold(
      ctx,
      appBarTitle: 'Order Receipt',
      stepLabel: 'NakiPageRoute 4 / 4',
      heading: 'Confirmed: $product',
      summary:
          'Unwind back to /catalog or /product with Navigator.popUntil, reset '
          'with pushNamedAndRemoveUntil, or exit back to AppShell via '
          'rootNavigator: true.',
      actions: [
        _showcaseButton(
          ctx,
          "popUntil('/catalog')",
          onTap: () => _popUntil(ctx, '/catalog'),
        ),
        _showcaseButton(
          ctx,
          "popUntil('/product')",
          onTap: () => _popUntil(ctx, '/product'),
        ),
        _showcaseButton(
          ctx,
          'pushNamedAndRemoveUntil(/catalog)',
          onTap: () => _resetToCatalog(ctx),
        ),
        _showcaseButton(
          ctx,
          'Exit Flow (rootNavigator)',
          onTap: () => _exitFlow(ctx, 'Completed purchase: $product'),
        ),
        _showcaseButton(
          ctx,
          "pop('done')",
          destructive: true,
          onTap: () => _tryPop(ctx, 'done'),
        ),
      ],
    );
  }

  @override
  Component build(BuildContext context) {
    return Navigator(
      initialRoute: '/catalog',
      onGenerateRoute: _onGenerateRoute,
    );
  }
}

Component _backButton(BuildContext ctx, {required VoidCallback onTap}) {
  return Button.icon(
    MaterialIcons.icon_round_arrow_back,
    semanticLabel: 'Back',
    backgroundColor: Colors.transparent,
    foregroundColor: ctx.textColor,
    border: const BorderData.only(radius: BorderRadiusData.circular),
    onTap: onTap,
  );
}

Component _showcaseButton(
  BuildContext ctx,
  String label, {
  required VoidCallback onTap,
  bool destructive = false,
}) {
  return Button.text(
    label,
    padding: const EdgeInsets.symmetric(horizontal: Dim.px(12)),
    backgroundColor: destructive ? Colors.red : null,
    foregroundColor: destructive ? Colors.white : null,
    onTap: onTap,
  );
}
