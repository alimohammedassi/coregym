import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'Login&SignUp.dart'; // Import the AuthService from your existing file

/// **UserProfileService - User Profile Data Service**
///
/// This service handles user profile data operations with Firestore
class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
      return true;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }

  // Create user profile document if it doesn't exist
  Future<bool> createUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Create profile error: $e');
      return false;
    }
  }

  // Upload profile image
  Future<String?> uploadProfileImage(String uid, File imageFile) async {
    try {
      Reference ref = _storage.ref().child('profile_images').child('$uid.jpg');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Update user document with new image URL
      await updateUserProfile(uid, {'profileImageUrl': downloadUrl});

      return downloadUrl;
    } catch (e) {
      print('Upload image error: $e');
      return null;
    }
  }
}

/// **ProfilePage - User Profile Page with Firebase Integration**
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final UserProfileService _profileService = UserProfileService();
  final ImagePicker _imagePicker = ImagePicker();
  
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      final profile = await _profileService.getUserProfile(user.uid);
      if (profile == null) {
        // Create default profile if it doesn't exist
        final defaultProfile = {
          'name': user.displayName ?? 'User',
          'email': user.email ?? '',
          'profileImageUrl': user.photoURL ?? '',
          'bio': '',
          'age': 0,
          'weight': 0.0,
          'height': 0.0,
          'fitnessGoal': '',
          'createdAt': FieldValue.serverTimestamp(),
        };
        await _profileService.createUserProfile(user.uid, defaultProfile);
        setState(() {
          _userProfile = defaultProfile;
          _isLoading = false;
        });
      } else {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() => _isUploadingImage = true);
        
        final File imageFile = File(image.path);
        final String? downloadUrl = await _profileService.uploadProfileImage(
          user.uid, 
          imageFile,
        );

        if (downloadUrl != null) {
          setState(() {
            _userProfile?['profileImageUrl'] = downloadUrl;
          });
          _showSuccessSnackBar('Profile image updated successfully!');
        } else {
          _showErrorSnackBar('Failed to upload image. Please try again.');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error selecting image: $e');
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
          (route) => false,
        );
      }
    } catch (e) {
      _showErrorSnackBar('Error signing out: $e');
    }
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userProfile?['name'] ?? '');
    final bioController = TextEditingController(text: _userProfile?['bio'] ?? '');
    final ageController = TextEditingController(text: (_userProfile?['age'] ?? 0).toString());
    final weightController = TextEditingController(text: (_userProfile?['weight'] ?? 0.0).toString());
    final heightController = TextEditingController(text: (_userProfile?['height'] ?? 0.0).toString());
    final goalController = TextEditingController(text: _userProfile?['fitnessGoal'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEditTextField(nameController, 'Name', Icons.person),
              const SizedBox(height: 16),
              _buildEditTextField(bioController, 'Bio', Icons.info, maxLines: 3),
              const SizedBox(height: 16),
              _buildEditTextField(ageController, 'Age', Icons.cake, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildEditTextField(weightController, 'Weight (kg)', Icons.scale, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildEditTextField(heightController, 'Height (cm)', Icons.height, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildEditTextField(goalController, 'Fitness Goal', Icons.track_changes),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = _authService.currentUser;
              if (user != null) {
                final updatedData = {
                  'name': nameController.text.trim(),
                  'bio': bioController.text.trim(),
                  'age': int.tryParse(ageController.text) ?? 0,
                  'weight': double.tryParse(weightController.text) ?? 0.0,
                  'height': double.tryParse(heightController.text) ?? 0.0,
                  'fitnessGoal': goalController.text.trim(),
                };

                final success = await _profileService.updateUserProfile(user.uid, updatedData);
                if (success) {
                  setState(() {
                    _userProfile = {..._userProfile!, ...updatedData};
                  });
                  Navigator.pop(context);
                  _showSuccessSnackBar('Profile updated successfully!');
                } else {
                  _showErrorSnackBar('Failed to update profile. Please try again.');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
            ),
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6C5CE7),
          ),
        ),
      );
    }

    final user = _authService.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(
          child: Text(
            'User not found',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        foregroundColor: Colors.white,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildProfileImage(),
            const SizedBox(height: 20),
            Text(
              _userProfile?['name'] ?? user.displayName ?? 'User',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _userProfile?['email'] ?? user.email ?? '',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
            if (_userProfile?['bio'] != null && _userProfile!['bio'].isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _userProfile!['bio'],
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 30),
            _buildProfileInfoCard(),
            const SizedBox(height: 30),
            _buildActionButton(
              context,
              'Edit Profile',
              Icons.edit,
              _showEditProfileDialog,
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              context,
              'Logout',
              Icons.logout,
              _showLogoutDialog,
              isDestructive: true,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    final profileImageUrl = _userProfile?['profileImageUrl'] ?? '';
    
    return Stack(
      children: [
        CircleAvatar(
          radius: 70,
          backgroundColor: const Color(0xFF2A2A2A),
          backgroundImage: profileImageUrl.isNotEmpty 
            ? NetworkImage(profileImageUrl)
            : null,
          child: profileImageUrl.isEmpty
            ? const Icon(
                Icons.person,
                size: 80,
                color: Colors.grey,
              )
            : null,
        ),
        if (_isUploadingImage)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6C5CE7),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _isUploadingImage ? null : _pickAndUploadImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF6C5CE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF424242), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.cake_outlined,
            'Age',
            (_userProfile?['age'] ?? 0) > 0 
              ? '${_userProfile!['age']} years'
              : 'Not set',
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.scale_outlined,
            'Weight',
            (_userProfile?['weight'] ?? 0.0) > 0 
              ? '${_userProfile!['weight']} kg'
              : 'Not set',
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.height_outlined,
            'Height',
            (_userProfile?['height'] ?? 0.0) > 0 
              ? '${_userProfile!['height']} cm'
              : 'Not set',
          ),
          _buildDivider(),
          _buildInfoRow(
            Icons.track_changes_outlined,
            'Fitness Goal',
            _userProfile?['fitnessGoal']?.isNotEmpty == true
              ? _userProfile!['fitnessGoal']
              : 'Not set',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFA29BFE), size: 24),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey[700], height: 20);
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed, {
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive ? Colors.red[700] : const Color(0xFF6C5CE7),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}