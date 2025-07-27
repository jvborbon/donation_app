import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadProofPage extends StatefulWidget {
  final String donationId;
  final String collection;
  const UploadProofPage({super.key, required this.donationId, required this.collection});

  @override
  State<UploadProofPage> createState() => _UploadProofPageState();
}

class _UploadProofPageState extends State<UploadProofPage> {
  final List<File> _selectedImages = [];
  final List<Uint8List> _webImages = [];
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImages.add(bytes);
        });
      } else {
        setState(() {
          _selectedImages.add(File(pickedFile.path));
        });
      }
    }
  }

  Future<void> _submitProof() async {
    final hasImages = kIsWeb ? _webImages.isNotEmpty : _selectedImages.isNotEmpty;
    if (!hasImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      List<String> base64Images = [];
      if (kIsWeb) {
        for (final bytes in _webImages) {
          base64Images.add(base64Encode(bytes));
        }
      } else {
        for (final image in _selectedImages) {
          final bytes = await image.readAsBytes();
          base64Images.add(base64Encode(bytes));
        }
      }

      await FirebaseFirestore.instance
          .collection('in_kind_donations')
          .doc(widget.donationId)
          .update({
        'proof_images_base64': base64Images,
        'status': 'proof_submitted',
        'proof_submittedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proof submitted successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit proof: $e')),
      );
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Upload Proof of Delivery', style: TextStyle(color: Colors.white),),
        backgroundColor: Color.fromARGB(255, 209, 14, 14),
      ),
      body: _isUploading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Uploading images...'),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Upload proof of your donation delivery:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: kIsWeb
                        ? _webImages.isEmpty
                            ? const Center(child: Text('No images selected'))
                            : GridView.builder(
                                itemCount: _webImages.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemBuilder: (context, index) {
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.memory(_webImages[index], fit: BoxFit.cover),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          icon: const Icon(Icons.remove_circle),
                                          color: Colors.red,
                                          onPressed: () {
                                            setState(() {
                                              _webImages.removeAt(index);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              )
                        : _selectedImages.isEmpty
                            ? const Center(child: Text('No images selected'))
                            : GridView.builder(
                                itemCount: _selectedImages.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemBuilder: (context, index) {
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(_selectedImages[index], fit: BoxFit.cover),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          icon: const Icon(Icons.remove_circle),
                                          color: Colors.red,
                                          onPressed: () {
                                            setState(() {
                                              _selectedImages.removeAt(index);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Select Image'),
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload),
                    label: const Text('Submit Proof'),
                    onPressed: _submitProof,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}