import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  File? file;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        file = File(result.files.single.path!);
      });
    }
  }

  void saveNote() {
    Navigator.pop(context, {
      "title": titleController.text,
      "desc": descController.text,
      "file": file?.path,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Note")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),

            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text("Pick PDF / Image"),
            ),

            if (file != null) Text("Selected: ${file!.path.split('/').last}"),

            const Spacer(),

            ElevatedButton(onPressed: saveNote, child: const Text("Save Note")),
          ],
        ),
      ),
    );
  }
}
