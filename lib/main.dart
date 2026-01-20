import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tasks.dart';
import 'database_helper.dart';
import 'background_service.dart';
import 'package:intl/intl.dart';
import 'welcome_screen.dart';
import 'settings_screen.dart';
import 'alarm_manager.dart';
import 'notification_manager.dart';
import 'tts_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa todos os serviços
  await initializeService();
  await NotificationManager.initialize();
  await TTSManager.initialize();
  await AlarmManager.initialize();
  
  // Agenda os alarmes
  await AlarmManager.scheduleDailyTask();
  
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstRun = prefs.getBool('first_run') ?? true;
  
  runApp(StoicApp(isFirstRun: isFirstRun));
}

class StoicApp extends StatelessWidget {
  final bool isFirstRun;
  const StoicApp({super.key, required this.isFirstRun});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vigilância Estoica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF111621),
      ),
      home: isFirstRun ? const WelcomeScreen() : const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentDay = 1;
  bool _isTaskCompleted = false;
  final TextEditingController _reportController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentDay = prefs.getInt('current_day') ?? 1;
      _isTaskCompleted = prefs.getBool('task_completed') ?? false;
    });
  }

  Future<String> _getTaskText() async {
    return await TTSManager.getActivityText(_currentDay);
  }

  _completeTask() async {
    if (_reportController.text.length < 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("O relato deve ter no mínimo 300 caracteres.")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    String taskText = await TTSManager.getActivityText(_currentDay);
    await _dbHelper.insertLog({
      'day': _currentDay,
      'task': taskText,
      'report': _reportController.text,
      'timestamp': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
    });

    await prefs.setBool('task_completed', true);
    
    // Cancela os lembretes
    await AlarmManager.cancelAllAlarms();
    
    setState(() {
      _isTaskCompleted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Dever cumprido. A vigilância cessará até amanhã."),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String currentTask = stoicTasks[_currentDay - 1];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vigilância Estoica"),
        backgroundColor: const Color(0xFF1A202E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "DIA $_currentDay",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF195de6)),
                ),
                if (_isTaskCompleted)
                  const Icon(Icons.check_circle, color: Colors.green, size: 28),
              ],
            ),
            const SizedBox(height: 20),
            FutureBuilder<String>(
              future: _getTaskText(),
              builder: (context, snapshot) {
                String displayTask = snapshot.data ?? currentTask;
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A202E),
                    border: Border.all(color: Colors.white10),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    displayTask,
                    style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            if (!_isTaskCompleted) ...[
              const Text(
                "Escreva sua Carta ao Sábio:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _reportController,
                maxLines: 8,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1A202E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Descreva como cumpriu sua tarefa. Mínimo de 300 caracteres...",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _completeTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF195de6),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text("CUMPRIR DEVER", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ] else ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 100),
              const SizedBox(height: 20),
              const Text(
                "A tarefa de hoje foi concluída.\nO silêncio retornou.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, height: 1.4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
