# Fala Comigo — Documento de transferência do projeto

## Como usar este arquivo

Este documento existe para permitir que outra pessoa, agente ou IA entenda o projeto sem depender do histórico desta conversa. Leia primeiro este arquivo, depois `AGENTS.md`, `README.md`, `docs/PLANO_SEQUENCIAL_ATE_BUILD.md` e `docs/CHECKLIST_PRE_LANCAMENTO.md`.

O código oficial está no GitHub:

- Repositório: https://github.com/falacomigocaa-app/fala-comigo
- Branch principal: `main`
- Branch de trabalho atual: `feat/affordable-plans-model`
- Último commit registrado neste handoff: `8b0d7d7 — docs: add numbered plan to first build`

Não existem segredos, tokens, senhas ou chaves privadas neste documento. Nunca coloque credenciais no Git.

## Identidade do produto

**Fala Comigo** é um aplicativo de Comunicação Aumentativa e Alternativa (CAA) para crianças e adolescentes autistas, suas famílias e redes de apoio. O produto deve apoiar comunicação, previsibilidade, autonomia e cuidado conectado sem transformar a criança em um conjunto de métricas.

A regra de produto mais importante é:

> A comunicação básica deve funcionar localmente, sem internet, sem conta e sem plano pago.

O aplicativo não diagnostica, não substitui terapia, não promete resultado clínico e não deve usar dados da criança para publicidade ou venda.

## Estado técnico conhecido

O projeto é Flutter multiplataforma, com diretórios para Android, iOS, Web, Windows, macOS e Linux. O núcleo atual está concentrado em `lib/`.

Já existem:

- grade de pictogramas e categorias;
- montagem de frases;
- síntese de voz;
- modos falar, adicionar e falar + adicionar;
- cartões padrão e cartões personalizados;
- área protegida do responsável;
- PIN parental com PBKDF2-HMAC-SHA256;
- sessão parental temporária;
- caixas Hive protegidas;
- armazenamento nativo de mídias com AES-GCM-256;
- exclusão local de dados, credenciais e chaves;
- registros ABC com exportação minimizada;
- diário de vídeo;
- alertas de transição com TTS ou áudio gravado;
- acessibilidade semântica para cartões e remoção de itens da frase;
- fallback para áudio ausente, corrompido ou incompatível;
- catálogo de planos e estados de licença;
- controle de recursos sem bloquear o modo offline;
- tela de status do plano na Área do Responsável;
- persistência local cifrada da licença;
- workflow do GitHub Actions com formatador, análise, testes, política de assinatura e build Web;
- política de privacidade e documentação de pré-lançamento.

A versão Web possui implementação condicional para mídia. O núcleo CAA pode ser compilado sem `dart:io`, mas mídia personalizada no navegador está deliberadamente limitada até existir armazenamento cifrado adequado para Web. Não remover essa proteção apenas para fazer uma demonstração compilar.

## Arquitetura relevante

A comunicação está em `lib/features/aac_grid/`. A Área do Responsável está em `lib/features/parental_area/`. Serviços transversais estão em `lib/core/services/`. O módulo de planos está em `lib/core/plans/`.

Arquivos importantes:

- `lib/main.dart`: inicialização do Hive, serviços e aplicação.
- `lib/features/aac_grid/presentation/screens/aac_grid_screen.dart`: tela principal da criança.
- `lib/features/aac_grid/data/providers/cards_provider.dart`: cartões, frase e comportamento de toque.
- `lib/features/aac_grid/presentation/widgets/grid_card.dart`: cartão acessível.
- `lib/features/aac_grid/presentation/widgets/sentence_bar_widget.dart`: barra de frase.
- `lib/features/parental_area/presentation/screens/settings_screen.dart`: painel parental.
- `lib/features/parental_area/presentation/screens/plan_status_screen.dart`: status e catálogo de planos.
- `lib/core/plans/plan_models.dart`: recursos, planos e licenças.
- `lib/core/plans/plan_catalog.dart`: catálogo inicial.
- `lib/core/plans/plan_access_controller.dart`: regras de acesso.
- `lib/core/plans/plan_access_provider.dart`: estado Riverpod.
- `lib/core/plans/plan_license_store.dart`: persistência cifrada da licença.
- `lib/core/services/data_wipe_service.dart`: exclusão completa local.
- `.github/workflows/flutter.yml`: validações automatizadas e build Web.

## Regras de planos

O catálogo atual contém:

- **Essencial:** gratuito, comunicação local e controles básicos.
- **Família:** recursos remotos opcionais; preço ainda não definido.
- **Cuidado Conectado:** vínculos autorizados com profissionais ou escolas; preço ainda não definido.
- **Patrocinado:** licença financiada por empresa ou instituição sem acesso ao conteúdo familiar; preço ainda não definido.
- **Organização:** plano administrativo não público para organizações.

Os estados de licença são `invited`, `active`, `grace`, `suspended`, `expired` e `revoked`. Os estados `active` e `grace` mantêm recursos remotos autorizados. Qualquer estado mantém a comunicação offline, acessibilidade, controle parental e dados locais.

