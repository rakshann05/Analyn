import 'package:flutter/material.dart';
import 'main.dart';
import 'info_page.dart';
import 'app_theme.dart';

class ServicesPage extends StatelessWidget {
  ServicesPage({super.key});

  final List<Service> services = [
    Service(id: 1, name: 'Analyn Care – Foot Massage', description: 'Soothe tired feet and refresh your step with deep relaxation.', duration: '30 mins', price: 799.0, imageUrl: 'assets/images/foot_massage.jpeg'),
    Service(id: 2, name: 'Analyn Relax – Head Massage', description: 'Relieve stress and improve sleep with a calming head massage.', duration: '20 mins', price: 599.0, imageUrl: 'assets/images/head-massage.jpg'),
    Service(id: 3, name: 'Analyn Healing – Neck & Shoulder', description: 'Ease stiffness and release tension from your neck and shoulders.', duration: '30 mins', price: 899.0, imageUrl: 'assets/images/neck_shoulder_massage.jpg'),
    Service(id: 4, name: 'Analyn Touch – Full Body Massage', description: 'Complete relaxation therapy that restores balance to your body.', duration: '60 mins', price: 1799.0, imageUrl: 'assets/images/full_body_massage.jpeg'),
    Service(id: 5, name: 'Analyn Wellness – Back Massage', description: 'Targeted therapy for back pain and muscle tightness.', duration: '30 mins', price: 899.0, imageUrl: 'assets/images/back_massage.jpg'),
    Service(id: 6, name: 'Analyn Glow – Face Massage', description: 'Enhance skin glow, relax facial muscles, and improve circulation.', duration: '25 mins', price: 699.0, imageUrl: 'assets/images/face_massage.jpg'),
    Service(id: 7, name: 'Analyn Rejuvenate – Hand Massage', description: 'Soothe sore hands and wrists with a refreshing therapy.', duration: '20 mins', price: 599.0, imageUrl: 'assets/images/hand_massage.jpeg'),
    Service(id: 8, name: 'Analyn Energy – Leg Massage', description: 'Reduce fatigue and heaviness with a calming leg massage.', duration: '30 mins', price: 799.0, imageUrl: 'assets/images/leg_massage.jpeg'),
    Service(id: 9, name: 'Analyn Stress Relief – Deep Tissue', description: 'For sore muscles and deep knots, experience strong pressure therapy.', duration: '60 mins', price: 1999.0, imageUrl: 'assets/images/deep_tissue_massage.jpg'),
    Service(id: 10, name: 'Analyn Calm – Swedish Massage', description: 'A gentle, relaxing massage that improves circulation and melts stress.', duration: '60 mins', price: 1699.0, imageUrl: 'assets/images/swedish_massage.jpeg'),
    Service(id: 11, name: 'Analyn Harmony – Couple Massage', description: 'Share the experience of relaxation with a soothing couple’s session.', duration: '75 mins', price: 3299.0, imageUrl: 'assets/images/couple_massage.jpeg'),
    Service(id: 12, name: 'Analyn Vitality – Aroma Oil', description: 'Relax with essential oils that refresh your body and mind.', duration: '60 mins', price: 1899.0, imageUrl: 'assets/images/aroma_oil_massage.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello!', style: AppTheme.textTheme.bodyMedium),
                  Text('What service do you need?', style: AppTheme.textTheme.headlineMedium),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return _ServiceCard(
                    service: service,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => InfoPage(service: service))),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;

  const _ServiceCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.asset(
                  service.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: AppTheme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${service.price.toStringAsFixed(0)} · ${service.duration}',
                    style: AppTheme.textTheme.bodyMedium,
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
