import 'dart:io';

class AdHelper {
  // ⚠️ استبدل هذه المعرفات التجريبية بمعرفات وحداتك الإعلانية الحقيقية من AdMob عند النشر الفعلي
  
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // معرف بنر حقيقي
      return 'ca-app-pub-5604419232354544/8663471539'; 
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // معرف إعلان بيني تجريبي (تستبدله بالفعلي لاحقاً)
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    throw UnsupportedError('Unsupported platform');
  }
}
