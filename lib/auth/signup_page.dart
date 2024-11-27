import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:users_connect_app/auth/signin_page.dart';
import 'package:users_connect_app/pages/home_page.dart';
import 'package:users_connect_app/widgets/loading_dialog.dart';

import 'package:users_connect_app/pages/DriverSignUpPage.dart'; // Correct the path as needed


import '../global.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  File? selectedFile;
  String fileUrl = "";  // To store the file URL after upload

  // Function to pick the file (driver documents)
  pickFile() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        selectedFile = File(file.path);
      });
    }
  }

  // Upload the selected file to Firebase Storage
  uploadFile() async {
    if (selectedFile != null) {
      final storageRef = FirebaseStorage.instance.ref().child('driver_documents/${DateTime.now().millisecondsSinceEpoch}.jpg');
      try {
        await storageRef.putFile(selectedFile!);
        fileUrl = await storageRef.getDownloadURL();  // Get the file URL
        print("File uploaded successfully: $fileUrl");
      } catch (e) {
        print("Error uploading file: $e");
        associateMethods.showSnackBarMsg("File upload failed", context);
      }
    } else {
      associateMethods.showSnackBarMsg("No file selected", context);
    }
  }

  validateSignUpForm() {
    if (userNameTextEditingController.text.trim().length < 3) {
      associateMethods.showSnackBarMsg("Name must be at least 5 or more characters", context);
    } else if (userPhoneTextEditingController.text.trim().length < 10) {
      associateMethods.showSnackBarMsg("Phone number must be at least 10 or more numbers", context);
    } else if (!emailTextEditingController.text.trim().contains("@")) {
      associateMethods.showSnackBarMsg("Email is not valid", context);
    } else if (passwordTextEditingController.text.trim().length < 5) {
      associateMethods.showSnackBarMsg("Password must be at least 5 or more characters", context);
    } else {
      signUpUserNow();
    }
  }

  signUpUserNow() async {
    showDialog(
        context: context,
        builder: (BuildContext context) => LoadingDialog(messageTxt: "please wait....")
    );
    try {
      final User? firebaseUser = (
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: emailTextEditingController.text.trim(),
              password: passwordTextEditingController.text.trim()
          ).catchError((onError) {
            Navigator.pop(context);
            associateMethods.showSnackBarMsg(onError.toString(), context);
          })
      ).user;

      Map userDataMap = {
        "name": userNameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": userPhoneTextEditingController.text.trim(),
        "id": firebaseUser!.uid,
        "blockStatus": "no",
        "driverDocumentUrl": fileUrl,  // Store the document URL here
      };
      FirebaseDatabase.instance.ref().child("users").child(firebaseUser.uid).set(userDataMap);
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (c) => const HomePage()));
    } on FirebaseAuthException catch (e) {
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
      associateMethods.showSnackBarMsg(e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Image.asset(
                "assets/signup.webp",
                width: MediaQuery.of(context).size.width * .7,
              ),
              const Text(
                "Register New Account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 70),
              Padding(
                padding: const EdgeInsets.all(1),
                child: Column(
                  children: [
                    TextField(
                      controller: userNameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "User Name",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    TextField(
                      controller: userPhoneTextEditingController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "User Phone Number",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "User Email",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "User Password",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        validateSignUpForm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 80,
                          vertical: 10,
                        ),
                      ),
                      child: const Text("SignUp", style: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SigninPage()),
                        );
                      },
                      child: const Text(
                        "I already have an account! Login here",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DriverSignUpPage

































































































































































































































































                            ()),
                        );
                      },
                      child: const Text(
                        "Are you a driver? Register here",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Button to upload documents
                    ElevatedButton(
                      onPressed: pickFile,
                      child: const Text("Upload Driver Documents"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
