import 'package:arpicoiam/iam.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../config/app_config.dart';
import '../../app/route_paths.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(RoutePaths.home, (route) => false);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: AppLogo(
          source: 'assets/icons/logo.png',
          size: MediaQuery.of(context).size.width * 0.5,
        ),
      ),
      bottomNavigationBar: Container(
        height: kMinInteractiveDimension * 2,
        padding: MediaQuery.of(context).viewPadding,
        alignment: Alignment.center,
        child: FutureBuilder(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return const CircularProgressIndicator();
            }
            return Row(
              mainAxisAlignment: .center,
                children: [
              Text('Powered by ${AppConfig.info.poweredBy}', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              SizedBox(
                  height: 14,
                  child: VerticalDivider(
                    width: 12,
                  )
              ),
              Text('Version ${snapshot.data?.version} + ${snapshot.data?.buildNumber}', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant))
            ]);
          },
        ),
      ),
    );
  }
}
