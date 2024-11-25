import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html;
import 'package:path/path.dart' as path;
import 'package:webunicamp/src/widgets/custom_appbar.dart';

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});

  @override
  _AddLocationScreenState createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  // Existing variables
  LatLng _pinLocation = LatLng(7.071811, 125.612781);
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedBuilding;
  bool _isVisible = true;
  final List<html.File> _selectedPhotos = [];
  final List<String> _photoPreviewUrls = [];
  bool _isUploading = false;

  // Add list to store building names
  List<String> _buildingNames = [];
  bool _isLoadingBuildings = true;

  @override
  void initState() {
    super.initState();
    _fetchBuildings();
  }

  Future<void> _fetchBuildings() async {
    setState(() {
      _isLoadingBuildings = true;
    });

    try {
      final QuerySnapshot buildingSnapshot = 
          await FirebaseFirestore.instance.collection('Buildings').get();
      
      setState(() {
        // Add "None" as first option, then add the fetched building names
        _buildingNames = ["None", ...buildingSnapshot.docs
            .map((doc) => doc['Name'] as String)
            .toList()
          ..sort()]; // Sort will only sort the building names, "None" stays first
        _isLoadingBuildings = false;
      });
    } catch (e) {
      print('Error fetching buildings: $e');
      setState(() {
        _buildingNames = ["None"]; // Even if fetch fails, we still have "None" option
        _isLoadingBuildings = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading buildings: ${e.toString()}')),
      );
    }
  }

  Future<List<String>> _uploadPhotos() async {
  List<String> photoUrls = [];

  for (html.File photo in _selectedPhotos) {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}_${photo.name}';
    Reference storageRef = FirebaseStorage.instance.ref().child(fileName); // Without the "location_photos/" path

    try {
      // Create a FileReader
      final reader = html.FileReader();
      // Read the file as array buffer
      reader.readAsArrayBuffer(photo);

      // Wait for the reader to complete
      await reader.onLoadEnd.first;

      // Get the result as Blob
      final blob = html.Blob([reader.result]);

      // Determine the Content-Type based on file extension (simplified example)
      String contentType = 'application/octet-stream'; // Default content type
      if (photo.name.endsWith('.png')) {
        contentType = 'image/png';
      } else if (photo.name.endsWith('.jpg') || photo.name.endsWith('.jpeg')) {
        contentType = 'image/jpeg';
      } else if (photo.name.endsWith('.gif')) {
        contentType = 'image/gif';
      }

      // Set the metadata with contentType
      final metadata = SettableMetadata(
        contentType: contentType,
      );

      // Upload the file with the metadata
      await storageRef.putBlob(blob, metadata);
      
      // Get the download URL
      String downloadUrl = await storageRef.getDownloadURL();
      photoUrls.add(downloadUrl);
    } catch (e) {
      print('Error uploading photo: $e');
      throw e;
    }
  }

  return photoUrls;
}


  // Method to pick images for web
  Future<void> _pickImages() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..multiple = true;

    input.click();

    await input.onChange.first;

    if (input.files != null) {
      setState(() {
        _selectedPhotos.addAll(input.files!);
        // Create preview URLs for the selected images
        for (var file in input.files!) {
          final reader = html.FileReader();
          reader.readAsDataUrl(file);
          reader.onLoad.listen((e) {
            setState(() {
              _photoPreviewUrls.add(reader.result as String);
            });
          });
        }
      });
    }
  }

  Future<void> _addLocationToFirebase() async {
    setState(() {
      _isUploading = true;
    });

    try {
      List<String> photoUrls = await _uploadPhotos();

      await FirebaseFirestore.instance.collection('Locations').add({
        'Name': _nameController.text,
        'Email': _emailController.text,
        'Description': _descriptionController.text,
        'Building': _selectedBuilding ?? "None", // Default to "None" if nothing selected
        'PhotoURL': photoUrls,
        'Visibility': _isVisible,
        'Location': GeoPoint(_pinLocation.latitude, _pinLocation.longitude),
        'Date Created': FieldValue.serverTimestamp(),
      });
    Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('Error uploading location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error uploading location: ${e.toString()}')),
    );
    } finally {
    setState(() {
      _isUploading = false;
    });
  }
  }

  // Widget to display selected photos
  Widget _buildPhotoPreview() {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _photoPreviewUrls.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  _photoPreviewUrls[index],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _selectedPhotos.removeAt(index);
                      _photoPreviewUrls.removeAt(index);
                    });
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff3f3f3),
      appBar: CustomAppBar(),
      body: Row(
        children: [
          // Map Section
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: _pinLocation,
                      initialZoom: 18.0,
                      onTap: (tapPosition, point) {
                        setState(() {
                          _pinLocation = point;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                      urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: _pinLocation,
                            child: Icon(Icons.pin_drop, color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Input Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(64.0),
              child: Container(
                color: Color(0xfff3f3f3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                        "Add a New Location",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                
                    const SizedBox(height: 64),
                    
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: const OutlineInputBorder(),
                        labelStyle: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.black, // Label text color
                            fontSize: 20, // Font size
                            fontWeight: FontWeight.w500, // Font weight
                          ),
                        ),
                      ),
                    ),
                
                    const SizedBox(height: 16),
                
                    // Email Input
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        labelStyle: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.black, // Label text color
                            fontSize: 20, // Font size
                            fontWeight: FontWeight.w500, // Font weight
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                
                    // Description Input
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        labelText: 'Description',
                        border: const OutlineInputBorder(),
                        labelStyle: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.black, // Label text color
                            fontSize: 20, // Font size
                            fontWeight: FontWeight.w500, // Font weight
                          ),
                        ),
                      ),
                      
                    ),
                    const SizedBox(height: 16),
                
                    _isLoadingBuildings
                      ? const CircularProgressIndicator()
                      : DropdownButtonFormField<String>(
                        isExpanded: true, // Ensures the dropdown and button fit the available space
                        value: _selectedBuilding ?? "None",
                        items: _buildingNames
                            .map((building) => DropdownMenuItem(
                                  value: building,
                                  child: Text(
                                    building,
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBuilding = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Building',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: const Color(0xfff3f3f3), // Background color
                          labelStyle: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        dropdownColor: Colors.white,
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ),

                
                    const SizedBox(height: 16),
                    
                    // Photo upload section
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Upload Button
                          SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _isUploading ? null : _pickImages,
                                    icon: Icon(Icons.photo_library, color: Colors.black),
                                    label: Text(
                                      'Attach Photos',
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                                      backgroundColor: Color(0xfff3f3f3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          if (_photoPreviewUrls.isNotEmpty) 
                            _buildPhotoPreview(),
                            
                          const SizedBox(height: 16),
                          
                          // Visibility Checkbox
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Checkbox(
                                value: _isVisible,
                                onChanged: (value) {
                                  setState(() {
                                    _isVisible = value ?? true;
                                  });
                                },
                                activeColor: Colors.black,
                              ),
                              Text(
                                'Visible to Others',
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                
                    const SizedBox(height: 16),
                
                    // Save button with loading indicator
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _addLocationToFirebase,
                        child: _isUploading 
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Uploading ...',
                                  style: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                                'Save Location',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black
                                  ),
                                ),
                              ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5), // Reduced corner radius
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                            backgroundColor: Color(0xfff3f3f3)
                          ),
                      ),
                    ),
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