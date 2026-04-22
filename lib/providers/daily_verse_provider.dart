import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

class DailyVerse {
  final String reference;
  final String text;
  final String backgroundAsset;

  DailyVerse({
    required this.reference,
    required this.text,
    required this.backgroundAsset,
  });
}

final dailyVerseProvider = Provider<DailyVerse>((ref) {
  final verses = [
    DailyVerse(
      reference: "Psalm 23:1",
      text: "The Lord is my shepherd; I shall not want.",
      backgroundAsset: "assets/images/bg_morning.png",
    ),
    DailyVerse(
      reference: "Philippians 4:13",
      text: "I can do all things through Christ who strengthens me.",
      backgroundAsset: "assets/images/bg_devotion.png",
    ),
    DailyVerse(
      reference: "John 3:16",
      text: "For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life.",
      backgroundAsset: "assets/images/bg_star.png",
    ),
    DailyVerse(
      reference: "Proverbs 3:5",
      text: "Trust in the Lord with all your heart, and do not lean on your own understanding.",
      backgroundAsset: "assets/images/bg_forest.png",
    ),
    DailyVerse(
      reference: "Isaiah 41:10",
      text: "Fear not, for I am with you; be not dismayed, for I am your God; I will strengthen you, I will help you, I will uphold you with my righteous right hand.",
      backgroundAsset: "assets/images/bg_parchment.png",
    ),
    DailyVerse(
      reference: "Matthew 11:28",
      text: "Come to me, all who labor and are heavy laden, and I will give you rest.",
      backgroundAsset: "assets/images/bg_marble.png",
    ),
    DailyVerse(
      reference: "Romans 8:28",
      text: "And we know that for those who love God all things work together for good, for those who are called according to his purpose.",
      backgroundAsset: "assets/images/bg_sunset.png",
    ),
    DailyVerse(
      reference: "Joshua 1:9",
      text: "Have I not commanded you? Be strong and courageous. Do not be frightened, and do not be dismayed, for the Lord your God is with you wherever you go.",
      backgroundAsset: "assets/images/bg_clouds.png",
    ),
    DailyVerse(
      reference: "Jeremiah 29:11",
      text: "For I know the plans I have for you, declares the Lord, plans for welfare and not for evil, to give you a future and a hope.",
      backgroundAsset: "assets/images/bg_dunes.png",
    ),
    DailyVerse(
      reference: "Psalm 46:1",
      text: "God is our refuge and strength, a very present help in trouble.",
      backgroundAsset: "assets/images/bg_water.png",
    ),
  ];

  // Pick a verse based on the day of the year to keep it consistent for 24h
  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
  return verses[dayOfYear % verses.length];
});
