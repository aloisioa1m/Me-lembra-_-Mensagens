# 📐 ARQUITETURA COMPLETA - VIGILÂNCIA ESTOICA

## 1️⃣ ESTRUTURA GERAL DA APLICAÇÃO

```
┌─────────────────────────────────────────────────────────────────┐
│                    VIGILÂNCIA ESTOICA v2.0                      │
│                                                                 │
│  ┌────────────────┐         ┌──────────────────┐                │
│  │   main.dart    │─────────│   HomeScreen     │                │
│  │ (Aplicação)    │         │ (Tela Principal) │                │
│  └────────────────┘         └──────────────────┘                │
│         │                            │                          │
│         ├─────────────────────────────┤                          │
│         │                             │                          │
│    ┌────▼─────┐  ┌──────────┐  ┌────▼──────┐                   │
│    │ Managers  │  │ Screens  │  │ Utilities  │                  │
│    └─────┬─────┘  └──────────┘  └────┬──────┘                   │
│          │                            │                          │
│    ┌─────┴──────┬──────────┬─────┐    │                         │
│    │            │          │     │    │                         │
│    ▼            ▼          ▼     ▼    ▼                         │
│  Alarm    Notification   TTS    Bg   Database                  │
│ Manager    Manager      Manager Srv  Helper                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2️⃣ CLASSES E ESTRUTURA

### 📦 main.dart
**Responsabilidade:** Inicialização da aplicação e gerenciamento da tela principal

#### Classe: `StoicApp` (StatelessWidget)
```dart
class StoicApp extends StatelessWidget {
  - final bool isFirstRun              // Verifica se é primeira execução
  - build(BuildContext context) → Widget
}
```

#### Classe: `HomeScreen` (StatefulWidget)
```dart
class HomeScreen extends StatefulWidget {
  - createState() → State<HomeScreen>
}

class _HomeScreenState extends State<HomeScreen> {
  
  // ========== ATRIBUTOS ==========
  - int _currentDay                   // Dia atual (1-21)
  - bool _isTaskCompleted            // Status da tarefa do dia
  - int _selectedPhraseIndex          // Índice da frase selecionada
  - TextEditingController _reportController  // Controle do relato
  - DatabaseHelper _dbHelper          // Gerenciador do banco de dados
  
  // ========== CICLO DE VIDA ==========
  + initState()                       // Carrega o progresso ao abrir
  + dispose()                         // Limpa recursos
  
  // ========== MÉTODOS PRIVADOS ==========
  - _loadProgress() → Future<void>    // Carrega progresso do SharedPreferences
  - _completeTask() → Future<void>    // Marca tarefa como concluída
  - _selectPhrase(int index) → Future<void>  // Seleciona frase de cobrança
  - _startChallenge() → Future<void>  // Inicia desafio com frase
  - _viewAllPhrases() → void          // Abre modal com todas as frases
  
  // ========== MÉTODOS PÚBLICOS ==========
  + build(BuildContext context) → Widget  // Constrói a UI
  + _getTaskText() → Future<String>   // Obtém texto da tarefa
}
```

**Fluxo de Dados:**
```
_loadProgress()
    ↓
SharedPreferences (lê dados salvos)
    ↓
setState() com _currentDay, _isTaskCompleted, _selectedPhraseIndex
    ↓
build() renderiza a UI com os dados
```

---

### 📋 alarm_manager.dart
**Responsabilidade:** Gerenciar alarmes do Android para agendamento de tarefas

#### Classe: `AlarmManager` (Singleton com métodos estáticos)
```dart
class AlarmManager {
  
  // ========== CONSTANTES ==========
  + static const int dailyTaskAlarmId = 1001
  + static const int reminderAlarmId = 1002
  + static const int repeatActivityAlarmId = 1003
  
  // ========== MÉTODOS ESTÁTICOS ==========
  
  + initialize() → Future<void>
    └─ Inicializa AndroidAlarmManager
  
  + scheduleDailyTask() → Future<void>
    └─ Agenda tarefa para 05:30 todos os dias
    └─ Triggers: _dailyTaskCallback
  
  + scheduleReminders() → Future<void>
    └─ Agenda lembretes a cada 20 minutos
    └─ Verifica se tarefa foi concluída
    └─ Triggers: _reminderCallback
  
  + scheduleActivityRepeat() → Future<void>
    └─ Agenda repetição a cada 2 horas
    └─ Triggers: _repeatActivityCallback
  
