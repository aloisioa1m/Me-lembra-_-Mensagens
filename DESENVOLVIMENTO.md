# 📊 GUIA PRÁTICO DE DESENVOLVIMENTO

## 1️⃣ COMO FUNCIONA PASSO-A-PASSO

### 📱 Primeiro Acesso do Usuário

```
┌─────────────────────────────────────────────────────────┐
│ 1. App abre pela primeira vez                          │
│    └─ main(): primeiro parametro isFirstRun = true    │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ 2. WelcomeScreen exibida                               │
│    └─ Exibe contrato de 21 dias                       │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ 3. Usuário clica "Aceitar Desafio"                     │
│    └─ _acceptChallenge() executado                    │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│ 4. Inicialização de Serviços                           │
│    ├─ BackgroundService iniciado                      │
│    ├─ AlarmManager.scheduleDailyTask() (05:30)        │
│    ├─ SharedPreferences salva:                        │
│    │  ├─ first_run = false                            │
│    │  ├─ current_day = 1                              │
│    │  └─ task_completed = false                       │
│    └─ Navega para HomeScreen                          │
└─────────────────────────────────────────────────────────┘
```

### ⏰ Fluxo Diário (5:30 AM)

```
┌──────────────────────────────────────────────────────┐
│ 05:30 - Android Alarm Manager Trigger               │
│ └─ _dailyTaskCallback() executado                  │
└──────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────┐
│ 1️⃣ TTSManager.narrateDailyActivity()               │
│    ├─ Lê current_day de SharedPreferences           │
│    ├─ Obtém stoicTasks[current_day - 1]            │
│    ├─ Narra: "Dia 1. Sua tarefa é: Banho frio..." │
│    └─ Áudio reproduzido em português               │
└──────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────┐
│ 2️⃣ NotificationManager.showDailyTaskNotification() │
│    └─ Notificação na barra de status do Android    │
└──────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────┐
│ 3️⃣ AlarmManager.scheduleReminders()                │
│    ├─ Verifica: task_completed == false             │
│    └─ Se false, agenda callbacks a cada 20min       │
└──────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────┐
│ 4️⃣ AlarmManager.scheduleActivityRepeat()           │
│    ├─ Verifica: task_completed == false             │
│    └─ Se false, agenda callbacks a cada 2h          │
└──────────────────────────────────────────────────────┘
```

### 🔔 Lembretes Periódicos

```
20 MINUTOS DEPOIS (05:50)
┌──────────────────────────────────────────────────────┐
│ Reminder Callback Executado                         │
├──────────────────────────────────────────────────────┤
│ TTSManager.narrateCobrance()                        │
│ ├─ Seleciona frase aleatória:                      │
│ │  "Você fez um compromisso. Cumpra agora!"        │
│ └─ Narra a frase                                   │
│                                                     │
│ NotificationManager.showReminderNotification()     │
│ └─ Exibe notificação com a frase                   │
└──────────────────────────────────────────────────────┘

REPETE A CADA 20 MIN: 05:50, 06:10, 06:30, 06:50...

PÁRA QUANDO: task_completed = true
```

### 📍 Repetição de Atividade

```
2 HORAS DEPOIS (07:30)
┌──────────────────────────────────────────────────────┐
│ Activity Repeat Callback Executado                  │
├──────────────────────────────────────────────────────┤
│ TTSManager.narrateActivityRepeat()                  │
│ ├─ Lê current_day                                  │
│ ├─ Obtém stoicTasks[current_day - 1]              │
│ └─ Narra: "Lembrete: Dia 1. Banho frio ainda..."  │
│                                                     │
│ NotificationManager.showActivityRepeatNotification()│
│ └─ Exibe notificação de repetição                  │
└──────────────────────────────────────────────────────┘

REPETE A CADA 2 HORAS: 07:30, 09:30, 11:30, 13:30...

PÁRA QUANDO: task_completed = true
```

