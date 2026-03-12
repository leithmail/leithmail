import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/build_utils.dart';
import 'package:core/utils/config/env_loader.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/main.dart';
import 'package:tmail_ui_user/main/bindings/main_bindings.dart';
import 'package:tmail_ui_user/main/utils/asset_preloader.dart';
import 'package:tmail_ui_user/main/utils/cozy_integration.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:worker_manager/worker_manager.dart';

Future<void> runTmail() async {
  await runTmailPreload();
  runApp(const TMailApp());
}

Future<void> runTmailPreload() async {
  ThemeUtils.setSystemLightUIStyle();

  await MainBindings().dependencies();
  await HiveCacheConfig.instance.setUp();
  await EnvLoader.loadEnvFile();

  if (PlatformInfo.isWeb) {
    await AssetPreloader.preloadHtmlEditorAssets();
  }

  await HiveCacheConfig.instance.initializeEncryptionKey();
  await Get.find<Executor>().warmUp(log: BuildUtils.isDebugMode);
  await CozyIntegration.integrateCozy();

  if (PlatformInfo.isWeb) {
    setPathUrlStrategy();
  }
}
