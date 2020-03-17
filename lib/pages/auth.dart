import 'package:flutter/material.dart';
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

  Widget _buildEmailInput() {
    return TextFormField(
      decoration: InputDecoration(
          labelText: 'E-Mail', filled: true, fillColor: Colors.black54),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Email is required.';
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
      obscureText: true,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Password is required.';
        }
        return null;
      },
      onSaved: (String value) {
        _formData['password'] = value;
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

  void _submitForm(Function login) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    login(_formData['email'], _formData['password']);
    Navigator.pushReplacementNamed(context, '/products');
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
              _buildAcceptTermsTile(),
              SizedBox(
                height: 10.0,
              ),
              ScopedModelDescendant<MainViewModel>(builder:
                  (BuildContext context, Widget child, MainViewModel model) {
                return RaisedButton(
                  textColor: Colors.white,
                  child: Text('LOGIN'),
                  onPressed: () => _submitForm(model.login),
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
        title: Text('Login'),
      ),
      body: _buildPageBody(),
    );
  }
}
