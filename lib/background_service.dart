import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'tasks.dart';
import 'notification_manager.dart';
import 'tts_manager.dart';
import 'alarm_manager.dart';

/// Inicializa o serviço de background
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'stoic_foreground_service',
      initialNotificationTitle: 'Vigilância Estoica Ativa',
      initialNotificationContent: 'Monitorando sua disciplina...',
      foregroundServiceNotificationId: 888,
      autoStartOnBoot: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

/// Inicia o serviço de background
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

/// Callback principal do serviço de background
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // Inicializa os gerenciadores
  await NotificationManager.initialize();
  await TTSManager.initialize();
  await AlarmManager.initialize();

  // Mantém o dispositivo acordado
  await WakelockPlus.enable();

  final FlutterTts flutterTts = FlutterTts();

  // Timer para verificar o estado a cada 5 minutos
  Timer.periodic(const Duration(minutes: 5), (timer) async {
    final prefs = await SharedPreferences.getInstance();
    bool isTaskCompleted = prefs.getBool('task_completed') ?? false;
    int currentDay = prefs.getInt('current_day') ?? 1;

    if (service is AndroidServiceInstance) {
      if (isTaskCompleted) {
        service.setForegroundNotificationInfo(
          title: 'Vigilância Estoica',
          content: 'Dia $currentDay concluído. Retorno amanhã às 05:30.',
        );
      } else {
        service.setForegroundNotificationInfo(
          title: 'Vigilância Estoica - TAREFA PENDENTE',
          content: 'Dia $currentDay: Cumpra seu dever!',
        );
      }
    }
  });

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

/// Inicia o serviço de background manualmente
Future<void> startBackgroundService() async {
  final service = FlutterBackgroundService();
  
  try {
    bool isServiceRunning = await service.isRunning();
    
    if (!isServiceRunning) {
      await service.startService();
      print('✓ Serviço de background iniciado');
    } else {
      print('✓ Serviço de background já está em execução');
    }
  } catch (e) {
    print('Erro ao iniciar serviço de background: $e');
  }
}

/// Para o serviço de background
Future<void> stopBackgroundService() async {
  final service = FlutterBackgroundService();
  
  try {
    service.invoke('stopService');
    await WakelockPlus.disable();
    print('✓ Serviço de background parado');
  } catch (e) {
    print('Erro ao parar serviço de background: $e');
  }
}

/// Verifica se o serviço está em execução
Future<bool> isBackgroundServiceRunning() async {
  final service = FlutterBackgroundService();
  return await service.isRunning();
}
