import 'package:atc_mobile_app/contracts/api_service_contract.dart';
//import 'package:atc_mobile_app/contracts/notification_service_contract.dart';
import 'package:atc_mobile_app/contracts/local_storage_service_contract.dart';
import 'package:atc_mobile_app/route/route_main.dart';
import 'package:atc_mobile_app/services/api_service.dart';
import 'package:atc_mobile_app/services/azure_api_service.dart';
//import 'package:atc_mobile_app/services/notification_service.dart';
import 'package:atc_mobile_app/services/local_storage_service.dart';
import 'package:atc_mobile_app/view_models/app_hub_view_model.dart';
import 'package:atc_mobile_app/view_models/class_view_model.dart';
import 'package:atc_mobile_app/view_models/home_view_model.dart';
import 'package:atc_mobile_app/view_models/programs_view_model.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';

//TODO: Maybe refactor this into the main class???

/// This route describes the loading phase of the application.
/// 
/// All preprocessors will be completed in this class before the route is
/// switched to the main route. All dependencies are loaded in this class.
class RouteSplash extends StatefulWidget {
  const RouteSplash({super.key});

  @override
  State<RouteSplash> createState() => _RouteSplashState();
}

class _RouteSplashState extends State<RouteSplash> {
  /// Number of preprocesses that have completed.
  var _preprocessProgress = 0;

  /// Number of preprocesses that must be completed to continue.
  static const _numPreprocesses = 2;

  //FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  GetIt getIt = GetIt.instance;

  _registerServices() {
    getIt.registerSingleton<ApiServiceContract>(AzureApiService());
    //getIt.registerSingleton<NotificationServiceContract>(NotificationService());
    getIt.registerSingleton<LocalStorageServiceContract>(LocalStorageService());

    setState(() {
      _preprocessProgress++;
    });
  }

  _registerViewModels() {
    getIt.registerSingleton<HomeViewModel>(HomeViewModel());
    getIt.registerSingleton<ProgramsViewModel>(ProgramsViewModel());
    getIt.registerSingleton<ProgramViewModel>(ProgramViewModel());
    getIt.registerSingleton<AppHubViewModel>(AppHubViewModel());

    setState(() {
      _preprocessProgress++;
    });
  }

  @override
  void initState() {
    super.initState();

    _registerServices();
    _registerViewModels();

    //getIt.registerSingleton<FlutterLocalNotificationsPlugin>(notificationsPlugin);
  }

  @override
  Widget build(BuildContext context) {
    return _preprocessProgress == _numPreprocesses 
      ? const RouteMain() 
      : const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
  }
}

