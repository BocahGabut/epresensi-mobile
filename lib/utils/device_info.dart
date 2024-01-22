import 'package:device_information/device_information.dart';
import 'package:flutter/services.dart';
import 'dart:io';

Future<Map<String, dynamic>> getDeviceInfo() async {
  late String platformVersion,
      imeiNo = '',
      modelName = '',
      manufacturer = '',
      deviceName = '',
      productName = '',
      cpuType = '',
      hardware = '';
  var apiLevel;

  try {
    platformVersion = await DeviceInformation.platformVersion;
    imeiNo = await DeviceInformation.deviceIMEINumber;
    modelName = await DeviceInformation.deviceModel;
    manufacturer = await DeviceInformation.deviceManufacturer;
    apiLevel = await DeviceInformation.apiLevel;
    deviceName = await DeviceInformation.deviceName;
    productName = await DeviceInformation.productName;
    cpuType = await DeviceInformation.cpuName;
    hardware = await DeviceInformation.hardware;

    // Membuat objek Map yang berisi informasi perangkat
    Map<String, dynamic> deviceInfo = {
      'platformVersion': platformVersion,
      'imeiNo': imeiNo,
      'modelName': modelName,
      'manufacturerName': manufacturer,
      'apiLevel': apiLevel,
      'deviceName': deviceName,
      'productName': productName,
      'cpuType': cpuType,
      'hardware': hardware,
    };
    return deviceInfo;
  } on PlatformException catch (e) {
    return {'error': 'Error getting device info: ${e.message}'};
  }
}

Future<String> getIpAddress() async {
  try {
    // Mendapatkan daftar antarmuka jaringan
    List<NetworkInterface> interfaces = await NetworkInterface.list();

    // Pilih antarmuka yang tidak loopback dan memiliki alamat IPv4
    NetworkInterface selectedInterface = interfaces.firstWhere(
      (interface) =>
          interface.name != 'lo' &&
          interface.addresses
              .any((addr) => addr.type == InternetAddressType.IPv4),
    );

    // Ambil alamat IP dari antarmuka yang dipilih
    InternetAddress ipAddress = selectedInterface.addresses
        .firstWhere((addr) => addr.type == InternetAddressType.IPv4);

    return ipAddress.address;
  } catch (e) {
    return '';
  }
}
