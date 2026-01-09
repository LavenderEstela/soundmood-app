import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// 修复: 使用正确的包名 soundmood
import 'package:soundmood/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // 修复: 使用正确的类名 SoundMoodApp
    await tester.pumpWidget(const SoundMoodApp());
    
    // 等待所有动画完成
    await tester.pumpAndSettle();
    
    // 基本的冒烟测试 - 确保应用能启动
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}