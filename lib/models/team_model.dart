import 'package:flutter/material.dart';

enum MemberType { intern, employee, coreTeam }
enum SkillLevel { beginner, intermediate, advanced }
enum CommPreference { whatsapp, inPerson, googleMeet, email }

class MemberModel {
  final String id;
  final String name;
  final String displayCode;
  final String? phone;
  final String? email;
  final String? college;
  final DateTime? startDate;
  final DateTime? endDate;
  final String dept;
  final String? cohort;
  final String? project;
  final MemberType type;
  final String role;
  final List<String> skills;
  final List<String> domainKnowledge;
  final SkillLevel skillLevel;
  final String? privateNotes;
  final CommPreference commPreference;
  final Color avatarColor;

  MemberModel({
    required this.id,
    required this.name,
    required this.displayCode,
    this.phone,
    this.email,
    this.college,
    this.startDate,
    this.endDate,
    required this.dept,
    this.cohort,
    this.project,
    this.type = MemberType.intern,
    required this.role,
    this.skills = const [],
    this.domainKnowledge = const [],
    this.skillLevel = SkillLevel.beginner,
    this.privateNotes,
    this.commPreference = CommPreference.email,
    required this.avatarColor,
  });

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      id: map['id'],
      name: map['full_name'],
      displayCode: (map['full_name'] as String).split(' ').map((e) => e[0]).take(2).join('').toUpperCase(),
      email: map['email'],
      role: map['role'] ?? 'user',
      dept: 'AI / ML', // Defaulting for now, should come from JOIN
      avatarColor: const Color(0xFFC9A84C), // Default gold
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'full_name': name,
      'email': email,
      'role': role,
    };
  }
}
