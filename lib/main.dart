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
import 'cobrance_phrases.dart';

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
  int _selectedPhraseIndex = 0;
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
      _selectedPhraseIndex = prefs.getInt('selected_phrase_index') ?? 0;
    });
  }

  Future<String> _getTaskText() async {
    return await TTSManager.getActivityText(_currentDay);
  }

  _selectPhrase(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_phrase_index', index);
    setState(() {
      _selectedPhraseIndex = index;
    });
  }

  _startChallenge() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Desafio iniciado com a frase: ${cobrancePhrases[_selectedPhraseIndex]}"),
        backgroundColor: const Color(0xFF195de6),
      ),
    );
  }

  _viewAllPhrases() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111621),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "TODAS AS FRASES",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF195de6),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: cobrancePhrases.length,
                itemBuilder: (context, index) {
                  bool isSelected = index == _selectedPhraseIndex;
                  return GestureDetector(
                    onTap: () {
                      _selectPhrase(index);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF195de6).withOpacity(0.3)
                            : const Color(0xFF1A202E),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF195de6)
                              : Colors.white10,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Frase ${index + 1}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF195de6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            cobrancePhrases[index],
                            style: const TextStyle(fontSize: 13, height: 1.4),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
            const SizedBox(height: 30),
            
            // ========== PAINEL DE FRASES DE COBRANÇA ==========
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF195de6).withOpacity(0.5), width: 2),
                borderRadius: BorderRadius.circular(15),
                color: const Color(0xFF1A202E),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flash_on, color: Color(0xFF195de6), size: 24),
                      const SizedBox(width: 10),
                      const Text(
                        "ESCOLHA SUA COBRANÇA",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF195de6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  
                  // Exibe a frase selecionada
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111621),
                      border: Border.all(color: const Color(0xFF195de6).withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Frase ${_selectedPhraseIndex + 1} de ${cobrancePhrases.length}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF195de6),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          cobrancePhrases[_selectedPhraseIndex],
                          style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Botões para navegar nas frases
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _selectedPhraseIndex > 0
                              ? () => _selectPhrase(_selectedPhraseIndex - 1)
                              : () => _selectPhrase(cobrancePhrases.length - 1),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text("ANTERIOR"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF195de6).withOpacity(0.7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _selectedPhraseIndex < cobrancePhrases.length - 1
                              ? () => _selectPhrase(_selectedPhraseIndex + 1)
                              : () => _selectPhrase(0),
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text("PRÓXIMA"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF195de6).withOpacity(0.7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  
                  // Botão para iniciar desafio
                  ElevatedButton.icon(
                    onPressed: _startChallenge,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("INICIAR DESAFIO"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF195de6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Botão para ver todas as frases
                  ElevatedButton.icon(
                    onPressed: _viewAllPhrases,
                    icon: const Icon(Icons.list),
                    label: Text("VER TODAS (${cobrancePhrases.length})"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF195de6).withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            // ========== FIM DO PAINEL DE FRASES ==========
            
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Você está na tela inicial com o painel de frases"),
              duration: Duration(seconds: 2),
            ),
          );
        },
        backgroundColor: const Color(0xFF195de6),
        icon: const Icon(Icons.info_outline),
        label: const Text("HOME"),
      ),
    );
  }
}