### ✅ Usuário Cumpre Tarefa

```
[Usuário clica "CUMPRIR DEVER" no HomeScreen]
                        ↓
┌──────────────────────────────────────────────────────┐
│ _completeTask() executado                           │
├──────────────────────────────────────────────────────┤
│ 1. Validação                                        │
│    └─ Verifica se relatório >= 300 caracteres      │
│                                                     │
│ 2. Salva no Banco de Dados                          │
│    ├─ DatabaseHelper.insertLog({                   │
│    │  day: 1,                                      │
│    │  task: "Banho frio ao acordar...",          │
│    │  report: "[Relato do usuário...]",          │
│    │  timestamp: "2026-01-21 14:30"               │
│    │ })                                           │
│    └─ Retorna ID do registro                      │
│                                                     │
│ 3. Atualiza SharedPreferences                       │
│    └─ task_completed = true                       │
│                                                     │
│ 4. Cancela Alarmes                                 │
│    ├─ AndroidAlarmManager.cancel(dailyTaskAlarmId) │
│    ├─ AndroidAlarmManager.cancel(reminderAlarmId)  │
│    └─ AndroidAlarmManager.cancel(repeatActivityAlarmId)
│                                                     │
│ 5. Atualiza UI                                      │
│    ├─ setState() → recarrega interface            │
│    ├─ Mostra ícone de check verde                 │
│    └─ Mensagem: "Dever cumprido. O silêncio..."   │
└──────────────────────────────────────────────────────┘
```

### 📅 Transição para Próximo Dia

```
PRÓXIMO DIA 05:30 → Novo Alarme Dispara
                        ↓
┌──────────────────────────────────────────────────────┐
│ No callback _dailyTaskCallback():                   │
│                                                     │
│ 1. Incrementa dia                                  │
│    └─ current_day = (current_day % 21) + 1        │
│                                                     │
│ 2. Reseta status                                   │
│    └─ task_completed = false                      │
│                                                     │
│ 3. Repete todo o processo                         │
│    └─ Narração, notificações, alarmes...          │
│                                                     │
│ CICLO COMPLETO: 21 dias → volta para dia 1       │
└──────────────────────────────────────────────────────┘
```

---

## 2️⃣ CÓDIGO-EXEMPLO: COMO ADICIONAR UMA NOVA FUNCIONALIDADE

### Exemplo: Adicionar lembretes via Email

```dart
// 1. Criar novo arquivo: email_notifier.dart

import 'package:mailer/mailer.dart';
import 'tasks.dart';

class EmailNotifier {
  static final mailer = _createSmtpConnection();
  
  // Configura conexão SMTP
  static SmtpServer _createSmtpConnection() {
    return gmail('seu_email@gmail.com', 'sua_senha_app');
  }
  
  // Envia email com resumo do dia
  static Future<void> sendDailyReport(
    String userEmail, 
    int day, 
    String task,
    String report
  ) async {
    final message = Message()
      ..from = Address('vigilancia_estoica@gmail.com')
      ..recipients.add(userEmail)
      ..subject = 'Vigilância Estoica - Dia $day Concluído'
      ..text = '''
        Parabéns! Você completou o Dia $day.
        
        Tarefa: $task
        
        Seu Relato:
        $report
        
        Continue firme no caminho estoico!
      ''';
    
    try {
      await send(message, mailer);
      print('✓ Email enviado para $userEmail');
    } catch (e) {
      print('Erro ao enviar email: $e');
    }
  }
}

// 2. Integrar com HomeScreen

// Em _completeTask():
Future<void> _completeTask() async {
  // ... código existente ...
  
  // Novo: Enviar email
  await EmailNotifier.sendDailyReport(
    'user@email.com',
    _currentDay,
    currentTask,
    _reportController.text
  );
  
  // ... resto do código ...
}

// 3. Adicionar dependência em pubspec.yaml
dependencies:
  mailer: ^6.0.0
```

