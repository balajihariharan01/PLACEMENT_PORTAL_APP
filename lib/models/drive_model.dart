import 'package:flutter/material.dart';

enum DriveStatus {
  eligible,
  applied, // "Opted-In"
  optedOut,
  notEligible,
  placed,
  closed,
}

class DriveRound {
  final String name; // e.g., "Round 1", "Technical Interview"
  final String description; // e.g. "Online Screening/Aptitude Test"
  final DateTime? startDate;
  final DateTime? endDate;
  final String? venue;
  final String mode; // "Online" or "Offline"

  const DriveRound({
    required this.name,
    required this.description,
    this.startDate,
    this.endDate,
    this.venue,
    required this.mode,
  });
}

class Drive {
  final String id;
  final String companyName;
  final String title; // e.g. "AmZetta On Campus drive"
  final String description;
  final String logoUrl; // Asset path or network URL
  final String salary; // e.g. "4 LPA", "8L PA"
  final String stipend; // e.g. "15k - 20k per month"
  final String location;
  final String domain; // "IT", "Core", etc.
  final String jobType; // "Internship", "Full-Time", "Internship and Full-Time"
  final bool isOnCampus; // true = On-Campus, false = Off-Campus
  final DateTime applyDate; // "Opt-In Before" or "Last Date"
  final DriveStatus status;
  final List<DriveRound> rounds;
  final String? aboutCompany;
  final String? jdPdfUrl;

  const Drive({
    required this.id,
    required this.companyName,
    required this.title,
    required this.description,
    required this.logoUrl,
    required this.salary,
    required this.stipend,
    required this.location,
    required this.domain,
    required this.jobType,
    required this.isOnCampus,
    required this.applyDate,
    required this.status,
    this.rounds = const [],
    this.aboutCompany,
    this.jdPdfUrl,
  });

  // Helper to get Color based on status
  Color get statusColor {
    switch (status) {
      case DriveStatus.applied:
        return const Color(0xFF4CAF50); // Green
      case DriveStatus.optedOut:
        return const Color(0xFFF44336); // Red
      case DriveStatus.placed:
        return const Color(0xFF9C27B0); // Purple
      case DriveStatus.eligible:
        return const Color(0xFF2196F3); // Blue
      case DriveStatus.notEligible:
        return Colors.grey;
      case DriveStatus.closed:
        return Colors.brown;
    }
  }

  // Helper to get formatted status text
  String get statusText {
    switch (status) {
      case DriveStatus.applied:
        return "Opted-In";
      case DriveStatus.optedOut:
        return "Opted-Out";
      case DriveStatus.placed:
        return "Placed";
      case DriveStatus.eligible:
        return "Eligible"; // Or check validity
      case DriveStatus.notEligible:
        return "Not Eligible";
      case DriveStatus.closed:
        return "Closed";
    }
  }
}
