# 🎨 DIAGRAMAS VISUAIS E FLUXOS

## 1️⃣ ARQUITETURA DE CAMADAS

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                     │
│  (O que o usuário vê)                                      │
│                                                             │
│  ┌────────────────────────────────────────────────────┐   │
│  │  WelcomeScreen │ HomeScreen │ SettingsScreen      │   │
│  │  (Contrato)    │ (Principal)│ (Edição)            │   │
│  └────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                      BUSINESS LAYER                         │
│  (Lógica da aplicação)                                    │
│                                                             │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐      │
│  │ AlarmManager │ │TTSManager    │ │NotificationM│      │
│  │ (Agendamento)│ │(Áudio)       │ │(Notif.)     │      │
│  └──────────────┘ └──────────────┘ └──────────────┘      │
│                                                             │
│  ┌────────────────────────────────────────────────────┐   │
│  │ BackgroundService (Execução contínua)             │   │
│  └────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                             │
│  (Armazenamento de dados)                                 │
│                                                             │
│  ┌──────────────────┐       ┌──────────────────┐         │
│  │ SharedPreferences│       │  SQLite Database │         │
│  │ (Memória)        │       │  (Persistente)   │         │
│  │                  │       │                  │         │
│  │ ├─ first_run     │       │ ├─ logs table    │         │
│  │ ├─ current_day   │       │ │  ├─ id         │         │
│  │ ├─ task_completed│       │ │  ├─ day        │         │
│  │ └─ selected_..   │       │ │  ├─ task       │         │
│  │                  │       │ │  ├─ report     │         │
│  │                  │       │ │  └─ timestamp  │         │
│  │                  │       │ └─ (50+ linhas) │         │
│  └──────────────────┘       └──────────────────┘         │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                  ANDROID OS / KERNEL                        │
│  (Sistema operacional)                                    │
│                                                             │
│  Alarm Service │ Notification Service │ Audio Service     │
└─────────────────────────────────────────────────────────────┘
```

---

## 2️⃣ SEQUÊNCIA TEMPORAL (DIA COMPLETO)

```
HORA          EVENTO                    SISTEMA RESPONSÁVEL
────────────────────────────────────────────────────────────────
00:00    │ App em modo idle          │ OS (standby)
         │                           │
05:29:59 │ Esperando alarme...       │ AlarmManager (agendado)
         │                           │
05:30:00 │ ┌─ ALARME DISPARA ────┐  │ AlarmManager
         │ │                     │  │
         │ ├─ Narração começa    ├─→ TTSManager.narrateDailyActivity()
         │ │                     │  │ 🔊 "Dia 1. Sua tarefa é..."
         │ │                     │  │
         │ ├─ Notificação        ├─→ NotificationManager
         │ │                     │  │ 🔔 Tarefa do dia
         │ │                     │  │
         │ ├─ Schedula lembretes ├─→ AlarmManager.scheduleReminders()
         │ │                     │  │ ⏱️  Próximos: 05:50, 06:10, 06:30...
         │ │                     │  │
         │ └─ Schedula repetição ├─→ AlarmManager.scheduleActivityRepeat()
         │                       │  │ ⏱️  Próximos: 07:30, 09:30, 11:30...
         │
05:50    │ ┌─ LEMBRETE 1 ─────────┐  │ AlarmManager
         │ │                     │  │
         │ ├─ Frase aleatória    ├─→ TTSManager.narrateCobrance()
         │ │                     │  │ 🔊 "Você fez um compromisso..."
         │ │                     │  │
         │ └─ Notificação lembrete├─→ NotificationManager
         │                       │  │ 🔔 Frase motivacional
         │
06:10    │ LEMBRETE 2            │ (repetido como 05:50)
06:30    │ LEMBRETE 3            │
06:50    │ LEMBRETE 4            │
         │
07:30    │ ┌─ REPETIÇÃO 1 ─────┐  │ AlarmManager
         │ │                   │  │
         │ ├─ Narra repetição  ├─→ TTSManager.narrateActivityRepeat()
         │ │                   │  │ 🔊 "Lembrete: Dia 1..."
         │ │                   │  │
         │ └─ Notificação      ├─→ NotificationManager
         │                     │  │ 🔔 Repetição
         │
[09:30]  │ REPETIÇÃO 2 (similar)
[11:30]  │ REPETIÇÃO 3 (similar)
         │
