import 'package:flutter/material.dart';
import 'package:flutter_app/models/auth.dart';
import 'package:flutter_app/viewmodels/mainViewModel.dart';
import 'package:scoped_model/scoped_model.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
    'acceptTerms': false
  };

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  AuthMode _authMode = AuthMode.Login;

  Widget _buildEmailInput() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'E-Mail', filled: true, fillColor: Colors.black54),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value.trim())) {
          return 'Please provide a valid email address';
        }
        return null;
      },
      onSaved: (String value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildPasswordInput() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Password', filled: true, fillColor: Colors.black54),
      controller: _passwordTextController,
      obscureText: true,
      validator: (String value) {
        if (value.isEmpty || value.length < 6) {
          return 'Password is required and must be more than 6 characters.';
        }
        return null;
      },
      onSaved: (String value) {
        _formData['password'] = value;
      },
    );
  }

  Widget _buildPasswordConfirmInput() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Confirm Password',
          filled: true,
          fillColor: Colors.black54),
      obscureText: true,
      validator: (String value) {
        if (_passwordTextController.text.trim() != value.trim()) {
          return 'Passwords do not match.';
        }

        return null;
      },
    );
  }

  Widget _buildAcceptTermsTile() {
    return SwitchListTile(
      value:
          _formData['acceptTerms'] == null ? false : _formData['acceptTerms'],
      onChanged: (bool value) {
        _formData['acceptTerms'] = value;
      },
      title: Text('Accept Terms'),
    );
  }

  void _submitForm(Function authenticate) async {
    Map<String, dynamic> response;
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    response = await authenticate(
        _formData['email'], _formData['password'], _authMode);

    if (response['success']) {
      //Navigator.pushReplacementNamed(context, '/');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(response['message']),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        },
      );
    }
  }

  Widget _buildInputScrollView() {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    return SingleChildScrollView(
      child: Container(
        width: targetWidth,
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _buildEmailInput(),
              SizedBox(
                height: 10.0,
              ),
              _buildPasswordInput(),
              SizedBox(
                height: 10.0,
              ),
              _authMode == AuthMode.Signup
                  ? _buildPasswordConfirmInput()
                  : Container(),
              _buildAcceptTermsTile(),
              SizedBox(
                height: 10.0,
              ),
              FlatButton(
                onPressed: () {
                  setState(() {
                    _authMode = _authMode == AuthMode.Login
                        ? AuthMode.Signup
                        : AuthMode.Login;
                  });
                },
                child: Text(
                    'Switch to ${_authMode == AuthMode.Login ? 'Signup' : 'Login'}'),
              ),
              SizedBox(
                height: 10.0,
              ),
              ScopedModelDescendant<MainViewModel>(builder:
                  (BuildContext context, Widget child, MainViewModel model) {
                return model.isLoading
                    ? CircularProgressIndicator()
                    : RaisedButton(
                        textColor: Colors.white,
                        child: Text(
                            '${_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'}'),
                        onPressed: () => _submitForm(model.authenticate),
                      );
              })
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageBody() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5), BlendMode.dstATop),
          image: AssetImage('assets/background.jpg'),
        ),
      ),
      padding: EdgeInsets.all(10.0),
      child: Center(
        child: _buildInputScrollView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_authMode == AuthMode.Login ? 'Login' : 'Sign Up'}'),
      ),
      body: _buildPageBody(),
    );
  }
}
