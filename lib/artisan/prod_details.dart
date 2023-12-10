import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resculpt/models/waste_object.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class ProdDetails extends StatefulWidget {
  const ProdDetails({super.key});

  @override
  State<ProdDetails> createState() => _ProdDetailsState();
}

class _ProdDetailsState extends State<ProdDetails> {
  late File _selectedImage;
  final _db = FirebaseFirestore.instance;
  final storageRef = FirebaseStorage.instance.ref();

  List<DropdownMenuEntry<dynamic>> dropdownMenuEntries = [
    const DropdownMenuEntry(value: 1, label: "plastic"),
    const DropdownMenuEntry(value: 2, label: "glass"),
    const DropdownMenuEntry(value: 3, label: "fabric"),
    const DropdownMenuEntry(value: 4, label: "metal"),
    const DropdownMenuEntry(value: 1, label: "wood")
  ];

  late final TextEditingController _title;
  late final TextEditingController _desc;
  late final TextEditingController _cat;
  late final TextEditingController _adr;
  late final TextEditingController _price;

  @override
  void initState() {
    _title = TextEditingController();
    _desc = TextEditingController();
    _cat = TextEditingController();
    _adr = TextEditingController();
    _price = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _cat.dispose();
    _adr.dispose();
    _price.dispose();
    super.dispose();
  }

  Future submitDetails() async {
    final title = _title.text.trim();
    final description = _desc.text.trim();
    final category = _cat.text.trim();
    final address = _adr.text.trim();
    const type = 'product';
    final double price = double.parse(_price.text.trim());
    final email = FirebaseAuth.instance.currentUser?.email;
    WasteObject obj = WasteObject(
        type: type,
        email: email,
        title: title,
        desc: description,
        cat: category,
        adr: address,
        price: price);
    await _db.collection('items').add(obj.toJson());
  }

  Future _storeImageToDb(File selectedImage) async {
    final wasteRef = storageRef.child("Waste items");
    final imageRef = wasteRef.child("yourImg.png");
    await imageRef.putFile(_selectedImage);
  }

  Future _pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage == null) return;
    setState(() {
      _selectedImage = File(returnedImage.path);
    });
    _storeImageToDb(_selectedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Enter item details'),
      ),
      body: Column(
        children: [
          TextField(
              controller: _title,
              decoration: const InputDecoration(hintText: "Enter title")),
          TextField(
            controller: _desc,
            decoration: const InputDecoration(hintText: "Enter description"),
          ),
          DropdownMenu<dynamic>(
              controller: _cat,
              hintText: "type",
              initialSelection: dropdownMenuEntries.first,
              dropdownMenuEntries: dropdownMenuEntries),
          TextField(
            controller: _adr,
            decoration: const InputDecoration(hintText: "Enter location"),
          ),
          TextField(
            controller: _price,
            decoration: const InputDecoration(hintText: "Enter price"),
          ),
          ElevatedButton(
            onPressed: () {
              _pickImageFromGallery();
            },
            child: const Text('Upload Image'),
          ),
          ElevatedButton(
            onPressed: () {
              submitDetails();
              Navigator.pop(context);
            },
            child: const Text('Submit details'),
          ),
        ],
      ),
    );
  }
}