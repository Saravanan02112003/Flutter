import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class TrackingDirectionScreen extends StatefulWidget {
  const TrackingDirectionScreen({super.key});

  @override
  State<TrackingDirectionScreen> createState() =>
      _TrackingDirectionScreenState();
}

class _TrackingDirectionScreenState extends State<TrackingDirectionScreen> {
  LatLng? fromLocation;
  LatLng? toLocation;

  final MapController mapController = MapController();

  TextEditingController searchController = TextEditingController();

  List<LatLng> routePoints = [];
  List<dynamic> searchResults = [];

  bool routeStarted = false;
  bool showRouteInfo = false;
  bool isFollowingUser = true;

  Timer? timer;

  double routeDistance = 0;
  double routeDuration = 0;

  @override
  void initState() {
    super.initState();
    getLiveLocation();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  /// Get current location
  Future<void> getLiveLocation() async {
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      fromLocation = LatLng(pos.latitude, pos.longitude);
    });

    mapController.move(fromLocation!, 13);
  }

  /// Search places (LIVE)
  Future<void> searchPlace(String query) async {
    final url =
        "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5";

    try {
      final res = await http.get(
        Uri.parse(url),
        headers: {
          "User-Agent":
              "delivery_tracking_app (abc@gmail.com)"
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          searchResults = data;
        });
      }
    } catch (e) {
      debugPrint("Search error: $e");
    }
  }

  ///  Select place from list
  void selectPlace(dynamic place) {
    final lat = double.parse(place["lat"]);
    final lon = double.parse(place["lon"]);

    setState(() {
      toLocation = LatLng(lat, lon);
      searchResults.clear();
      searchController.text = place["display_name"];
    });

    mapController.move(toLocation!, 15);

    if (fromLocation != null) {
      startRoute();
    }
  }

  ///  Start route
  Future<void> startRoute() async {
    await updateRoute();

   setState(() {
  routeStarted = true;
  showRouteInfo = true;
  isFollowingUser = true; //  start following
});

    startTracking();
  }

  ///  Live tracking
  void startTracking() {
timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
  Position pos = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  LatLng newLocation = LatLng(pos.latitude, pos.longitude);

  setState(() {
    fromLocation = newLocation;
  });

  //  Only move map if following user
  if (isFollowingUser) {
    mapController.move(newLocation, 16);
  }

  if (routeStarted) {
    await updateRoute();
  }
});
  }

  ///  Get route from OSRM
  Future<void> updateRoute() async {
    final url =
        "https://router.project-osrm.org/route/v1/driving/"
        "${fromLocation!.longitude},${fromLocation!.latitude};"
        "${toLocation!.longitude},${toLocation!.latitude}"
        "?overview=full&geometries=geojson";

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      final coords = data["routes"][0]["geometry"]["coordinates"];
      final distanceMeters = data["routes"][0]["distance"];
      final durationSeconds = data["routes"][0]["duration"];

      List<LatLng> points = [];
      for (var c in coords) {
        points.add(LatLng(c[1], c[0]));
      }

      setState(() {
        routePoints = points;
        routeDistance = distanceMeters / 1000;
        routeDuration = durationSeconds / 60;
      });
    }
  }

  ///  Format duration
  String formatDuration(double minutes) {
    int hrs = minutes ~/ 60;
    int mins = (minutes % 60).round();

    return hrs > 0 ? "$hrs hr $mins min" : "$mins min";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tracking Direction"),
        backgroundColor: Colors.indigo,
        actions: [
          if (routeStarted)
            IconButton(
              icon: Icon(showRouteInfo ? Icons.close : Icons.visibility),
              onPressed: () {
                setState(() {
                  showRouteInfo = !showRouteInfo;
                });
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          ///  MAP
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
  initialCenter: fromLocation ?? LatLng(12.9, 80.2),
  initialZoom: 13,

  onPositionChanged: (position, hasGesture) {
    if (hasGesture) {
      // User manually moved map → stop auto-follow
      isFollowingUser = false;
    }
  },
),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),

              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                        points: routePoints,
                        color: Colors.blue,
                        strokeWidth: 5)
                  ],
                ),

              MarkerLayer(
                markers: [
                  if (fromLocation != null)
                    Marker(
                      point: fromLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.my_location,
                          color: Colors.blue, size: 40),
                    ),
                  if (toLocation != null)
                    Marker(
                      point: toLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_pin,
                          color: Colors.red, size: 40),
                    ),
                ],
              ),
            ],
          ),

          ///  SEARCH + LIST
          if (!routeStarted || !showRouteInfo)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Search destination",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.length > 2) {
                        searchPlace(value);
                      } else {
                        setState(() => searchResults.clear());
                      }
                    },
                  ),
                ),

                if (searchResults.isNotEmpty)
                  Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: Colors.white,
                    child: ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final place = searchResults[index];

                        return ListTile(
                          title: Text(place["display_name"]),
                          onTap: () => selectPlace(place),
                        );
                      },
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton.icon(
                    onPressed:
                        (fromLocation != null && toLocation != null)
                            ? startRoute
                            : null,
                    icon: const Icon(Icons.directions),
                    label: const Text("Start Direction"),
					style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50), //  size
    ),
                  ),
                ),
              ],
            ),

          ///  BOTTOM PANEL
          if (routeStarted && showRouteInfo)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Distance: ${routeDistance.toStringAsFixed(2)} km"),
                    Text("ETA: ${formatDuration(routeDuration)}"),
                  ],
                ),
              ),
            ),
			if (!isFollowingUser && fromLocation != null)
  Positioned(
    bottom: 100,
    right: 20,
    child: FloatingActionButton(
      backgroundColor: Colors.white,
      child: const Icon(Icons.my_location, color: Colors.blue),
      onPressed: () {
        setState(() {
          isFollowingUser = true;
        });

        mapController.move(fromLocation!, 16);
      },
    ),
  ),
        ],
      ),
    );
  }
}