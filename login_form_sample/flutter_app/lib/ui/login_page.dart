import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_app/repository/auth_repository.dart';
import 'package:flutter_app/ui/index_page.dart';
import 'package:flutter_app/ui/login_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginModel(
        AuthRepository(),
      ),
      child: LoginApp(),
    );
  }
}

class LoginApp extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'UserId',
                    hintText: 'ユーザIDを入力してください',
                  ),
                  validator: context.read<LoginModel>().emptyValidator,
                  onSaved: (value) => context.read<LoginModel>().id = value!,
                ),
                TextFormField(
                  obscureText: !context.watch<LoginModel>().showPassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'パスワードを入力してください',
                    suffixIcon: IconButton(
                      icon: Icon(context.watch<LoginModel>().showPassword
                          ? FontAwesomeIcons.solidEye
                          : FontAwesomeIcons.solidEyeSlash),
                      onPressed: () =>
                          context.read<LoginModel>().togglePasswordVisible(),
                    ),
                  ),
                  validator: context.read<LoginModel>().emptyValidator,
                  onSaved: (value) =>
                      context.read<LoginModel>().password = value!,
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 16, 0, 8),
                  // メッセージ表示
                  child: Text(
                    context.watch<LoginModel>().message,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
                Container(
                  // margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton(
                      onPressed: () async {
                        context.read<LoginModel>().setMessage('');

                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          var response =
                              await context.read<LoginModel>().auth();
                          print('auth response = $response');

                          if (response) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IndexPage(),
                              ),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('ログインしました'),
                              ),
                            );
                          } else {
                            context
                                .read<LoginModel>()
                                .setMessage('パスワードが誤っています');
                          }
                        }
                      },
                      child: const Text('ログイン'),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
