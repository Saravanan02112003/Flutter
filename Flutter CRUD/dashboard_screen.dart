import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'model_detail_screen.dart';
import 'create_family_screen.dart';

class DashboardScreen extends StatefulWidget {

  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  List models = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchModels();
  }

  Future fetchModels() async {

    var url = Uri.parse("http://localhost:8080/api/sample-data");

    var response = await http.get(url);

    if (response.statusCode == 200) {

      setState(() {
        models = jsonDecode(response.body);
        loading = false;
      });

    } else {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Family Variants"),
        backgroundColor: Colors.green,
		foregroundColor: Colors.white,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: models.length,
              itemBuilder: (context, index) {

                var model = models[index];

                return Card(
                  margin: const EdgeInsets.all(10),

                  child: ListTile(

                    title: Text(
                      model["familyVariantCode"] ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text("Variant Code : ${model["familyVariantCode"] ?? ""}"),

                        Text("Family Code : ${model["familyCode"] ?? ""}"),

                      ],
                    ),

                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ModelDetailScreen(model: model),
                        ),
                      );

                    },

                  ),
                );

              },
            ),

      floatingActionButton: FloatingActionButton(

        backgroundColor: Colors.green,

        child: const Icon(Icons.add),

        onPressed: () async {

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateFamilyScreen(),
            ),
          );

          fetchModels(); // refresh list after create

        },

      ),
    );
  }
}