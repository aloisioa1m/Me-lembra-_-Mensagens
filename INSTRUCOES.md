# Guia de Instalação - Vigilância Estoica

Este projeto foi construído em **Flutter**. Para rodá-lo no seu celular via USB usando o VS Code, siga os passos abaixo:

## 1. Pré-requisitos no Computador
- **Flutter SDK** instalado ([Guia de Instalação](https://docs.flutter.dev/get-started/install)).
- **VS Code** com as extensões "Flutter" e "Dart" instaladas.
- **Android Studio** (necessário para as ferramentas de build do Android).

## 2. Preparação do Celular
1. Vá em **Configurações > Sobre o telefone**.
2. Toque 7 vezes em **Número da Versão** para ativar o "Modo Desenvolvedor".
3. Vá em **Sistema > Opções do Desenvolvedor** e ative a **Depuração USB**.
4. Conecte o celular ao PC via cabo USB.

## 3. Abrindo o Projeto no VS Code
1. Abra o VS Code.
2. Vá em `File > Open Folder` e selecione a pasta `vigilancia_estoica`.
3. No terminal do VS Code, execute:
   ```bash
   flutter pub get
   ```

## 4. Rodando no Celular
1. No canto inferior direito do VS Code, certifique-se de que seu celular real está selecionado como dispositivo.
2. Pressione `F5` para iniciar o build e instalação.
3. O app abrirá automaticamente no seu celular.

## 5. Gerando o APK (Opcional)
Se quiser gerar o arquivo para instalar manualmente:
```bash
flutter build apk --release
```
O arquivo estará em: `build/app/outputs/flutter-apk/app-release.apk`.

---

### Notas sobre o Funcionamento:
- **Serviço de Background:** O app usa um serviço de primeiro plano (Foreground Service) para garantir que o áudio toque a cada 30 minutos se a tarefa não for concluída.
- **Permissões:** Ao abrir o app pela primeira vez, ele solicitará permissão para notificações e para rodar em segundo plano. **Aceite todas** para o funcionamento correto.
- **Áudio:** O app usa o sistema de Text-to-Speech (TTS) do Android. Certifique-se de que o volume de mídia está alto.
