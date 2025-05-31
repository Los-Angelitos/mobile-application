import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _countries = ['Perú', 'Argentina', 'Chile'];
  final _languages = ['Español', 'Inglés', 'Portugués'];

  Map<String, dynamic> _userData = {};
  Map<String, bool> _editMode = {
    'name': false,
    'email': false,
    'phone': false,
    'password': false,
  };

  final _controllers = {
    'name': TextEditingController(),
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
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _userData = {
        'name': 'Arian Rodriguez',
        'email': 'arianrmv12@gmail.com',
        'phone': '+34 654 123 456',
        'password': '********'
      };

      _controllers['name']!.text = _userData['name'];
      _controllers['email']!.text = _userData['email'];
      _controllers['phone']!.text = _userData['phone'];
      _controllers['password']!.text = '';
    });
  }

  Future<void> _updateField(String field) async {
    setState(() => _editMode[field] = false);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _userData[field] = _controllers[field]!.text;
      if (field == 'password') {
        _userData[field] = '********';
      }
    });
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
          const CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_userData['name'] ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('Guest', style: TextStyle(color: Colors.grey)),
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
          _editableRow('name', 'Full name'),
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