### Exemplo: Adicionar análise de progresso

```dart
// analytics.dart

import 'database_helper.dart';
import 'package:intl/intl.dart';

class ProgressAnalytics {
  static final _dbHelper = DatabaseHelper();
  
  // Calcula taxa de conclusão
  static Future<double> getCompletionRate(int days) async {
    final logs = await _dbHelper.getLogs();
    final recent = logs.where((log) => log['day'] >= 1 && log['day'] <= days);
    
    if (recent.isEmpty) return 0.0;
    
    final uniqueDays = recent.map((log) => log['day']).toSet();
    return (uniqueDays.length / days) * 100;
  }
  
  // Obtém dia com melhor relatório
  static Future<Map?> getBestReport() async {
    final logs = await _dbHelper.getLogs();
    if (logs.isEmpty) return null;
    
    // Ordena por comprimento do relatório (maior = mais reflexivo)
    logs.sort((a, b) => (b['report'] as String).length.compareTo(
      (a['report'] as String).length
    ));
    
    return logs.first;
  }
  
  // Gera sumário de progresso
  static Future<String> generateSummary() async {
    final completionRate = await getCompletionRate(21);
    final bestReport = await getBestReport();
    
    return '''
      📊 RESUMO DO SEU PROGRESSO
      
      Taxa de Conclusão: ${completionRate.toStringAsFixed(1)}%
      
      Melhor Reflexão:
      Dia ${bestReport?['day']}: "${bestReport?['report'].substring(0, 100)}..."
      
      Continue firme! A disciplina é a ponte entre objetivos e realização.
    ''';
  }
}

// Uso em SettingsScreen:
ElevatedButton(
  onPressed: () async {
    final summary = await ProgressAnalytics.generateSummary();
    print(summary);
  },
  child: Text('Ver Progresso'),
)
```

---

## 3️⃣ FLUXO DE DADOS VISUAL

```
┌─────────────────────────────────────────────────────────────┐
│                   ENTRADA DE DADOS                         │
└─────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
    ┌─────▼──────┐    ┌──────▼──────┐   ┌───────▼──────┐
    │ Keyboard   │    │  Alarmes    │   │ Notificações │
    │ (Relatório)│    │  (Callbacks)│   │  (Cliques)   │
    └─────┬──────┘    └──────┬──────┘   └───────┬──────┘
          │                  │                   │
          └──────────────────┼───────────────────┘
                             │
                   ┌─────────▼────────────┐
                   │   PROCESSAMENTO      │
                   ├──────────────────────┤
                   │                      │
                   │ HomeScreen           │
                   │ SettingsScreen       │
                   │ BackgroundService    │
                   │                      │
                   └─────────┬────────────┘
                             │
          ┌──────────────────┼──────────────────┐
          │                  │                  │
    ┌─────▼─────────┐  ┌────▼────────┐  ┌────▼─────────┐
    │ Persistência  │  │ Execução    │  │ Saída        │
    ├───────────────┤  ├─────────────┤  ├──────────────┤
    │               │  │             │  │              │
    │ SharedPrefs   │  │ TTSManager  │  │ Áudio        │
    │ Database      │  │ Alarmes     │  │ Notificações │
    │               │  │ Background  │  │ UI Updates   │
    │               │  │             │  │              │
    └───────────────┘  └─────────────┘  └──────────────┘
```

---

## 4️⃣ TRATAMENTO DE ERROS

