// William Strong  November 2024
// This file contains the Dart model for the Events database table.

class EventModel {
  final String title;
  final DateTime startTimestamp;
  final String location;
  final bool shown;
  final bool headline;
  final String? headlineTitle;
  final String? summary;
  final String? imageUrl;

  const EventModel(
    this.title,
    this.startTimestamp,
    this.location,
    this.shown,
    this.headline,
    this.headlineTitle,
    this.summary,
    this.imageUrl,
  );

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'title': String title,
        'startTimestamp': String startTimestamp,
        'location': String location,
        'shown': bool isShown,
        'headline': bool isHeadline,
        'headlineTitle': String? headlineTitle,
        'summary': String? summary,
        'imageUrl': String? imageUrl,
      } => EventModel(title, DateTime.parse(startTimestamp), location, isShown, isHeadline, headlineTitle, summary, imageUrl),
      _ => throw const FormatException("Failed to load event.")
    };
  }
}