[14:00]  │ ┌─ USUÁRIO CUMPRE TAREFA ─┐
         │ │                        │
         │ ├─ Digita relatório (300+)├─→ HomeScreen._completeTask()
         │ │                        │
         │ ├─ Valida entrada       │
         │ │                        │
         │ ├─ Salva no banco       ├─→ DatabaseHelper.insertLog()
         │ │                        │  📍 INSERT INTO logs...
         │ │                        │
         │ ├─ Atualiza preferências├─→ SharedPreferences
         │ │ task_completed=true   │  ✓ task_completed = true
         │ │                        │
         │ ├─ Cancela alarmes      ├─→ AlarmManager.cancelAllAlarms()
         │ │                        │  ✗ Sem mais lembretes
         │ │                        │
         │ └─ UI atualiza          ├─→ setState()
         │                         │  ✓ Mostra checkmark verde
         │
23:59    │ App aguarda próximo dia │
         │
PRÓXIMO DIA 05:30
         │ Tudo recomeça...        │ (ciclo completo novamente)
```

---

## 3️⃣ ÁRVORE DE CHAMADAS (Call Stack)

```
┌─ main()
│  └─ WidgetsFlutterBinding.ensureInitialized()
│  └─ initializeService()  [BackgroundService]
│  └─ NotificationManager.initialize()
│  └─ TTSManager.initialize()
│  └─ AlarmManager.initialize()
│  └─ AlarmManager.scheduleDailyTask()
│  └─ runApp(StoicApp)
│     └─ StoicApp.build()
│        └─ MaterialApp
│           └─ home: HomeScreen (ou WelcomeScreen)
│
├─ WelcomeScreen._acceptChallenge()
│  ├─ SharedPreferences.setBool('first_run', false)
│  ├─ SharedPreferences.setInt('current_day', 1)
│  ├─ AlarmManager.scheduleDailyTask()
│  └─ Navigator.pushReplacement() → HomeScreen
│
├─ HomeScreen._loadProgress()
│  ├─ SharedPreferences.getInt('current_day')
│  ├─ SharedPreferences.getBool('task_completed')
│  ├─ SharedPreferences.getInt('selected_phrase_index')
│  └─ setState() [re-render]
│
├─ HomeScreen._completeTask()
│  ├─ Validação (_reportController.text.length >= 300)
│  ├─ DatabaseHelper.insertLog({day, task, report, timestamp})
│  │  └─ db.insert('logs', row)
│  ├─ SharedPreferences.setBool('task_completed', true)
│  ├─ AlarmManager.cancelAllAlarms()
│  │  ├─ cancel(1001)
│  │  ├─ cancel(1002)
│  │  └─ cancel(1003)
│  ├─ ScaffoldMessenger.showSnackBar()
│  └─ setState() [re-render com ✓]
│
├─ HomeScreen._selectPhrase(index)
│  ├─ SharedPreferences.setInt('selected_phrase_index', index)
│  └─ setState() [atualiza UI]
│
├─ HomeScreen._startChallenge()
│  ├─ TTSManager.speak(cobrancePhrases[index])
│  └─ ScaffoldMessenger.showSnackBar()
│
├─ HomeScreen._viewAllPhrases()
│  └─ showModalBottomSheet()
│     └─ ListView.builder()
│        └─ GestureDetector.onTap() → _selectPhrase()
│
├─ AlarmManager._dailyTaskCallback()
│  ├─ SharedPreferences.setBool('task_completed', false)
│  ├─ startBackgroundService()
│  ├─ scheduleReminders()
│  └─ scheduleActivityRepeat()
│
├─ AlarmManager._reminderCallback()
│  └─ [executado a cada 20 min]
│
├─ TTSManager.narrateDailyActivity()
│  ├─ initialize()
│  ├─ SharedPreferences.getInt('current_day')
│  ├─ _flutterTts.speak(message)
│  └─ print('[IMPORTANTE]')
│
├─ NotificationManager.showDailyTaskNotification()
│  ├─ AndroidNotificationDetails(...)
│  └─ _flutterLocalNotificationsPlugin.show()
│
├─ DatabaseHelper.insertLog()
│  ├─ get database
│  │  └─ _database ?? _initDatabase()
│  │     ├─ getDatabasesPath()
│  │     ├─ openDatabase()
│  │     └─ _onCreate()
│  └─ db.insert('logs', row)
│
└─ SettingsScreen._saveTaskText()
   ├─ TTSManager.editActivityText(day, text)
   │  └─ SharedPreferences.setString('activity_text_day_X', text)
   └─ ScaffoldMessenger.showSnackBar()
```

---

## 4️⃣ MÁQUINA DE ESTADOS

```
┌─────────────────────────────────────────────────────────────┐
│ ESTADO: AppInitialization                               │
├─────────────────────────────────────────────────────────────┤
│ Ações:                                                   │
│  ├─ initializeService()                                │
│  ├─ NotificationManager.initialize()                   │
│  ├─ TTSManager.initialize()                            │
│  ├─ AlarmManager.initialize()                          │
│  └─ AlarmManager.scheduleDailyTask()                   │
│                                                          │
│ Próximo Estado:                                         │
│  ├─ Se first_run == true → FirstRun                   │
│  └─ Se first_run == false → DailyActive                │
└─────────────────────────────────────────────────────────────┘
           │
      ┌────▼────────┬──────────────┐
      │             │              │
