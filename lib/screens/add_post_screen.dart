import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  String? selectedSubject;
  File? pdfFile;
  bool isLoading = false;

  final List<String> subjects = const [
    "Mathematics",
    "Physics",
    "Chemistry",
    "Programming",
    "English",
  ];

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> pickPDF() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;

    setState(() {
      pdfFile = File(result.files.single.path!);
    });
  }

  Future<String?> uploadPDF(File file) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final ref = FirebaseStorage.instance.ref().child("pdfs/$fileName.pdf");

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> publishPost() async {
    if (titleController.text.trim().isEmpty ||
        descController.text.trim().isEmpty ||
        selectedSubject == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    try {
      String? pdfUrl;

      if (pdfFile != null) {
        pdfUrl = await uploadPDF(pdfFile!);

        if (pdfUrl == null) {
          throw Exception("PDF upload failed");
        }
      }

      await FirebaseFirestore.instance.collection("posts").add({
        "title": titleController.text.trim(),
        "description": descController.text.trim(),
        "subject": selectedSubject,
        "pdfUrl": pdfUrl ?? "",
        "userId": FirebaseAuth.instance.currentUser!.uid,
        "likes": 0,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post published successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to publish post")));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Post"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedSubject,
              items: subjects
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) {
                setState(() => selectedSubject = value);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Subject",
              ),
            ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: pickPDF,
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(pdfFile == null ? "Choose PDF" : "PDF Selected ✔"),
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : publishPost,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Publish"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
