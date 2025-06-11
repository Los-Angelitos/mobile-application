

import 'package:flutter/material.dart';
import 'package:sweetmanager/shared/widgets/base_layout.dart';

class SubscriptionPlans  extends StatelessWidget {
  const SubscriptionPlans({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseLayout(role: '', childScreen: getContentView(context));
  }

  Widget getContentView(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            PlanCard(
              icon: Icons.bed_outlined,
              title: 'BÁSICO',
              price: '\$29.99 al mes',
              features: [
                'Access to room management with IoT technology',
                'Collaborative administration for up to two people',
              ],
            ),
            SizedBox(height: 16),
            PlanCard(
              icon: Icons.apartment_outlined,
              title: 'REGULAR',
              price: '\$58.99 al mes',
              features: [
                'Access to room management with IoT technology',
                'Collaborative administration for up to two people',
                'Access to interactive business management dashboards',
              ],
            ),
            SizedBox(height: 16),
            PlanCard(
              icon: Icons.business_outlined,
              title: 'PREMIUM',
              price: '\$110.69 al mes',
              features: [
                'Access to room management with IoT technology',
                'Collaborative administration for up to two people',
                'Access to interactive business management dashboards',
                '24/7 support and maintenance',
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PlanCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String price;
  final List<String> features;

  const PlanCard({
    super.key,
    required this.icon,
    required this.title,
    required this.price,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 40, color: Colors.blue),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(price, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (var feature in features)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {},
                child: const Text('CONTRATAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}