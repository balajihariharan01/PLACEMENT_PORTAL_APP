import 'package:flutter/material.dart';

class FilterModal extends StatefulWidget {
  final Map<String, String?> initialFilters;
  final Function(Map<String, String?>) onApply;
  final VoidCallback onClear;

  const FilterModal({
    super.key,
    required this.initialFilters,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  // Selection state - each category stores a single selected value (radio behavior)
  late Map<String, String?> _selectedFilters;

  // Data to match screenshot
  final Map<String, List<String>> _filters = {
    'Status': ['Opted-In', 'Opted-Out', 'Placed', 'Eligible', 'Not Eligible'],
    'Salary': ['0 - 3L PA', '3 - 5L PA', '5 - 10L PA', '> 10L PA'],
    'Drive Type': ['On Campus', 'Off Campus'],
    'Company Domain': ['IT', 'Core', 'Non-Core', 'Services'],
    'Drive Objective': ['Placement', 'Academic Internship'],
    'Company Category': ['Startup', 'MNC', 'Product-Based', 'Service-Based'],
  };

  String _selectedCategory = 'Status';

  @override
  void initState() {
    super.initState();
    // Initialize with passed filters or empty map
    _selectedFilters = Map.from(widget.initialFilters);
  }

  void _clearAllFilters() {
    setState(() {
      _selectedFilters.clear();
    });
    widget.onClear();
  }

  void _applyFilters() {
    widget.onApply(_selectedFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Filter",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Body
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // sidebar
                Container(
                  width: 140,
                  color: const Color(0xFFF5F5F7),
                  child: ListView(
                    children: _filters.keys
                        .map((cat) => _buildCategoryItem(cat))
                        .toList(),
                  ),
                ),
                // content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: _filters[_selectedCategory]!
                        .map((opt) => _buildOptionItem(opt))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearAllFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.black87),
                    ),
                    child: const Text("Clear Filters"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Apply"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title) {
    final isSelected = _selectedCategory == title;
    final hasSelection = _selectedFilters[title] != null;
    return InkWell(
      onTap: () => setState(() => _selectedCategory = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        color: isSelected ? Colors.white : Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.black87 : Colors.grey[600],
                ),
              ),
            ),
            if (hasSelection)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(String option) {
    final isSelected = _selectedFilters[_selectedCategory] == option;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          setState(() {
            if (_selectedFilters[_selectedCategory] == option) {
              // Deselect if already selected
              _selectedFilters.remove(_selectedCategory);
            } else {
              _selectedFilters[_selectedCategory] = option;
            }
          });
        },
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.black87 : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.black87 : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              option,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
