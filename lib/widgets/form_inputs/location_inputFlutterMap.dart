import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class LocationInputFlutterMap extends StatelessWidget {
  @override
 Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(center: LatLng(51.5, -0.09), zoom: 13.0),
      layers: [
        new TileLayerOptions(
          urlTemplate:
              "https://atlas.microsoft.com/map/tile/png?api-version=1&layer=basic&style=main&tileSize=256&view=Auto&zoom={z}&x={x}&y={y}&subscription-key={subscriptionKey}",
          additionalOptions: {
            'subscriptionKey': '<AzureKey>'
          },
        ),
        MarkerLayerOptions(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(51.5, -0.09),
              builder: (ctx) => Container(
                child: Icon(Icons.pin_drop,color: Colors.purple,),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
