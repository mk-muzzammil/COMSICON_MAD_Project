import 'package:flutter/material.dart';

class AppConstants {
  // Cloudinary Configurations
  static const String cloudinaryCloudName = 'djnqejhoj';

  // Make sure this exact upload preset name exists in your Cloudinary account
  static const String cloudinaryUploadPreset = 'EdTech';

  // These folders will be created automatically in Cloudinary
  static const String cloudinaryUsersFolder = 'EdTech/Users';

  // API URL (for debugging only)
  static String get cloudinaryApiUrl =>
      'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload';

  // Add other app constants here as needed
}
