import 'package:device_info_plus/device_info_plus.dart';
import 'package:get_it/get_it.dart';

import '../data/repositories/device_health_repository.dart';
import '../data/repositories/firestore_health_repository.dart';
import '../viewmodels/health_viewmodel.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<FirestoreHealthRepository>(
    () => FirestoreHealthRepository(),
  );

  getIt.registerLazySingleton<DeviceHealthRepository>(
    () => DeviceHealthRepository(),
  );

  getIt.registerLazySingleton<DeviceInfoPlugin>(() => DeviceInfoPlugin());

  getIt.registerFactory<HealthViewModel>(
    () => HealthViewModel(
      firestoreRepository: getIt<FirestoreHealthRepository>(),
      deviceHealthRepository: getIt<DeviceHealthRepository>(),
    ),
  );
}