Não existe cobrança real. Não conectar um provedor de pagamentos antes de comparar custos, taxas, portabilidade, cancelamento e impacto para famílias.

## Sequência de implementação

A sequência completa está em `docs/PLANO_SEQUENCIAL_ATE_BUILD.md`. A ordem resumida é:

```text
00 ambiente e linha de base
→ 01 navegação inicial
→ 02 grade CAA
→ 03 barra de frases
→ 04 cartões personalizados
→ 05 PIN e sessão
→ 06 Área do Responsável
→ 07 ABC e exportação
→ 08 mídia nativa
→ 09 alertas
→ 10 planos e licença
→ 11 build Web
→ 13 build Android de teste
→ 15 validação humana
→ 12 site institucional
→ 14 build Android de publicação
→ 16 portal conectado
→ 17 cobrança e domínio
```

O catálogo, a tela de planos e a persistência local já foram implementados. O próximo trabalho deve validar e consolidar os fluxos existentes, não começar cobrança ou portal clínico prematuramente.

## Próxima retomada recomendada

1. Confirmar a branch e o estado limpo do Git.
2. Ler `AGENTS.md` e este arquivo.
3. Instalar Flutter na versão usada pelo CI, atualmente `3.38.0`.
4. Executar `flutter pub get`.
5. Executar `dart format lib test`.
6. Executar `flutter analyze --no-fatal-infos --no-fatal-warnings`.
7. Executar `flutter test`.
8. Executar `flutter build web --release`.
9. Corrigir primeiro falhas do CI ou do núcleo CAA.
10. Trabalhar em branch própria, adicionar teste, revisar diff, comitar e enviar ao GitHub.

Comandos básicos:

```bash
gh repo clone falacomigocaa-app/fala-comigo
cd fala-comigo
git checkout feat/affordable-plans-model
flutter pub get
dart format lib test
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
flutter build web --release
```

O ambiente usado para desenvolvimento pode não conter Flutter localmente. Nesse caso, usar o GitHub Actions como validação remota e declarar a limitação sem afirmar que os testes passaram localmente.

## Critérios do primeiro build funcional

O primeiro build está pronto para teste controlado quando:

- uma instalação limpa abre a grade CAA;
- cartões padrão funcionam sem internet;
- frases podem ser montadas, removidas e faladas;
- a Área do Responsável exige PIN;
- a sessão expira e bloqueia ao sair do segundo plano;
- cartões e configurações persistem;
- falhas de mídia não encerram o app;
- registros ABC e exportação respeitam minimização;
- alertas básicos funcionam sem conteúdo sensível nas notificações;
- plano Essencial aparece sem cobrança;
- exclusão completa remove dados locais, mídia, licença, credenciais e chaves;
- testes, análise e build Web passam no CI;
- Android é testado em celular e tablet antes de publicação.

## Limites do que ainda não está implementado

Ainda não estão prontos para produção:

- backend do portal conectado;
- contas e organizações remotas;
- autorização clínica no servidor;
- consentimento versionado remoto;
- auditoria de acesso remoto;
- sincronização clínica;
- cobrança real;
- painel corporativo em produção;
- site institucional público definitivo;
- domínio final;
- validação humana completa com famílias e profissionais;
- build Android de release validado em dispositivo real.

Não tratar documentação conceitual como implementação existente. O portal e o benefício corporativo exigem backend, isolamento e testes de negação antes de qualquer sincronização.

## Regras para a próxima IA

- Não pedir confirmação para decisões técnicas reversíveis.
- Priorizar falhas que interrompam a comunicação, depois segurança, acessibilidade, testes e produto.
- Não alterar a `main` diretamente quando uma branch de trabalho for suficiente.
- Não adicionar segredos ao repositório.
- Não usar dados reais de crianças em testes, logs, issues ou screenshots.
- Não bloquear comunicação, acessibilidade ou modo offline por plano.
- Não afirmar que um teste ou build passou sem evidência recente.
- Não comprar domínio, contratar serviço, ativar cobrança ou publicar amplamente sem confirmação explícita.
- Registrar decisões importantes em documentação versionada.

## Documentos de referência

- `AGENTS.md`: instruções persistentes de execução autônoma.
- `README.md`: setup e estrutura inicial.
- `docs/PLANO_SEQUENCIAL_ATE_BUILD.md`: sequência numerada até o build.
- `docs/ROADMAP_FULL_CYCLE.md`: roadmap de produto e engenharia.
- `docs/CHECKLIST_PRE_LANCAMENTO.md`: gates funcionais, acessibilidade, segurança e publicação.
- `docs/MODELO_AUTORIZACAO_CLINICAS_ESCOLAS.md`: modelo de autorização futura.
- `docs/MODELO_CUSTOS_E_PLANOS.md`: estratégia de baixo custo e planos.
- `privacy_policy.html`: política de privacidade alinhada ao armazenamento local.
