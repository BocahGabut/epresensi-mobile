import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Object> getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
  
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return '';
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    print('Lokasi pengguna: ${position.latitude}, ${position.longitude}');
    return position;
  }
}
