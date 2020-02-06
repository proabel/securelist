import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securelist/providers/appState.dart';

class BgLocationService with ChangeNotifier {
  List _places = [];
   //final _appState = AppState();
    //
    // 2.  Configure the plugin
    //
  List get places => _places;
    void configAndStart(){
       bg.BackgroundGeolocation.onLocation((bg.Location location) {
         _places.add('onLoc ' + location.coords.latitude.toString() + ' / '  + location.coords.latitude.toString() + '\n');
          print('got on location');
          print('[location] - $location');
          notifyListeners();
        });

        // Fired whenever the plugin changes motion-state (stationary->moving and vice-versa)
        bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
         _places.add('onChange ' + location.coords.latitude.toString() + ' / '  + location.coords.latitude.toString() + '\n');
          print('motion detected');
          print('[motionchange] - $location');
          notifyListeners();
        });

        // Fired whenever the state of location-services changes.  Always fired at boot
        bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
          print('[providerchange] - $event');
        });

      bg.BackgroundGeolocation.ready(bg.Config(
          enableHeadless: true,
          desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
          distanceFilter: 10.0,
          stopOnTerminate: false,
          startOnBoot: true,
          debug: true,
          logLevel: bg.Config.LOG_LEVEL_VERBOSE
      )).then((bg.State state) {
        if (!state.enabled) {
          ////
          // 3.  Start the plugin.
          //
          print('starting loc plugin');
          bg.BackgroundGeolocation.start();
        }
      });
    }
}