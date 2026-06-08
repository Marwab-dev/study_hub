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
  final _formKey = GlobalKey<FormState>();

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

    if (result == null || result.files.single.path == null) return;

    setState(() {
      pdfFile = File(result.files.single.path!);
    });
  }

  Future<String?> uploadPDF(File file) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child("pdfs/$fileName.pdf");

      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> publishPost() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (selectedSubject == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a subject")));
      return;
    }

    setState(() => isLoading = true);

    try {
      String? pdfUrl;

      if (pdfFile != null) {
        pdfUrl = await uploadPDF(pdfFile!);
        if (pdfUrl == null) throw Exception();
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
        const SnackBar(content: Text("Post published successfully 🚀")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to publish post ❌")));
    }

    setState(() => isLoading = false);
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),

      appBar: AppBar(
        title: const Text("Create Post"),
        centerTitle: true,
        elevation: 0,
      ),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildCard(
                    child: TextFormField(
                      controller: titleController,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? "Enter title" : null,
                      decoration: const InputDecoration(
                        labelText: "Post Title",
                        border: InputBorder.none,
                        icon: Icon(Icons.title),
                      ),
                    ),
                  ),

                  _buildCard(
                    child: TextFormField(
                      controller: descController,
                      maxLines: 5,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? "Enter description"
                          : null,
                      decoration: const InputDecoration(
                        labelText: "Description",
                        border: InputBorder.none,
                        icon: Icon(Icons.description),
                      ),
                    ),
                  ),

                  _buildCard(
                    child: DropdownButtonFormField<String>(
                      value: selectedSubject,
                      items: subjects
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => selectedSubject = value);
                      },
                      decoration: const InputDecoration(
                        labelText: "Subject",
                        border: InputBorder.none,
                        icon: Icon(Icons.school),
                      ),
                    ),
                  ),

                  _buildCard(
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            pdfFile == null
                                ? "No PDF selected"
                                : "PDF selected ✔",
                            style: TextStyle(
                              color: pdfFile == null
                                  ? Colors.grey
                                  : Colors.green,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: pickPDF,
                          child: const Text("Choose"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : publishPost,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Publish Post",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
