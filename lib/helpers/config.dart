abstract class Config {
  static const firebaseProjectId =
      String.fromEnvironment('DEFINE_FIREBASE_PROJECT_ID');

  static const firebaseIosApiKey =
      String.fromEnvironment('DEFINE_FIREBASE_IOS_API_KEY');

  static const firebaseIosAppId =
      String.fromEnvironment('DEFINE_FIREBASE_IOS_APP_ID');

  static const firebaseAndroidApiKey =
      String.fromEnvironment('DEFINE_FIREBASE_ANDROID_API_KEY');

  static const firebaseAndroidAppId =
      String.fromEnvironment('DEFINE_FIREBASE_ANDROID_APP_ID');

  static const firebaseMessagingSenderId =
      String.fromEnvironment('DEFINE_FIREBASE_SENDER_ID');

  static const firebaseStorageBucket =
      String.fromEnvironment('DEFINE_FIREBASE_BUCKET_NAME');
}
