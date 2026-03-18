import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'edit_model_screen.dart';

class ModelDetailScreen extends StatefulWidget {

  final Map model;

  const ModelDetailScreen({Key? key, required this.model}) : super(key: key);

  @override
  _ModelDetailScreenState createState() => _ModelDetailScreenState();
}

class _ModelDetailScreenState extends State<ModelDetailScreen> {

  late Map model;

  @override
  void initState() {
    super.initState();
    model = widget.model;
  }

  // DELETE API
  Future deleteModel() async {

    var code = model["familyVariantCode"];

    var url = Uri.parse(
        "http://localhost:8080/api/sample-data/$code");

    var response = await http.delete(url);

    if (response.statusCode == 200) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Record Deleted"))
      );

      // go back to dashboard
      Navigator.pop(context);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Delete Failed"))
      );

    }

  }

  // CONFIRM DELETE DIALOG
  void confirmDelete() {

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(

          title: const Text("Delete Record"),

          content: const Text(
              "Are you sure you want to delete this record?"),

          actions: [

            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red
              ),

              child: const Text("Delete"),

              onPressed: () {
                Navigator.pop(context);
                deleteModel();
              },
            )

          ],
        );

      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(model["familyVariantCode"] ?? "Details"),
        backgroundColor: Colors.indigo,
		foregroundColor: Colors.white,

        actions: [

          // EDIT BUTTON
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white,),

            onPressed: () async {

              var result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditModelScreen(model: model),
                ),
              );

              if (result != null) {
                setState(() {
                  model = result;
                });
              }

            },
          ),

          // DELETE BUTTON
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white,),
            onPressed: confirmDelete,
          )

        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: Table(
              border: TableBorder.all(
                color: Colors.grey,
                width: 1,
              ),

              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
              },

              children: [

                TableRow(
                  decoration: BoxDecoration(color: Colors.indigo.shade100),
                  children: [
                    tableCell("Field", true),
                    tableCell("Value", true),
                  ],
                ),

                TableRow(
                  children: [
                    tableCell("Variant Code", false),
                    tableCell(model["familyVariantCode"] ?? "", false),
                  ],
                ),

                TableRow(
                  children: [
                    tableCell("Family Code", false),
                    tableCell(model["familyCode"] ?? "", false),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget tableCell(String text, bool header) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: header ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}