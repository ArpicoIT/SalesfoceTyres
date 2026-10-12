import 'package:arpicoiam/iam.dart';
import 'package:flutter/foundation.dart';

import '../../data/dashboard_repository.dart';
import '../../data/dashboard_summary.dart';

/// Holds dashboard state; the view only listens and renders.
class DashboardController extends ChangeNotifier {
  DashboardController({
    DashboardRepository repository = const DashboardRepository(),
  }) : _repository = repository;

  final DashboardRepository _repository;

  UserModel? _currentUser;
  DashboardSummary _summary = DashboardSummary.empty;
  bool _isLoading = true;
  bool _isDisposed = false;

  UserModel? get currentUser => _currentUser;
  DashboardSummary get summary => _summary;
  bool get isLoading => _isLoading;

  String get displayName =>
      _currentUser?.userName ?? _currentUser?.userId ?? 'User';

  Future<void> load() async {
    try {
      _currentUser = await IAMService.instance.currentUser();
      final user = _currentUser;
      if (user == null) return;

      _summary = await _repository.loadTodaySummary(user);
    } catch (e) {
      debugPrint('Dashboard load error: $e');
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
