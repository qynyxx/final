import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Wajib import http

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State {
  String _quote = "Tekan tombol di bawah untuk memuat motivasi lari...";
  String _author = "System";
  bool _isLoading = false;

  // Fungsi melakukan HTTP Request dengan HTTPS
  Future _fetchRunningQuote() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Menggunakan protokol HTTPS sesuai ketentuan tugas
      final url = Uri.parse('https://api.quotable.io/random?tags=inspirational');
      
      // HTTP Request GET
      final response = await http.get(url);

      // HTTP Response Check
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _quote = data['content'];
          _author = data['author'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _quote = "Gagal memuat data dari server.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _quote = "Terjadi kesalahan koneksi internet: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motivasi Lari (Page 2 - HTTP API)'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_download, size: 64, color: Color(0xFF3B82F6)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                children: [
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          '"$_quote"',
                          style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                  const SizedBox(height: 12),
                  Text(
                    '- $_author -',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _fetchRunningQuote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Ambil HTTP Request (HTTPS)',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}