┌─────▼─────────────┐  ┌──────────▼──────────────┐
│ ESTADO: FirstRun  │  │ ESTADO: DailyActive    │
├───────────────────┤  ├────────────────────────┤
│ Exibe:            │  │ Propriedades:         │
│ ├─ WelcomeScreen │  │ ├─ currentDay (1-21)   │
│ ├─ Contrato      │  │ ├─ isTaskCompleted     │
│ └─ Botão Aceitar │  │ └─ selectedPhraseIndex │
│                  │  │                        │
│ Ações:           │  │ Sub-estados:          │
│ └─ Clica Aceitar │  │ ├─ Waiting (05:30)    │
│                  │  │ ├─ Alarming (05:30)   │
│ Próximo Estado:  │  │ ├─ Reminding (20 min) │
│ └─ DailyActive   │  │ ├─ Repeating (2 h)    │
└───────────────────┘  │ └─ Completed (logado) │
                       │                        │
                       │ Transições:          │
                       │ ├─ task_completed=F   │
                       │ ├─ → Completed       │
                       │ ├─ task_completed=T   │
                       │ ├─ → Waiting (next)  │
                       │ └─ day > 21           │
                       │    → day = 1          │
                       └────────────────────────┘
```

---

## 5️⃣ FLUXO DE NOTIFICAÇÕES

```
┌──────────────────────────────────────────────────────┐
│ NotificationManager: 3 Canais de Notificação        │
└──────────────────────────────────────────────────────┘

┌─────────────────────────┐  ┌─────────────────────────┐
│ stoic_daily_task        │  │ stoic_reminder          │
│                         │  │                         │
│ ID: 1                   │  │ ID: 2                   │
│ Importância: MAX        │  │ Importância: HIGH       │
│ Som: SIM                │  │ Som: SIM                │
│ Vibração: SIM           │  │ Vibração: SIM           │
│                         │  │                         │
│ Triggers:              │  │ Triggers:              │
│ ├─ 05:30 (Diariamente) │  │ ├─ 05:50               │
│ │ "Dia X. Sua          │  │ ├─ 06:10               │
│ │  tarefa é: ..."      │  │ ├─ 06:30               │
│ │                     │  │ ├─ ... (20 em 20)       │
│ └─ Clique abre app    │  │ │ "Você fez um          │
│                         │  │  compromisso..."       │
│                         │  │                         │
│                         │  └─ Clique abre app      │
└─────────────────────────┘  └─────────────────────────┘

┌─────────────────────────┐
│ stoic_repeat_activity   │
│                         │
│ ID: 3                   │
│ Importância: HIGH       │
│ Som: SIM                │
│ Vibração: SIM           │
│                         │
│ Triggers:              │
│ ├─ 07:30               │
│ ├─ 09:30               │
│ ├─ 11:30               │
│ ├─ ... (2 em 2 horas)   │
│ │ "Lembrete: Dia X...  │
│ │  Sua tarefa..."      │
│ │                     │
│ └─ Clique abre app    │
└─────────────────────────┘
```

---

## 6️⃣ ESTRUTURA DO BANCO DE DADOS

```
stoic_vigilance.db (SQLite)
│
└─ logs (tabela)
   │
   ├─ Column: id
   │  ├─ Type: INTEGER
   │  ├─ Constraints: PRIMARY KEY AUTOINCREMENT
   │  └─ Exemplo: 1, 2, 3, ...
   │
   ├─ Column: day
   │  ├─ Type: INTEGER
   │  ├─ Range: 1-21
   │  ├─ Example: 1, 2, 3, ...
   │  └─ Usado para: Identificar dia do desafio
   │
   ├─ Column: task
   │  ├─ Type: TEXT
   │  ├─ Length: 200-300 chars
   │  ├─ Example: "Banho frio ao acordar. Entre sem hesitar..."
   │  └─ Usado para: Registrar tarefa realizada
   │
   ├─ Column: report
   │  ├─ Type: TEXT (LONG)
   │  ├─ Min Length: 300 caracteres
   │  ├─ Example: "Fiz o banho frio às 5:30 da manhã, o desconforto..."
   │  └─ Usado para: Reflexão do usuário
   │
   └─ Column: timestamp
      ├─ Type: TEXT (ISO 8601)
      ├─ Format: "YYYY-MM-DD HH:MM:SS"
      ├─ Example: "2026-01-21 14:35:22"
      └─ Usado para: Quando foi registrado