  + cancelAllAlarms() → Future<void>
    └─ Cancela todos os 3 alarmes
  
  // ========== CALLBACKS (Pragma annotation) ==========
  
  - _dailyTaskCallback() → Future<void>
    └─ Reseta status da tarefa
    └─ Inicia background service
    └─ Agenda lembretes
  
  - _reminderCallback() → Future<void>
    └─ Executa lembrete a cada 20min
  
  - _repeatActivityCallback() → Future<void>
    └─ Executa repetição a cada 2h
  
  // ========== UTILIDADES ==========
  
  - _getNextOccurrence(int hour, int minute) → DateTime
    └─ Calcula próxima ocorrência de um horário
}
```

**Fluxo Temporal:**
```
05:30 → _dailyTaskCallback()
   ├─ Reseta 'task_completed' = false
   ├─ Inicia Background Service
   ├─ Agenda reminders a cada 20min
   └─ Agenda activity repeat a cada 2h

Cada 20min (05:50, 06:10, etc) → _reminderCallback()
   └─ TTSManager.narrateCobrance() (frase aleatória)

Cada 2h (07:30, 09:30, etc) → _repeatActivityCallback()
   └─ TTSManager.narrateActivityRepeat() (lembrete da tarefa)

Quando task_completed = true
   └─ cancelAllAlarms()
```

---

### 🔔 notification_manager.dart
**Responsabilidade:** Gerenciar notificações locais do Android

#### Classe: `NotificationManager` (Singleton com métodos estáticos)
```dart
class NotificationManager {
  
  // ========== ATRIBUTOS ESTÁTICOS ==========
  - static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin
  
  // ========== CONSTANTES ==========
  + static const int dailyTaskNotificationId = 1
  + static const int reminderNotificationId = 2
  + static const int repeatActivityNotificationId = 3
  
  // ========== MÉTODOS ESTÁTICOS ==========
  
  + initialize() → Future<void>
    ├─ Configura AndroidInitializationSettings
    ├─ Cria canais de notificação
    └─ Define handler para clique em notificações
  
  - _createNotificationChannels() → Future<void>
    ├─ Cria canal 'stoic_daily_task' (Importância: MAX)
    ├─ Cria canal 'stoic_reminder' (Importância: HIGH)
    ├─ Cria canal 'stoic_repeat_activity' (Importância: HIGH)
    └─ Todas com som, vibração e reprodução ativados
  
  + showDailyTaskNotification() → Future<void>
    └─ Mostra notificação da tarefa diária
  
  + showReminderNotification(String phrase) → Future<void>
    └─ Mostra notificação com frase de cobrança
  
  + showActivityRepeatNotification() → Future<void>
    └─ Mostra notificação de repetição
}
```

**Canais de Notificação:**
```
┌─────────────────────────────────────────────┐
│ stoic_daily_task (Tarefa Diária)           │
│ - ID: 1, Importância: MAX                  │
│ - Som: notification, Vibração: SIM         │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ stoic_reminder (Lembretes)                 │
│ - ID: 2, Importância: HIGH                 │
│ - Som: notification, Vibração: SIM         │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ stoic_repeat_activity (Repetição)          │
│ - ID: 3, Importância: HIGH                 │
│ - Som: notification, Vibração: SIM         │
└─────────────────────────────────────────────┘
```

---

### 🔊 tts_manager.dart
**Responsabilidade:** Gerenciar Text-to-Speech para narração

#### Classe: `TTSManager` (Singleton com métodos estáticos)
```dart
class TTSManager {
  
  // ========== ATRIBUTOS ESTÁTICOS ==========
  - static final FlutterTts _flutterTts
  - static bool _isInitialized = false
  
  // ========== MÉTODOS ESTÁTICOS ==========
  
  + initialize() → Future<void>
    ├─ Configura idioma: "pt-BR" (Português Brasil)
    ├─ velocidade: 0.8 (moderada)
    ├─ tom (pitch): 1.0 (natural)
    ├─ volume: 1.0 (máximo)
    └─ engine: "com.google.android.tts"
  
  + narrateDailyActivity() → Future<void>
    ├─ Lê currentDay do SharedPreferences
    ├─ Obtém tarefa de stoicTasks[currentDay-1]
    ├─ Narra: "Dia X. Sua tarefa é: [task]. Cumpra com disciplina."
    └─ Chamado às 05:30 por AlarmManager
  
