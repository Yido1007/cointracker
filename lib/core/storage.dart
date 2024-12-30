import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  Future<bool> isFirstLaunch() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();

    // `runned` değeri uygulamanın daha önce çalışıp çalışmadığını kontrol ediyor.
    final bool? runned = storage.getBool("runned");

    // `launchCount` değeri kaç kez çalıştırıldığını takip ediyor.
    int counter = storage.getInt("launchCount") ?? 0;

    if (runned == null) {
      // Eğer uygulama ilk kez çalışıyorsa `runned` null olur.
      counter = 1;
      await storage.setInt("launchCount", counter);
      await storage.setBool("runned", true); // İlk kez çalıştırıldığını kaydediyoruz.
      return true;
    } else {
      // Eğer uygulama daha önce çalıştırılmışsa sayacı artırıyoruz.
      counter += 1;
      await storage.setInt("launchCount", counter);
      return false;
    }
  }

  Future<void> firstLaunched() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.setBool("runned", true);
  }

  Future<void> clearStorage() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    await storage.clear();
  }

  setConfig({String? language}) async {
    final SharedPreferences storage = await SharedPreferences.getInstance();

    if (language != null) {
      await storage.setString("language", language);
    }
  }

  // get config function
  getConfig() async {
    final SharedPreferences storage = await SharedPreferences.getInstance();
    return {
      "language": storage.getString("language"),
    };
  }
}
