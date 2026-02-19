import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1abc9c),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF1abc9c),
              size: 20,
            ),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF1FFF3),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          children: [
            // Today Section
            _buildSectionHeader('Today'),
            _buildNotificationItem(
              icon: Icons.notifications_active,
              title: 'Reminder!',
              subtitle:
                  'Set up your automatic savings to meet your savings goal...',
              time: '17:00 - April 24',
              iconColor: const Color(0xFF1abc9c),
            ),
            _buildDivider(),
            _buildNotificationItem(
              icon: Icons.star,
              title: 'New Update',
              subtitle:
                  'Set up your automatic savings to meet your savings goal...',
              time: '17:00 - April 24',
              iconColor: const Color(0xFF1abc9c),
            ),
            const SizedBox(height: 24),
            // Yesterday Section
            _buildSectionHeader('Yesterday'),
            _buildNotificationItem(
              icon: Icons.shopping_bag_outlined,
              title: 'Transactions',
              subtitle: 'A new transaction has been registered',
              time: '17:00 - April 24',
              iconColor: const Color(0xFF1abc9c),
              tags: ['Groceries', 'Pantry', '-\$100.00'],
            ),
            _buildDivider(),
            _buildNotificationItem(
              icon: Icons.notifications_active,
              title: 'Reminder!',
              subtitle:
                  'Set up your automatic savings to meet your savings goal...',
              time: '17:00 - April 24',
              iconColor: const Color(0xFF1abc9c),
            ),
            const SizedBox(height: 24),
            // This Weekend Section
            _buildSectionHeader('This Weekend'),
            _buildNotificationItem(
              icon: Icons.trending_down,
              title: 'Expense Record',
              subtitle:
                  'We recommend that you be more attentive to your finances.',
              time: '17:00 - April 24',
              iconColor: const Color(0xFF1abc9c),
            ),
            _buildDivider(),
            _buildNotificationItem(
              icon: Icons.shopping_bag_outlined,
              title: 'Transactions',
              subtitle: 'A new transaction has been registered',
              time: '17:00 - April 24',
              iconColor: const Color(0xFF1abc9c),
              tags: ['Food', 'Dinner', '-\$70.40'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color iconColor,
    List<String>? tags,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.2),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tags != null && tags.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (int i = 0; i < tags.length; i++)
                        Text(
                          tags[i],
                          style: TextStyle(
                            fontSize: 11,
                            color: i == tags.length - 1
                                ? const Color(0xFF7c3aed)
                                : Colors.blue,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(height: 1, color: Colors.black.withValues(alpha: 0.1)),
    );
  }
}
