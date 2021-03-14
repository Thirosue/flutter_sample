import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/repository/auth_repository.dart';
import 'package:flutter_app/ui/login_model.dart';
import 'package:flutter_app/ui/login_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

RenderEditable findRenderEditable(WidgetTester tester, int index) {
  final RenderObject root =
      tester.renderObject(find.byType(EditableText).at(index));
  expect(root, isNotNull);

  late RenderEditable renderEditable;
  void recursiveFinder(RenderObject child) {
    if (child is RenderEditable) {
      renderEditable = child;
      return;
    }
    child.visitChildren(recursiveFinder);
  }

  root.visitChildren(recursiveFinder);
  expect(renderEditable, isNotNull);
  return renderEditable;
}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() async {
  final mockAuthRepository = MockAuthRepository();

  MaterialApp loginApp() {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (context) => LoginModel(
          mockAuthRepository,
        ),
        child: LoginApp(),
      ),
    );
  }

  /// ///////////////////
  /// target elements
  /// //////////////////
  final _id = find.byType(TextFormField).at(0);
  final _password = find.byType(TextFormField).at(1);
  final _passwordViewToggle = find.byType(IconButton);
  final _submitButton = find.text('ログイン');

  group('LoginPage ', () {
    testWidgets('1. 画面が表示されたとき、ログインボタンが存在すること', (tester) async {
      await tester.pumpWidget(loginApp());
      expect(_submitButton, findsOneWidget);
    });

    testWidgets('2. 画面が表示されたとき、入力チェックが動作していないこと', (tester) async {
      await tester.pumpWidget(loginApp());
      expect(find.text('入力してください'), findsNothing);
    });

    testWidgets('3. ユーザIDを入力せずにログインボタンを押したとき、入力チェックが動作し、エラーとなること',
        (tester) async {
      await tester.pumpWidget(loginApp());

      await tester.enterText(_password, 'password');

      await tester.tap(_submitButton);
      await tester.pump();

      final validationErrorMessages = find.text('入力してください');
      expect(validationErrorMessages, findsOneWidget);
      expect(validationErrorMessages.evaluate().length, 1);
    });

    testWidgets('4. パスワードを入力せずにログインボタンを押したとき、入力チェックが動作し、エラーとなること',
        (tester) async {
      await tester.pumpWidget(loginApp());

      await tester.enterText(_id, 'demo');

      await tester.tap(_submitButton);
      await tester.pump();

      final validationErrorMessages = find.text('入力してください');
      expect(validationErrorMessages, findsOneWidget);
      expect(validationErrorMessages.evaluate().length, 1);
    });

    testWidgets('5. ユーザID、及びパスワードを入力せずにログインボタンを押したとき、入力チェックが動作し、エラーとなること',
        (tester) async {
      await tester.pumpWidget(loginApp());

      await tester.tap(_submitButton);
      await tester.pump();

      final validationErrorMessages = find.text('入力してください');
      expect(validationErrorMessages.at(0), findsOneWidget);
      expect(validationErrorMessages.at(1), findsOneWidget);
      expect(validationErrorMessages.evaluate().length, 2);
    });

    testWidgets('5. ユーザID、及びパスワードを入力しログインボタンを押したとき、入力チェックが動作し、エラーとならないこと',
        (tester) async {
      await tester.pumpWidget(loginApp());
      when(mockAuthRepository.auth())
          .thenAnswer((_) => Future.value(true)); // 認証OK

      await tester.enterText(_password, 'password');
      await tester.enterText(_id, 'demo');

      await tester.tap(_submitButton);
      await tester.pump(Duration(seconds: 10)); // SnackBarが表示されるのを待ち合わせる

      expect(find.text('入力してください'), findsNothing);
      expect(find.text('パスワードが誤っています'), findsNothing);
    });

    testWidgets('6. パスワードを入力したとき、入力した文言がマスク(••••)されていること', (tester) async {
      await tester.pumpWidget(loginApp());
      await tester.enterText(_password, 'hoge');
      await tester.pump();

      final String editText = findRenderEditable(tester, 1).text!.text!;
      print(editText);

      expect(editText.substring(editText.length - 1), '\u2022');
    });

    testWidgets(
        '7. パスワードを入力し、パスワード表示アイコンを押したとき、入力した文言のマスクが解除されていること。もう一度パスワードマスクアイコンを押したとき、パスワードがマスクされること',
        (tester) async {
      await tester.pumpWidget(loginApp());
      await tester.enterText(_password, 'hoge');
      await tester.tap(_passwordViewToggle);
      await tester.pump();

      final String editText = findRenderEditable(tester, 1).text!.text!;
      print('unMask: $editText');

      expect(editText, 'hoge');

      await tester.tap(_passwordViewToggle);
      await tester.pump();

      final String editTextAfter = findRenderEditable(tester, 1).text!.text!;
      print('Mask: $editTextAfter');
      expect(editTextAfter.substring(editText.length - 1), '\u2022');
    });
  });

  testWidgets('8. ユーザID、及びパスワードを入力しログインボタンを押し、認証エラーが発生したとき、パスワード誤り文言が表示されること',
      (tester) async {
    await tester.pumpWidget(loginApp());
    when(mockAuthRepository.auth())
        .thenAnswer((_) => Future.value(false)); // 認証NG

    await tester.enterText(_password, 'password');
    await tester.enterText(_id, 'demo');

    await tester.tap(_submitButton);
    await tester.pump(Duration(seconds: 1));

    expect(find.text('パスワードが誤っています'), findsOneWidget);
  });
}
