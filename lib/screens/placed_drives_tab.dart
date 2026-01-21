import 'package:flutter/material.dart';
import '../widgets/drive_card.dart';
import '../widgets/no_data_widget.dart';

class PlacedDrivesTab extends StatefulWidget {
  const PlacedDrivesTab({super.key});

  @override
  State<PlacedDrivesTab> createState() => _PlacedDrivesTabState();
}

class _PlacedDrivesTabState extends State<PlacedDrivesTab> {
  String _selectedTab = "Upcoming";

  final List<String> _tabs = [
    "Upcoming (0)",
    "Ongoing (0)",
    "Completed (0)",
    "Deleted (0)",
    "OnHold (0)",
    "Reopened (0)"
  ];

  final List<Map<String, dynamic>> _ongoingDrives = [
    {
      "company": "Netgear Technologies",
      "subtitle": "Netgear Oncampus drive",
      "salary": "₹ 16L PA",
      "date": "Oct 10, 2025",
      "status": "Opted-Out",
      "statusColor": const Color(0xFFE53935),
      "statusBgColor": const Color(0xFFFFEBEE),
    },
    {
      "company": "MALLOW TECHNOLOGIES",
      "subtitle": "Mallow Technologies",
      "salary": "₹ 4L PA",
      "date": "Aug 11, 2025",
      "status": "Opted-In",
      "statusColor": const Color(0xFF2E7D32),
      "statusBgColor": const Color(0xFFE8F5E9),
    },
    {
      "company": "Calibraint Technologies",
      "subtitle": "Calibraint Technologies",
      "salary": "₹ 4L PA",
      "date": "Aug 5, 2025",
      "status": "Opted-In",
      "statusColor": const Color(0xFF2E7D32),
      "statusBgColor": const Color(0xFFE8F5E9),
    },
    {
      "company": "Radiant Global Technolog...",
      "subtitle": "Radiant Global Technolog...",
      "salary": "₹ 7L PA",
      "date": "Aug 1, 2025",
      "status": "Opted-Out",
      "statusColor": const Color(0xFFE53935),
      "statusBgColor": const Color(0xFFFFEBEE),
    },
    {
      "company": "PENTAFOX TECHNOLOGIES",
      "subtitle": "Pentafox Technologies Pr...",
      "salary": "₹ 6L PA",
      "date": "Jul 28, 2025",
      "status": "Opted-In",
      "statusColor": const Color(0xFF2E7D32),
      "statusBgColor": const Color(0xFFE8F5E9),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scrollable Filter Tabs
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _tabs.map((tab) {
                final isSelected = tab.startsWith(_selectedTab);
                
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                         // Extract the main name (e.g., "Upcoming" from "Upcoming (0)")
                         _selectedTab = tab.split(' ')[0];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Sort and Filter Buttons
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Sort", style: TextStyle(fontWeight: FontWeight.bold)),
                      Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: const [
                    Text("Filter", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.tune, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: _selectedTab == "Ongoing"
              ? ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ongoingDrives.length,
                  itemBuilder: (context, index) {
                    final drive = _ongoingDrives[index];
                    return DriveCard(
                      companyName: drive['company'],
                      industry: drive['subtitle'],
                      salary: drive['salary'],
                      lastDate: drive['date'],
                      status: drive['status'],
                      statusColor: drive['statusColor'],
                      statusBgColor: drive['statusBgColor'],
                    );
                  },
                )
              : _buildNoDataFound(),
        ),
      ],
    );
  }



  Widget _buildNoDataFound() {
    return const NoDataWidget();
  }
}
