import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:users_connect_app/auth/signup_page.dart';
import 'package:users_connect_app/pages/home_page.dart';

import '../global.dart';
import '../widgets/loading_dialog.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  validateSignInForm()
  {
    if(!emailTextEditingController.text.trim().contains("@"))

    {
      associateMethods.showSnackBarMsg("Email is not valid", context);
    }

    else if(passwordTextEditingController.text.trim().length<5)
    {
      associateMethods.showSnackBarMsg("Password must be atleast 5 or more characters", context);
    }

    else
    {
      signInUserNow();
    }
  }

  signInUserNow() async
  {
    showDialog(
        context: context,
        builder: (BuildContext context) => LoadingDialog(messageTxt: "please wait....")
    );

    try
    {
      final User? firebaseUser = (
          await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: emailTextEditingController.text.trim(),
              password: passwordTextEditingController.text.trim()
          ).catchError((onError)
          {
            Navigator.pop(context);
            associateMethods.showSnackBarMsg(e.toString(), context);
          })
      ).user;

      if(firebaseUser !=null)
      {
        DatabaseReference ref =FirebaseDatabase.instance.ref().child("users").child(firebaseUser.uid);
        await ref.once().then((dataSnapshot)
        {

          if(dataSnapshot.snapshot.value != null)
          {
            if((dataSnapshot.snapshot.value as Map)["blockStatus"] == "no")
            {
              userName = (dataSnapshot.snapshot.value as Map)["name"];
              userPhone = (dataSnapshot.snapshot.value as Map)["phone"];
              Navigator.push(context, MaterialPageRoute(builder: (c)=> const HomePage()));
              associateMethods.showSnackBarMsg("logged-in successful", context);
            }
            else
            {
              Navigator.pop(context);
              FirebaseAuth.instance.signOut();
              associateMethods.showSnackBarMsg("You are blocked. Contact Admin", context);
            }
          }
          else
          {
            Navigator.pop(context);
            FirebaseAuth.instance.signOut();
            associateMethods.showSnackBarMsg("Your record doesn't exist as a User", context);
          }

        });

      }

    }
    on FirebaseAuthException catch(e)
    {
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
              const SizedBox(height: 122),
              Image.asset(
                "assets/signin.webp",
                width: MediaQuery.of(context).size.width*.7,

              ),

              const Text(
                "Login",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 120),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
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
                      onPressed: ()
                      {

                        validateSignInForm();

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 80,
                          vertical: 10,
                        ),
                      ),
                      child: const Text("Login", style: TextStyle(color: Colors.black),),
                    ),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupPage()
                            )
                        );
                      },
                      child: const Text(
                        "Don't have an Account? SignUp here",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
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
