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
    final apiService = Provider.of<ApiService>(context);
    final patient = apiService.currentPatient;

    final List<Widget> screens = [
      HomeScreen(patient: patient),
      const ChatScreen(),
      ProfileScreen(patient: patient, onLogout: () async {
        await apiService.logout();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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

  @override
  Widget build(BuildContext context) {
    // Данные с безопасным доступом
    final String name = patient != null && patient!.containsKey('name') 
        ? patient!['name'].toString() 
        : 'Patient';
    
    final int progress = patient != null && patient!.containsKey('progress') 
        ? patient!['progress'] as int 
        : 0;
    
    final String status = patient != null && patient!.containsKey('status') 
        ? patient!['status'].toString() 
        : 'active';
    
    final String treatment = patient != null && patient!.containsKey('treatment_type') 
        ? patient!['treatment_type'].toString() 
        : 'Consultation';
    
    final String lastVisit = patient != null && patient!.containsKey('last_visit') && patient!['last_visit'] != null
        ? patient!['last_visit'].toString() 
        : 'Not scheduled';
    
    final String nextVisit = patient != null && patient!.containsKey('next_visit') && patient!['next_visit'] != null
        ? patient!['next_visit'].toString() 
        : 'Not scheduled';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Treatment'),
        backgroundColor: const Color(0xFF13B6A5),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final apiService = Provider.of<ApiService>(context, listen: false);
              await apiService.getPatientData();
            },
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
              // Welcome Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome, $name!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Your treatment is on track', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Progress Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Treatment Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Overall Progress', style: TextStyle(color: Colors.grey)),
                          Text('$progress%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress / 100,
                        color: const Color(0xFF13B6A5),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.check_circle, size: 16, color: Colors.green),
                              SizedBox(width: 6),
                              Text('On Track'),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: status == 'active' ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status == 'active' ? 'Active' : 'Completed',
                              style: TextStyle(color: status == 'active' ? Colors.orange : Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Treatment Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Current Treatment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF13B6A5).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.medical_services, color: Color(0xFF13B6A5), size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(treatment, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                const Text('Current treatment plan', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Visit Info Row
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.grey[600], size: 28),
                            const SizedBox(height: 8),
                            const Text('Last Visit', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(lastVisit, style: const TextStyle(fontWeight: FontWeight.w600)),
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
                            const Text('Next Visit', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(nextVisit, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF13B6A5))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}