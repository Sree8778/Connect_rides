import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart'; // Import Google Place API package

class DestinationSelectionPage extends StatefulWidget {
  @override
  _DestinationSelectionPageState createState() => _DestinationSelectionPageState();
}

class _DestinationSelectionPageState extends State<DestinationSelectionPage> {
  final String apiKey = 'AIzaSyDJ3A_r-loBWsqQR4Y0nEIFsWFc_Ss2Dhk'; // Your Google API key
  GooglePlace? googlePlace;
  List<AutocompletePrediction> predictions = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize GooglePlace with your API key
    googlePlace = GooglePlace(apiKey);  // Ensure the API key is used correctly
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
        title: const Text('Select Pickup location'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                autoCompleteSearch(value);  // Trigger search on input change
              },
              decoration: InputDecoration(
                hintText: "Search destination",
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