  + narrateCobrance() → Future<void>
    ├─ Verifica se task_completed = true
    ├─ Se false, obtém frase aleatória de cobrancePhrases
    ├─ Narra a frase
    └─ Chamado a cada 20 minutos
  
  + narrateActivityRepeat() → Future<void>
    ├─ Verifica se task_completed = true
    ├─ Se false, narra lembretes de repetição
    └─ Chamado a cada 2 horas
  
  + testNarration(String text) → Future<void>
    └─ Testa TTS com um texto específico
  
  + getActivityText(int day) → Future<String>
    ├─ Tenta ler do SharedPreferences (customização)
    └─ Se não existir, retorna stoicTasks[day-1]
  
  + editActivityText(int day, String text) → Future<void>
    └─ Salva tarefa customizada no SharedPreferences
}
```

**Configurações de Voz:**
```
Idioma: Português Brasil (pt-BR)
Velocidade: 0.8 (0 = mais lento, 1 = normal, >1 = mais rápido)
Tom (Pitch): 1.0 (1 = normal, >1 = mais agudo, <1 = mais grave)
Volume: 1.0 (máximo)
Engine: Google TTS (offline, suporta português)
```

---

### 💾 database_helper.dart
**Responsabilidade:** Gerenciar banco de dados SQLite

#### Classe: `DatabaseHelper` (Singleton com Factory)
```dart
class DatabaseHelper {
  
  // ========== ATRIBUTOS PRIVADOS ESTÁTICOS ==========
  - static final DatabaseHelper _instance = DatabaseHelper._internal()
  - static Database? _database
  
  // ========== CONSTRUCTOR ==========
  + factory DatabaseHelper() → DatabaseHelper
    └─ Retorna _instance (Singleton)
  
  - DatabaseHelper._internal()
    └─ Constructor privado
  
  // ========== GETTERS ==========
  + get database → Future<Database>
    ├─ Se _database é nulo, inicializa
    └─ Retorna _database
  
  // ========== MÉTODOS PRIVADOS ==========
  
  - _initDatabase() → Future<Database>
    ├─ Caminho: getDatabasesPath() + '/stoic_vigilance.db'
    ├─ Versão: 1
    ├─ Chama _onCreate se banco novo
    └─ Retorna database aberto
  
  - _onCreate(Database db, int version) → Future<void>
    └─ Cria tabela 'logs' com schema:
    
  // ========== MÉTODOS PÚBLICOS ==========
  
  + insertLog(Map<String, dynamic> row) → Future<int>
    ├─ Insere registro na tabela 'logs'
    └─ Retorna id do registro inserido
  
  + getLogs() → Future<List<Map<String, dynamic>>>
    ├─ Lê todos os logs
    └─ Ordena por 'day DESC' (dia mais recente primeiro)
}
```

**Schema da Tabela 'logs':**
```
┌──────────────────────────────────────────┐
│ logs                                    │
├──────────────────────────────────────────┤
│ id       | INTEGER PRIMARY KEY (autoincrement) │
│ day      | INTEGER (dia 1-21)         │
│ task     | TEXT (tarefa realizada)    │
│ report   | TEXT (relato mínimo 300ch) │
│ timestamp| TEXT (data/hora do registro)│
└──────────────────────────────────────────┘
```

---

### 🎯 tasks.dart
**Responsabilidade:** Armazenar lista de tarefas dos 21 dias

```dart
const List<String> stoicTasks = [
  // Dia 1
  "Banho frio ao acordar. Entre sem hesitar. ...",
  // Dia 2
  "Coma apenas o necessário hoje. Elimine...",
  // ... (21 tarefas no total)
]
```

**Estrutura:**
- Lista imutável com 21 strings
- Cada string é uma tarefa diária completa
- Acessada por índice: `stoicTasks[currentDay - 1]`

---

### 💬 cobrance_phrases.dart
**Responsabilidade:** Armazenar frases de motivação

```dart
const List<String> cobrancePhrases = [
  "Você fez um compromisso. Onde está sua disciplina?",
  "Você jurou dedicar 15 minutos. Não seja um tratante.",
  // ... (50+ frases motivacionais)
]

String getRandomCobrancePhrase() → String
  └─ Retorna frase aleatória da lista
