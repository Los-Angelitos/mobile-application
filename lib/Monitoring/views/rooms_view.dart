import 'package:flutter/material.dart';
import 'package:sweetmanager/Monitoring/models/room.dart';
import 'package:sweetmanager/Monitoring/services/room_service.dart';
import 'package:sweetmanager/Monitoring/widgets/room_card.dart';

class RoomsView extends StatefulWidget {
  const RoomsView({super.key});

  @override
  State<RoomsView> createState() => _RoomsViewState();
}

class _RoomsViewState extends State<RoomsView> {
  final RoomService _roomService = RoomService();

  List<Room> _rooms = [];
  bool _isLoading = false;
  String? _error;
  bool _showAddRoomModal = false;
  bool _showStateModal = false;
  bool _isAddingRoom = false;
  bool _isUpdatingState = false;
  Room? _selectedRoom;
  String _newState = 'Disponible';

  final TextEditingController _roomNumberController = TextEditingController();
  int _selectedRoomTypeId = 1;
  String _selectedNewRoomState = 'Disponible';

  final List<RoomType> _roomTypes = [
    RoomType(id: 1, name: 'Individual'),
    RoomType(id: 2, name: 'Doble'),
    RoomType(id: 3, name: 'Suite'),
    RoomType(id: 4, name: 'Familiar'),
  ];

