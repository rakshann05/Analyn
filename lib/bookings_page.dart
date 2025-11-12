import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'app_theme.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.lightText,
          indicatorColor: AppTheme.accent,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _OrderList(isUpcoming: true),
              _OrderList(isUpcoming: false),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderList extends StatelessWidget {
  final bool isUpcoming;
  const _OrderList({required this.isUpcoming});
  Future<void> _cancelBooking(BuildContext context, String orderId) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Cancellation'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('orders')
            .doc(orderId)
            .delete();
            
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Booking cancelled successfully'),
                backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to cancel booking: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to see your orders.'));
    }
    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('orders');

    if (isUpcoming) {
      query = query
          .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.now())
          .orderBy('scheduledAt', descending: false);
    } else {
      query = query
          .where('scheduledAt', isLessThan: Timestamp.now())
          .orderBy('scheduledAt', descending: true);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
                'Error: ${snapshot.error}', // This will show any error
                textAlign: TextAlign.center,
                style: AppTheme.textTheme.bodyMedium),
          ));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'You have no ${isUpcoming ? 'upcoming' : 'completed'} orders.',
              style: AppTheme.textTheme.bodyMedium,
            ),
          );
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final orderData = orders[index].data() as Map<String, dynamic>;
            final orderId = orders[index].id; 

            final Timestamp scheduledTimestamp = orderData['scheduledAt'];
            final String formattedDate =
                DateFormat('EEE, MMM d, yyyy').format(scheduledTimestamp.toDate());
            final String formattedTime =
                DateFormat('h:mm a').format(scheduledTimestamp.toDate());

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.receipt_long, color: AppTheme.accent),
                title: Text(
                  orderData['serviceName'] ?? 'Unnamed Service',
                  style: AppTheme.textTheme.titleMedium,
                ),
                subtitle: Text('$formattedDate at $formattedTime',
                    style: AppTheme.textTheme.bodyMedium),
                trailing: isUpcoming
                    ? TextButton(
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.red)),
                        onPressed: () => _cancelBooking(context, orderId),
                      )
                    : Text(
                        '₹${(orderData['price'] as num).toStringAsFixed(0)}',
                        style: AppTheme.textTheme.titleMedium
                            ?.copyWith(color: AppTheme.darkText),
                      ),
              ),
            );
          },
        );
      },
    );
  }
}