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
  final tagController = TextEditingController();

  File? file;

  bool isLoading = false;
  double progress = 0;

  List<String> tags = [];

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  void _loadDraft() {
    // draft بسيط (ممكن تحوله لاحقًا لـ SharedPreferences)
    titleController.text = "";
    descController.text = "";
  }

  Future<void> pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        file = File(result.files.single.path!);
      });
    }
  }

  void addTag() {
    final tag = tagController.text.trim();

    if (tag.isEmpty) return;

    setState(() {
      tags.add(tag.startsWith("#") ? tag : "#$tag");
      tagController.clear();
    });
  }

  void removeTag(String tag) {
    setState(() {
      tags.remove(tag);
    });
  }

  Future<void> saveNote() async {
    if (titleController.text.trim().isEmpty) return;

    setState(() {
      isLoading = true;
      progress = 0;
    });

    // 🔥 fake upload progress (جاهز تربطه Firebase)
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      setState(() {
        progress = i / 10;
      });
    }

    Navigator.pop(context, {
      "title": titleController.text.trim(),
      "desc": descController.text.trim(),
      "file": file?.path,
      "tags": tags,
    });
  }

  Widget _card(Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
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

  Widget _filePreview() {
    if (file == null) {
      return GestureDetector(
        onTap: pickFile,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
                SizedBox(height: 6),
                Text("Tap to upload file"),
              ],
            ),
          ),
        ),
      );
    }

    final name = file!.path.split("/").last;
    final isImage =
        name.endsWith(".png") ||
        name.endsWith(".jpg") ||
        name.endsWith(".jpeg");

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            isImage ? Icons.image : Icons.picture_as_pdf,
            color: Colors.blue,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
          IconButton(
            onPressed: () => setState(() => file = null),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _tagsSection() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tags", style: TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          Wrap(
            spacing: 6,
            children: tags
                .map(
                  (t) => Chip(
                    label: Text(t),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => removeTag(t),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: tagController,
                  decoration: const InputDecoration(
                    hintText: "Add tag",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: addTag, child: const Text("Add")),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),

      appBar: AppBar(title: const Text("Create Note"), centerTitle: true),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                _card(
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Title",
                      border: InputBorder.none,
                      icon: Icon(Icons.title),
                    ),
                  ),
                ),

                _card(
                  TextField(
                    controller: descController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: InputBorder.none,
                      icon: Icon(Icons.description),
                    ),
                  ),
                ),

                _card(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Attach File",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _filePreview(),
                    ],
                  ),
                ),

                _tagsSection(),

                const SizedBox(height: 10),

                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : saveNote,
                    child: const Text("Save Note"),
                  ),
                ),
              ],
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Uploading..."),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(value: progress),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