  final List<String> _availableStates = [
    'Disponible',
    'Ocupada',
    'Mantenimiento',
    'Limpieza',
    'Fuera de Servicio',
  ];

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  @override
  void dispose() {
    _roomNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rooms = await _roomService.getRoomsByHotel();

      setState(() {
        _rooms = rooms;
        _isLoading = false;
      });

      if (rooms.isEmpty) {
        setState(() {
          _error = 'No se encontraron habitaciones para este hotel';
        });
      }

    } catch (error) {
      setState(() {
        _isLoading = false;

        if (error.toString().contains('token') ||
            error.toString().contains('autenticación')) {
          _error = 'Problema de autenticación. Por favor, inicia sesión nuevamente.';
        } else if (error.toString().contains('401')) {
          _error = 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.';
        } else if (error.toString().contains('403')) {
          _error = 'No tienes permisos para ver las habitaciones de este hotel.';
        } else if (error.toString().contains('404')) {
          _error = 'El servicio de habitaciones no está disponible.';
        } else if (error.toString().contains('500')) {
          _error = 'Error del servidor. Por favor, intenta más tarde.';
        } else {
          _error = 'Error al cargar las habitaciones: ${error.toString()}';
        }
      });
    }
  }

  Future<void> _addRoom() async {
    if (_roomNumberController.text.trim().isEmpty) {
      _showErrorSnackBar('El número de habitación es requerido');
      return;
    }

    if (_selectedRoomTypeId == 0) {
      _showErrorSnackBar('El tipo de habitación es requerido');
      return;
    }

    final existingRoom = _rooms.any((room) =>
    room.number == _roomNumberController.text.trim() ||
        room.number == 'Habitación ${_roomNumberController.text.trim()}'
    );

    if (existingRoom) {
      _showErrorSnackBar('La habitación ${_roomNumberController.text.trim()} ya existe');
      return;
    }

    setState(() {
      _isAddingRoom = true;
    });

    try {
      final request = CreateRoomRequest(
        typeRoomId: _selectedRoomTypeId,
        hotelId: 0,
        state: _selectedNewRoomState,
        roomNumber: _roomNumberController.text.trim(),
        number: _roomNumberController.text.trim(),
        name: _roomNumberController.text.trim(),
      );

      await _roomService.createRoom(request);

      await _loadRooms();

      _closeAddRoomModal();
      _showSuccessSnackBar('Habitación creada exitosamente');

    } catch (error) {
      _showErrorSnackBar('Error al crear la habitación: ${error.toString()}');
    } finally {
      setState(() {
        _isAddingRoom = false;
      });
    }
  }

  // MÉTODO CORREGIDO: Manejo mejorado del cambio de estado
  Future<void> _updateRoomState() async {
    if (_selectedRoom == null || _newState.isEmpty) return;

    setState(() {
      _isUpdatingState = true;
    });

    try {
      // Intentar actualizar en el servidor
      await _roomService.updateRoomState(_selectedRoom!.id, _newState);

      // Actualización OPTIMISTA: Actualizar inmediatamente en la UI
      setState(() {
        final roomIndex = _rooms.indexWhere((r) => r.id == _selectedRoom!.id);
        if (roomIndex != -1) {
          _rooms[roomIndex] = Room(
            id: _rooms[roomIndex].id,
            number: _rooms[roomIndex].number,
            guest: _rooms[roomIndex].guest,
            checkIn: _rooms[roomIndex].checkIn,
            checkOut: _rooms[roomIndex].checkOut,
            available: _newState == 'Disponible',
            typeRoomId: _rooms[roomIndex].typeRoomId,
            state: _newState,
          );
        }
      });

      // CERRAR MODAL INMEDIATAMENTE después de la actualización exitosa
      _closeStateModal();

      // Mostrar mensaje de éxito
      _showSuccessSnackBar('Estado actualizado exitosamente');

      // Opcional: Recargar datos del servidor en segundo plano para sincronizar
      // pero sin bloquear la UI ni mostrar indicadores de carga
      _refreshDataSilently();

    } catch (error) {
      // Solo mostrar error si realmente falla
      _showErrorSnackBar('No se pudo actualizar el estado');

      // Cerrar modal incluso si hay error para evitar que se quede abierto
      _closeStateModal();
    } finally {
      setState(() {
        _isUpdatingState = false;
      });
    }
  }

  // NUEVO MÉTODO: Recarga silenciosa de datos
  Future<void> _refreshDataSilently() async {
    try {
      final rooms = await _roomService.getRoomsByHotel();
      setState(() {
        _rooms = rooms;
      });
    } catch (e) {
      // Error silencioso - no mostrar nada al usuario
      print('Error en recarga silenciosa: $e');
    }
  }

  void _openAddRoomModal() {
    setState(() {
      _showAddRoomModal = true;
      _roomNumberController.clear();
      _selectedRoomTypeId = 1;
      _selectedNewRoomState = 'Disponible';
    });
  }

  void _closeAddRoomModal() {
    setState(() {
      _showAddRoomModal = false;
      _isAddingRoom = false;
    });
  }

  void _openStateModal(Room room) {
    setState(() {
      _selectedRoom = room;
      _newState = room.state;
      _showStateModal = true;
    });
  }

  // MÉTODO CORREGIDO: Cierre limpio del modal
  void _closeStateModal() {
    setState(() {
      _showStateModal = false;
      _selectedRoom = null;
      _isUpdatingState = false;
      _newState = 'Disponible'; // Reset del estado
    });
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) { // Verificar que el widget esté montado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2), // Reducido a 2 segundos
          behavior: SnackBarBehavior.floating, // Floating para mejor UX
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) { // Verificar que el widget esté montado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating, // Floating para mejor UX
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Header personalizado
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Título centrado
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Gestión de Habitaciones',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    // Acciones a la derecha
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.black87),
                          onPressed: _loadRooms,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.black87),
                          onPressed: _openAddRoomModal,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Contenedor de estadísticas
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFF8F9FA),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total de habitaciones: ${_rooms.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Disponibles: ${_rooms.where((r) => r.available).length}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _buildRoomsContent(),
              ),
            ],
          ),

          // MODALES CONDICIONALES: Solo mostrar si están activos
          if (_showAddRoomModal && !_isUpdatingState) _buildAddRoomModal(),
          if (_showStateModal && !_isAddingRoom) _buildStateModal(),
        ],
      ),
    );
  }

  Widget _buildRoomsContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando habitaciones...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRooms,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_rooms.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hotel_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No hay habitaciones registradas',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Agrega tu primera habitación usando el botón +',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _rooms.length,
      itemBuilder: (context, index) {
        final room = _rooms[index];
        return RoomCardWidget(
          room: room,
          onChangeState: () => _openStateModal(room),
        );
      },
    );
  }

  Widget _buildAddRoomModal() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Agregar Nueva Habitación',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _closeAddRoomModal,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _roomNumberController,
                decoration: const InputDecoration(
                  labelText: 'Número de Habitación',
                  border: OutlineInputBorder(),
                  hintText: 'Ej: 101, 202, etc.',
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                value: _selectedRoomTypeId,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Habitación',
                  border: OutlineInputBorder(),
                ),
                items: _roomTypes.map((type) {
                  return DropdownMenuItem<int>(
                    value: type.id,
                    child: Text(type.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRoomTypeId = value ?? 1;
                  });
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedNewRoomState,
                decoration: const InputDecoration(
                  labelText: 'Estado Inicial',
                  border: OutlineInputBorder(),
                ),
                items: _availableStates.map((state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedNewRoomState = value ?? 'Disponible';
                  });
                },
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _closeAddRoomModal,
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isAddingRoom ? null : _addRoom,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066CC),
                      foregroundColor: Colors.white,
                    ),
                    child: _isAddingRoom
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text('Crear Habitación'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateModal() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cambiar Estado de Habitación',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _closeStateModal,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (_selectedRoom != null) ...[
                Text(
                  'Habitación: ${_selectedRoom!.number}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Estado actual: ${_selectedRoom!.state}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _availableStates.contains(_newState) ? _newState : _availableStates.first,
                  decoration: const InputDecoration(
                    labelText: 'Nuevo Estado',
                    border: OutlineInputBorder(),
                  ),
                  items: _availableStates.map((state) {
                    return DropdownMenuItem<String>(
                      value: state,
                      child: Text(state),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _newState = value ?? 'Disponible';
                    });
                  },
                ),
              ],
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _closeStateModal,
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isUpdatingState ? null : _updateRoomState,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066CC),
                      foregroundColor: Colors.white,
                    ),
                    child: _isUpdatingState
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text('Actualizar Estado'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}