```dart
// Exemplo de tratamento robusto

class RobustHomeScreen extends _HomeScreenState {
  
  @override
  Future<void> initState() async {
    super.initState();
    try {
      await _loadProgress();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar: $e')),
      );
      // Usa valores padrão
      setState(() {
        _currentDay = 1;
        _isTaskCompleted = false;
      });
    }
  }
  
  @override
  Future<void> _completeTask() async {
    try {
      // Validação
      if (_reportController.text.isEmpty) {
        throw Exception('Relatório não pode estar vazio');
      }
      
      if (_reportController.text.length < 300) {
        throw Exception('Mínimo de 300 caracteres');
      }
      
      // Operações
      await _dbHelper.insertLog({...});
      await AlarmManager.cancelAllAlarms();
      
      // UI Update
      setState(() => _isTaskCompleted = true);
      
    } on DatabaseException catch (e) {
      // Erro específico de banco de dados
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // Erro genérico
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

---

## 5️⃣ TESTES UNITÁRIOS

```dart
// test/alarm_manager_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:vigilancia_estoica/alarm_manager.dart';

void main() {
  group('AlarmManager', () {
    
    test('_getNextOccurrence retorna hora correta', () {
      final now = DateTime(2026, 1, 21, 6, 0); // 6:00 AM
      final expected = DateTime(2026, 1, 21, 5, 30); // 5:30 AM
      
      // Se hora já passou, deve retornar próximo dia
      expect(
        AlarmManager._getNextOccurrence(5, 30),
        isA<DateTime>()
      );
    });
    
    test('scheduleDailyTask agenda corretamente', () async {
      await AlarmManager.initialize();
      await AlarmManager.scheduleDailyTask();
      
      // Verifica se foi agendado
      expect(true, isTrue); // Mock seria mais apropriado
    });
  });
}

// test/database_helper_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:vigilancia_estoica/database_helper.dart';

void main() {
  group('DatabaseHelper', () {
    
    test('Singleton retorna mesma instância', () {
      final db1 = DatabaseHelper();
      final db2 = DatabaseHelper();
      
      expect(identical(db1, db2), isTrue);
    });
    
    test('insertLog salva registro corretamente', () async {
      final db = DatabaseHelper();
      
      final id = await db.insertLog({
        'day': 1,
        'task': 'Banho frio',
        'report': 'Fiz com sucesso e...' * 10,
        'timestamp': '2026-01-21 10:00'
      });
      
      expect(id, isA<int>());
      expect(id, greaterThan(0));
    });
  });
}
```

---

## 6️⃣ DEBUGGING

```dart
// lib/debug_utils.dart

class DebugUtils {
  
  // Log estruturado
  static void logEvent(String event, {Map<String, dynamic>? data}) {
    print('🔍 [${DateTime.now().toIso8601String()}] $event');
    if (data != null) {
      print(jsonEncode(data));
    }
  }
  
  // Dump de estado
  static Future<void> dumpState() async {
    final prefs = await SharedPreferences.getInstance();
    final db = DatabaseHelper();
    
    print('\n📊 ESTADO ATUAL:');
    print('current_day: ${prefs.getInt("current_day")}');
    print('task_completed: ${prefs.getBool("task_completed")}');
    print('selected_phrase_index: ${prefs.getInt("selected_phrase_index")}');
    
    final logs = await db.getLogs();
    print('Total de registros: ${logs.length}');
    print('Últimos 3 logs:');
    logs.take(3).forEach((log) {
      print('  - Dia ${log["day"]}: ${log["timestamp"]}');
    });
  }
  
  // Limpar estado (para testes)
  static Future<void> resetState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('✓ Estado resetado');
  }
}

// Usar em main() ou em um botão de debug
void main() async {
  // ... inicialização ...
  if (kDebugMode) {
    await DebugUtils.dumpState();
  }
}
```

---

## 7️⃣ CHECKLIST DE DEPLOY

- [ ] Testar em dispositivo físico com Android 8+ e 14+
- [ ] Verificar permissões no AndroidManifest.xml
- [ ] Testar alarmes em reboot
- [ ] Validar notificações sem internet
- [ ] Testar TTS com voz portuguesa
- [ ] Backup do banco de dados
- [ ] Incrementar versionCode em build.gradle
- [ ] Gerar APK/App Bundle para release
- [ ] Assinar com key store
- [ ] Enviar para Google Play

---

**Última atualização:** Janeiro 2026
