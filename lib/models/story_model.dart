/// Data model for backend-driven story payloads.
class StoryModel {
  const StoryModel({
    required this.title,
    required this.subtitle,
    required this.paragraphs,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      paragraphs: (json['paragraphs'] as List<dynamic>).cast<String>(),
    );
  }

  final String title;
  final String subtitle;
  final List<String> paragraphs;

  /// Full narration text for TTS — paragraphs separated by pauses.
  String get narrationText => paragraphs.join('\n\n');

  int get wordCount =>
      narrationText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  int get estimatedReadMinutes => (wordCount / 130).ceil().clamp(1, 99);
}
