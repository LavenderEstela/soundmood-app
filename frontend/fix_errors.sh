find lib -name "*.dart" -exec sed -i 's/cardTheme: CardTheme(/cardTheme: CardThemeData(/g' {} \;

# 2. 修复测试文件包名
sed -i "s/package:frontend/package:soundmood/g" test/widget_test.dart
sed -i "s/MyApp()/SoundMoodApp()/g" test/widget_test.dart

# 3. 清理并重新分析
flutter clean
flutter pub get
flutter analyze