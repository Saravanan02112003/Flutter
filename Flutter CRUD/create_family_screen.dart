import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateFamilyScreen extends StatefulWidget {
  @override
  _CreateFamilyScreenState createState() => _CreateFamilyScreenState();
}

class _CreateFamilyScreenState extends State<CreateFamilyScreen> {

  TextEditingController variantController = TextEditingController();
  TextEditingController familyController = TextEditingController();

  bool loading = false;

  Future createFamily() async {

    setState(() {
      loading = true;
    });

    var url = Uri.parse("http://localhost:8080/api/sample-data");

    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "familyVariantCode": variantController.text,
        "familyCode": familyController.text
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data Added Successfully"))
      );

      Navigator.pop(context);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add data"))
      );

    }

    setState(() {
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Create Family Variant"),
        backgroundColor: Colors.green,
		foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              controller: variantController,
              decoration: InputDecoration(
                labelText: "Family Variant Code",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            TextField(
              controller: familyController,
              decoration: InputDecoration(
                labelText: "Family Code",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green
                ),

                onPressed: loading ? null : createFamily,

                child: loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "CREATE",
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            )

          ],
        ),
      ),
    );
  }
}