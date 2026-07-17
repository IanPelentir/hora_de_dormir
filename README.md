# 🌙 Sleep Tracker

> Aplicativo Flutter de monitoramento de sono com conformidade LGPD, autenticação Firebase e arquitetura MVC limpa.

---

## 🎯 Problema Resolvido

As pessoas precisam de uma maneira simples e confiável de registrar seus padrões de sono. No entanto, a **privacidade é uma preocupação central**. Este aplicativo fornece uma interface intuitiva para iniciar e encerrar sessões de sono, cumprindo explicitamente a **Lei Geral de Proteção de Dados (LGPD)**, garantindo que os usuários saibam exatamente como seus dados são usados e armazenados.

---

## 👥 Público-Alvo

Indivíduos que desejam monitorar a duração e o histórico de seu sono em um ambiente seguro e transparente, sem que seus dados sejam compartilhados ou vendidos.

---

## 📸 Telas Principais

| Splash | Monitor de Sono | Histórico |
|--------|-----------------|-----------|
| Animação Rive de boas-vindas | Controle de sessão + gráfico semanal reativo | Lista de registros com feedback de qualidade |

---

## 🏗️ Arquitetura (MVC)

O projeto segue o padrão **Model-View-Controller (MVC)** com separação rígida de responsabilidades:

```
lib/
├── controllers/        # Lógica de negócio e integração com Firebase
│   └── sleep_controller.dart
├── models/             # Estruturas de dados (serialização toMap/fromMap)
│   └── sleep_model.dart
├── providers/          # Gerenciamento de estado (ChangeNotifier)
│   ├── auth_provider.dart
│   └── sleep_provider.dart
├── services/           # Integrações externas (Firestore, Auth)
│   └── firebase_service.dart
├── views/              # Componentes de UI (reagem ao Provider)
│   ├── auth_view.dart
│   ├── history_view.dart
│   ├── home_page.dart
│   ├── sleep_view.dart
│   ├── splash_view.dart
│   └── terms_view.dart
├── widgets/            # Componentes reutilizáveis
│   ├── custom_button.dart
│   ├── info_tile.dart
│   ├── sleep_card.dart
│   └── sleep_chart.dart     ← Gráfico interativo e reativo
├── firebase_options.dart
└── main.dart
```

### Responsabilidades por Camada

| Camada | Responsabilidade |
|--------|-----------------|
| **Model** | Define `SleepModel` com serialização `toMap`/`fromMap` e getters computados (`formattedDuration`, `durationInHours`) |
| **View** | Componentes Flutter puros. Ouvem mudanças via `context.watch<Provider>()` e re-renderizam automaticamente |
| **Controller** | Gerencia lógica de negócio: cálculo de durações, recomendações de sono por idade, classificação de qualidade |
| **Provider** | Ponte entre Controller e View. Herda `ChangeNotifier` e chama `notifyListeners()` para propagar estado |
| **Service** | Abstrai o acesso ao Firestore e Firebase Auth |

---

## 📊 Gráfico Interativo e Reativo

O widget `SleepChart` é **totalmente interativo e reativo**:

- **Reatividade automática**: Conectado ao `SleepProvider` via `context.watch()`. Qualquer nova sessão salva atualiza o gráfico instantaneamente sem reload manual.
- **Animação fluída**: Transição animada de 800ms com curva `easeInOut` ao mudar os dados.
- **Tooltip ao toque**: Ao tocar em uma barra, exibe o valor exato em horas (ex: `7.5 h`).
- **Linha de meta**: Linha tracejada verde mostrando o ideal de sono (8h padrão, configurável pelo slider).
- **Cores semânticas**: Barras em azul índigo para sono dentro da faixa ideal (7–9h) e roxo profundo para fora da faixa.
- **Eixos legíveis**: Eixo X com iniciais dos dias da semana; eixo Y com escala de 4 em 4 horas.

---

## ☁️ Backend (Firebase)

A aplicação se integra ao ecossistema Firebase para persistência segura:

| Serviço | Uso |
|---------|-----|
| **Firebase Auth** | Autenticação por e-mail/senha e modo anônimo |
| **Cloud Firestore** | Coleção `sleep_records` com documentos vinculados ao `userId` do proprietário |

### Estrutura do Documento Firestore

```json
{
  "userId": "uid_do_usuario",
  "sleepStart": "2026-07-13T22:00:00.000Z",
  "sleepEnd": "2026-07-14T06:30:00.000Z",
  "durationInSeconds": 30600,
  "createdAt": "2026-07-14T06:30:01.000Z"
}
```

---

## 🧠 Gerenciamento de Estado (Provider)

```dart
// main.dart — Injeção de dependências na raiz
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => SleepProvider()),
    ChangeNotifierProvider(create: (_) => SleepController()),
  ],
  child: const MyApp(),
)
```