Exemplo de Registro:
┌───┬─────┬──────────────────────────┬────────────────────┬──────────────────┐
│ id│ day │ task                     │ report             │ timestamp        │
├───┼─────┼──────────────────────────┼────────────────────┼──────────────────┤
│ 1 │  1  │ Banho frio ao acordar... │ Acordei às 5:30... │ 2026-01-21 06:15 │
│ 2 │  2  │ Coma apenas necessário.. │ Comi salada pela.. │ 2026-01-22 12:40 │
│ 3 │  3  │ 30 min de exercício...   │ Fiz 40 minutos... │ 2026-01-23 19:00 │
└───┴─────┴──────────────────────────┴────────────────────┴──────────────────┘
```

---

## 7️⃣ FLUXO DE TTS (Text-to-Speech)

```
                    ┌─ TTSManager ─┐
                    │              │

1. INICIALIZAÇÃO
   └─ initialize()
      ├─ setLanguage("pt-BR")
      ├─ setSpeechRate(0.8)  [velocidade: 80%]
      ├─ setPitch(1.0)       [tom: normal]
      ├─ setVolume(1.0)      [volume: máximo]
      └─ setEngine("com.google.android.tts")

2. NARRAÇÃO DE TAREFA (05:30)
   └─ narrateDailyActivity()
      ├─ Obtém: current_day
      ├─ Obtém: stoicTasks[day-1]
      ├─ Formata: "Dia X. Sua tarefa é: [task]. Cumpra..."
      └─ speak(text)
         └─ Sistema Android executa áudio

3. NARRAÇÃO DE COBRANÇA (20 em 20 min)
   └─ narrateCobrance()
      ├─ Verifica: task_completed == false
      ├─ Obtém: frase aleatória de cobrancePhrases
      ├─ speak(frase)
      └─ Áudio em português

4. NARRAÇÃO DE REPETIÇÃO (2 em 2 h)
   └─ narrateActivityRepeat()
      ├─ Obtém: current_day
      ├─ Obtém: stoicTasks[day-1]
      ├─ Formata: "Lembrete: Dia X. Sua tarefa: [task]..."
      └─ speak(text)

5. TESTE MANUAL
   └─ testNarration(text)
      └─ speak(text)
         └─ Usado em SettingsScreen para testar edições

Configurações de Voz:
┌────────────────────────────────────┐
│ Idioma: pt-BR (Português Brasil)  │
│ Velocidade: 0.8 (80%)             │
│ Tom (Pitch): 1.0 (Normal)         │
│ Volume: 1.0 (Máximo)              │
│ Motor: Google TTS (offline)       │
│                                   │
│ Resultado: Voz feminina natural,  │
│ clara, em ritmo moderado         │
└────────────────────────────────────┘
```

---

## 8️⃣ GESTÃO DE PERMISSÕES

```
AndroidManifest.xml Permissões Necessárias:

┌──────────────────────────────────────────────────────┐
│ <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
│ └─ Para AlarmManager.periodic(..., exact: true)
│
│ <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
│ └─ Para NotificationManager.show()
│
│ <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
│ └─ Para banco de dados SQLite
│
│ <uses-permission android:name="android.permission.WAKE_LOCK" />
│ └─ Para WakelockPlus (manter CPU ativa)
│
│ <uses-permission android:name="android.permission.INTERNET" />
│ └─ Para TTS (download de vozes se necessário)
│
│ <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
│ └─ Para BackgroundService com localização
│
│ <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
│ └─ Para localização (futura expansão)
└──────────────────────────────────────────────────────┘

Permissões em Runtime (Android 6+):
permission_handler plugin cuidará automaticamente
```

---

## 9️⃣ CICLO DE VIDA DO WIDGET

```
HomeScreen Lifecycle (StatefulWidget)

┌─────────────────────────────────────────┐
│ 1. createState()                       │
│    └─ Cria _HomeScreenState            │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│ 2. initState()                         │
│    ├─ Inicializa controllers           │
│    ├─ Carrega dados (SharedPreferences)│
│    └─ setState() → rebuild             │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│ 3. build()                             │
│    ├─ Constrói UI                      │
│    ├─ Scaffold                         │
│    ├─ AppBar                           │
│    ├─ Body com Column/Row              │
│    └─ FloatingActionButton             │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│ 4. setState() (múltiplas vezes)        │
│    ├─ Triggered por: user actions      │
│    ├─ _selectPhrase()                  │
│    ├─ _completeTask()                  │
│    └─ Volta para build()               │
└─────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────┐
│ 5. dispose()                           │
│    ├─ Limpa controllers                │
│    ├─ _reportController.dispose()      │
│    └─ Widget removido da árvore        │
└─────────────────────────────────────────┘
```

---

🎯 **Fin!**

Estes diagramas complementam **ARQUITETURA.md** e **DESENVOLVIMENTO.md**
para dar uma visão 360º do projeto.

**Última atualização:** Janeiro 2026
