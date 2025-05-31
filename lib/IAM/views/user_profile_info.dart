import 'package:flutter/material.dart';
import 'package:sweetmanager/IAM/domain/model/aggregates/guest.dart';
import 'package:sweetmanager/IAM/domain/model/aggregates/owner.dart';
import 'package:sweetmanager/IAM/domain/model/queries/update_user_profile_request.dart';
import 'package:sweetmanager/IAM/infrastructure/auth/user_service.dart';

class ProfilePage extends StatefulWidget {
  Owner? ownerProfile;
  Guest? guestProfile;
  String? userType;

  final userId = 72221572; // Replace with actual user ID logic
  final roleId = 3; // Replace with actual role ID logic

  ProfilePage(
      {super.key, this.ownerProfile, this.guestProfile, this.userType}) {
    print('ProfilePage initialized with userType: $userType');
    print('Owner Profile: ${ownerProfile?.toJson()}');
    print('Guest Profile: ${guestProfile?.toJson()}');
  }

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService userService = UserService();

  String get userFullName {
    return widget.ownerProfile?.name ??
        widget.guestProfile?.name ??
        'Unknown User';
  }

  String get userRole {
    return widget.ownerProfile != null ? 'Owner' : 'Guest';
  }

  String get userPhotoURL {
    return widget.ownerProfile?.photoURL ??
        widget.guestProfile?.photoURL ??
        'https://static.vecteezy.com/system/resources/previews/009/292/244/non_2x/default-avatar-icon-of-social-media-user-vector.jpg'; // Default image
  }

  final _countries = ['Perú', 'Argentina', 'Chile'];
  final _languages = ['Español', 'Inglés', 'Portugués'];

  Map<String, dynamic> _userData = {};
  Map<String, bool> _editMode = {
    'name': false,
    'surname': false,
    'email': false,
    'phone': false,
    'password': false,
  };

  final _controllers = {
    'name': TextEditingController(),
    'surname': TextEditingController(),
    'email': TextEditingController(),
    'phone': TextEditingController(),
    'password': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (widget.guestProfile == null && widget.ownerProfile == null) {
      try {
        widget.guestProfile = await userService.getGuestProfile(widget.userId);
        widget.ownerProfile = await userService.getOwnerProfile(widget.userId);

        if (widget.guestProfile != null) {
          widget.userType = 'Guest';
        } else if (widget.ownerProfile != null) {
          widget.userType = 'Owner';
        } else {
          widget.userType = 'unknown';
        }
      } catch (e) {
        print('Error fetching guest profile: $e');
      }
    }

    if (widget.userType == 'Owner') {
      _userData = {
        'name': widget.ownerProfile?.name ?? '',
        'surname': widget.ownerProfile?.surname ?? '',
        'email': widget.ownerProfile?.email ?? '',
        'phone': widget.ownerProfile?.phone ?? '',
        'password': '********'
      };
    } else if (widget.userType == 'Guest') {
      _userData = {
        'name': widget.guestProfile?.name ?? '',
        'surname': widget.guestProfile?.surname ?? '',
        'email': widget.guestProfile?.email ?? '',
        'phone': widget.guestProfile?.phone ?? '',
        'password': '********'
      };
    } else {
      _userData = {
        'name': 'Unknown User',
        'surname': 'Unknown Surname',
        'email': '',
        'phone': '',
        'password': '********'
      };
    }

    _controllers['name']!.text = _userData['name'];
    _controllers['surname']!.text =
        _userData['surname']; // Assuming surname is same as name
    _controllers['email']!.text = _userData['email'];
    _controllers['phone']!.text = _userData['phone'];
    _controllers['password']!.text = '';
    setState(() {});
  }

  Future<void> _updateField(String field) async {
    setState(() => _editMode[field] = false);

    try {
      String newValue = _controllers[field]!.text.trim();
      if (newValue.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Field cannot be empty')));

        return;
      }

      if (newValue == _userData[field]) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$field has not changed')),
        );

        return;
      }

      if (field == 'password') {
        newValue = '********'; // Placeholder for actual password handling
      }

      // Update the user data locally
      _userData[field] = newValue;

      // Call the service to update the user profile
      final request = EditUserProfileRequest(
        name: _userData['name'],
        surname: _userData['surname'],
        phone: _userData['phone'],
        email: _userData['email'],
        state: (widget.userType == 'Owner')
            ? widget.ownerProfile?.state
            : widget.guestProfile?.state,
        roleId: widget.roleId,
        photoURL: userPhotoURL, // Assuming photo URL remains unchanged
      );

      final success = await userService.updateUserProfile(
        request,
        widget.userId,
        widget.roleId,
      );

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update $field')),
        );
        print('Failed to update $field');

        setState(() {
          _userData[field] =
              _controllers[field]!.text; // Revert to previous value
        });

        return;
      }

      // If successful, update the UI
      setState(() {
        _userData[field] = newValue;
        _controllers[field]!.text = newValue; // Update controller text
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$field updated successfully')),
      );
    } catch (e) {
      print('Error updating $field: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update $field: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildEditableInfo(),
            const SizedBox(height: 16),
            _buildAdditionalForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(userPhotoURL),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_userData['name'] ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text(userRole, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personal information',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _editableRow('name', 'Name'),
          _editableRow('surname', 'Surname'),
          _editableRow('email', 'Email address'),
          _editableRow('phone', 'Phone number'),
          _editableRow('password', 'Password'),
        ],
      ),
    );
  }

  Widget _editableRow(String fieldKey, String label) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: _editMode[fieldKey]!
          ? TextField(
              controller: _controllers[fieldKey],
              obscureText: fieldKey == 'password',
              decoration: const InputDecoration(isDense: true),
            )
          : Text(_userData[fieldKey] ?? '',
              style: const TextStyle(color: Colors.grey)),
      trailing: GestureDetector(
        child: Text(
          _editMode[fieldKey]! ? 'Save' : 'Edit',
          style: const TextStyle(color: Colors.blue),
        ),
        onTap: () {
          if (_editMode[fieldKey]!) {
            _updateField(fieldKey);
          } else {
            setState(() => _editMode[fieldKey] = true);
          }
        },
      ),
    );
  }

  Widget _buildAdditionalForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Additional information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Birth date',
              hintText: 'dd/mm/aaaa',
              suffixIcon: Icon(Icons.calendar_today),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Country'),
            value: _countries.first,
            items: _countries
                .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                .toList(),
            onChanged: (value) {},
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Favorite language'),
            value: _languages.first,
            items: _languages
                .map((l) => DropdownMenuItem<String>(value: l, child: Text(l)))
                .toList(),
            onChanged: (value) {},
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Save changes',
                style: TextStyle(fontSize: 16, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B61B6),
              minimumSize: const Size.fromHeight(45),
            ),
          ),
        ],
      ),
    );
  }
}