As Views utilizam `context.watch<T>()` para ouvir mudanças dinamicamente:

```dart
// Exemplo em sleep_view.dart
final provider = context.watch<SleepProvider>();
// Qualquer chamada a notifyListeners() no provider re-renderiza este widget
```

---

## ⚖️ Conformidade com a LGPD

Antes de acessar o app, os usuários **devem aceitar** os Termos de Uso e a Política de Privacidade.

| Pilar | Implementação |
|-------|---------------|
| **Transparência** | Explicação clara dos dados coletados (e-mail e horários de sono) |
| **Finalidade** | Dados usados exclusivamente para exibição ao próprio usuário |
| **Proteção** | Garantia de não comercialização nem compartilhamento |
| **Persistência** | Consentimento salvo via `shared_preferences` para respeitar a escolha do usuário entre sessões |

---

## 🛠️ Tecnologias Usadas

| Tecnologia | Versão | Uso |
|------------|--------|-----|
| **Flutter & Dart** | SDK ^3.11.4 | Framework principal cross-platform |
| **Firebase Core** | ^4.7.0 | Inicialização do ecossistema Firebase |
| **Firebase Auth** | ^6.4.0 | Autenticação de usuários |
| **Cloud Firestore** | ^6.3.0 | Banco de dados NoSQL em tempo real |
| **Provider** | ^6.1.5 | Gerenciamento de estado (padrão MVC) |
| **fl_chart** | ^1.2.0 | Gráficos de barras interativos e animados |
| **Rive** | ^0.14.6 | Animações vetoriais na Splash Screen |
| **Google Fonts** | ^8.1.0 | Tipografia moderna |
| **shared_preferences** | ^2.5.5 | Persistência local do aceite LGPD |
| **flutter_localizations** | SDK | Suporte à localização pt-BR |

---

## 🚀 Como Executar o Projeto

### Pré-requisitos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) instalado e configurado (`flutter doctor` sem erros críticos)
- [Firebase CLI](https://firebase.google.com/docs/cli) instalado
- Conta no [Firebase Console](https://console.firebase.google.com/) com projeto configurado

### Passos

```bash
# 1. Clone o repositório
git clone <url-do-repositorio>
cd sleep_tracker

# 2. Instale as dependências
flutter pub get

# 3. Configure o Firebase (se necessário)
# Baixe o google-services.json (Android) e GoogleService-Info.plist (iOS)
# e coloque nas pastas android/app/ e ios/Runner/ respectivamente.
# O arquivo lib/firebase_options.dart já deve estar configurado.

# 4. Execute o app
flutter run

# 5. Para gerar o build de produção (Android)
flutter build apk --release

# 6. Para gerar o build de produção (iOS)
flutter build ios --release
```

### Emulador/Dispositivo Recomendado

- **Android**: API 33+ (Android 13)
- **iOS**: iOS 16+
- **Web**: Chrome para desenvolvimento

---

## 🔄 Fluxo da Aplicação

```
Splash Screen (Rive)
       ↓
Aceite de Termos (LGPD)   ← shared_preferences persiste o aceite
       ↓
Auth Screen (Login/Registro/Anônimo)
       ↓
Sleep View (Monitor de Sono)
  ├── Slider de Idade → Recalcula recomendação de sono
  ├── Slider de Meta → Atualiza linha de referência no gráfico
  ├── Gráfico Semanal Reativo (fl_chart) ← atualiza com cada nova sessão
  ├── Botão "Dormir" → Inicia timer em tempo real
  └── Botão "Acordar" → Salva sessão no Firestore + atualiza gráfico
       ↓
History View
  └── Lista de sessões com qualidade (Ótimo / Bom / Ruim)
```

---

## 🤖 Uso de IA (Antigravity)

O **Antigravity (Gemini/Claude)** atuou como assistente de _pair-programming_ durante o desenvolvimento, auxiliando em:

- **Design e UI/UX**: Criação do tema "Calm Bedtime Experience" com foco no uso noturno, Material 3 e Splash Screen com animação Rive.
- **Arquitetura MVC**: Estruturação limpa das camadas e injeção de dependências com `MultiProvider`.
- **Lógica de Negócio**: Cálculo correto de durações com virada de dia, serialização `toMap`/`fromMap` e recomendações de sono por faixa etária.
- **Integração Firebase**: Configuração do `flutterfire`, fluxos de auth, queries Firestore com filtro por `userId` (LGPD).
- **Gráfico Reativo**: Refatoração do `SleepChart` para ser interativo, animado e atualizar automaticamente com novas sessões.
- **Debugging**: Resolução de erros de compilação, estados de loading e redirecionamento entre telas.

---

## 📄 Licença

Projeto educacional — uso restrito à disciplina de desenvolvimento mobile.