import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi_hunter/wifi_hunter.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:io';

void main() {
  runApp(Theme(
    data: ThemeData(
      textTheme: const TextTheme( // Text theme for all text styles
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white), // Set your desired color
        // ... other text styles (e.g., headline, subtitle, etc.)
      ),
    ),
    child: MyApp(), // Your app's main widget
  ));
}


 class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  WiFiHunterResult wiFiHunterResult = WiFiHunterResult();
  Future<void> access() async {
      if (Platform.isAndroid) {
      var status = await Permission.locationWhenInUse.request();
      if (!status.isGranted) {
        // permission 
        return;
      }
      
    }
}
Future<bool> checkLocationEnabled() async {
  final serviceStatus = await Permission.locationWhenInUse.serviceStatus;
  return serviceStatus.isEnabled;
}
late bool locationenabled;
Future<void> setlocationenable() async{
       locationenabled= await checkLocationEnabled();
}
  @override
  void initState() {
    super.initState();
    access();
  }
  Future<void> reff() async{
    setlocationenable();
                  if (!locationenabled) {
                    return;
                  }
                  else{
                    _huntWiFis();
                    return ;
                  }
  }
  Future<void> _huntWiFis() async {
    try {
      wiFiHunterResult = (await WiFiHunter.huntWiFiNetworks)!;
      setState(() {}); // Update UI with new results
    } on PlatformException catch (error) {
      // Handle errors gracefully, e.g., display an error message
      print('Erreur: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:"Scanner Wi-Fi",
      debugShowCheckedModeBanner: false,
      theme:  ThemeData(scaffoldBackgroundColor: const Color(0xFFFFFFFF), ),
      home: Scaffold(
        
        appBar: AppBar(
          backgroundColor: const Color(0xFF1d1e20), 
          title: 
              const Text('Scanner Wi-Fi',style: TextStyle(color: Color(0xFFFFFFFF)),),
              toolbarHeight: 80.0,
        ),
        body:
        
            RefreshIndicator(
              onRefresh: reff, // Refresh list on pull-down
              child: FutureBuilder<bool>(
              future: checkLocationEnabled(), // Call your location check function
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final locationEnabled = snapshot.data!;
                  if (locationEnabled) {
                // Location enabled, proceed with your existing code
                    return wiFiHunterResult.results.isEmpty 
                    ? const Center(child: Text('Aucun réseau Wi-Fi trouvé',style: TextStyle(color: Color(0xFF1d1e20)),))
                    :ListView.builder(
                      itemCount: wiFiHunterResult.results.length,
                        itemBuilder: (context, index) {
                          final network = wiFiHunterResult.results[index];
                          return Card( 
                            color:const Color(0xFF1d1e20),
                          child: ListTile(
                            title:
                            Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                            Text(network.ssid==''? "Réseau non identifié" : network.ssid,style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 25,fontWeight: FontWeight.bold),),
                              const SizedBox(width: 10.0), //espace
                              Icon(
                                    (network.level)<-90 
                                    ? Icons.network_wifi_2_bar
                                    : (network.level)<-75
                                      ? Icons.network_wifi_3_bar
                                      : Icons.network_wifi,
                                    color: Colors.white,
                                    size:25, 
                                  ),
                            ],
                            ),
                            subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                  Text('Adresse MAC du modem: ${network.bssid}',style: const TextStyle(color: Color(0xFFFFFFFF),fontSize: 15),),
                                  Text(network.frequency<2500 ? 'Fréquence du Wi-Fi: 2.4 GHz' : 'Fréquence du Wi-Fi: 5 GHz' ,style: const TextStyle(color: Color(0xFFFFFFFF),fontSize: 15),),
                                  //Text('Fréquence du Wi-Fi: ${network.frequency} MHz',style: const TextStyle(color: Color(0xFFFFFFFF),fontSize: 15),),
                                  Text('Signal du Wi-Fi: ${network.level} dBm',style: const TextStyle(color: Color(0xFFFFFFFF),fontSize: 15),),   
                                 // Text('WIFI capabilites: ${network.capabilities} dBm',style: const TextStyle(color: Color(0xFFFFFFFF),fontSize: 15),),   


                                ],
                              
                              ),
                          ),
                          );
                        },
                      );
                  
                  
              } else {
                // Location disabled, show message
                return const Center(child: Text('Localisation non activée',style: TextStyle(color: Color(0xFF1d1e20)),));
              }
            }
            // Show a progress indicator while waiting for location check
            return const Center(child: CircularProgressIndicator());
    },
            ),
          ),
          floatingActionButton:  FloatingActionButton(
          onPressed:(){
          _huntWiFis();
          setlocationenable();
          },
          tooltip: 'Refresh Wi-Fi List',
          backgroundColor:const  Color(0xFFe8e6e3),
          child: const Icon(Icons.wifi),
        ),
        ),
    );
  }
}