```

**Categorias de Frases:**
- Compromisso (4 frases)
- Estoicismo (4 frases)
- Virtude (4 frases)
- Controle (4 frases)
- Tempo (4 frases)
- Coragem (4 frases)
- Responsabilidade (4 frases)
- Transformação (6+ frases)

---

### 🖥️ settings_screen.dart
**Responsabilidade:** Permitir edição de tarefas

#### Classe: `SettingsScreen` (StatefulWidget)
```dart
class SettingsScreen extends StatefulWidget {
  - createState() → State<SettingsScreen>
}

class _SettingsScreenState extends State<SettingsScreen> {
  
  // ========== ATRIBUTOS ==========
  - late TextEditingController _taskEditController
  - int _selectedDay = 1
  - bool _isPlaying = false
  
  // ========== CICLO DE VIDA ==========
  + initState() → void
    └─ Inicializa _taskEditController
  
  + dispose() → void
    └─ Libera _taskEditController
  
  // ========== MÉTODOS ==========
  
  - _loadTaskText() → Future<void>
    └─ Carrega tarefa do dia selecionado
  
  - _saveTaskText() → Future<void>
    ├─ Valida se texto não está vazio
    ├─ Salva no TTSManager
    └─ Mostra SnackBar de sucesso
  
  - _testNarration() → Future<void>
    ├─ Toca o áudio da tarefa customizada
    └─ Gerencia estado _isPlaying
  
  - _testCobrancePhrase() → Future<void>
    ├─ Toca uma frase aleatória de cobrança
    └─ Gerencia estado _isPlaying
  
  - _resetToDefault() → Future<void>
    ├─ Restaura tarefa padrão do dia
    └─ Salva no TTSManager
  
  + build(BuildContext context) → Widget
    └─ Constrói UI com seletor de dias e editor
}
```

---

### 🎬 welcome_screen.dart
**Responsabilidade:** Tela inicial e contrato de compromisso

#### Classe: `WelcomeScreen` (StatefulWidget)
```dart
class WelcomeScreen extends StatefulWidget {
  - createState() → State<WelcomeScreen>
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  
  // ========== ATRIBUTOS ==========
  - bool _acceptedCommitment = false
  
  // ========== MÉTODOS ==========
  
  - _acceptChallenge() → Future<void>
    ├─ Marca 'first_run' = false
    ├─ Seta current_day = 1
    ├─ Inicializa AlarmManager
    ├─ Schedula os alarmes
    └─ Navega para HomeScreen
  
  + build(BuildContext context) → Widget
    └─ Exibe contrato e botão de aceitar
}
```

---

### ⏰ background_service.dart
**Responsabilidade:** Gerenciar serviço em background

```dart
class BackgroundService {
  
  + initializeService() → Future<void>
    └─ Inicializa flutter_background_service
  
  + startBackgroundService() → Future<void>
    ├─ Inicia o serviço
    ├─ Configura notificação persistente
    └─ Executa callbacks periodicamente
  
  - onStart(ServiceInstance service) → void
    ├─ Ativa WakelockPlus para manter CPU ativa
    └─ Executa tarefas periodicamente
  
  - stopBackgroundService() → Future<void>
    ├─ Desativa WakelockPlus
    └─ Para o serviço
}
```

---

## 3️⃣ FLUXO DE FUNCIONAMENTO

### 📱 Inicialização da Aplicação
```
main()
  ↓
WidgetsFlutterBinding.ensureInitialized()
  ↓
initializeService()  [Background Service]
  ↓
NotificationManager.initialize()  [Notificações]
  ↓
TTSManager.initialize()  [TTS]
  ↓
AlarmManager.initialize()  [Alarmes]
  ↓
AlarmManager.scheduleDailyTask()  [Agenda 05:30 diariamente]
  ↓
SharedPreferences.getBool('first_run')
  ├─ true → WelcomeScreen (contrato)
  └─ false → HomeScreen (tela principal)
```

### 📅 Fluxo Diário Completo
```
05:30 [Alarme Diário]
  ├─ TTSManager.narrateDailyActivity()
  │  └─ "Dia X. Sua tarefa é: [task]. Cumpra!"
  │
  ├─ NotificationManager.showDailyTaskNotification()
  │
  ├─ AlarmManager.scheduleReminders()
  │  └─ Agenda callbacks a cada 20 minutos
  │
  └─ AlarmManager.scheduleActivityRepeat()
     └─ Agenda callbacks a cada 2 horas

