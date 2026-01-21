# Vigilância Estoica - Aplicativo Flutter

Aplicativo mobile para gerenciamento de tarefas e monitoramento com notificações e sistema de cobrança.

## 📚 Documentação Completa

### 🎯 Comece Aqui
- **[INDICE.md](INDICE.md)** - 📖 Guia geral e matriz de responsabilidades

### 🔍 Entenda a Arquitetura
- **[ARQUITETURA.md](ARQUITETURA.md)** - 📐 UML completo, classes, métodos, atributos e fluxos
- **[DIAGRAMAS.md](DIAGRAMAS.md)** - 🎨 Diagramas visuais, máquinas de estado e sequências
- **[DESENVOLVIMENTO.md](DESENVOLVIMENTO.md)** - 💻 Guia prático com exemplos de código

### 🚀 Execução Rápida
- **[INSTRUCOES.md](INSTRUCOES.md)** - ⚡ Comandos git, setup e deployment
- **[README.md](README.md)** - 📖 Este arquivo

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado:
- Git
- Flutter SDK
- Android Studio ou VS Code com extensão Flutter
- Celular Android com USB Debug ativado

## 🚀 Começando

### 1. Clonar o Repositório

```bash
git clone <URL_DO_REPOSITORIO>
cd vigilancia_estoica_atualizado
```

### 2. Abrir no VS Code

```bash
code .
```

### 3. Instalar Dependências

```bash
flutter pub get
```

## 📱 Rodar no Celular (via USB)

### Verificar Conexão do Dispositivo

```bash
flutter devices
```

### Instalar e Rodar a Aplicação

```bash
# Limpar build anterior (recomendado na primeira vez)
flutter clean

# Instalar e executar no celular
flutter run
```

### Hot Reload Durante Desenvolvimento

- Pressione `r` no terminal para hot reload (recarrega o código sem perder estado)
- Pressione `R` para hot restart (reinicia a aplicação)
- Pressione `q` para sair

## 🎯 Recursos Principais

### 📍 Tela Home - Painel de Frases de Cobrança

Na tela inicial, você encontrará um **painel interativo** com:

- **Visualização da frase selecionada** - Exibe a frase motivadora atual
- **Botões de navegação** - Anterior/Próxima para percorrer as frases
- **Iniciar Desafio** - Começa o desafio com a frase escolhida
- **Ver Todas (X frases)** - Modal com lista completa de todas as frases para seleção rápida

### 🏠 Navegação Fácil

- **Botão HOME (flutuante)** - Aparece na tela inicial para confirmar que você está vendo o painel
- **Botão Voltar Home** - Na tela de Configurações, clique no ícone de casa para retornar
- **AppBar com ícone de Home** - Em qualquer tela secundária, use o ícone de casa para voltar

## 🔄 Workflow Git Completo

### 1. Verificar Status

```bash
git status
```

### 2. Adicionar Alterações

```bash
# Adicionar todos os arquivos modificados
git add .

# Ou adicionar arquivos específicos
git add lib/main.dart
```

### 3. Fazer Commit

```bash
git commit -m "Descrição clara das alterações"
```

### 4. Fazer Push

```bash
# Para a branch principal
git push origin main

# Ou se usar master
git push origin master
```

### 5. Atualizar o Celular com Novas Alterações

```bash
flutter run
```

## 📦 Comandos Úteis

### Verificar Dependências e Configuração

```bash
flutter doctor
```

### Ver Logs da Aplicação

```bash
flutter logs
```

### Build para Release (Android)

```bash
# Gerar APK
flutter build apk --release

# Gerar App Bundle (para Google Play)
flutter build appbundle --release
```

### Desfazer Alterações Não Commitadas

```bash
git checkout -- .
```

### Ver Histórico de Commits

```bash
git log --oneline
```

### Sincronizar com Repositório Remoto

```bash
git pull origin main
```

## 📂 Estrutura do Projeto

```
lib/
├── main.dart                    # Arquivo principal
├── welcome_screen.dart          # Tela de boas-vindas
├── settings_screen.dart         # Tela de configurações
├── tasks.dart                   # Gerenciador de tarefas
├── database_helper.dart         # Gerenciador de banco de dados
├── notification_manager.dart    # Gerenciador de notificações
├── alarm_manager.dart           # Gerenciador de alarmes
├── background_service.dart      # Serviço em background
├── tts_manager.dart             # Gerenciador de síntese de fala
└── cobrance_phrases.dart        # Frases de cobrança
```

## 🔧 Configuração do Celular

### Ativar USB Debug (Android)

1. Vá para **Configurações → Sobre o telefone**
2. Toque 7 vezes em **Número de compilação**
3. Volte para **Configurações → Opções de desenvolvedor**
4. Ative **Depuração por USB**

## ⚠️ Solução de Problemas

### ❌ Celular não aparece em `flutter devices`

#### Passo 1: Verificar USB Debug do Celular

1. Vá para **Configurações → Sobre o telefone**
2. Toque **7 vezes** em **Número de compilação** para ativar modo desenvolvedor
3. Volte para **Configurações → Opções de desenvolvedor**
4. Ative **Depuração por USB** (USB Debug)
5. Quando conectar via USB, selecione **Permitir acesso de depuração** no celular

#### Passo 2: Reinstalar Drivers USB (Windows)

Se ainda não aparecer, execute:

```bash
# Desconectar celular do USB primeiro!

# Limpar Flutter
flutter clean

# Reinstalar ferramentas Flutter
flutter doctor

# Reconectar o celular e testar
flutter devices
```

#### Passo 3: Resetar Android SDK Tools (Última opção)

Se ainda não funcionar, abra **Android Studio** → **SDK Manager** → Marque a última versão do **Android SDK Platform-Tools** → Clique **Apply** → **OK**

#### Passo 4: Se ADB não for reconhecido

```bash
# Adicionar ADB ao PATH manualmente
# Se você está no Windows e vê erro "adb não reconhecido":

# 1. Encontre o caminho do ADB:
# Normalmente em: C:\Users\SeuUsuario\AppData\Local\Android\sdk\platform-tools

# 2. Teste diretamente com caminho completo:
C:\Users\SeuUsuario\AppData\Local\Android\sdk\platform-tools\adb devices
```

### ❌ Erro "Permission denied" ao fazer push

```bash
# Verificar status do Git
git status

# Resolver conflitos (se houver)
git pull origin main
git add .
git commit -m "Resolve conflitos"
git push origin main
```

### ❌ Dependências desatualizadas

```bash
flutter pub upgrade
```

### ❌ Outras Verificações

```bash
# Ver status completo do Flutter
flutter doctor -v

# Listar emuladores disponíveis
flutter emulators

# Testar build básico
flutter build apk

# Ver logs em tempo real
flutter logs
```

## 📝 Dicas de Desenvolvimento

1. **Sempre faça commit frequentemente** com mensagens descritivas
2. **Teste no celular antes de fazer push** para garantir funcionamento
3. **Use `flutter pub get`** após fazer alterações em `pubspec.yaml`
4. **Mantenha o celular conectado via USB** durante o desenvolvimento

## 📞 Contribuindo

Para contribuir ao projeto:

1. Crie uma branch para sua feature: `git checkout -b feature/nova-funcionalidade`
2. Faça commits descritivos: `git commit -m "Add: nova funcionalidade"`
3. Faça push da branch: `git push origin feature/nova-funcionalidade`
4. Abra um Pull Request

## 📄 Licença

Este projeto está sob licença [Especificar Licença]

---

**Última atualização:** Janeiro 2026
