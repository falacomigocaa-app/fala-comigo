# Fala Comigo — Plano sequencial até o build

## Objetivo

Este plano organiza a programação restante em partes numeradas. Cada parte possui uma entrega concreta, arquivos ou módulos envolvidos, testes esperados e um critério objetivo de conclusão.

O objetivo da primeira versão rodável é entregar um aplicativo Flutter local-first, útil sem internet, com comunicação CAA, Área do Responsável, segurança local, acessibilidade básica, planos administrativos sem cobrança real e build verificável. O portal conectado, a cobrança e a compra do domínio pertencem a etapas posteriores e não devem bloquear o primeiro build funcional.

## Estado atual resumido

A base já possui a grade CAA, montagem de frases, voz, Área do Responsável, PIN parental, sessão temporária, caixas Hive protegidas, mídia cifrada nativa, registros ABC, diário de vídeo, alertas de transição, política de privacidade, catálogo de planos, controle de recursos e tela de status do plano.

A branch de trabalho atual é `feat/affordable-plans-model`. O ambiente local ainda não possui Flutter/Dart; por isso, o GitHub Actions é a validação remota principal até a instalação da toolchain. O CI também deve executar o build Web.

## Sequência de programação

### 00 — Preparar o ambiente e confirmar a linha de base

**Entrega:** reproduzir o projeto localmente e confirmar o estado do CI.

**Ações:** instalar Flutter na versão declarada pelo workflow; executar `flutter pub get`; executar `dart format lib test`; executar `flutter analyze`; executar `flutter test`; verificar o build Web e, quando possível, o build Android em modo release.

**Critério de conclusão:** a versão atual compila, os testes existentes passam e as falhas de ambiente ficam separadas de falhas do código.

### 01 — Consolidar a navegação inicial

**Tela:** Splash e entrada na grade CAA.

**Ações:** confirmar primeira execução, caixas necessárias, cartões padrão, inicialização de voz, restauração após reinício e orientação de tela.

**Testes:** primeira execução limpa, reabertura do app, ausência de PIN padrão e abertura da grade sem internet.

**Critério de conclusão:** uma instalação limpa chega à tela de comunicação sem exigir conta ou assinatura.

### 02 — Finalizar a grade de comunicação CAA

**Tela:** `AACGridScreen`.

**Ações:** validar categorias, quantidade responsiva de colunas, tamanho dos alvos, imagem padrão, cartão sem imagem, cartão corrompido, foco acessível e comportamento sem conexão.

**Testes:** seleção de cartão, modo falar e adicionar, modo somente adicionar, modo somente falar, cartão inexistente e frase vazia.

**Critério de conclusão:** a criança consegue comunicar-se com cartões padrão em celular, tablet e Web compatível, sem abrir a Área do Responsável.

### 03 — Finalizar a barra de frases

**Tela:** `SentenceBarWidget`.

**Ações:** adicionar cartões, remover cartão, limpar frase, falar frase inteira, impedir índice inválido, anunciar corretamente a ação de remoção e preservar ordem.

**Testes:** frase com um item, frase longa, remoção no início/meio/fim, limpeza e ação obsoleta de acessibilidade.

**Critério de conclusão:** a montagem de frases não encerra o app em nenhum estado esperado e possui semântica acessível.

### 04 — Finalizar cartões personalizados

**Tela:** `AddCardScreen` e lista de cartões da Área do Responsável.

**Ações:** criar cartão, editar cartão, trocar imagem, excluir cartão, reordenar, validar nome, categoria, extensão e falha de permissão.

**Testes:** persistência após reinício, exclusão da mídia antiga, caminho inválido, mídia acima do limite, cancelamento e dados incompletos.

**Critério de conclusão:** a família consegue administrar cartões sem perder dados por falha de imagem ou cancelamento.

### 05 — Finalizar PIN, sessão e bloqueio parental

**Telas:** `ParentalGateScreen`, `ChangePinScreen` e painel parental.

**Ações:** criar PIN, validar PIN fraco, bloquear após falhas, trocar PIN, expirar sessão, bloquear ao ir para segundo plano e impedir acesso direto às configurações.

**Testes:** PIN correto, incorreto, repetido, bloqueio progressivo, expiração, retorno do segundo plano e exclusão das credenciais.

**Critério de conclusão:** somente o responsável acessa configurações protegidas e a sessão não permanece aberta indevidamente.

### 06 — Finalizar Área do Responsável

**Telas:** `SettingsScreen`, perfil, comportamento, diário e configurações.

**Ações:** revisar navegação, estados vazios, mensagens de erro, confirmação de exclusão e orientação portrait/landscape.

**Testes:** cada entrada do painel abre e retorna corretamente; nenhuma ação destrutiva ocorre sem confirmação; o modo da criança permanece separado do painel.

**Critério de conclusão:** o responsável consegue configurar o aplicativo sem assistência técnica nos fluxos principais.

### 07 — Finalizar registros ABC e exportação

**Tela:** `BehaviorLogScreen`.

**Ações:** revisar linguagem neutra, campos opcionais, observação, apoio utilizado, exportação minimizada e compartilhamento somente após confirmação.

**Testes:** registro incompleto, registro completo, exportação sem identificadores, escolha explícita de identificadores, PDF vazio e cancelamento.

**Critério de conclusão:** o relatório não transforma observação em diagnóstico e não envia dados além do escopo escolhido.

### 08 — Finalizar diário de vídeo e mídia nativa

**Tela:** `VideoDiaryScreen`.

