import 'package:flutter/material.dart';
import '../models/provider.dart';
import '../services/provider_service.dart';
import '../widgets/provider_card.dart';

class ProvidersView extends StatefulWidget {
  const ProvidersView({super.key});

  @override
  State<ProvidersView> createState() => _ProvidersViewState();
}

class _ProvidersViewState extends State<ProvidersView> {
  final ProviderService _providerService = ProviderService();
  List<Provider> _providers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProviders();
  }

  Future<void> _fetchProviders() async {
    final result = await _providerService.getProviders();
    setState(() {
      _providers = result.where((p) => p.state.toLowerCase() == 'active').toList();
      _loading = false;
    });
  }

  void _showDetails(Provider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
            ),
            const SizedBox(height: 12),
            Text(provider.name, textAlign: TextAlign.center),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Email: ${provider.email}'),
            Text('Phone: ${provider.phone}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  void _deleteProvider(Provider provider) async {
    final success = await _providerService.deleteProvider(provider.id);
    if (success == false) {
      _fetchProviders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete provider')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Providers")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: _providers.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final provider = _providers[index];
            return ProviderCard(
              provider: provider,
              onDetailsPressed: () => _showDetails(provider),
              onDeletePressed: () => _deleteProvider(provider),
            );
          },
        ),
      ),
    );
  }
}
