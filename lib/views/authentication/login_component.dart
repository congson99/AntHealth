import 'dart:math';

import 'package:anthealth_mobile/blocs/app_cubit.dart';
import 'package:anthealth_mobile/blocs/app_state.dart';
import 'package:anthealth_mobile/blocs/authentication/authentication_cubit.dart';
import 'package:anthealth_mobile/blocs/authentication/authetication_states.dart';
import 'package:anthealth_mobile/blocs/common_logic/authentication_logic.dart';
import 'package:anthealth_mobile/generated/l10n.dart';
import 'package:anthealth_mobile/views/common_widgets/common_button.dart';
import 'package:anthealth_mobile/views/common_widgets/common_text_field.dart';
import 'package:anthealth_mobile/views/common_widgets/custom_error_widget.dart';
import 'package:anthealth_mobile/views/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginComponent extends StatefulWidget {
  const LoginComponent({Key? key, this.intentUsername, this.intentPassword})
      : super(key: key);

  final String? intentUsername;
  final String? intentPassword;

  @override
  _LoginComponentState createState() => _LoginComponentState();
}

class _LoginComponentState extends State<LoginComponent> {
  String _errorUsername = 'null';
  String _errorPassword = 'null';

  var _usernameController = TextEditingController();
  var _passwordController = TextEditingController();

  var _usernameFocus = FocusNode();
  var _passwordFocus = FocusNode();

  @override
  void initState() {
    _checkAutoFill();
    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AuthenticationCubit, CubitState>(builder: (context, state) {
        if (state is LoginState)
          return buildContent(context, state.username, state.password);
        else
          return CustomErrorWidget(error: S.of(context).something_wrong);
      });

  Widget buildContent(BuildContext context, String username, String password) =>
      Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Expanded(child: buildLogo()),
            SizedBox(height: 64),
            buildLoginArea(context, username, password),
            Expanded(child: buildRegisterArea())
          ]));

  Widget buildLogo() => Container(
      width: min(MediaQuery.of(context).size.width * 3 / 5, 350),
      alignment: Alignment.bottomCenter,
      child:
          Image.asset("assets/app_text_logo_slogan.png", fit: BoxFit.fitWidth));

  Widget buildLoginArea(
          BuildContext context, String username, String password) =>
      Container(
          width: min(MediaQuery.of(context).size.width, 450),
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CommonTextField.round(
                    onChanged: (value) => setState(() {
                          BlocProvider.of<AuthenticationCubit>(context)
                              .updateLoginState(value, password);
                          _disappearError();
                        }),
                    context: context,
                    focusNode: _usernameFocus,
                    textEditingController: _usernameController,
                    errorText:
                        (_errorUsername == 'null') ? null : _errorUsername,
                    labelText: S.of(context).Email),
                SizedBox(height: 16),
                CommonTextField.round(
                    onChanged: (value) => setState(() {
                          BlocProvider.of<AuthenticationCubit>(context)
                              .updateLoginState(username, value);
                          _disappearError();
                        }),
                    context: context,
                    focusNode: _passwordFocus,
                    errorText:
                        (_errorPassword == 'null') ? null : _errorPassword,
                    textEditingController: _passwordController,
                    labelText: S.of(context).Password,
                    isVisibility: true),
                SizedBox(height: 16),
                Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: InkWell(
                        onTap: () =>
                            BlocProvider.of<AuthenticationCubit>(context)
                                .forgotPassword(),
                        child: Text(S.of(context).Forgot_password,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2!
                                .copyWith(color: AnthealthColors.primary1)))),
                SizedBox(height: 16),
                CommonButton.round(
                    context,
                    () => _loginAuthentication(context, username, password),
                    S.of(context).button_login,
                    AnthealthColors.primary1)
              ]));

  Widget buildRegisterArea() => Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(S.of(context).You_are_new_user,
                style: Theme.of(context).textTheme.bodyText2),
            SizedBox(height: 4),
            Container(
                alignment: Alignment.center,
                child: InkWell(
                    onTap: () => BlocProvider.of<AuthenticationCubit>(context)
                        .register(),
                    child: Text(S.of(context).Register_now,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2!
                            .copyWith(color: AnthealthColors.primary1)))),
            SizedBox(height: 48)
          ]);

  // Hepper Functions
  void _checkAutoFill() {
    if (widget.intentUsername != null && widget.intentPassword != null) {
      _usernameController.text = widget.intentUsername!;
      _passwordController.text = widget.intentPassword!;
    }
  }

  void _loginAuthentication(
      BuildContext context, String username, String password) {
    if (_checkUsername(context, username)) if (_checkPassword(
        context, username, password)) {
      var token = BlocProvider.of<AuthenticationCubit>(context)
          .getToken(username, password);
      if (token == 'null') {
        setState(() {
          _errorUsername = S.of(context).Wrong_email_or_password;
          _clearPassword(username);
        });
        FocusScope.of(context).requestFocus(_usernameFocus);
      }
      else BlocProvider.of<AppCubit>(context)
          .authenticate(token);
    }
  }

  bool _checkUsername(BuildContext context, String username) {
    var _result = AuthenticationLogic.checkValidEmail(context, username);
    if (_result != 'ok') {
      setState(() {
        _errorUsername = _result;
        _clearPassword(username);
      });
      FocusScope.of(context).requestFocus(_usernameFocus);
      return false;
    }
    return true;
  }

  bool _checkPassword(BuildContext context, String username, String password) {
    var _result = AuthenticationLogic.checkValidPassword(context, password);
    if (_result != 'ok') {
      setState(() {
        _errorPassword = _result;
        _clearPassword(username);
      });
      FocusScope.of(context).requestFocus(_passwordFocus);
      return false;
    }
    return true;
  }

  void _disappearError() {
    _errorUsername = 'null';
    _errorPassword = 'null';
  }

  void _clearPassword(String username) {
    BlocProvider.of<AuthenticationCubit>(context).login(username, '');
    _passwordController.clear();
  }
}
