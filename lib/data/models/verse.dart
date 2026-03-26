class Verse {
  final int? id;
  final String reference;
  final String book;
  final String text;
  final String translation;
  int familiarityScore;
  DateTime? lastReviewed;
  DateTime? nextReviewDue;
  int consecutiveCorrect;
  int timesStruggled;
  bool isActive;

  Verse({
    this.id,
    required this.reference,
    required this.book,
    required this.text,
    this.translation = 'KJV',
    this.familiarityScore = 0,
    this.lastReviewed,
    this.nextReviewDue,
    this.consecutiveCorrect = 0,
    this.timesStruggled = 0,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reference': reference,
      'book': book,
      'text': text,
      'translation': translation,
      'familiarityScore': familiarityScore,
      'lastReviewed': lastReviewed?.toIso8601String(),
      'nextReviewDue': nextReviewDue?.toIso8601String(),
      'consecutiveCorrect': consecutiveCorrect,
      'timesStruggled': timesStruggled,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      id: map['id'],
      reference: map['reference'],
      book: map['book'],
      text: map['text'],
      translation: map['translation'],
      familiarityScore: map['familiarityScore'],
      lastReviewed: map['lastReviewed'] != null ? DateTime.parse(map['lastReviewed']) : null,
      nextReviewDue: map['nextReviewDue'] != null ? DateTime.parse(map['nextReviewDue']) : null,
      consecutiveCorrect: map['consecutiveCorrect'],
      timesStruggled: map['timesStruggled'],
      isActive: map['isActive'] == 1,
    );
  }

  Verse copyWith({
    int? id,
    String? reference,
    String? book,
    String? text,
    String? translation,
    int? familiarityScore,
    DateTime? lastReviewed,
    DateTime? nextReviewDue,
    int? consecutiveCorrect,
    int? timesStruggled,
    bool? isActive,
  }) {
    return Verse(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      book: book ?? this.book,
      text: text ?? this.text,
      translation: translation ?? this.translation,
      familiarityScore: familiarityScore ?? this.familiarityScore,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextReviewDue: nextReviewDue ?? this.nextReviewDue,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
      timesStruggled: timesStruggled ?? this.timesStruggled,
      isActive: isActive ?? this.isActive,
    );
  }
}
