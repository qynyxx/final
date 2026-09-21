import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Running Reminder',
      theme: ThemeData(
        fontFamily: 'Sans-Serif',
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      _isLoading = false;
    });
  }

  void _handleLoginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _isLoggedIn
        ? HomeScreen(onLogout: _handleLogout)
        : LoginScreen(onLoginSuccess: _handleLoginSuccess);
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const HomeScreen({super.key, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Data default jika belum ada jadwal tersimpan
  List<Map<String, dynamic>> _schedules = [
    {
      'day': 'Senin',
      'time': '06:00 AM',
      'type': 'Easy Run',
      'distance': '5 km',
      'isCompleted': true
    },
    {
      'day': 'Selasa',
      'time': '06:00 AM',
      'type': 'Recovery run',
      'distance': '6 km',
      'isCompleted': false
    },
    {
      'day': 'Rabu',
      'time': '05:30 PM',
      'type': 'Tempo Run',
      'distance': '8 km',
      'isCompleted': false
    },
    {
      'day': 'Jumat',
      'time': '06:00 AM',
      'type': 'Interval Run',
      'distance': '4 km',
      'isCompleted': false
    },
    {
      'day': 'Sabtu',
      'time': '06:30 AM',
      'type': 'Long Run',
      'distance': '12 km',
      'isCompleted': false
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  // Memuat jadwal dari SharedPreferences
  Future<void> _loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final String? schedulesJson = prefs.getString('saved_schedules');
    if (schedulesJson != null) {
      final List<dynamic> decoded = jsonDecode(schedulesJson);
      setState(() {
        _schedules = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  // Menyimpan jadwal ke SharedPreferences
  Future<void> _saveSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_schedules', jsonEncode(_schedules));
  }

  // Menghitung total jarak dari semua jadwal
  int _calculateTotalDistance() {
    int total = 0;
    for (var item in _schedules) {
      final String distanceStr = item['distance'].toString().replaceAll(RegExp(r'[^0-9]'), '');
      total += int.tryParse(distanceStr) ?? 0;
    }
    return total;
  }

  // Fungsi Dialog Tambah Jadwal Baru
  void _showAddScheduleDialog() {
    final dayController = TextEditingController();
    final timeController = TextEditingController();
    final typeController = TextEditingController();
    final distanceController = TextEditingController();

    String selectedDay = 'Senin';
    final List<String> days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

    showDialog(
      context: context,
     builder: (context) {
    return StatefulBuilder(
    builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Tambah Jadwal Lari', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedDay,
                      decoration: const InputDecoration(labelText: 'Hari'),
                      items: days.map((day) {
                        return DropdownMenuItem(value: day, child: Text(day));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedDay = val);
                      },
                    ),
                    TextField(
                      controller: timeController,
                      decoration: const InputDecoration(labelText: 'Waktu (misal: 06:00 AM)'),
                    ),
                    TextField(
                      controller: typeController,
                      decoration: const InputDecoration(labelText: 'Jenis Lari (misal: Easy Run)'),
                    ),
                    TextField(
                      controller: distanceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Jarak dalam km (misal: 5)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (timeController.text.isEmpty ||
                        typeController.text.isEmpty ||
                        distanceController.text.isEmpty) {
                      return;
                    }

                    setState(() {
                      _schedules.add({
                        'day': selectedDay,
                        'time': timeController.text.trim(),
                        'type': typeController.text.trim(),
                        'distance': '${distanceController.text.trim()} km',
                        'isCompleted': false,
                      });
                    });

                    _saveSchedules();
                    Navigator.pop(context);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Jadwal Lari Saya',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddScheduleDialog,
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Total Sasaran Minggu Ini
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sasaran Minggu Ini',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_calculateTotalDistance()} KM',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    backgroundColor: Colors.white10,
                    radius: 24,
                    child: Icon(Icons.directions_run, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Jadwal Akan Datang',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Daftar Schedule
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _schedules.length,
              itemBuilder: (context, index) {
                final item = _schedules[index];
                final bool isCompleted = item['isCompleted'] ?? false;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isCompleted
                              ? Colors.green.shade100
                              : Colors.blue.shade50,
                          child: Icon(
                            isCompleted ? Icons.check_circle : Icons.access_time_filled,
                            color: isCompleted ? Colors.green : Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${item['day']} • ${item['time']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    isCompleted ? 'Selesai' : 'Akan datang',
                                    style: TextStyle(
                                      color: isCompleted ? Colors.green : Colors.orange,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item['type']} — Jarak: ${item['distance']}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}