import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ApiService>(context);
    final patient = api.currentPatient;

    final screens = [
      HomeScreen(patient: patient),
      const ChatScreen(),
      ProfileScreen(patient: patient, onLogout: () async {
        await api.logout();
        if (mounted) Navigator.of(context).pushReplacementNamed('/login');
      }),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: const Color(0xFF13B6A5),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic>? patient;

  const HomeScreen({super.key, this.patient});

  String _get(String key, [String def = 'N/A']) => patient?.containsKey(key) == true ? patient![key].toString() : def;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Treatment'),
        backgroundColor: const Color(0xFF13B6A5),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => Provider.of<ApiService>(context, listen: false).getPatientData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Provider.of<ApiService>(context, listen: false).getPatientData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Welcome, ${_get('name', 'Patient')}!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Your treatment is on track', style: TextStyle(color: Colors.grey[600])),
              ])),
              const SizedBox(height: 20),
              _progressCard(),
              const SizedBox(height: 20),
              _treatmentCard(),
              const SizedBox(height: 20),
              _visitRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(Widget child) => Card(child: Padding(padding: const EdgeInsets.all(20), child: child));

  Widget _progressCard() {
    int progress = int.tryParse(_get('progress', '0')) ?? 0;
    String status = _get('status', 'active');
    return _card(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Treatment Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Overall Progress', style: TextStyle(color: Colors.grey[600])),
          Text('$progress%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress / 100, color: const Color(0xFF13B6A5), minHeight: 8),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Row(children: [Icon(Icons.check_circle, size: 16, color: Colors.green), SizedBox(width: 6), Text('On Track')]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: status == 'active' ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status == 'active' ? 'Active' : 'Completed', style: TextStyle(color: status == 'active' ? Colors.orange : Colors.green)),
          ),
        ]),
      ],
    ));
  }

  Widget _treatmentCard() {
    String treatment = _get('treatment_type', 'Consultation');
    return _card(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Current Treatment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF13B6A5).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.medical_services, color: Color(0xFF13B6A5), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(treatment, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  Text('Current treatment plan', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ],
    ));
  }

  Widget _visitRow() {
    String last = _get('last_visit', 'Not scheduled');
    String next = _get('next_visit', 'Not scheduled');
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey[600], size: 28),
                  const SizedBox(height: 8),
                  Text('Last Visit', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Text(last, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.event, color: Color(0xFF13B6A5), size: 28),
                  const SizedBox(height: 8),
                  Text('Next Visit', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Text(next, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF13B6A5))),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}