05:50, 06:10, 06:30... [Lembretes a cada 20min]
  ├─ TTSManager.narrateCobrance()
  │  └─ Seleciona frase aleatória
  │  └─ "Você fez um compromisso. Cumpra agora!"
  │
  ├─ NotificationManager.showReminderNotification(phrase)
  │
  └─ [Se task_completed = true, para os lembretes]

07:30, 09:30, 11:30... [Repetição a cada 2h]
  ├─ TTSManager.narrateActivityRepeat()
  │  └─ "Lembrete: Dia X. Sua tarefa continua: [task]"
  │
  └─ NotificationManager.showActivityRepeatNotification()

[Usuário cumpre tarefa]
  ├─ HomeScreen._completeTask()
  │  ├─ Valida relatório (mín. 300 caracteres)
  │  ├─ DatabaseHelper.insertLog() → Salva no banco
  │  └─ SharedPreferences.setBool('task_completed', true)
  │
  ├─ AlarmManager.cancelAllAlarms()
  │
  └─ Próximo dia: current_day += 1
     └─ Ao atingir dia 22, volta para dia 1

[Próximo dia: 05:30]
  └─ Tudo recomeça...
```

### 🎯 Fluxo de Seleção de Frase
```
HomeScreen.build()
  ├─ Exibe painel "ESCOLHA SUA COBRANÇA"
  │  └─ Frase atual: cobrancePhrases[_selectedPhraseIndex]
  │
  ├─ Botão ANTERIOR
  │  └─ _selectPhrase(_selectedPhraseIndex - 1)
  │     └─ SharedPreferences.setInt('selected_phrase_index', index)
  │
  ├─ Botão PRÓXIMA
  │  └─ _selectPhrase(_selectedPhraseIndex + 1)
  │     └─ SharedPreferences.setInt('selected_phrase_index', index)
  │
  ├─ Botão VER TODAS
  │  └─ _viewAllPhrases()
  │     └─ Abre Bottom Sheet com ListView
  │        └─ Toque em frase → _selectPhrase(index)
  │
  └─ Botão INICIAR DESAFIO
     └─ _startChallenge()
        └─ TTSManager.speak(cobrancePhrases[_selectedPhraseIndex])
```

---

## 4️⃣ DEPENDÊNCIAS (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Banco de Dados
  sqflite: ^2.4.0           # SQLite para armazenar logs
  
  # Preferências
  shared_preferences: ^2.3.0  # Armazenar estado (dia, task_completed, etc)
  
  # Alarmes
  android_alarm_manager_plus: ^4.0.8  # Agendamento de tarefas
  
  # Notificações
  flutter_local_notifications: ^17.2.4  # Notificações locais
  
  # Text-to-Speech
  flutter_tts: ^4.2.3       # Narração de tarefas e frases
  
  # Background Service
  flutter_background_service: ^5.1.0  # Serviço em background
  flutter_background_service_android: ^10.0.0
  
  # Wakelock
  wakelock_plus: ^1.2.1     # Mantém CPU ativa durante execução
  
  # Permissões
  permission_handler: ^11.4.0  # Gerenciar permissões do Android
  
  # Internacionalização
  intl: ^0.19.0             # Formatação de datas
```

---

## 5️⃣ FLUXO DE DADOS (SharedPreferences)

```
SharedPreferences: Dados Persistentes
│
├─ first_run: bool (padrão: true)
│  └─ Define se é primeira execução
│
├─ current_day: int (padrão: 1)
│  └─ Dia atual do desafio (1-21)
│
├─ task_completed: bool (padrão: false)
│  └─ Se a tarefa do dia foi concluída
│
├─ selected_phrase_index: int (padrão: 0)
│  └─ Índice da frase selecionada no painel
│
└─ activity_text_day_X: String (customizações)
   └─ Texto customizado para cada dia (se editado)

Database SQLite: stoic_vigilance.db
│
└─ Tabela 'logs'
   ├─ id: INTEGER PRIMARY KEY
   ├─ day: INTEGER (1-21)
   ├─ task: TEXT (tarefa realizada)
   ├─ report: TEXT (relato do usuário)
   └─ timestamp: TEXT (data/hora)
```

---

## 6️⃣ DIAGRAMA UML COMPLETO

