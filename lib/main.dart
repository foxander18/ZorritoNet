import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

void main() {
  runApp(ZorritoNetApp());
}

class ZorritoNetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZorritoNet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NetworkScannerScreen(),
    );
  }
}

class NetworkScannerScreen extends StatefulWidget {
  @override
  _NetworkScannerScreenState createState() => _NetworkScannerScreenState();
}

class _NetworkScannerScreenState extends State<NetworkScannerScreen> {
  List<String> devices = [];
  bool isScanning = false;

  Future<void> scanNetwork() async {
    setState(() {
      isScanning = true;
      devices.clear();
    });

    final localIp = await _getLocalIp();
    final subnet = localIp.substring(0, localIp.lastIndexOf('.'));

    for (var i = 1; i <= 255; i++) {
      final ip = '$subnet.$i';
      if (await _ping(ip)) {
        setState(() {
          devices.add(ip);
        });
      }
    }

    setState(() {
      isScanning = false;
    });
  }

  Future<String> _getLocalIp() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
          return addr.address;
        }
      }
    }
    return '127.0.0.1';
  }

  Future<bool> _ping(String ip) async {
    try {
      final result = await InternetAddress(ip).lookup();
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ZorritoNet - Escáner de Red'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Dispositivo encontrado: ${devices[index]}'),
                );
              },
            ),
          ),
          if (isScanning) CircularProgressIndicator(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isScanning ? null : scanNetwork,
        child: Icon(Icons.search),
      ),
    );
  }
}
