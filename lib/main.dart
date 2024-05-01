import 'package:flutter/material.dart';

import 'package:flutter/services.dart'; //exceptions

import 'package:wifi_hunter/wifi_hunter.dart'; //bibliotheque wifihunter 
import 'package:wifi_hunter/wifi_hunter_result.dart';

import 'package:permission_handler/permission_handler.dart'; //Permissions

import 'dart:io';//Platformes

import 'dart:async'; //timer

void main() {
  runApp(MyApp());
}


 class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  
  WiFiHunterResult wiFiHunterResult = WiFiHunterResult();
  /* wifiHunterResult est un tableau, chaque element de ce tableau est un reseau wifi capture, les proprietes de chaque wif est comme suit:
  String ssid; nom du wifi
  String bssid; mac du modem
  String capabilities; 
  int frequency; 
  int level; signal du wifi
  int channelWidth; chaine du wifi
  int timestamp; quand est ce que le wifi a ete capture
   */
  Future<void> demanderlocal() async {
      if (Platform.isAndroid) {
      var status = await Permission.locationWhenInUse.request(); //permission de la localisation
      if (!status.isGranted) { 
        return;
      }else{
        print('Autorisation refusée');
        return;
      }
      
    }
}
Future<bool> checkLocationEnabled() async {
  final serviceStatus = await Permission.locationWhenInUse.serviceStatus;
  //autorisee ou non
  return serviceStatus.isEnabled;
}
late bool locationenabled; //"late" sert a declarer une variable sans une valeur initial; "bool enabled;" est fausse
Future<void> locationstate() async{
       locationenabled= await checkLocationEnabled(); //variable qui represente l'etat de la localisation
}

  Future<void> reff() async{
    locationstate();
                  if (!locationenabled) {
                    //si la localisation est desactivee, ne pas perdre du temps a chercher les wifi
                    setState(() {}); //actualiser l'affichage
                    return;
                  }
                  else{
                    _huntWiFis(); //si la localisation est desactivee, ne pas perdre du temps a chercher les wifi
                    return ;
                  }
  }
  Future<void> _huntWiFis() async {
    try {
      wiFiHunterResult = (await WiFiHunter.huntWiFiNetworks)!; //reseaux captures; " ! " ==null == peut être une liste vide
      setState(() {}); // Afficher ces nouveaux resultats
    } on PlatformException catch (error) {
      // toute erreur possible
      print('Erreur: $error');
    }
  }
    @override
  void initState() {
    super.initState();
    demanderlocal(); //demander la permission d'utiliser la localisation
    locationstate(); //variable globale a utiliser apres
     Timer.periodic( const Duration(seconds: 2), (_) => reff()); //actualiser automatiquement chaque 5s
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
              onRefresh: reff, // Actualiser on pull-down
              child: FutureBuilder<bool>(
              future: checkLocationEnabled(), // Verifier si la localisation est activee. La localisation est necessaire pour Wifihunter
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final locationEnabled = snapshot.data!;
                  if (locationEnabled) {
                // Localisation activee, afficher les resultats, sinon (localisation desactivee), aller a la ligne 144
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
                                    ? Icons.network_wifi_2_bar //signal le plus faible
                                    : (network.level)<-75
                                      ? Icons.network_wifi_3_bar //signal un peu plus puissant
                                      : Icons.network_wifi, //signal max
                                    color: Colors.white,
                                    size:25, 
                                    //Source: https://fonts.google.com/icons?icon.query=network+wifi
                                  ),
                            ],
                            ),
                            subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                  Text('Adresse MAC du modem: ${network.bssid}',style: const TextStyle(color: Color(0xFFFFFFFF),fontSize: 15),),
                                  Text(network.frequency<2500 ? 'Fréquence du Wi-Fi: 2.4 GHz' : 'Fréquence du Wi-Fi: 5 GHz' ,style: const TextStyle(color: Color(0xFFFFFFFF),fontSize: 15),),
                                  //nettwork.frequenecy est en Mhz, (2437Mhz pour un modem de 2.4Ghz, 5ghz sinon)
                                  Text('Signal du Wi-Fi: ${network.level} dBm',style: const TextStyle(color: Color(0xFFFFFFFF),fontSize: 15),),   
                                ],
                              
                              ),
                          ),
                          );
                        },
                      );
                  
                  
              } else {
                // Localisation desactivee
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
          locationstate();
          },
          tooltip: 'Refresh Wi-Fi List',
          backgroundColor:const  Color(0xFFe8e6e3),
          child: const Icon(Icons.wifi),
        ),
        ),
    );
  }
}