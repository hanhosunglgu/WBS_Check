import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://api.example.com/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );
      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            ElevatedButton(onPressed: _isLoading ? null : _login, child: const Text('Login')),
            TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text('Register')),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    final response = await http.get(Uri.parse('https://api.example.com/api/items'));
    if (response.statusCode == 200) {
      setState(() => _items = jsonDecode(response.body));
    }
  }

  void _logout() async {
    await http.post(Uri.parse('https://api.example.com/api/auth/logout'));
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout)]),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(_items[index]['name']),
          onTap: () => Navigator.pushNamed(context, '/detail', arguments: _items[index]['id']),
        ),
      ),
    );
  }
}
