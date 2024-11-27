import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';

class DestinationSelectionPage extends StatefulWidget {
  final bool isPickup; // New parameter to indicate if it's for pickup

  const DestinationSelectionPage({Key? key, required this.isPickup}) : super(key: key);

  @override
  _DestinationSelectionPageState createState() => _DestinationSelectionPageState();
}

class _DestinationSelectionPageState extends State<DestinationSelectionPage> {
  final String apiKey = 'AIzaSyDJ3A_r-loBWsqQR4Y0nEIFsWFc_Ss2Dhk';
  GooglePlace? googlePlace;
  List<AutocompletePrediction> predictions = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace(apiKey); // Initialize Google Place API
  }

  void autoCompleteSearch(String input) async {
    if (input.isNotEmpty) {
      var result = await googlePlace!.autocomplete.get(input);

      if (result != null && result.predictions != null) {
        setState(() {
          predictions = result.predictions!;
        });
      }
    } else {
      setState(() {
        predictions = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPickup ? 'Select Pickup Location' : 'Select Destination'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                autoCompleteSearch(value); // Trigger search on input change
              },
              decoration: InputDecoration(
                hintText: "Search for your location",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      predictions = [];
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(predictions[index].description!),
                  onTap: () {
                    // Return the selected place back to HomePage
                    Navigator.pop(context, predictions[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
