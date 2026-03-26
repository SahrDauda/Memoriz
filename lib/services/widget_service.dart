import 'package:home_widget/home_widget.dart';
import '../data/models/verse.dart';

class WidgetService {
  static const String androidWidgetName = 'ScriptureWidgetProvider';
  static const String iosWidgetName = 'ScriptureWidget';

  static Future<void> updateVerseWidget(Verse verse) async {
    await HomeWidget.saveWidgetData('verse_reference', verse.reference);
    await HomeWidget.saveWidgetData('verse_text', verse.text);
    
    await HomeWidget.updateWidget(
      name: androidWidgetName,
      iOSName: iosWidgetName,
    );
  }
}
