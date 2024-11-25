import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:html' as html;
import 'package:webunicamp/src/widgets/custom_appbar.dart';

class UpdateLocationScreen extends StatefulWidget {
  final String locationId;
  final Map<String, dynamic> locationData;

  const UpdateLocationScreen({
    super.key, 
    required this.locationId,
    required this.locationData,
  });

  @override
  _UpdateLocationScreenState createState() => _UpdateLocationScreenState();
}

class _UpdateLocationScreenState extends State<UpdateLocationScreen> {
  late LatLng _pinLocation;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _descriptionController;
  String? _selectedBuilding;
  bool _isVisible = true;
  final List<html.File> _newPhotos = [];
  final List<String> _photoPreviewUrls = [];
  List<String> _existingPhotoUrls = [];
  bool _isUploading = false;
  List<String> _buildingNames = [];
  bool _isLoadingBuildings = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _fetchBuildings();
  }

  void _initializeData() {
    // Initialize controllers with existing data
    _nameController = TextEditingController(text: widget.locationData['Name']);
    _emailController = TextEditingController(text: widget.locationData['Email']);
    _descriptionController = TextEditingController(text: widget.locationData['Description']);
    
    // Initialize location
    GeoPoint locationPoint = widget.locationData['Location'];
    _pinLocation = LatLng(locationPoint.latitude, locationPoint.longitude);
    
    // Initialize building
    _selectedBuilding = widget.locationData['Building'];
    
    // Initialize visibility
    _isVisible = widget.locationData['Visibility'] ?? true;
    
    // Initialize existing photos
    _existingPhotoUrls = List<String>.from(widget.locationData['PhotoURL'] ?? []);
    _photoPreviewUrls.addAll(_existingPhotoUrls);
  }

  Future<void> _fetchBuildings() async {
    setState(() {
      _isLoadingBuildings = true;
    });

    try {
      final QuerySnapshot buildingSnapshot = 
          await FirebaseFirestore.instance.collection('Buildings').get();
      
      setState(() {
        _buildingNames = ["None", ...buildingSnapshot.docs
            .map((doc) => doc['Name'] as String)
            .toList()
          ..sort()];
        _isLoadingBuildings = false;
      });
    } catch (e) {
      print('Error fetching buildings: $e');
      setState(() {
        _buildingNames = ["None"];
        _isLoadingBuildings = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading buildings: ${e.toString()}')),
      );
    }
  }

  Future<List<String>> _uploadNewPhotos() async {
    List<String> newPhotoUrls = [];

    for (html.File photo in _newPhotos) {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${photo.name}';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

      try {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(photo);
        await reader.onLoadEnd.first;
        final blob = html.Blob([reader.result]);

        String contentType = 'application/octet-stream';
        if (photo.name.endsWith('.png')) {
          contentType = 'image/png';
        } else if (photo.name.endsWith('.jpg') || photo.name.endsWith('.jpeg')) {
          contentType = 'image/jpeg';
        } else if (photo.name.endsWith('.gif')) {
          contentType = 'image/gif';
        }

        final metadata = SettableMetadata(contentType: contentType);
        await storageRef.putBlob(blob, metadata);
        String downloadUrl = await storageRef.getDownloadURL();
        newPhotoUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading new photo: $e');
        throw e;
      }
    }

    return newPhotoUrls;
  }

  Future<void> _pickImages() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..multiple = true;

    input.click();

    await input.onChange.first;

    if (input.files != null) {
      setState(() {
        _newPhotos.addAll(input.files!);
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

  Future<void> _deletePhoto(int index) async {
    try {
      if (index < _existingPhotoUrls.length) {
        // If it's an existing photo
        String photoUrl = _existingPhotoUrls[index];
        // Remove from Firebase Storage if needed
        // Note: You might want to add logic to delete the actual file from Storage
        setState(() {
          _existingPhotoUrls.removeAt(index);
          _photoPreviewUrls.removeAt(index);
        });
      } else {
        // If it's a newly added photo
        int newPhotoIndex = index - _existingPhotoUrls.length;
        setState(() {
          _newPhotos.removeAt(newPhotoIndex);
          _photoPreviewUrls.removeAt(index);
        });
      }
    } catch (e) {
      print('Error deleting photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting photo: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateLocationInFirebase() async {
    setState(() {
      _isUploading = true;
    });

    try {
      // Upload new photos if any
      List<String> newPhotoUrls = await _uploadNewPhotos();
      
      // Combine existing and new photo URLs
      List<String> allPhotoUrls = [..._existingPhotoUrls, ...newPhotoUrls];

      // Update the document
      await FirebaseFirestore.instance
          .collection('Locations')
          .doc(widget.locationId)
          .update({
        'Name': _nameController.text,
        'Email': _emailController.text,
        'Description': _descriptionController.text,
        'Building': _selectedBuilding ?? "None",
        'PhotoURL': allPhotoUrls,
        'Visibility': _isVisible,
        'Location': GeoPoint(_pinLocation.latitude, _pinLocation.longitude),
        'Last Updated': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('Error updating location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating location: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Widget _buildPhotoPreview() {
  return Container(
    child: Wrap(
      spacing: 8.0, // Horizontal space between images
      runSpacing: 8.0, // Vertical space between rows
      children: _photoPreviewUrls.map((url) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(
                url,
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
                onPressed: () => _deletePhoto(_photoPreviewUrls.indexOf(url)),
              ),
            ),
          ],
        );
      }).toList(),
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
                      "Update Location",
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
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        labelStyle: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        labelText: 'Description',
                        border: const OutlineInputBorder(),
                        labelStyle: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
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
                        onPressed: _isUploading ? null : _updateLocationInFirebase,
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
                            backgroundColor: Color(0xff18E436)
                          ),
                      ),
                    ),
                    SizedBox(height: 16,),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (){Navigator.pushNamed(context, '/home');},
                        child: Text(
                                'Cancel',
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
                            backgroundColor: Color(0xffFC2F2F)
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