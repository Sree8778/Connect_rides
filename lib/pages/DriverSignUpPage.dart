import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:users_connect_app/widgets/loading_dialog.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class DriverSignUpPage extends StatefulWidget {
  const DriverSignUpPage({Key? key}) : super(key: key);

  @override
  _DriverSignUpPageState createState() => _DriverSignUpPageState();
}

class _DriverSignUpPageState extends State<DriverSignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController carModelController = TextEditingController();
  final TextEditingController carNumberController = TextEditingController();

  File? _driverLicense;
  File? _carInsurance;
  File? _vehicleRegistration;

  final ImagePicker _picker = ImagePicker();

  // Pick an image from the gallery
  Future<void> _pickImage(String type) async {
    final permissionStatus = await Permission.photos.request();
    if (permissionStatus.isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          if (type == 'driver_license') {
            _driverLicense = File(pickedFile.path);
          } else if (type == 'car_insurance') {
            _carInsurance = File(pickedFile.path);
          } else if (type == 'vehicle_registration') {
            _vehicleRegistration = File(pickedFile.path);
          }
        });
      }
    } else {
      // Handle permission denial
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission to access photos denied')),
      );
    }
  }

  // Validate the form fields
  void validateForm() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().length < 10 ||
        email.isEmpty ||
        !email.contains("@") ||
        password.length < 6 ||
        password != confirmPassword ||
        _driverLicense == null ||
        _carInsurance == null ||
        _vehicleRegistration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and upload documents')),
      );
    } else {
      signUpDriver();
    }
  }

  // Sign up driver and save data to Firebase
  Future<void> signUpDriver() async {
    showDialog(
      context: context,
      builder: (BuildContext context) =>  LoadingDialog(messageTxt: 'Signing up...'),
    );

    try {
      final User? firebaseUser = (await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      ))
          .user;

      if (firebaseUser != null) {
        // Upload images to Firebase Storage
        String driverLicenseUrl = await uploadImage(_driverLicense!, 'driver_licenses');
        String carInsuranceUrl = await uploadImage(_carInsurance!, 'car_insurances');
        String vehicleRegistrationUrl = await uploadImage(_vehicleRegistration!, 'vehicle_registrations');

        Map<String, dynamic> driverData = {
          "name": nameController.text.trim(),
          "phone": phoneController.text.trim(),
          "email": emailController.text.trim(),
          "car_model": carModelController.text.trim(),
          "car_number": carNumberController.text.trim(),
          "driver_license": driverLicenseUrl,
          "car_insurance": carInsuranceUrl,
          "vehicle_registration": vehicleRegistrationUrl,
          "status": "pending", // Driver status can be 'pending' until verified
          "id": firebaseUser.uid,
        };

        // Save driver data to Realtime Database
        FirebaseDatabase.instance.ref().child("drivers").child(firebaseUser.uid).set(driverData);

        Navigator.pop(context); // Close loading dialog
        Navigator.pop(context); // Close sign-up page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver registered successfully!')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Upload image to Firebase Storage
  Future<String> uploadImage(File file, String folder) async {
    try {
      String fileName = path.basename(file.path);
      Reference storageReference = FirebaseStorage.instance.ref().child('$folder/$fileName');
      UploadTask uploadTask = storageReference.putFile(file);

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Error uploading image: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Sign-Up'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
              ),
              TextField(
                controller: carModelController,
                decoration: const InputDecoration(labelText: 'Car Model'),
              ),
              TextField(
                controller: carNumberController,
                decoration: const InputDecoration(labelText: 'Car Number'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _pickImage('driver_license'),
                child: const Text('Upload Driver License'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _pickImage('car_insurance'),
                child: const Text('Upload Car Insurance'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _pickImage('vehicle_registration'),
                child: const Text('Upload Vehicle Registration'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: validateForm,
                child: const Text('Sign Up as Driver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
