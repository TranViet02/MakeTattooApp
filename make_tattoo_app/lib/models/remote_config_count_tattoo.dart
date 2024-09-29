import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  RemoteConfigService() {
    _initRemoteConfig();
  }

  Future<void> _initRemoteConfig() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await _remoteConfig.fetchAndActivate();
  }

  int getImageCount(String category) {
    return _remoteConfig.getInt('${category}_images_count');
  }
}
