// lib/screens/tutor_dashboard.dart
import 'package:comsicon/pages/courseDetails.dart';
import 'package:comsicon/services/databaseHandler.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({Key? key}) : super(key: key);

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  final DatabaseService _databaseService = DatabaseService();

  String? _userName;
  String? _photoUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _databaseService.fetchUserData();
    if (userData != null) {
      setState(() {
        _userName = userData['displayName'];
        _photoUrl = userData['photoURL'];
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddCourseDialog() async {
    // Your existing add course dialog code
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tutor Dashboard'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _databaseService.signOut(context),
          ),
        ],
      ),
      drawer: Drawer(
        // Your existing drawer code
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : StreamBuilder<List<Map<String, dynamic>>>(
                stream: _databaseService.fetchTutorCoursesRealTime(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    print("Error in StreamBuilder: ${snapshot.error}");
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final courses = snapshot.data ?? [];

                  return courses.isEmpty
                      ? _buildEmptyState()
                      : _buildCoursesList(courses);
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCourseDialog,
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add),
        tooltip: 'Add New Course',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No Courses Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Create your first micro-course',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddCourseDialog,
            icon: Icon(Icons.add),
            label: Text('Create Course'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList(List<Map<String, dynamic>> courses) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildCourseCard(course);
      },
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    // Format timestamp
    String formattedDate = 'Date not available';
    if (course['createdAt'] != null) {
      final timestamp = course['createdAt'] as Timestamp;
      formattedDate = DateFormat('MMM d, yyyy').format(timestamp.toDate());
    }

    final enrolledStudents = course['enrolledStudents'] as List? ?? [];

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        onTap: () {
          print("Course ID being passed: ${course['id']}");
          // Direct navigation to course details screen with courseId
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailsScreen(courseId: course['id']),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course image
            Container(
              height: 160,
              width: double.infinity,
              child:
                  course['coverImageUrl'] != null &&
                          course['coverImageUrl'].isNotEmpty
                      ? Image.network(
                        course['coverImageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.image_not_supported, size: 50),
                            ),
                      )
                      : Container(
                        color: Colors.indigo.withOpacity(0.2),
                        child: Center(
                          child: Icon(
                            Icons.school,
                            size: 70,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['title'] ?? 'Untitled Course',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    course['description'] ?? 'No description',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.indigo),
                      SizedBox(width: 4),
                      Text('${enrolledStudents.length} Students'),
                      SizedBox(width: 16),
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.indigo,
                      ),
                      SizedBox(width: 4),
                      Text(formattedDate),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          print("Course ID being passed: ${course['id']}");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CourseDetailsScreen(
                                    courseId: course['id'],
                                  ),
                            ),
                          );
                        },
                        icon: Icon(Icons.edit, color: Colors.indigo),
                        label: Text(
                          'Manage',
                          style: TextStyle(color: Colors.indigo),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.indigo),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmation(course['id']),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String courseId) {
    // Your existing delete confirmation dialog
  }
}
