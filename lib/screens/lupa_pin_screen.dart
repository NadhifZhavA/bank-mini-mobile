import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LupaPinScreen extends StatefulWidget {
  final String nis;
  const LupaPinScreen({super.key, required this.nis});

  @override
  State<LupaPinScreen> createState() => _LupaPinScreenState();
}

class _LupaPinScreenState extends State<LupaPinScreen> {
  late final TextEditingController _nisController;
  final _passwordController = TextEditingController();
  final _pinBaruController = TextEditingController();
  final _pinConfirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nisController = TextEditingController(text: widget.nis);
  }

  void _handleSubmit() async {
    final nis = _nisController.text.trim();
    final pwd = _passwordController.text.trim();
    final pin = _pinBaruController.text.trim();
    final confirm = _pinConfirmController.text.trim();

    if (nis.isEmpty || pwd.isEmpty || pin.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi formulir dan pastikan PIN terdiri dari 6 digit angka.')),
      );
      return;
    }

    if (pin != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi PIN baru tidak sesuai.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final res = await ApiService.lupaPin(nis, pwd, pin);
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'PIN berhasil diperbarui.'),
          backgroundColor: const Color(0xFF166534),
        ),
      );
      Navigator.pop(context);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Gagal reset PIN.'),
          backgroundColor: const Color(0xFF991B1B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Reset PIN Keamanan Transaksi'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/logo-smkn1bantul.png',
                      height: 38,
                      width: 38,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.shield_outlined, size: 36, color: Color(0xFF1E3A8A)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BANK MINI SEKOLAH', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                          Text('Otorisasi PIN Penarikan Uang Siswa', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, color: Color(0xFFE5E7EB)),

                const Text(
                  'Atur Ulang PIN Otorisasi (6-Digit)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Verifikasi kata sandi akun siswa Anda untuk menetapkan PIN penarikan kas baru secara mandiri.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 18),

                const Text('Nomor Induk Siswa (NIS) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _nisController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Kata Sandi Akun Siswa *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Masukkan kata sandi login Anda',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('PIN Baru (6 Digit Angka) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _pinBaruController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  obscureText: true,
                  style: const TextStyle(fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: '000000',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 8),

                const Text('Konfirmasi PIN Baru *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _pinConfirmController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  obscureText: true,
                  style: const TextStyle(fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'Ketik ulang 6 digit PIN baru',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Simpan PIN Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
