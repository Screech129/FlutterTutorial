import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/locationData.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/shared/global_config.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as geoLoc;

class LocationInputFlutterMap extends StatefulWidget {
  final Function setLocation;
  final Product selectedProduct;
  
  LocationInputFlutterMap(this.setLocation, this.selectedProduct);

  @override
  State<StatefulWidget> createState() {
    return _LocationInputFlutterMapState();
  }
}

class _LocationInputFlutterMapState extends State<LocationInputFlutterMap> {
  final FocusNode _addressInputFocusNode = FocusNode();
  final TextEditingController _addressInputController = TextEditingController();
  final MapController _mapController = MapController();
  LocationData _locationData;

  @override
  void initState() {
    _addressInputFocusNode.addListener(_updateMap);
    if (widget.selectedProduct != null) {
      _updateLocation(widget.selectedProduct.location.address, geocode: false);
    }
    super.initState();
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateMap);
    super.dispose();
  }

  void _updateMap() {
    _updateLocation(_addressInputController.text);
  }

  void _updateLocation(String address,
      {geocode = false, double lat, double lon}) async {
    if (!_addressInputFocusNode.hasFocus) {
      if (geocode) {
        final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json',
            {'address': address, 'key':googleApiKey});
        await http.get(uri).then((http.Response response) {
          final decodedResponse = jsonDecode(response.body);
          final formattedAddress =
              decodedResponse['results'][0]['formatted_address'];
          final coords = decodedResponse['results'][0]['geometry']['location'];

          _locationData = LocationData(
              address: formattedAddress,
              latitude: coords['lat'],
              longitude: coords['lng']);
          _addressInputController.text = _locationData.address;
        });
      } else if (lat == null && lon == null) {
        _locationData = widget.selectedProduct.location;
        _addressInputController.text = _locationData.address;
      } else {
        _locationData =
            LocationData(address: address, latitude: lat, longitude: lon);
        _addressInputController.text = _locationData.address;
      }

      widget.setLocation(_locationData);
      _mapController.move(
          LatLng(_locationData.latitude, _locationData.longitude), 13.0);
      _buildMarker(_locationData.latitude, _locationData.longitude);

      setState(() {
         _addressInputController.text = _locationData.address;
      });
    }
  }

  void _getUserLocation() async {
    final location = geoLoc.Location();
    final currLocation = await location.getLocation();
    final address =
        await _getAddress(currLocation.latitude, currLocation.longitude);
    _updateLocation(address,
        geocode: false,
        lat: currLocation.latitude,
        lon: currLocation.longitude);
  }

  Future<String> _getAddress(double lat, double lon) async {
    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '${lat.toString()},${lon.toString()}',
      'key': googleApiKey
    });
    var response = await http.get(uri);
    final decodedResponse = jsonDecode(response.body);
    final formattedAddress = decodedResponse['results'][0]['formatted_address'];
    return formattedAddress;
  }

  Marker _buildMarker(double lat, double lon) {
    return Marker(
      width: 80.0,
      height: 80.0,
      point: LatLng(lat, lon),
      builder: (ctx) => Container(
        child: Icon(
          Icons.pin_drop,
          color: Colors.purple,
        ),
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      options: MapOptions(center: LatLng(33.46, -81.96), zoom: 13.0),
      mapController: _mapController,
      layers: [
        new TileLayerOptions(
          urlTemplate:
              "https://atlas.microsoft.com/map/tile/png?api-version=1&layer=basic&style=main&tileSize=256&view=Auto&zoom={z}&x={x}&y={y}&subscription-key={subscriptionKey}",
          additionalOptions: {
            'subscriptionKey': azureApiKey
          },
        ),
        MarkerLayerOptions(
          markers: [_buildMarker(33.46, -81.96)],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextFormField(
          focusNode: _addressInputFocusNode,
          controller: _addressInputController,
          decoration: InputDecoration(labelText: 'Address'),
          onEditingComplete: _updateMap,
          validator: (String value) {
            if (_locationData == null || value.isEmpty) {
              return 'No Valid Location Found.';
            }
            return null;
          },
        ),
        SizedBox(
          height: 10.0,
        ),
        FlatButton(
          child: Text('Get Current Location'),
          onPressed: _getUserLocation,
        ),
        Container(
          height: 200,
          child: _buildMap(),
        )
      ],
    );
  }
}
