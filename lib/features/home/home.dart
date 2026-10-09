import 'package:arpicoiam/iam.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/route_paths.dart';
import '../../helpers/number_helper.dart';
import '../../helpers/responsive.dart';
import '../../services/database/db_columns.dart';
import '../../services/database/db_helper.dart';
import '../../services/database/db_tables.dart';
import '../../services/database/repositories/collection_db_repository.dart';
import '../../services/database/repositories/visit_location_db_repository.dart';
import '../../shared/components/app/app_exit_handler.dart';
import 'drawer.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  static final RouteObserver<PageRoute> routeObserver =
  RouteObserver<PageRoute>();

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver, RouteAware {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  UserModel? _currentUser;
  int _todayCollections = 0;
  double _todayCollectionAmount = 0;
  int _todayVisits = 0;
  List<Map<String, dynamic>> _collectionSummary = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    HomeView.routeObserver.subscribe(
      this,
      ModalRoute.of(context) as PageRoute,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  @override
  void didPopNext() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _currentUser = await IAMService.instance.currentUser();

      if(_currentUser == null){
        return;
      }

      // Today's collection count and amount
      final todayHeaders =
          await CollectionDbRepository.getTodayCollections(
            _currentUser!,
          );
      _todayCollections = todayHeaders.length;
      _todayCollectionAmount = todayHeaders.fold<double>(
        0.0,
        (sum, h) => sum + ((h.totalAmount as num?)?.toDouble() ?? 0.0),
      );

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Collection summary by pay mode
      _collectionSummary = await DBHelper.query(
        DBTables.COLLECTION_HEADERS,
        columns: [
          DBColumns.PAY_MODE,
          'SUM(${DBColumns.TOTAL_AMOUNT}) as total',
          'COUNT(*) as count',
        ],
        where:
        '${DBColumns.SBU_CODE} = ? AND ${DBColumns.LOC_CODE} = ? AND ${DBColumns.CREATED_BY} = ? AND ${DBColumns.TXN_DATE} = ?',
        whereArgs: [_currentUser!.sbuCode, _currentUser!.locCode, _currentUser!.userId, today],
        groupBy: DBColumns.PAY_MODE
      );

      // Today's visit count
      _todayVisits = await VisitLocationDbRepository.getTodayCount(_currentUser!);

    } catch (e) {
      debugPrint('Dashboard load error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppExitHandler(
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: const Text('Sales Force Tyres'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
          ],
        ),
        drawer: HomeDrawer(
            afterRouteCompleted: () => scaffoldKey.currentState?.closeDrawer(),
            currentUser: _currentUser
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(cs),
                const SizedBox(height: 20),
                _buildQuickActions(cs),
                const SizedBox(height: 20),
                _buildStatCards(cs),
                const SizedBox(height: 20),
                if (_collectionSummary.isNotEmpty) ...[
                  _buildCollectionChart(cs),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(ColorScheme cs) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: TextStyle(
              color: cs.onPrimary.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currentUser?.userName ?? _currentUser?.userId ?? 'User',
            style: TextStyle(
              color: cs.onPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Have a great day at work!',
            style: TextStyle(
              color: cs.onPrimary.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ColorScheme cs) {
    final quickActions = [
      // QuickAction(
      //   icon: Icons.receipt_long,
      //   label: 'Collections',
      //   color: cs.primary,
      //   onTap: () => Navigator.of(context).pushNamed(RoutePaths.collections),
      // ),
      QuickAction(
        icon: Icons.list_alt_rounded,
        label: 'Collections',
        color: Colors.blue,
        onTap: () => Navigator.of(context).pushNamed(RoutePaths.startCollection),
      ),
      // QuickAction(
      //   icon: Icons.upload_file_outlined,
      //   label: 'Bank Deposits',
      //   color: Colors.purple,
      //   onTap: () => Navigator.of(context).pushNamed(RoutePaths.bankDeposits),
      // ),
      QuickAction(
        icon: Icons.location_on,
        label: 'Visits',
        color: Colors.green,
        onTap: () => Navigator.of(context).pushNamed(RoutePaths.visitLocations),
      ),
      QuickAction(
        icon: Icons.manage_search,
        label: 'Inquiries',
        color: Colors.orange,
        onTap: () => Navigator.of(context).pushNamed(RoutePaths.inquiries),
      ),
    ];

    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        width: .infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.of(context).isPhone ? 3 : 5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),

              itemCount: quickActions.length,
              itemBuilder: (context, index) {
                final item = quickActions[index];

                return _buildQuickActionButton(
                  icon: item.icon,
                  label: item.label,
                  color: item.color,
                  onTap: item.onTap,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      // overlayColor: .all(Colors.red),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: .center,
              maxLines: 2,
              overflow: .ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(ColorScheme cs) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.attach_money,
            title: 'Today Collections',
            value: _todayCollections.toString(),
            subtitle: NumberHelper.formatCurrency(_todayCollectionAmount),
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.location_on,
            title: 'Today Visits',
            value: _todayVisits.toString(),
            subtitle: 'Today',
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionChart(ColorScheme cs) {
    // Build bar chart data from collection summary
    final barGroups = <BarChartGroupData>[];
    final labels = <String>[];
    double maxY = 0;

    for (int i = 0; i < _collectionSummary.length; i++) {
      final row = _collectionSummary[i];
      final payMode = row[DBColumns.PAY_MODE]?.toString() ?? 'Unknown';
      final total = (row['total'] as num?)?.toDouble() ?? 0;
      if (total > maxY) maxY = total;

      labels.add(payMode);
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: total,
              color: cs.primary,
              width: 20,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Collections by Payment Mode",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${labels[group.x]}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: NumberHelper.formatCurrency(rod.toY),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[index],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            NumberHelper.formatCompact(value),
                            style: TextStyle(
                              fontSize: 10,
                              color: cs.onSurfaceVariant,
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY > 0 ? maxY / 4 : 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: cs.outlineVariant,
                      strokeWidth: 0.5,
                    ),
                  ),
                  barGroups: barGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
