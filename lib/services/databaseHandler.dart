import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comsicon/services/cloudinaryServices.dart';
import 'package:comsicon/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // AUTH METHODS (unchanged)
  Future<bool> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logged in successfully!')));
        Navigator.pushNamed(context, '/home');
        return true;
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: ${e.message}')));
      return false;
    }
    return false;
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User created successfully!')));
        Navigator.pushNamed(context, '/profileSetup');
        return true;
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign up failed: ${e.message}')));
      return false;
    }
    return false;
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut().then(
        (value) => {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Log Out Successfully'))),
          Navigator.pushNamed(context, '/login'),
        },
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign out failed: ${e.message}')));
    }
  }

  // FIRESTORE USER DATA METHODS

  // Fetch user data from Firestore
  Future<Map<String, dynamic>?> fetchUserData() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (userDoc.exists) {
          return userDoc.data() as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  // Save profile data to Firestore
  Future<bool> saveProfileData({
    required String Name,
    required String Role,
    String? PhotoURL,
    required BuildContext context,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User is not logged in')));
      return false;
    }

    try {
      // Create the data map
      Map<String, dynamic> userData = {
        'displayName': Name,
        'email': user.email,
        'role': Role,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Only add photoURL if it's provided and not empty
      if (PhotoURL != null && PhotoURL.isNotEmpty) {
        userData['photoURL'] = PhotoURL;
      }

      // Check if this is a new user
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // Add createdAt for new users
        userData['createdAt'] = FieldValue.serverTimestamp();
      }

      // Use set with merge option to handle both new and existing documents
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile data saved successfully')),
      );

      Navigator.of(context).pushReplacementNamed('/home');
      return true;
    } catch (error) {
      print('Error saving profile data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile data: $error')),
      );
      return false;
    }
  }

  // Update specific user data fields
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Add timestamp for when the document was updated
        data['updatedAt'] = FieldValue.serverTimestamp();

        await _firestore.collection('users').doc(currentUser.uid).update(data);
      }
    } catch (e) {
      print('Error updating user data: $e');
      throw e;
    }
  }

  // Upload profile photo to Cloudinary and update user profile in Firestore
  Future<String?> uploadProfilePhoto({
    required String filePath,
    required BuildContext context,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User is not logged in')));
      return null;
    }

    try {
      print('Starting upload to Cloudinary...');
      print('Upload preset: ${AppConstants.cloudinaryUploadPreset}');

      // Upload to Cloudinary
      final CloudinaryService cloudinaryService = CloudinaryService();
      final String? imageUrl = await cloudinaryService.uploadImage(
        filePath,
        AppConstants.cloudinaryUploadPreset,
        folder: 'EdTech/Users',
      );

      print('Cloudinary upload complete, URL: $imageUrl');

      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          // First check if the document exists
          DocumentSnapshot docSnapshot =
              await _firestore.collection('users').doc(user.uid).get();

          if (docSnapshot.exists) {
            // If document exists, update it
            await _firestore.collection('users').doc(user.uid).update({
              'photoURL': imageUrl,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          } else {
            // If document doesn't exist, create it with set()
            await _firestore.collection('users').doc(user.uid).set({
              'photoURL': imageUrl,
              'email': user.email,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated successfully!'),
            ),
          );

          return imageUrl;
        } catch (firestoreError) {
          print('Firestore error: $firestoreError');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving photo URL: $firestoreError')),
          );
          // Still return the URL even if Firestore update failed
          return imageUrl;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload profile photo')),
        );
        return null;
      }
    } catch (e) {
      print('Profile photo upload error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading photo: $e')));
      return null;
    }
  }

  // Upload challenge image to Cloudinary
  Future<String?> uploadChallengeImage(String filePath) async {
    try {
      final String? imageUrl = await _cloudinaryService.uploadImage(
        filePath,
        AppConstants.cloudinaryUploadPreset,
        fileName: 'challenge_${DateTime.now().millisecondsSinceEpoch}',
        folder: 'EdTech/Challenges',
      );
      return imageUrl;
    } catch (e) {
      print('Challenge image upload error: $e');
      throw Exception("Failed to upload challenge image: $e");
    }
  }
}
