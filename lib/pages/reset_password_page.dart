import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;
  const ResetPasswordPage({required this.token});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final supabase = Supabase.instance.client;
    setState(() => isLoading = true);

    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPasswordController.text),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password berhasil diubah")),
      );

      Navigator.pop(context); // Kembali ke login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal ganti password: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _setSessionWithToken();
  }

  Future<void> _setSessionWithToken() async {
    final supabase = Supabase.instance.client;
    try {
      final response = await supabase.auth.exchangeCodeForSession(widget.token);
      debugPrint("Session created: ${response.session}");
    } catch (e) {
      debugPrint("Gagal set session dengan code: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Icon(Icons.lock_reset, size: 80, color: Colors.blue),
                SizedBox(height: 30),
                Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('Silakan masukkan password baru Anda',
                    style: TextStyle(color: Colors.grey)),
                SizedBox(height: 30),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password Baru',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _resetPassword,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Simpan Password Baru'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
