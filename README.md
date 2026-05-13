# Sleep Tracker - Empresa Fictícia

Uma aplicação Flutter pronta para produção, projetada para monitorar sessões de sono com foco rigoroso na conformidade com a **LGPD**, autenticação segura e uma arquitetura limpa **Model-View-Controller (MVC)**.

## 🎯 Problema Resolvido
As pessoas precisam de uma maneira simples e confiável de registrar seus padrões de sono. No entanto, a privacidade é uma preocupação central. Este aplicativo fornece uma interface intuitiva para iniciar e terminar sessões de sono, cumprindo explicitamente a **Lei Geral de Proteção de Dados (LGPD)**, garantindo que os usuários saibam exatamente como seus dados são usados e armazenados.

## 👥 Público-Alvo
Indivíduos que desejam monitorar a duração e o histórico de seu sono em um ambiente seguro, sem que seus dados sejam compartilhados ou vendidos.

## 🏗️ Arquitetura (MVC)
[cite_start]O projeto foi construído utilizando o padrão arquitetural **Model-View-Controller (MVC)**, conforme os requisitos da disciplina, separando rigidamente a lógica, o estado e a interface do usuário (UI)[cite: 75, 77, 83].

- [cite_start]**Models (`lib/models/`)**: Define as estruturas de dados (ex: `SleepModel` com serialização `toMap` e `fromMap`)[cite: 84].
- **Views (`lib/views/`)**: Componentes de interface puros construídos com Flutter. [cite_start]Eles reagem às mudanças de estado usando o `Provider`[cite: 84].
- [cite_start]**Controllers (`lib/controllers/`)**: Gerenciam a lógica de negócio, como o cálculo de durações de sono baseadas na idade[cite: 84, 126].
- [cite_start]**Providers (`lib/providers/`)**: Gerenciam o estado da aplicação, servindo de ponte entre Controllers e Views[cite: 33, 112].
- [cite_start]**Services (`lib/services/`)**: Gerenciam integrações externas e a persistência de dados[cite: 84, 127].

## ☁️ Backend (Firebase)
[cite_start]A aplicação realiza operações reais de comunicação com dados persistentes através do ecossistema Firebase[cite: 89, 99]:
- [cite_start]**Autenticação**: O Firebase Auth gerencia o acesso do usuário de forma segura[cite: 103].
- [cite_start]**Banco de Dados**: O Cloud Firestore é utilizado para persistir os registros de sono (`sleep_records`), vinculando cada documento ao `userId` do proprietário[cite: 106].

## 🧠 Gerenciamento de Estados (Provider)
[cite_start]Utilizamos o pacote **Provider**, conforme trabalhado em sala de aula[cite: 112]. [cite_start]O `MultiProvider` na raiz do app injeta as dependências necessárias, e as Views utilizam `context.watch()` para ouvir mudanças de estado dinamicamente[cite: 165].

## ⚖️ Conformidade com a LGPD
Antes de acessar o app, os usuários devem ler e concordar com os Termos de Uso e a Política de Privacidade.
- **Transparência**: Explicação clara de quais dados (e-mail e horários de sono) são coletados.
- **Proteção**: Garantia de não comercialização de dados.
- **Persistência**: O consentimento é salvo localmente para respeitar a escolha do usuário.

## 🤖 Uso de IA (Antigravity)
[cite_start]Conforme as diretrizes da atividade, o **Antigravity com IA** foi utilizado como ferramenta de apoio técnico para[cite: 18, 120, 139]:
- [cite_start]Estruturação inicial da arquitetura de pastas e separação de responsabilidades[cite: 122].
- [cite_start]Refatoração da lógica de cálculo de horas para tratar casos de "virada de dia"[cite: 131].
- [cite_start]Criação dos métodos de serialização nos modelos de dados[cite: 125].
- [cite_start]Auxílio na configuração e integração dos serviços do Cloud Firestore[cite: 129].

### 🚀 Como Executar o Projeto
1. Clone o repositório.
2. Certifique-se de ter o Flutter instalado e configurado.
3. Instale as dependências:
   ```bash
   flutter pub get