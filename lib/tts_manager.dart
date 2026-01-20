import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tasks.dart';
import 'cobrance_phrases.dart';

/// Gerenciador de Text-to-Speech
class TTSManager {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;

  /// Inicializa o TTS com configurações para português brasileiro
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configura o idioma
      await _flutterTts.setLanguage("pt-BR");
      
      // Configura a voz (preferir voz feminina natural)
      await _flutterTts.setSpeechRate(0.8); // Velocidade moderada
      await _flutterTts.setPitch(1.0); // Tom natural
      await _flutterTts.setVolume(1.0); // Volume máximo
      
      // Configura para usar o TTS do sistema (offline)
      await _flutterTts.setEngine("com.google.android.tts");
      
      _isInitialized = true;
      print('✓ TTS inicializado com sucesso');
    } catch (e) {
      print('Erro ao inicializar TTS: $e');
    }
  }

  /// Narra a atividade diária (chamada às 05:30)
  static Future<void> narrateDailyActivity() async {
    await initialize();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      int currentDay = prefs.getInt('current_day') ?? 1;
      
      if (currentDay > stoicTasks.length) {
        currentDay = 1;
        await prefs.setInt('current_day', 1);
      }

      String task = stoicTasks[currentDay - 1];
      String message = "Dia $currentDay. Sua tarefa de hoje é: $task. "
          "Você fez um compromisso. Agora cumpra com disciplina e constância.";

      await _flutterTts.speak(message);
      print('🔊 Narração da atividade diária iniciada (Dia $currentDay)');
    } catch (e) {
      print('Erro ao narrar atividade diária: $e');
    }
  }

  /// Narra frases de cobrança (a cada 20 minutos)
  static Future<void> narrateCobrance() async {
    await initialize();

    try {
      final prefs = await SharedPreferences.getInstance();
      bool isTaskCompleted = prefs.getBool('task_completed') ?? false;

      if (isTaskCompleted) {
        print('✓ Tarefa já foi cumprida. Sem cobrança necessária.');
        return;
      }

      // Obtém uma frase aleatória de cobrança
      String phrase = getRandomCobrancePhrase();

      await _flutterTts.speak(phrase);
      print('🔊 Frase de cobrança narrada: $phrase');
    } catch (e) {
      print('Erro ao narrar cobrança: $e');
    }
  }

  /// Narra a repetição da atividade (a cada 2 horas)
  static Future<void> narrateActivityRepeat() async {
    await initialize();

    try {
      final prefs = await SharedPreferences.getInstance();
      int currentDay = prefs.getInt('current_day') ?? 1;
      bool isTaskCompleted = prefs.getBool('task_completed') ?? false;

      if (isTaskCompleted) {
        print('✓ Tarefa já foi cumprida. Sem repetição necessária.');
        return;
      }

      if (currentDay > stoicTasks.length) {
        currentDay = 1;
      }

      String task = stoicTasks[currentDay - 1];
      String message = "Lembrete: Dia $currentDay. Sua tarefa continua pendente: $task. "
          "Você tem o poder de escolher. Escolha a disciplina.";

      await _flutterTts.speak(message);
      print('🔊 Repetição da atividade narrada (Dia $currentDay)');
    } catch (e) {
      print('Erro ao narrar repetição de atividade: $e');
    }
  }

  /// Testa a narração manualmente
  static Future<void> testNarration(String text) async {
    await initialize();

    try {
      await _flutterTts.speak(text);
      print('🔊 Teste de narração: $text');
    } catch (e) {
      print('Erro ao testar narração: $e');
    }
  }

  /// Para a narração em andamento
  static Future<void> stop() async {
    try {
      await _flutterTts.stop();
      print('⏹️ Narração parada');
    } catch (e) {
      print('Erro ao parar narração: $e');
    }
  }

  /// Edita o texto da atividade diária
  static Future<void> editActivityText(int day, String newText) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_task_$day', newText);
      print('✓ Texto da atividade do dia $day atualizado');
    } catch (e) {
      print('Erro ao editar texto da atividade: $e');
    }
  }

  /// Obtém o texto customizado da atividade (se existir)
  static Future<String> getActivityText(int day) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? customText = prefs.getString('custom_task_$day');
      
      if (customText != null && customText.isNotEmpty) {
        return customText;
      }
      
      // Retorna o texto padrão se não houver customização
      if (day > 0 && day <= stoicTasks.length) {
        return stoicTasks[day - 1];
      }
      
      return "Tarefa não encontrada";
    } catch (e) {
      print('Erro ao obter texto da atividade: $e');
      return "Erro ao carregar tarefa";
    }
  }
}
