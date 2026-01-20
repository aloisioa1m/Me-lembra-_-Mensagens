import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'background_service.dart';

/// Gerenciador de alarmes para agendamento de tarefas
class AlarmManager {
  static const int dailyTaskAlarmId = 1001;
  static const int reminderAlarmId = 1002;
  static const int repeatActivityAlarmId = 1003;

  /// Inicializa o Android Alarm Manager
  static Future<void> initialize() async {
    try {
      await AndroidAlarmManager.initialize();
    } catch (e) {
      print('Erro ao inicializar AndroidAlarmManager: $e');
    }
  }

  /// Agenda a tarefa diária para 05:30
  static Future<void> scheduleDailyTask() async {
    try {
      // Agenda para 05:30 todos os dias
      await AndroidAlarmManager.periodic(
        const Duration(hours: 24),
        dailyTaskAlarmId,
        _dailyTaskCallback,
        startAt: _getNextOccurrence(5, 30),
        exact: true,
        wakeup: true,
      );
      print('✓ Alarme diário agendado para 05:30');
    } catch (e) {
      print('Erro ao agendar tarefa diária: $e');
    }
  }

  /// Agenda lembretes a cada 20 minutos (se tarefa não foi cumprida)
  static Future<void> scheduleReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool isTaskCompleted = prefs.getBool('task_completed') ?? false;

      if (!isTaskCompleted) {
        // Agenda para executar a cada 20 minutos
        await AndroidAlarmManager.periodic(
          const Duration(minutes: 20),
          reminderAlarmId,
          _reminderCallback,
          exact: true,
          wakeup: true,
        );
        print('✓ Lembretes agendados a cada 20 minutos');
      }
    } catch (e) {
      print('Erro ao agendar lembretes: $e');
    }
  }

  /// Agenda repetição da atividade a cada 2 horas
  static Future<void> scheduleActivityRepeat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool isTaskCompleted = prefs.getBool('task_completed') ?? false;

      if (!isTaskCompleted) {
        // Agenda para executar a cada 2 horas
        await AndroidAlarmManager.periodic(
          const Duration(hours: 2),
          repeatActivityAlarmId,
          _repeatActivityCallback,
          exact: true,
          wakeup: true,
        );
        print('✓ Repetição de atividade agendada a cada 2 horas');
      }
    } catch (e) {
      print('Erro ao agendar repetição de atividade: $e');
    }
  }

  /// Cancela todos os alarmes
  static Future<void> cancelAllAlarms() async {
    try {
      await AndroidAlarmManager.cancel(dailyTaskAlarmId);
      await AndroidAlarmManager.cancel(reminderAlarmId);
      await AndroidAlarmManager.cancel(repeatActivityAlarmId);
      print('✓ Todos os alarmes foram cancelados');
    } catch (e) {
      print('Erro ao cancelar alarmes: $e');
    }
  }

  /// Callback para tarefa diária (05:30)
  @pragma('vm:entry-point')
  static Future<void> _dailyTaskCallback() async {
    print('🔔 Callback: Tarefa diária às 05:30');
    final prefs = await SharedPreferences.getInstance();
    
    // Reseta o status de conclusão para o novo dia
    await prefs.setBool('task_completed', false);
    
    // Inicia o serviço de background
    await startBackgroundService();
    
    // Agenda os lembretes
    await scheduleReminders();
    await scheduleActivityRepeat();
  }

  /// Callback para lembretes a cada 20 minutos
  @pragma('vm:entry-point')
  static Future<void> _reminderCallback() async {
    print('🔔 Callback: Lembrete a cada 20 minutos');
  }

  /// Callback para repetição de atividade a cada 2 horas
  @pragma('vm:entry-point')
  static Future<void> _repeatActivityCallback() async {
    print('🔔 Callback: Repetição de atividade a cada 2 horas');
  }
  

  /// Calcula a próxima ocorrência de um horário específico
  static DateTime _getNextOccurrence(int hour, int minute) {
    final now = DateTime.now();
    var nextOccurrence = DateTime(now.year, now.month, now.day, hour, minute);

    if (nextOccurrence.isBefore(now)) {
      nextOccurrence = nextOccurrence.add(const Duration(days: 1));
    }

    return nextOccurrence;
  }
}
