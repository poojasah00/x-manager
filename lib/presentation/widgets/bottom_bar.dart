import 'package:flutter/material.dart';
import '../screens/categories/categories_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(181, 187, 246, 170),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home, 0, context),
            _buildNavItem(Icons.bar_chart_outlined, 1, context),
            _buildNavItem(Icons.compare_arrows, 2, context),
            _buildNavItem(Icons.layers_outlined, 3, context),
            _buildNavItem(Icons.settings_outlined, 4, context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, BuildContext context) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 3) {
          // Open CategoriesScreen when layers_outlined is tapped
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CategoriesScreen()));
        } else {
          onItemSelected(index);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? const Color(0xFF1abc9c) : Colors.transparent,
        ),
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey[600],
          size: 24,
        ),
      ),
    );
  }
}
