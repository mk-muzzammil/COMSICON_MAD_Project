// import 'package:comsicon/services/cloudinaryServices.dart';
// import 'package:comsicon/utils/constants.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// // import 'package:google_sign_in/google_sign_in.dart';

// class DatabaseService {
//   final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance

//   // ------------------- AUTH METHODS (unchanged) -------------------
//   Future<bool> login({
//     required String email,
//     required String password,
//     required BuildContext context,
//   }) async {
//     try {
//       final UserCredential userCredential = await _auth
//           .signInWithEmailAndPassword(email: email, password: password);

//       if (userCredential.user != null) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Logged in successfully!')));
//         Navigator.pushNamed(context, '/home');
//         return true; // Indicate success
//       }
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Login failed: ${e.message}')));
//       return false; // Indicate failure
//     }
//     return false;
//   }

//   Future<bool> signUp({
//     required String email,
//     required String password,
//     required BuildContext context,
//   }) async {
//     try {
//       final UserCredential credential = await _auth
//           .createUserWithEmailAndPassword(email: email, password: password);

//       if (credential.user != null) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('User created successfully!')));
//         Navigator.pushNamed(context, '/profileSetup');
//         return true; // Indicate success
//       }
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Sign up failed: ${e.message}')));
//       return false; // Indicate failure
//     }
//     return false;
//   }

//   Future<void> signOut(BuildContext context) async {
//     try {
//       await _auth.signOut().then(
//         (value) => {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text('Log Out Successfully'))),
//           Navigator.pushNamed(context, '/login'),
//         },
//       );
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Sign out failed: ${e.message}')));
//     }
//   }

//   // Future<UserCredential?> logInWithGoogle(BuildContext context) async {
//   //   try {
//   //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//   //     if (googleUser == null) return null; // User canceled sign-in

//   //     final GoogleSignInAuthentication googleAuth =
//   //         await googleUser.authentication;

//   //     final AuthCredential credential = GoogleAuthProvider.credential(
//   //       accessToken: googleAuth.accessToken,
//   //       idToken: googleAuth.idToken,
//   //     );

//   //     final UserCredential userCredential =
//   //         await _auth.signInWithCredential(credential);
//   //     final User? user = userCredential.user;

//   //     if (user != null) {
//   //       // Store user information in Firebase Realtime Database
//   //       await _database.child('users').child(user.uid).set({
//   //         'displayName': user.displayName,
//   //         'email': user.email,
//   //         'photoURL': user.photoURL,
//   //       });
//   //     }

//   //     return userCredential;
//   //   } on FirebaseAuthException catch (e) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Google sign-in failed: ${e.message}')),
//   //     );
//   //   }
//   //   return null;
//   // }

//   // If you upload images to Cloudinary
//   // Future<String?> uploadChallengeImage(String filePath) async {
//   //   try {
//   //     final CloudinaryService cloudinaryService = CloudinaryService();
//   //     final String? imageUrl = await cloudinaryService.uploadImage(
//   //       filePath,
//   //       AppConstants.cloudinaryUploadPreset,
//   //       fileName: 'challenge_image_${DateTime.now().millisecondsSinceEpoch}',
//   //     );
//   //     return imageUrl;
//   //   } catch (e) {
//   //     throw Exception("Failed to upload challenge image: $e");
//   //   }
//   // }
// }
