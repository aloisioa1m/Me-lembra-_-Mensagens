import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tts_manager.dart';
import 'tasks.dart';
import 'cobrance_phrases.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _taskEditController;
  int _selectedDay = 1;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _taskEditController = TextEditingController();
    _loadTaskText();
  }

  @override
  void dispose() {
    _taskEditController.dispose();
    super.dispose();
  }

  Future<void> _loadTaskText() async {
    String taskText = await TTSManager.getActivityText(_selectedDay);
    setState(() {
      _taskEditController.text = taskText;
    });
  }

  Future<void> _saveTaskText() async {
    if (_taskEditController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("O texto não pode estar vazio.")),
      );
      return;
    }

    await TTSManager.editActivityText(_selectedDay, _taskEditController.text);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Tarefa do Dia $_selectedDay atualizada com sucesso!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _testNarration() async {
    setState(() => _isPlaying = true);
    
    try {
      await TTSManager.testNarration(_taskEditController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao narrar: $e")),
      );
    } finally {
      setState(() => _isPlaying = false);
    }
  }

  Future<void> _testCobrancePhrase() async {
    setState(() => _isPlaying = true);
    
    try {
      String phrase = getRandomCobrancePhrase();
      await TTSManager.testNarration(phrase);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao narrar: $e")),
      );
    } finally {
      setState(() => _isPlaying = false);
    }
  }

  Future<void> _resetToDefault() async {
    if (_selectedDay > 0 && _selectedDay <= stoicTasks.length) {
      _taskEditController.text = stoicTasks[_selectedDay - 1];
      await TTSManager.editActivityText(_selectedDay, stoicTasks[_selectedDay - 1]);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tarefa do Dia $_selectedDay restaurada ao padrão!"),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações"),
        backgroundColor: const Color(0xFF1A202E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seção: Editar Tarefa
            const Text(
              "Editar Tarefa Diária",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF195de6),
              ),
            ),
            const SizedBox(height: 15),

            // Seletor de dia
            const Text(
              "Selecione o dia:",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A202E),
                border: Border.all(color: Colors.white10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<int>(
                value: _selectedDay,
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: const Color(0xFF1A202E),
                items: List.generate(
                  21,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text("Dia ${index + 1}"),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedDay = value);
                    _loadTaskText();
                  }
                },
              ),
            ),
            const SizedBox(height: 20),

            // Campo de edição
            const Text(
              "Texto da tarefa:",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _taskEditController,
              maxLines: 6,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1A202E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                hintText: "Digite o texto da tarefa...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              ),
            ),
            const SizedBox(height: 15),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveTaskText,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF195de6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Salvar", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetToDefault,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Padrão", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Seção: Testar Áudio
            const Text(
              "Testar Narração",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF195de6),
              ),
            ),
            const SizedBox(height: 15),

            // Botão testar tarefa
            ElevatedButton.icon(
              onPressed: _isPlaying ? null : _testNarration,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPlaying ? Colors.grey : Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(
                _isPlaying ? "Parando..." : "Testar Narração da Tarefa",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            // Botão testar frase de cobrança
            ElevatedButton.icon(
              onPressed: _isPlaying ? null : _testCobrancePhrase,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPlaying ? Colors.grey : Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(
                _isPlaying ? "Parando..." : "Testar Frase de Cobrança",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),

            // Seção: Informações
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF1A202E),
                border: Border.all(color: Colors.white10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ℹ️ Informações",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF195de6),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "• Todas as narrações funcionam offline\n"
                    "• A tarefa diária é narrada às 05:30\n"
                    "• Lembretes a cada 20 minutos (se não cumprida)\n"
                    "• Repetição da atividade a cada 2 horas\n"
                    "• Idioma: Português Brasileiro\n"
                    "• Velocidade: Moderada",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
