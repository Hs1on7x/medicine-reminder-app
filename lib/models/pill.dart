import 'dart:convert';
import 'package:flutter/material.dart';

class Pill {
  final int? id;
  final String name;
  final String description;
  final String? image;
  final Color color;
  final List<TimeOfDay> times;
  final List<int> days;
  final bool isActive;
  final Map<String, DateTime> lastTaken;

  Pill({
    this.id,
    required this.name,
    required this.description,
    this.image,
    required this.color,
    required this.times,
    required this.days,
    this.isActive = true,
    Map<String, DateTime>? lastTaken,
  }) : lastTaken = lastTaken ?? {};

  // Create a copy of this Pill with the given fields replaced
  Pill copyWith({
    int? id,
    String? name,
    String? description,
    String? image,
    Color? color,
    List<TimeOfDay>? times,
    List<int>? days,
    bool? isActive,
    Map<String, DateTime>? lastTaken,
  }) {
    return Pill(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      color: color ?? this.color,
      times: times ?? this.times,
      days: days ?? this.days,
      isActive: isActive ?? this.isActive,
      lastTaken: lastTaken ?? Map.from(this.lastTaken),
    );
  }

  // Mark this pill as taken at the given time
  Pill markAsTaken(DateTime time) {
    final key = '${time.year}-${time.month}-${time.day}-${time.hour}-${time.minute}';
    final newLastTaken = Map<String, DateTime>.from(lastTaken);
    newLastTaken[key] = time;
    
    return copyWith(lastTaken: newLastTaken);
  }

  // Check if this pill was taken at the given time
  bool wasTaken(DateTime time) {
    final key = '${time.year}-${time.month}-${time.day}-${time.hour}-${time.minute}';
    return lastTaken.containsKey(key);
  }

  // Convert TimeOfDay to string for storage
  static String _timeOfDayToString(TimeOfDay time) {
    return '${time.hour}:${time.minute}';
  }

  // Convert string to TimeOfDay
  static TimeOfDay _stringToTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  // Convert to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'color': color.value,
      'times': jsonEncode(times.map((t) => _timeOfDayToString(t)).toList()),
      'days': jsonEncode(days),
      'isActive': isActive ? 1 : 0,
      'lastTaken': jsonEncode(lastTaken.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      )),
    };
  }

  // Create a Pill from a map (from database)
  factory Pill.fromMap(Map<String, dynamic> map) {
    final timesList = jsonDecode(map['times']) as List<dynamic>;
    final daysList = jsonDecode(map['days']) as List<dynamic>;
    
    Map<String, DateTime> lastTakenMap = {};
    if (map['lastTaken'] != null) {
      final lastTakenJson = jsonDecode(map['lastTaken']) as Map<String, dynamic>;
      lastTakenMap = lastTakenJson.map(
        (key, value) => MapEntry(key, DateTime.parse(value as String)),
      );
    }

    return Pill(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      image: map['image'],
      color: Color(map['color']),
      times: timesList.map((t) => _stringToTimeOfDay(t as String)).toList(),
      days: daysList.map((d) => d as int).toList(),
      isActive: map['isActive'] == 1,
      lastTaken: lastTakenMap,
    );
  }

  @override
  String toString() {
    return 'Pill(id: $id, name: $name, description: $description, image: $image, color: $color, times: $times, days: $days, isActive: $isActive, lastTaken: $lastTaken)';
  }
} 