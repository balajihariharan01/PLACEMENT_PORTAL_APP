import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/drive_model.dart';
import '../widgets/branded_header.dart';

class DriveDetailScreen extends StatelessWidget {
  final Drive drive;

  const DriveDetailScreen({super.key, required this.drive});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SubPageHeader(title: ''),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              // Header Content (Scrollable)
              SliverToBoxAdapter(child: _buildHeader(context)),

              // Standard Bar (Scrollable)
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: const Color(0xFFD1C4E9).withValues(alpha: 0.5),
                  alignment: Alignment.center,
                  child: const Text(
                    "Standard",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // Sticky Tabs
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  child: Container(
                    color: Colors.white,
                    child: Center(
                      child: TabBar(
                        isScrollable: true,
                        // tabAlignment: TabAlignment.center, // Use if Flutter >= 3.13
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey[600],
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.black87,
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        tabs: const [
                          Tab(text: "Details"),
                          Tab(text: "Rounds"),
                        ],
                      ),
                    ),
                  ),
                  height: 80, // Matches container height with padding
                ),
              ),
            ];
          },
          body: TabBarView(children: [_buildDetailsTab(), _buildRoundsTab()]),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  drive.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Logo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade200, blurRadius: 4),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  drive.logoUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.business),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Opt-In Badge
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: drive.statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                drive.statusText,
                style: TextStyle(
                  color: drive.statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Info Rows
          _buildInfoRow(Icons.business, drive.companyName),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.local_offer_outlined, drive.domain),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.monetization_on_outlined,
            "${drive.salary} | ${drive.stipend}",
          ),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on_outlined, drive.location),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.work_outline, drive.jobType),

          const SizedBox(height: 20),
          // Opt-In / Opt-Out Action Button
          if (drive.status == DriveStatus.eligible ||
              drive.status == DriveStatus.applied)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  // Placeholder for action
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Action for ${drive.companyName}")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: drive.status == DriveStatus.applied
                      ? Colors.white
                      : Colors.black87,
                  foregroundColor: drive.status == DriveStatus.applied
                      ? Colors.black87
                      : Colors.white,
                  side: drive.status == DriveStatus.applied
                      ? const BorderSide(color: Colors.black87)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.black87),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  drive.status == DriveStatus.applied ? "Opt-Out" : "Opt-In",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

          const SizedBox(height: 16),
          Text(
            "Apply before : ${DateFormat('MMM dd, yyyy').format(drive.applyDate)}   |   ${DateFormat('hh:mm a').format(drive.applyDate)}",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "Job Description",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          drive.aboutCompany ?? drive.description,
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
        ),
        const SizedBox(height: 24),

        // Profile & Salary Section
        const Text(
          "Profile & Salary",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF9575CD,
                ).withValues(alpha: 0.05), // Subtle purple tint
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                drive.title, // Role Name
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Salary",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.currency_rupee,
                        size: 14,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        drive.salary,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "PA",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Stipend",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.currency_rupee,
                        size: 14,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        drive.stipend.replaceAll(RegExp(r'[^0-9kK]'), ''),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "PM",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "About ${drive.companyName}:",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          drive.aboutCompany ?? drive.description,
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
        ),
        const SizedBox(height: 16),
        // Placeholder for more JD details
        Text(
          drive.description,
          style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
        ),
        const SizedBox(height: 80), // Bottom padding
      ],
    );
  }

  Widget _buildRoundsTab() {
    if (drive.rounds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_late_outlined,
              size: 60,
              color: Colors.indigo[100],
            ),
            const SizedBox(height: 16),
            Text(
              "No rounds available at the moment.",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: drive.rounds.length + 1,
      itemBuilder: (context, index) {
        if (index == drive.rounds.length) {
          return const SizedBox(height: 80); // Bottom padding
        }
        final round = drive.rounds[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Node
              Column(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFF9575CD), // Purple accent
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (index != drive.rounds.length - 1)
                    Container(
                      width: 2,
                      height: 100, // Approximate height for line
                      color: Colors.black54,
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      round.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      round.description,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRoundDetail("Confirmed Date", ""),
                    if (round.startDate != null)
                      _buildRoundDetail(
                        "Start:",
                        "${DateFormat('dd MMM, yyyy').format(round.startDate!)} / ${DateFormat('hh:mm a').format(round.startDate!)}",
                      ),
                    if (round.endDate != null)
                      _buildRoundDetail(
                        "End:",
                        "${DateFormat('dd MMM, yyyy').format(round.endDate!)} / ${DateFormat('hh:mm a').format(round.endDate!)}",
                      ),
                    _buildRoundDetail("Venue:", round.venue ?? "Not mentioned"),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoundDetail(String label, String value) {
    if (value.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text("View Company JD (PDF)"),
        ),
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyTabBarDelegate({required this.child, required this.height});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
