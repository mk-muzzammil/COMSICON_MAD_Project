import 'dart:io';
import 'package:comsicon/pages/sideBar.dart';
import 'package:comsicon/services/databaseHandler.dart';
import 'package:comsicon/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _databaseService = DatabaseService();
  final ImagePicker _picker = ImagePicker();

  String? _selectedRole;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Reduce quality for faster uploads
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _handleContinue() async {
    if (_formKey.currentState!.validate() && _selectedRole != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Step 1: Upload image to Cloudinary if selected
        String? photoURL;
        if (_imageFile != null) {
          try {
            // Ensure the CloudinaryService is properly initialized
            await _databaseService.uploadProfilePhoto(
              filePath: _imageFile!.path,
              context: context,
            );

            // Fetch the user data to get the uploaded image URL
            final userData = await _databaseService.fetchUserData();
            photoURL = userData?['photoURL'];

            // If the upload failed or URL was not saved properly
            if (photoURL == null || photoURL.isEmpty) {
              throw Exception("Failed to get uploaded image URL");
            }
          } catch (e) {
            // Log the error but continue with profile setup
            print('Image upload error: $e');
            // Show a message but don't stop the process
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Warning: Image upload failed, continuing with profile setup',
                ),
              ),
            );
          }
        }

        // Step 2: Save profile data
        await _databaseService.saveProfileData(
          Name: _nameController.text,
          Role: _selectedRole!,
          context: context,
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error setting up profile: $e')));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the profile setup')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(Icons.menu, color: theme.iconTheme.color),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
      ),
      drawer: CustomSidebar(
        userName: _nameController.text.isEmpty ? "User" : _nameController.text,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile Setup',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Circle Avatar with Image Picker
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              GestureDetector(
                                onTap: _pickImage,
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: theme.colorScheme.surface,
                                  backgroundImage:
                                      _imageFile != null
                                          ? FileImage(_imageFile!)
                                          : const AssetImage(
                                                'assets/images/Avatar.png',
                                              )
                                              as ImageProvider,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: theme.colorScheme.onPrimary,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Name input field
                        Text('Your Name', style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          style: theme.textTheme.bodyLarge,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Role selection (Tutor or Student)
                        Text(
                          'Select Your Role',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _RoleCard(
                                title: 'Tutor',
                                icon: Icons.school,
                                isSelected: _selectedRole == 'Tutor',
                                iconColor: AppColors.lightTextSecondary,
                                onTap:
                                    () =>
                                        setState(() => _selectedRole = 'Tutor'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _RoleCard(
                                title: 'Student',
                                icon: Icons.person,
                                isSelected: _selectedRole == 'Student',
                                iconColor: AppColors.darkTextSecondary,
                                onTap:
                                    () => setState(
                                      () => _selectedRole = 'Student',
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Continue button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : Text(
                                      'Continue',
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: theme.colorScheme.onPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final Color iconColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? theme.colorScheme.onPrimary : iconColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color:
                    isSelected ? theme.colorScheme.onPrimary : theme.hintColor,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