**Ações:** gravar ou selecionar vídeo, cifrar, listar, reproduzir, compartilhar após confirmação, excluir e tratar mídia corrompida.

**Testes:** permissão concedida e negada, arquivo ausente, arquivo alterado, compartilhamento cancelado, exclusão local e ausência de cópia fora do escopo.

**Critério de conclusão:** mídias nativas permanecem protegidas e uma falha de mídia não encerra o aplicativo.

### 09 — Finalizar alertas de transição

**Telas:** lista, edição, checklist e tela de alerta.

**Ações:** criar alerta TTS, criar alerta gravado, configurar contagem, checklist, agendamento, notificação privada e fallback para mídia indisponível.

**Testes:** sem permissão, alerta não agendado, áudio ausente, notificação sem conteúdo sensível, abertura pelo payload e cancelamento.

**Critério de conclusão:** alertas ajudam na previsibilidade sem revelar dados em notificações e sem bloquear a criança quando o áudio falha.

### 10 — Integrar o catálogo de planos ao produto

**Tela:** `PlanStatusScreen`.

**Ações:** exibir Essencial, Família, Cuidado Conectado e Patrocinado; mostrar preço gratuito ou pendente corretamente; restaurar licença local; manter comunicação offline em qualquer estado.

**Testes:** licença ativa, período de transição, suspensa, expirada, revogada, licença corrompida e exclusão completa.

**Critério de conclusão:** planos controlam recursos opcionais, mas nunca bloqueiam comunicação, acessibilidade, controle parental ou dados locais.

### 11 — Fechar compatibilidade Web do núcleo

**Ações:** executar build Web; manter implementações condicionais para mídia nativa; garantir que a grade com assets padrão funcione; informar claramente limitações de mídia personalizada no navegador.

**Testes:** `flutter build web --release`, abertura da grade Web, navegação parental compatível e ausência de import direto de `dart:io` em código compartilhado.

**Critério de conclusão:** o Web compila e executa o núcleo seguro sem fingir que recursos de mídia privada não implementados estão disponíveis.

### 12 — Criar o site institucional mínimo

**Escopo:** site estático separado do fluxo de comunicação da criança.

**Páginas:** início, para famílias, como funciona, acessibilidade, privacidade, planos, suporte e empresas patrocinadoras.

**Ações:** usar hospedagem de baixo custo, conteúdo acessível, sem domínio definitivo, sem cadastro obrigatório e sem backend desnecessário.

**Critério de conclusão:** o site apresenta o produto e os limites de privacidade sem depender do portal conectado.

### 13 — Preparar build Android de teste

**Ações:** revisar `applicationId`, ícone, permissões, orientação, backup, target SDK, assinatura de teste e versão.

**Testes:** instalação limpa, atualização sobre versão anterior, Android sem internet, celular, tablet, TalkBack e permissões negadas.

**Critério de conclusão:** um APK de teste ou build equivalente instala e executa os fluxos críticos em dispositivo real.

### 14 — Preparar build Android de publicação

**Ações:** configurar keystore de release fora do Git, gerar `.aab`, revisar política de privacidade, permissões e ficha da loja.

**Critério de conclusão:** `.aab` assinado é gerado sem chave de debug, sem segredos versionados e com política pública revisada.

### 15 — Validação humana e pré-lançamento

**Ações:** executar checklist em celular e tablet, offline, TalkBack, VoiceOver quando aplicável, com famílias e profissionais de CAA/TEA; registrar somente dados sintéticos ou consentidos.

**Critério de conclusão:** os fluxos críticos não têm bloqueadores, a acessibilidade foi observada e existe procedimento de suporte e incidentes.

### 16 — Portal web conectado e backend

**Ações futuras:** contas individuais, organizações, convites com expiração, consentimento versionado, finalidade, retenção, auditoria, revogação, isolamento e URLs temporárias.

**Regra:** não iniciar sincronização clínica apenas alterando o Flutter. O backend e os testes de negação devem existir antes de liberar dados remotos.

### 17 — Cobrança e domínio

**Ações finais:** comparar provedores, taxas, limites, portabilidade e cancelamento; definir preços; adquirir o domínio; conectar cobrança; publicar o site e o aplicativo.

**Regra:** não comprar domínio, contratar serviço ou ativar cobrança antes de concluir a análise de custo e o checklist de lançamento.

## Ordem dos próximos ciclos de código

A sequência imediata será:

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

O site institucional aparece no planejamento, mas a prioridade de programação continua sendo terminar e validar o aplicativo. O domínio, a cobrança e o portal conectado não são necessários para produzir o primeiro build funcional.

## Definição de “aplicativo finalizado para rodar”

A primeira versão será considerada pronta para rodar quando a instalação limpa abrir a grade CAA, funcionar offline, permitir montar e falar frases, proteger a Área do Responsável, persistir cartões e configurações, tratar falhas de mídia, executar alertas básicos, exibir o plano Essencial sem cobrança e passar o CI com testes e build Web. A publicação comercial exigirá ainda os testes em dispositivos, revisão de acessibilidade, política pública, assinatura de release e checklist de pré-lançamento.

## Referências

[1]: ../README.md "README do aplicativo Fala Comigo"
[2]: CHECKLIST_PRE_LANCAMENTO.md "Checklist de pré-lançamento do Fala Comigo"
[3]: ROADMAP_FULL_CYCLE.md "Roadmap Full-Cycle do Fala Comigo"
[4]: MODELO_CUSTOS_E_PLANOS.md "Modelo de custos e planos do Fala Comigo"
