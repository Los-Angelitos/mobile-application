import 'package:flutter/material.dart';
import 'package:sweetmanager/IAM/domain/model/aggregates/guest.dart';
import 'package:sweetmanager/IAM/domain/model/aggregates/owner.dart';
import 'package:sweetmanager/IAM/domain/model/entities/guest_preference.dart';
import 'package:sweetmanager/IAM/domain/model/queries/update_guest_preferences.dart';
import 'package:sweetmanager/IAM/infrastructure/auth/user_service.dart';

class UserPreferencesPage extends StatefulWidget {
  final UserService userService = UserService();
  Guest? guestProfile;
  Owner? ownerProfile;

  @override
  _GuestProfileScreenState createState() => _GuestProfileScreenState();
}

class _GuestProfileScreenState extends State<UserPreferencesPage> {
  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  String get userFullName {
    return widget.ownerProfile?.name ??
        widget.guestProfile?.name ??
        'Unknown User';
  }

  String get userRole {
    return widget.ownerProfile != null ? 'Owner' : 'Guest';
  }

  Future<void> fetchUserProfile() async {
    try {
      widget.guestProfile = await widget.userService.getGuestProfile();
      widget.ownerProfile = await widget.userService.getOwnerProfile();
      setState(() {});

      await recoverGuestPreferences();

      print(
          'User profile fetched successfully: ${widget.guestProfile?.toJson()}');
      print(
          'Owner profile fetched successfully: ${widget.ownerProfile?.toJson()}');
    } catch (e) {
      print('Error fetching user profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<GuestPreferences?> recoverGuestPreferences() async {
    if (widget.guestProfile == null) {
      print('Guest profile is null, cannot recover preferences');
      return null;
    }

    try {
      final response = await widget.userService.getGuestPreferences();

      if (response != null) {
        setState(() {
          temperature = response.temperature.toString();
        });

        return response;
      } else {
        print('No preferences found for guest ID ${widget.guestProfile!.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No preferences found')),
        );
        return null;
      }
    } catch (e) {
      print('Error recovering guest preferences: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to recover preferences')),
      );
      return null;
    }
  }

  Future<void> updateGuestPreferences(int temperature) async {
    if (widget.guestProfile == null) {
      print('Guest profile is null, cannot update preferences');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Guest profile not found')),
      );
      return;
    }

    if (temperature <= 0 || temperature > 50 || temperature is String) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid temperature')),
      );
      return;
    }

    try {
      final updatedPreferences = EditGuestPreferences(
        temperature: temperature,
        guestId: widget.guestProfile!.id,
      );

      // get the current preferences, if does not exist, create a new one
      final currentPreferences = await recoverGuestPreferences();
      if (currentPreferences == null) {
        // Create new preferences if none exist
        await widget.userService.setGuestPreferences(GuestPreferences(
          id: 0, // New preference, ID will be assigned by the backend
          guestId: widget.guestProfile!.id,
          temperature: temperature,
        ));
      } else {
        // Update existing preferences
        await widget.userService
            .updateGuestPreferences(updatedPreferences, currentPreferences.id);
      }

      // Update the local state with the new temperature
      setState(() {
        this.temperature = temperature.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preferences updated successfully')),
      );
    } catch (e) {
      print('Error updating guest preferences: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update preferences')),
      );
    }
  }

  String temperature = '';
  String lightType = 'Hot';
  String foodPreferences = 'Meat';
  String drinkPreferences = 'Soda, Water';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              userFullName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              userRole,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 32),

            // Preference Items
            PreferenceItem(
              title: 'Ideal Temperature for the room (C°)',
              value: temperature,
              onEdit: () =>
                  _editPreference('Temperature', temperature, (newValue) {
                setState(() {
                  temperature = newValue;
                });
              }),
            ),
            SizedBox(height: 24),

            PreferenceItem(
              title: 'Light Type',
              value: lightType,
              onEdit: () =>
                  _editPreference('Light Type', lightType, (newValue) {
                setState(() {
                  lightType = newValue;
                });
              }),
            ),
            SizedBox(height: 24),

            PreferenceItem(
              title: 'Food Preferences',
              value: foodPreferences,
              onEdit: () => _editPreference('Food Preferences', foodPreferences,
                  (newValue) {
                setState(() {
                  foodPreferences = newValue;
                });
              }),
            ),
            SizedBox(height: 24),

            PreferenceItem(
              title: 'Drink Preferences',
              value: drinkPreferences,
              onEdit: () => _editPreference(
                  'Drink Preferences', drinkPreferences, (newValue) {
                setState(() {
                  drinkPreferences = newValue;
                });
              }),
            ),
            SizedBox(height: 32),

            // Request Card Button
            GestureDetector(
              onTap: () => _showRequestCardModal(),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Couldn't find your entry card",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Request cancellation of your previous access card to obtain a new one.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.open_in_new,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Request',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editPreference(
      String title, String currentValue, Function(String) onSave) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditPreferenceDialog(
          title: title,
          currentValue: currentValue,
          onSave: onSave,
          // Solo pasar la función de actualización si es temperatura
          onUpdateTemperature: title.contains('Temperature')
              ? (int temp) async => await updateGuestPreferences(temp)
              : null,
        );
      },
    );
  }

  void _showRequestCardModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RequestCardModal();
      },
    );
  }
}

class PreferenceItem extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onEdit;

  const PreferenceItem({
    Key? key,
    required this.title,
    required this.value,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              size: 20,
              color: Colors.grey[600],
            ),
            onPressed: onEdit,
          ),
          Text(
            'Edit',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class EditPreferenceDialog extends StatefulWidget {
  final String title;
  final String currentValue;
  final Function(String) onSave;
  final Function(int)?
      onUpdateTemperature; // Agregar callback para actualizar temperatura

  const EditPreferenceDialog({
    Key? key,
    required this.title,
    required this.currentValue,
    required this.onSave,
    this.onUpdateTemperature, // Parámetro opcional
  }) : super(key: key);

  @override
  _EditPreferenceDialogState createState() => _EditPreferenceDialogState();
}

class _EditPreferenceDialogState extends State<EditPreferenceDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Text(
        'Edit ${widget.title}',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        autofocus: true,
        keyboardType: widget.title.contains('Temperature')
            ? TextInputType.number
            : TextInputType.text, // Teclado numérico para temperatura
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final newValue = _controller.text;

            // Actualizar el estado local primero
            widget.onSave(newValue);

            // Si es temperatura, actualizar en el backend
            if (widget.title.contains('Temperature') &&
                widget.onUpdateTemperature != null) {
              int temperature = int.tryParse(newValue) ?? 0;
              if (temperature > 0) {
                await widget.onUpdateTemperature!(temperature);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid temperature'),
                    backgroundColor: Colors.red,
                  ),
                );
                return; // No cerrar el diálogo si la temperatura no es válida
              }
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${widget.title} updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          },
          child: Text('Save'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class RequestCardModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Image
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue[400]!, Colors.blue[600]!],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.credit_card,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Request New Entry Card',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your previous access card will be cancelled and a new one will be issued. This process may take up to 24 hours to complete.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Card request submitted successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: Text('Request'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
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
}
