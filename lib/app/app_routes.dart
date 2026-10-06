import 'package:arpicoiam/iam.dart';
import '../app/route_paths.dart';

import '../features/app/landing.dart';
import '../features/collections/start_collection.dart';
import '../features/collections/invoice_setoff_view.dart';
import '../features/home/home.dart';
import '../features/inquiries/bank_deposit_inquiry.dart';
import '../features/inquiries/inquiries.dart';
import '../features/inquiries/visit_inquiry.dart';
import '../features/inquiries/collection_inquiry.dart';
import '../features/inquiries/invoice_inquiry.dart';
import '../features/backup_restore/backup_restore.dart';
import '../features/collections/bank_deposits.dart';
import '../features/downloads/downloads.dart';
import '../features/profile/profile.dart';
import '../features/settings/settings.dart';
import '../features/support/about_us.dart';
import '../features/support/contact_support.dart';
import '../features/sync/sync.dart';
import '../features/tasks/tasks.dart';
import '../features/visit_locations/visit_locations.dart';

class AppRoutes {
  AppRoutes._();

  static List<IAMRoute> get all => [
    IAMRoute(
      path: RoutePaths.landing,
      builder: (context, params) => const LandingView(),
    ),
    IAMRoute(
      protected: true,
      path: RoutePaths.home,
      builder: (context, params) => const HomeView(),
    ),
    IAMRoute(
      protected: true,
      path: RoutePaths.downloads,
      builder: (context, params) => const DownloadsView(),
    ),
    IAMRoute(
      protected: true,
      path: RoutePaths.sync,
      builder: (context, params) => const SyncView(),
    ),
    IAMRoute(
      protected: false,
      path: RoutePaths.backupRestore,
      builder: (context, params) => const BackupRestoreView(),
    ),
    IAMRoute(
      protected: false,
      path: RoutePaths.startCollection,
      builder: (context, params) => const StartCollection(),
    ),
    IAMRoute(
      protected: false,
      path: RoutePaths.receiptSetOff,
      builder: (context, params) => const InvoiceSetOffView(),
    ),
    IAMRoute(
      protected: true,
      path: RoutePaths.bankDeposits,
      builder: (context, params) => const BankDeposits(),
    ),
    IAMRoute(
      protected: false,
      path: RoutePaths.visitLocations,
      builder: (context, params) => const VisitLocationsView(),
    ),
    IAMRoute(
      protected: false,
      path: RoutePaths.inquiries,
      builder: (context, params) => const InquiriesView(),
    ),
    IAMRoute(
      protected: true,
      path: RoutePaths.visitInquiry,
      builder: (context, params) => const VisitInquiryView(),
    ),
    IAMRoute(
      protected: true,
      path: RoutePaths.collectionInquiry,
      builder: (context, params) => const CollectionInquiryView(),
    ),
    IAMRoute(
      protected: true,
      path: RoutePaths.invoiceInquiry,
      builder: (context, params) => const InvoiceInquiryView(),
    ),
    IAMRoute(
      protected: true,
      path: RoutePaths.bankDepositInquiry,
      builder: (context, params) => const BankDepositInquiryView(),
    ),
    IAMRoute(
      protected: true,
      path: RoutePaths.tasks,
      builder: (context, params) => const TasksView(),
    ),
    IAMRoute(
      protected: false,
      path: RoutePaths.profile,
      builder: (context, params) => const ProfileView(),
    ),
    IAMRoute(
      protected: false,
      path: RoutePaths.settings,
      builder: (context, params) => const SettingsView(),
    ),
    IAMRoute(
      protected: false,
      path: RoutePaths.contactSupport,
      builder: (context, params) => const ContactSupportView(),
    ),
    IAMRoute(
      protected: false,
      path: RoutePaths.aboutUs,
      builder: (context, params) => const AboutUsView(),
    ),
  ];
}