```
┌──────────────────────────────────────────────────────────────────┐
│                         StoicApp                                │
│                   (StatelessWidget)                             │
├──────────────────────────────────────────────────────────────────┤
│ - isFirstRun: bool                                              │
├──────────────────────────────────────────────────────────────────┤
│ + build(context): Widget                                         │
└──────────────────────────────────────────────────────────────────┘
                              △
                              │
                      ┌───────┴───────┐
                      │               │
          ┌─────────────────┐  ┌─────────────────┐
          │ WelcomeScreen   │  │  HomeScreen     │
          │ (StatefulWidget)│  │ (StatefulWidget)│
          └─────────────────┘  └─────────────────┘
                  △                     △
                  │                     │
      ┌───────────┴──────────┐         │
      │                      │         │
      │ _WelcomeScreenState  │ _HomeScreenState
      │                      │ ├─ _currentDay: int
      │ - _acceptedCommit..  │ ├─ _isTaskCompleted: bool
      │ + _acceptChallenge   │ ├─ _selectedPhraseIndex: int
      │ + build()            │ ├─ _reportController: TextEditingController
      │                      │ ├─ _dbHelper: DatabaseHelper
      │                      │ ├─ _loadProgress()
      │                      │ ├─ _completeTask()
      │                      │ ├─ _selectPhrase()
      │                      │ ├─ _startChallenge()
      │                      │ ├─ _viewAllPhrases()
      │                      │ └─ build()
      │                      │
      └──────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│                    AlarmManager                               │
│                   (static methods)                            │
├────────────────────────────────────────────────────────────────┤
│ + dailyTaskAlarmId: int = 1001                                │
│ + reminderAlarmId: int = 1002                                 │
│ + repeatActivityAlarmId: int = 1003                           │
├────────────────────────────────────────────────────────────────┤
│ + initialize(): Future<void>                                   │
│ + scheduleDailyTask(): Future<void>                            │
│ + scheduleReminders(): Future<void>                            │
│ + scheduleActivityRepeat(): Future<void>                       │
│ + cancelAllAlarms(): Future<void>                              │
│ - _dailyTaskCallback(): Future<void>                           │
│ - _reminderCallback(): Future<void>                            │
│ - _repeatActivityCallback(): Future<void>                      │
│ - _getNextOccurrence(hour, minute): DateTime                   │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│              NotificationManager                              │
│              (static methods)                                 │
├────────────────────────────────────────────────────────────────┤
│ - _flutterLocalNotificationsPlugin: FlutterLocalNotificationsPlugin │
│ + dailyTaskNotificationId: int = 1                            │
│ + reminderNotificationId: int = 2                             │
│ + repeatActivityNotificationId: int = 3                       │
├────────────────────────────────────────────────────────────────┤
│ + initialize(): Future<void>                                   │
│ - _createNotificationChannels(): Future<void>                  │
│ + showDailyTaskNotification(): Future<void>                    │
│ + showReminderNotification(phrase): Future<void>               │
│ + showActivityRepeatNotification(): Future<void>               │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│                    TTSManager                                 │
│              (static methods + Singleton)                     │
├────────────────────────────────────────────────────────────────┤
│ - _flutterTts: FlutterTts                                      │
│ - _isInitialized: bool = false                                │
├────────────────────────────────────────────────────────────────┤
│ + initialize(): Future<void>                                   │
│ + narrateDailyActivity(): Future<void>                         │
│ + narrateCobrance(): Future<void>                              │
│ + narrateActivityRepeat(): Future<void>                        │
│ + testNarration(text): Future<void>                            │
│ + getActivityText(day): Future<String>                         │
│ + editActivityText(day, text): Future<void>                    │
│ + getRandomCobrancePhrase(): String                            │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│              DatabaseHelper                                   │
│           (Singleton + Factory pattern)                       │
├────────────────────────────────────────────────────────────────┤
│ - _instance: DatabaseHelper (static)                           │
│ - _database: Database? (static)                                │
├────────────────────────────────────────────────────────────────┤
│ + factory DatabaseHelper()                                     │
│ - DatabaseHelper._internal()                                   │
│ + get database: Future<Database>                               │
│ - _initDatabase(): Future<Database>                            │
│ - _onCreate(db, version): Future<void>                         │
│ + insertLog(row): Future<int>                                  │
│ + getLogs(): Future<List<Map<String, dynamic>>>                │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│              BackgroundService                                │
│             (static initialization)                           │
├────────────────────────────────────────────────────────────────┤
│ + initializeService(): Future<void>                            │
│ + startBackgroundService(): Future<void>                       │
│ - onStart(service): void                                       │
│ + stopBackgroundService(): Future<void>                        │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│               SettingsScreen                                  │
│             (StatefulWidget)                                  │
├────────────────────────────────────────────────────────────────┤
│ - _taskEditController: TextEditingController                   │
│ - _selectedDay: int                                            │
│ - _isPlaying: bool                                             │
├────────────────────────────────────────────────────────────────┤
│ + initState(): void                                            │
│ + dispose(): void                                              │
│ - _loadTaskText(): Future<void>                                │
│ - _saveTaskText(): Future<void>                                │
│ - _testNarration(): Future<void>                               │
│ - _testCobrancePhrase(): Future<void>                          │
│ - _resetToDefault(): Future<void>                              │
│ + build(context): Widget                                       │
└────────────────────────────────────────────────────────────────┘
```

