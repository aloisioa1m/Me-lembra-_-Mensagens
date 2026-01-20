import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tasks.dart';

/// Gerenciador de notificações locais
class NotificationManager {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const int dailyTaskNotificationId = 1;
  static const int reminderNotificationId = 2;
  static const int repeatActivityNotificationId = 3;

  /// Inicializa o gerenciador de notificações
  static Future<void> initialize() async {
    try {
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: androidInitializationSettings,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('Notificação clicada: ${response.payload}');
        },
      );

      // Cria os canais de notificação para Android
      await _createNotificationChannels();

      print('✓ Gerenciador de notificações inicializado');
    } catch (e) {
      print('Erro ao inicializar notificações: $e');
    }
  }

  /// Cria os canais de notificação para Android 8+
  static Future<void> _createNotificationChannels() async {
    try {
      // Canal para tarefa diária
      const AndroidNotificationChannel dailyTaskChannel =
          AndroidNotificationChannel(
        'stoic_daily_task',
        'Tarefa Diária',
        description: 'Notificações da tarefa diária estoica',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('notification'),
        enableVibration: true,
        playSound: true,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(dailyTaskChannel);

      // Canal para lembretes
      const AndroidNotificationChannel reminderChannel =
          AndroidNotificationChannel(
        'stoic_reminder',
        'Lembretes de Cobrança',
        description: 'Lembretes para cumprir a tarefa',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('notification'),
        enableVibration: true,
        playSound: true,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(reminderChannel);

      // Canal para repetição de atividade
      const AndroidNotificationChannel repeatActivityChannel =
          AndroidNotificationChannel(
        'stoic_repeat_activity',
        'Repetição de Atividade',
        description: 'Repetição da atividade a cada 2 horas',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('notification'),
        enableVibration: true,
        playSound: true,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(repeatActivityChannel);

      print('✓ Canais de notificação criados');
    } catch (e) {
      print('Erro ao criar canais de notificação: $e');
    }
  }

  /// Exibe notificação de tarefa diária
  static Future<void> showDailyTaskNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int currentDay = prefs.getInt('current_day') ?? 1;

      if (currentDay > stoicTasks.length) {
        currentDay = 1;
      }

      String task = stoicTasks[currentDay - 1];

      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'stoic_daily_task',
        'Tarefa Diária',
        channelDescription: 'Notificações da tarefa diária estoica',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        fullScreenIntent: true,
      );

      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);

      await _flutterLocalNotificationsPlugin.show(
        dailyTaskNotificationId,
        'Dia $currentDay - Vigilância Estoica',
        task,
        notificationDetails,
        payload: 'daily_task_$currentDay',
      );

      print('🔔 Notificação de tarefa diária exibida (Dia $currentDay)');
    } catch (e) {
      print('Erro ao exibir notificação de tarefa diária: $e');
    }
  }

  /// Exibe notificação de lembrete/cobrança
  static Future<void> showReminderNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool isTaskCompleted = prefs.getBool('task_completed') ?? false;

      if (isTaskCompleted) {
        print('✓ Tarefa já foi cumprida. Sem lembrete necessário.');
        return;
      }

      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'stoic_reminder',
        'Lembretes de Cobrança',
        channelDescription: 'Lembretes para cumprir a tarefa',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);

      final reminderMessages = [
        'Você fez um compromisso. Cumpra agora!',
        'Disciplina é a chave. Não seja um tratante!',
        'Sua tarefa está pendente. Aja!',
        'Marcus Aurelius não deixaria para depois.',
        'Você é capaz. Levante-se e cumpra!',
      ];

      final random = DateTime.now().millisecond % reminderMessages.length;
      String message = reminderMessages[random];

      await _flutterLocalNotificationsPlugin.show(
        reminderNotificationId,
        'Lembrete de Cobrança',
        message,
        notificationDetails,
        payload: 'reminder',
      );

      print('🔔 Notificação de lembrete exibida: $message');
    } catch (e) {
      print('Erro ao exibir notificação de lembrete: $e');
    }
  }

  /// Exibe notificação de repetição de atividade
  static Future<void> showActivityRepeatNotification() async {
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

      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'stoic_repeat_activity',
        'Repetição de Atividade',
        channelDescription: 'Repetição da atividade a cada 2 horas',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);

      await _flutterLocalNotificationsPlugin.show(
        repeatActivityNotificationId,
        'Repetição - Dia $currentDay',
        'Sua tarefa continua: $task',
        notificationDetails,
        payload: 'repeat_activity_$currentDay',
      );

      print('🔔 Notificação de repetição de atividade exibida (Dia $currentDay)');
    } catch (e) {
      print('Erro ao exibir notificação de repetição: $e');
    }
  }

  /// Cancela todas as notificações
  static Future<void> cancelAll() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      print('✓ Todas as notificações foram canceladas');
    } catch (e) {
      print('Erro ao cancelar notificações: $e');
    }
  }
}

/// Funções globais para serem chamadas pelos alarmes
Future<void> triggerReminderNotification() async {
  await NotificationManager.initialize();
  await NotificationManager.showReminderNotification();
}

Future<void> triggerActivityRepeatNotification() async {
  await NotificationManager.initialize();
  await NotificationManager.showActivityRepeatNotification();
}
