import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          'How can we help?',
          style: AppTheme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Find answers to common questions or get in touch with our team.',
          style: AppTheme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),

        // --- FAQ Section ---
        _buildSectionHeader('Frequently Asked Questions'),
        _buildFaqTile(
          question: 'How do I cancel a booking?',
          answer:
              'You can cancel any upcoming booking from the "Bookings" tab. Find the order you wish to cancel and tap the "Cancel" button. Please note our cancellation policy.',
        ),
        _buildFaqTile(
          question: 'Is my payment information secure?',
          answer:
              'Yes, we take security very seriously. All payments are processed through Stripe, a certified PCI Level 1 Service Provider. We do not store your credit card details on our servers.',
        ),
        _buildFaqTile(
          question: 'How do I update my address?',
          answer:
              'You can add, edit, or delete your saved addresses by going to the "Profile" tab and selecting "Saved Addresses".',
        ),
        _buildFaqTile(
          question: 'Are the therapists verified?',
          answer:
              'Absolutely. All therapists on our platform go through a rigorous background check and professional verification process (KYC) before they can accept any bookings.',
        ),

        const SizedBox(height: 32),

        // --- Contact Us Section ---
        _buildSectionHeader('Get in Touch'),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.email_outlined, color: AppTheme.accent),
            title: const Text('Email Us'),
            subtitle: const Text('support@analyn.com'),
            onTap: () => _launchURL('mailto:support@analyn.com'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.phone_outlined, color: AppTheme.accent),
            title: const Text('Call Us'),
            subtitle: const Text('+91 12345 67890'),
            onTap: () => _launchURL('tel:+911234567890'),
          ),
        ),
      ],
    );
  }

  // Helper widget for FAQ tiles
  Widget _buildFaqTile({required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        title: Text(question, style: AppTheme.textTheme.titleMedium),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Text(
            answer,
            style: AppTheme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: AppTheme.textTheme.headlineMedium?.copyWith(
          color: AppTheme.darkText.withOpacity(0.8),
        ),
      ),
    );
  }
}