import 'package:flutter/material.dart';

class CategoryTabs extends StatelessWidget {
  final List<CategoryTab> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const CategoryTabs({
    Key? key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onTabSelected(index),
            child: Container(
              margin: EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  Icon(
                    tabs[index].icon,
                    color: isSelected ? Color(0xFF1976D2) : Colors.grey,
                    size: 28,
                  ),
                  SizedBox(height: 4),
                  Text(
                    tabs[index].label,
                    style: TextStyle(
                      color: isSelected ? Color(0xFF1976D2) : Colors.grey,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: EdgeInsets.only(top: 4),
                      height: 2,
                      width: 30,
                      color: Color(0xFF1976D2),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryTab {
  final IconData icon;
  final String label;

  CategoryTab({required this.icon, required this.label});
}