---

## 7️⃣ RELAÇÕES ENTRE CLASSES

```
                        main()
                          │
                ┌─────────┴─────────┐
                │                   │
          WelcomeScreen       HomeScreen
                │                   │
                └──────┬────────────┘
                       │
         ┌─────────────┼──────────────────┐
         │             │                  │
    AlarmManager  NotificationManager  TTSManager
         │             │                  │
         ├─────────────┼──────────────────┤
         │
    SettingsScreen (navegação separada)
         │
         ├─ TTSManager (edição customizada)
         └─ DatabaseHelper (consulta logs)

         
HomeScreen ←→ DatabaseHelper (salva logs)
HomeScreen ←→ SharedPreferences (persiste estado)
HomeScreen ←→ TTSManager (narra tarefas)
HomeScreen ←→ NotificationManager (mostra notifs)
HomeScreen ←→ AlarmManager (confirma status)

AlarmManager → TTSManager (narração periódica)
AlarmManager → NotificationManager (notif. periódica)
AlarmManager → BackgroundService (mantém ativo)
```

---

## 8️⃣ PADRÕES DE DESIGN UTILIZADOS

### 1. **Singleton Pattern**
```dart
// DatabaseHelper
static final DatabaseHelper _instance = DatabaseHelper._internal();
factory DatabaseHelper() => _instance;
DatabaseHelper._internal();
```

### 2. **Factory Pattern**
```dart
// DatabaseHelper construtor factory
factory DatabaseHelper() => _instance;
```

### 3. **Static Methods Pattern**
```dart
// AlarmManager, NotificationManager, TTSManager
class AlarmManager {
  static Future<void> initialize() async { ... }
}
```

### 4. **State Management Pattern**
```dart
// HomeScreen usando StatefulWidget
class HomeScreen extends StatefulWidget { ... }
class _HomeScreenState extends State<HomeScreen> { ... }
```

### 5. **Provider/Dependency Injection**
```dart
// DatabaseHelper injetado no HomeScreen
final DatabaseHelper _dbHelper = DatabaseHelper();
```

---

## 9️⃣ SEQUÊNCIA DE INICIALIZAÇÃO

```
1. main()
   └─ WidgetsFlutterBinding.ensureInitialized()

2. initializeService()
   └─ FlutterBackgroundService.initialize()

3. NotificationManager.initialize()
   ├─ AndroidInitializationSettings
   ├─ InitializationSettings
   └─ _createNotificationChannels()

4. TTSManager.initialize()
   ├─ Idioma: pt-BR
   ├─ Velocidade: 0.8
   ├─ Volume: 1.0
   └─ Engine: Google TTS

5. AlarmManager.initialize()
   └─ AndroidAlarmManager.initialize()

6. AlarmManager.scheduleDailyTask()
   └─ Agenda para 05:30 diariamente

7. SharedPreferences.getBool('first_run')
   ├─ true → WelcomeScreen
   └─ false → HomeScreen
```

---

## 🔟 MELHORIAS FUTURAS

1. **Múltiplos desafios** - Além do desafio de 21 dias
2. **Analytics** - Rastrear progresso com gráficos
3. **Sincronização em nuvem** - Backup e sincronização
4. **Social** - Compartilhar progresso
5. **Meditação guiada** - Áudio meditativo antes da tarefa
6. **Badges/Gamificação** - Conquistar badges ao atingir milestones

---

**Última atualização:** Janeiro 2026
**Versão:** 2.0
**Status:** ✅ Funcionando e em produção
