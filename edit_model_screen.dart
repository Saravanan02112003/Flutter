import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditModelScreen extends StatefulWidget {

  final Map model;

  const EditModelScreen({Key? key, required this.model}) : super(key: key);

  @override
  _EditModelScreenState createState() => _EditModelScreenState();
}

class _EditModelScreenState extends State<EditModelScreen> {

  late TextEditingController variantController;
  late TextEditingController familyController;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    variantController =
        TextEditingController(text: widget.model["familyVariantCode"] ?? "");

    familyController =
        TextEditingController(text: widget.model["familyCode"] ?? "");
  }

  Future updateModel() async {

    setState(() {
      loading = true;
    });

    var oldVariantCode = widget.model["familyVariantCode"];

    var url = Uri.parse(
        "http://localhost:8080/api/sample-data/$oldVariantCode");

    var response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "familyVariantCode": variantController.text,
        "familyCode": familyController.text
      }),
    );

    if (response.statusCode == 200) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Update Successful"))
      );

      // 🔥 Go back directly to Dashboard
      Navigator.popUntil(context, (route) => route.isFirst);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Update Failed"))
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
        title: const Text("Edit Model"),
        backgroundColor: Colors.indigo,
		foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: variantController,
              decoration: const InputDecoration(
                labelText: "Family Variant Code",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: familyController,
              decoration: const InputDecoration(
                labelText: "Family Code",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo
                ),

                onPressed: loading ? null : updateModel,

                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "UPDATE",
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