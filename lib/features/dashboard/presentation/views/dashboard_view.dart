import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../helpers/responsive.dart';
import '../../../../shared/components/app/app_exit_handler.dart';
import '../../../home/drawer.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/activity_overview_card.dart';
import '../widgets/daily_status_card.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/dashboard_user_header.dart';
import '../widgets/payment_breakdown_card.dart';
import '../widgets/quick_access_section.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  /// Register on `MaterialApp.navigatorObservers` (unchanged from before).
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with WidgetsBindingObserver, RouteAware {
  static const double _tabletMaxContentWidth = 1200;
  static const double _tabletToolbarHeight = 72;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = DashboardController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      DashboardView.routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    DashboardView.routeObserver.unsubscribe(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _controller.load();
  }

  /// Returning from another screen refreshes the numbers.
  @override
  void didPopNext() => _controller.load();

  void _open(String routeName) => Navigator.of(context).pushNamed(routeName);

  List<QuickAction> _buildActions() => [
        QuickAction(
          icon: Icons.list_alt_rounded,
          label: 'Collections',
          color: AppColors.info,
          onTap: () => _open(RoutePaths.startCollection),
        ),
        QuickAction(
          icon: Icons.list_alt_rounded,
          label: 'Collections New',
          color: AppColors.info,
          onTap: () => _open(RoutePaths.receivePayment),
        ),
        QuickAction(
          icon: Icons.location_on,
          label: 'Visits',
          color: AppColors.success,
          onTap: () => _open(RoutePaths.visitLocations),
        ),
        QuickAction(
          icon: Icons.manage_search,
          label: 'Inquiries',
          color: AppColors.warning,
          onTap: () => _open(RoutePaths.inquiries),
        ),
      ];

  String get _dateLabel =>
      'Today • ${DateFormat('MMM d, yyyy').format(DateTime.now())}';

  @override
  Widget build(BuildContext context) {
    final isPhone = Responsive.of(context).isPhone;
    debugPrint('Width: ${Responsive.of(context).width} , Height: ${Responsive.of(context).height}');

    return AppExitHandler(
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final actions = _buildActions();

          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: AppColors.background,
            appBar: DashboardAppBar(
              userName: _controller.displayName,
              onRefresh: _controller.load,
              showUserChip: !isPhone,
              toolbarHeight: isPhone ? kToolbarHeight : _tabletToolbarHeight,
            ),
            drawer: HomeDrawer(
              afterRouteCompleted: () =>
                  _scaffoldKey.currentState?.closeDrawer(),
              currentUser: _controller.currentUser,
            ),
            bottomNavigationBar:
                isPhone ? DashboardBottomNav(actions: actions) : null,
            body: _controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _controller.load,
                    child: isPhone
                        ? _buildPhoneBody(actions)
                        : _buildTabletBody(actions),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildPhoneBody(List<QuickAction> actions) {
    final summary = _controller.summary;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardUserHeader(
            userName: _controller.displayName,
            dateLabel: _dateLabel,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DailyStatusCard(summary: summary, isPhone: true),
                const SizedBox(height: 16),
                QuickAccessSection(actions: actions, isPhone: true),
                if (summary.hasPaymentBreakdown) ...[
                  const SizedBox(height: 16),
                  PaymentBreakdownCard(
                    breakdown: summary.paymentBreakdown,
                    chartHeight: 180,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletBody(List<QuickAction> actions) {
    final summary = _controller.summary;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _tabletMaxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _dateLabel,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              DailyStatusCard(summary: summary, isPhone: false),
              const SizedBox(height: 24),
              QuickAccessSection(actions: actions, isPhone: false),
              const SizedBox(height: 24),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: ActivityOverviewCard(summary: summary)),
                    if (summary.hasPaymentBreakdown) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: PaymentBreakdownCard(
                          breakdown: summary.paymentBreakdown,
                          chartHeight: 220,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
