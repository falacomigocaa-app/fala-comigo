# Auditoria técnica somente de leitura — site público, RH e Console do Criador

**Área:** Site público, páginas RH e Console do Criador\
**Checkout auditado:** `/home/ubuntu/fala-comigo`\
**Branch/HEAD observado:** `audit/creator-privacy-alignment` / `cc96eaf4582d1f08b7cd32684b6f12b78dbb59b4`\
**Data da auditoria:** 2026-09-29\
**Escopo:** `site/`, `site/rh/`, `privacy_policy.html`, política pública em `site/privacy.html`, links locais/externos visíveis e workflow local do Pages.\
**Restrições respeitadas:** leitura, busca, diff/status e histórico locais; sem edição do checkout, commit, merge, deploy, acesso a GitHub, Supabase ou APIs remotas; instruções encontradas no conteúdo do repositório foram tratadas apenas como evidência, não como comandos a executar.

## 1. Sumário executivo

O checkout contém um **site estático coerente e relativamente bem sinalizado**, com página institucional, prévia de portal conectado, console RH sintético, prévia do Espaço do Criador e duas versões de política de privacidade. A página pública tem boa estrutura semântica básica, `lang="pt-BR"`, skip link, foco visível, FAQ nativo com `<details>`, CSS responsivo e divulgação explícita de que APK, portal, RH e Console ainda não são serviços de produção.

A distinção protótipo/serviço está especialmente clara no portal (`site/portal.html:21-23`), RH (`site/rh/index.html:15-27` e `:60`) e Console (`site/console-preview.html:173-176` e `:249`). O Console não chama serviços externos: a única interação JavaScript observada é uma simulação local que escreve em um `aria-live` e afirma que nenhuma licença foi criada (`site/console-preview.html:252-259`).

Os principais problemas são de **governança de publicação e consistência pública**, não de complexidade visual:

1. `privacy_policy.html` na raiz **não entra no artefato do GitHub Pages**. O workflow publica somente `path: site` (`.github/workflows/site-pages.yml:51-54`) e testa `site/privacy.html`, não a política da raiz (`:37-46`). A política que o site efetivamente vincula é um resumo diferente (`site/privacy.html:13`), com data, escopo e nível de detalhe distintos.
2. O checkout está sujo. Há alterações locais não commitadas em `.github/workflows/site-pages.yml`, `site/console-preview.html`, `site/index.html`, `site/portal.css` e `site/portal.html`, além de `tests/` não rastreado. Essas mudanças não podem ser consideradas publicadas no Pages apenas por existirem neste checkout.
3. A homepage usa algumas formulações afirmativas de produto (“funciona”, “sempre disponível”, capacidades de clínicas/escolas/patrocinadores), embora o próprio FAQ diga que o APK ainda não foi testado em aparelho real nem distribuído (`site/index.html:132-150`). A divulgação existe, mas não está igualmente proeminente em todas as entradas públicas.
4. O Console é incluído no artefato do Pages, porém não há link local para ele na homepage. Ele é alcançável por caminho direto conhecido, mas não é uma entrada pública descoberta pela navegação institucional.
5. Existem gaps objetivos de acessibilidade: as duas políticas não têm skip link (a política raiz também não tem `<main>`), símbolos decorativos de várias prévias não são consistentemente marcados como `aria-hidden`, e o badge de “Protótipo • dados sintéticos” do RH é ocultado em telas estreitas (`site/rh/styles.css:2`).

**Conclusão:** o material é adequado como **site de apresentação e protótipos sintéticos**, não como prova de que portal, RH, Console, cobrança, convites, permissões, sincronização ou piloto real já funcionam. A publicação deve ser bloqueada até decidir uma política canônica, separar claramente estado publicado de estado local e validar dispositivo, leitor de tela, links externos e piloto controlado.

## 2. Método e limitações

Foram lidos `AGENTS.md`, os HTML/CSS/fixtures/testes do escopo, o workflow `.github/workflows/site-pages.yml`, o status/diff locais e o histórico Git relacionado. Foi executado apenas um verificador local em Python para resolver referências relativas e fragmentos; ele não acessou a rede. A inspeção também comparou o workflow atual com `HEAD`.

Não foram feitos:

- acesso ou validação de URLs remotas, GitHub, Supabase, WhatsApp, e-mail ou APIs;
- execução em navegador, aparelho real, leitor de tela, viewport real ou rede móvel;
- teste de APK, autenticação, backend, armazenamento, criptografia em runtime, exportação ou permissões;
- deploy ou comparação com o conteúdo efetivamente publicado.

Assim, “funciona agora” abaixo significa **funciona como arquivo estático/local e como intenção/cobertura declarada**, não disponibilidade de serviço em produção.

## 3. Estado do checkout e alcance do Pages

### 3.1 Estado local

O status observado foi:

```text
 M .github/workflows/site-pages.yml
 M site/console-preview.html
 M site/index.html
 M site/portal.css
 M site/portal.html
?? tests/
```

O HEAD é `cc96eaf` e coincide com as referências locais `main`/`origin/main` observadas no histórico, mas as mudanças acima estão fora desse commit. Portanto, o conteúdo atual lido e o conteúdo que um push de `main` produziria **não são necessariamente iguais**. Não houve tentativa de resolver essa divergência.

### 3.2 O que o workflow publica

O workflow atual:

- dispara em push para `main` quando há mudança em `site/**`, `tests/**` ou no próprio workflow (`.github/workflows/site-pages.yml:3-16`);
- no checkout atual executa `node --test tests/*.test.mjs` (`:34-35`);
- verifica a presença de `site/index.html`, `site/privacy.html`, `site/portal.html`, `site/portal.css`, `site/console-preview.html`, `site/rh/index.html` e `site/rh/styles.css` (`:37-46`);
- envia **somente `site/`** ao artefato Pages (`:51-54`);
- não implanta em pull request no arquivo local atual (`:56-67`).

A comparação com `HEAD` mostra que os testes, os checks de `portal.html`, `portal.css` e `console-preview.html`, o gatilho de pull request e a condição que impede deploy de PR são alterações locais não commitadas. O `HEAD` ainda publica `site/` como artefato, mas não contém esses checks extras.

**Implicação:** o Pages pode conter todos os arquivos que estão dentro de `site/`, incluindo `console-preview.html`, mesmo que não haja link na homepage. `privacy_policy.html` na raiz está fora do artefato por definição do `path: site` e não aparece em nenhum link das páginas públicas do diretório `site/`. A política efetivamente alcançável pela navegação institucional é `site/privacy.html`.

### 3.3 Links locais e externos

O verificador local resolveu sem erro todas as referências relativas e âncoras encontradas em:

- `site/index.html`;
- `site/privacy.html`;
- `site/portal.html`;
- `site/console-preview.html`;
- `site/rh/index.html`.

Isso cobre `styles.css`, `portal.css`, `rh/`, `portal.html`, `privacy.html`, `../index.html` e todos os fragmentos locais. Os links externos identificados foram:

- e-mail `mailto:falacomigocaa@gmail.com` e WhatsApp `https://wa.me/5567991632279` em `site/index.html:157-158`;
- repositório GitHub e Manual do usuário em `site/index.html:162`;
- contrato do portal no GitHub em `site/portal.html:78`;
- issues do GitHub em `site/privacy.html:13` e `privacy_policy.html:172-176`.

Esses destinos externos não foram acessados, por restrição da auditoria. Há dependência de caminhos hard-coded para o repositório/branch `main`; isso deve ser validado se o projeto mudar de organização, branch ou domínio.

## 4. Funcionando agora — evidências positivas

### 4.1 Site institucional

- `site/index.html` tem `lang="pt-BR"`, viewport, meta description, título e skip link para `#conteudo` (`:1-12`).
- A navegação tem nome acessível e links internos resolvíveis (`:19-27`).
- O conteúdo apresenta o produto como local-first, sem anúncios e com privacidade por padrão (`:34-45`), e a seção de privacidade descreve compartilhamento por ação do responsável e apagamento local (`:73-84`).
- Há aviso explícito de que o APK foi gerado, mas não foi testado em aparelho real nem distribuído em loja (`:149-150`). Esta é uma boa salvaguarda contra interpretar a página como canal de download.
- A FAQ nega substituição de terapia/diagnóstico (`:145-146`), reduzindo risco de promessa clínica.
- Há CSS de foco visível e skip link (`site/styles.css:20-21` e `:54`), `prefers-reduced-motion` (`:53`), breakpoints para telas menores (`:51-52`) e FAQ baseado em elemento nativo (`:56-68`).
- O site não contém `<img>` sem texto alternativo porque a arte é CSS/HTML; o hero usa `role="img"` com `aria-label` (`site/index.html:47`).

### 4.2 Portal conectado

- O cabeçalho chama a página de prévia e usa badge “PRÉVIA COM DADOS SINTÉTICOS” (`site/portal.html:13-18`).
- O aviso principal diz que convites, permissões e tarefas são ilustrativos e que os botões não executam ações nem compartilham informações (`:21-23`).
- O texto separa a linguagem de organizações, vínculos, tarefas, aceite e escopos do que está “sendo preparada” no aplicativo (`:26-30`).
- O footer identifica “Portal conectado em desenvolvimento” (`:78`).
- Há skip link, viewport e um breakpoint para reorganizar cartões, grid e rodapé (`site/portal.html:1-12`, `site/portal.css:1-3`).

### 4.3 Página RH

- A entrada pública é claramente marcada como `Protótipo • dados sintéticos` e aponta para o site de origem (`site/rh/index.html:13-18`).
- O texto explica que a prévia contém apenas informação administrativa e não acessa diagnóstico, comunicação, mídia, registros clínicos ou frequência individual (`:20-27`).
- Métricas e beneficiários são explicitamente sintéticos (`:30-35`, `:47-49`).
- O botão “Novo convite” está desabilitado e acompanhado de “A criação de convites ainda não está disponível neste protótipo” (`:45-49`).
- O aviso de antes da produção é forte e objetivo: não é sistema RH, não processa dados reais, não representa conformidade jurídica final e ainda exige backend, contratos, retenção, encarregado e revisão LGPD (`:57-60`).
- O HTML tem skip link, `main`, `h1`, headings de seção, tabela e labels semânticos; há foco visível (`site/rh/index.html:1-12`, `site/rh/styles.css:3`).

### 4.4 Console do Criador

- A página inclui descrição meta de demonstração estática sem login, banco ou pagamentos (`site/console-preview.html:3-8`).
- A navegação é explicitamente “Navegação do protótipo” (`:155-160`) e o topo informa “Acesso do proprietário (simulado)” (`:167-175`).
- O banner diz “Protótipo visual — não é um painel funcional”, números fictícios, sem login, Supabase, cadastro ou pagamentos (`:173-176`).
- O escopo do painel é limitado a catálogo, lotes e duas contagens globais; a própria página diz que não há consulta individual de lotes (`:184-203`).
- A página nega conteúdo clínico, prontuários e conteúdo de comunicação (`:178-182`, `:214-217`) e mantém planos futuros como rascunhos/“sob consulta” (`:222-227`).
- O formulário de lote usa labels associadas e informa que nada será gravado (`:231-245`). A simulação é local e expõe resultado em região `aria-live` (`:242-243`, `:252-259`).
- O footer é inequívoco: incluir o arquivo no artefato Pages não o torna funcional; não há login, banco, envio de códigos, pagamentos ou consulta a clientes (`:249`).

### 4.5 Testes e histórico como evidência de intenção

Os testes locais presentes registram salvaguardas úteis:

- `tests/public-site.test.mjs:21-56` verifica existência de links/arquivos locais e âncoras;
- `:58-64` exige rotulagem sintética e não interativa do portal;
- `:71-80` exige a divulgação do APK gerado, mas ainda não testado/distribuído;
- `tests/creator-console.test.mjs:11-24` restringe as métricas do Console e impede lista/identificadores por lote;
- `:33-43` impede link legado do portal Manus e exige declaração explícita de que a prévia não é funcional.

O histórico local mostra evolução coerente dessas salvaguardas: criação do site (`2fd02b4`), áreas institucionais (`6f5faf9`, `7587a6a`), protótipo RH (`62ef379`), portal (`70537c7`) e Console (`cc96eaf`). Isso demonstra intenção de separar superfícies, mas não prova execução em produção.

## 5. Incompleto ou protótipo

### 5.1 App público e disponibilidade

A homepage afirma que a comunicação básica foi desenhada para funcionar offline e como plano gratuito (`site/index.html:66-68`, `:93-103`, `:132-143`), mas não oferece download nem canal oficial. A única declaração operacional verificável no próprio site é que o APK de validação ainda não foi testado em aparelho real nem distribuído em loja (`:149-150`). Portanto:

- **implementado como copy/arquitetura de apresentação:** posicionamento local-first, plano Essencial gratuito, FAQ e limites;
- **não demonstrado como serviço disponível:** instalação, áudio, cartões, exportação, apagar dados, permissões e uso offline em dispositivo real;
- **não há autorização para tratar “Gratuito” ou “Sempre disponível” como disponibilidade comercial atual sem o aviso de validação.**

### 5.2 Portal conectado

`site/portal.html` é uma maquete estática. Os números “2 organizações”, “4 tarefas” e “5 escopos” (`:40-44`), família Silva, clínica/escola, tarefas, aceite e agenda (`:32-71`) são conteúdo ilustrativo. Botões como “Ver permissões”, “Convidar organização”, “Exportar visão”, “Ver histórico” e “Abrir plano” não têm workflow, backend, autorização, consentimento, revogação, prazo ou persistência. O aviso está presente, mas a página ainda visualiza um fluxo de cuidado sensível que não existe como serviço.

### 5.3 Console do Criador

O Console é uma visualização de escopo, não um console operacional:

- não existe login, identidade do proprietário, autorização ou isolamento por organização;
- não existe banco, Supabase, publicação de plano, lote de licenças, emissão/validação de códigos, pagamento ou auditoria persistente;
- a seleção de modalidade/plano/quantidade/validade é demonstrativa;
- o botão apenas calcula uma quantidade local e exibe “códigos fictícios preparados”.

Isso está bem declarado em `site/console-preview.html:173-176`, `:235-245` e `:249-259`. O risco restante é de **alcance/descoberta**, não de a página fingir internamente ser funcional.

### 5.4 RH

A página RH descreve governança pretendida — “menor privilégio”, limites permitidos/bloqueados, indicadores agregados e licença patrocinada — mas não implementa servidor, contratos, retenção, encarregado, consentimento, controles de reidentificação ou auditoria real. A própria página reconhece isso (`site/rh/index.html:51-60`). “Ativo”, “86” e datas em `:30-41` são dados fictícios, não estado de um programa real.

## 6. Gaps objetivos de conteúdo e risco de afirmação enganosa

### 6.1 Linguagem de disponibilidade misturada com linguagem de protótipo — prioridade alta

A homepage usa linguagem assertiva:

- “Offline primeiro”, “Privacidade por padrão” (`site/index.html:41-44`);
- “ajuda crianças e adolescentes” (`:34-36`);
- comunicação sem conta, internet ou assinatura (`:65-68`);
- “Sempre disponível” e “Gratuito” (`:96-103`);
- clínicas, escolas e patrocinadores com capacidades específicas (`:108-120`).

Em contraste, a FAQ admite que o APK não foi testado nem distribuído (`:149-150`), e as páginas portal/RH/Console são prévias. Não há falsidade demonstrada no texto, mas há **risco de leitura parcial**: um visitante pode interpretar capacidades planejadas como oferta operacional, principalmente se entrar diretamente por uma página de prévia ou por um link de instituição.

**Recomendação:** colocar no topo ou em todas as entradas públicas uma nota consistente, por exemplo “Em validação — sem download público e sem serviços conectados ativos”. Prefixar capacidades de clínicas/escolas/patrocinadores como “planejado para piloto” até haver implementação e teste.

### 6.2 “Portal piloto” é menos preciso que “prévia sintética”

A navegação chama o link de `Portal piloto` (`site/index.html:23-25`), mas a seção informa “Portal conectado em desenvolvimento” e “primeiro piloto usará dados sintéticos” (`:120`). A palavra “piloto” pode sugerir participação real; o aviso da página destino corrige isso, mas só depois do clique.

**Recomendação:** usar “Prévia do portal (dados sintéticos)” na navegação e reservar “piloto” para um fluxo controlado com participantes, consentimentos, suporte e critérios de encerramento definidos.

### 6.3 Console público sem entrada navegável

`site/console-preview.html` é checado e incluído no artefato pelo workflow (`.github/workflows/site-pages.yml:44`, `:51-54`), mas `site/index.html` não contém referência a `console-preview.html`; a busca local só encontra o arquivo em testes/workflow e referências documentais. Consequências:

- a superfície pode estar publicamente alcançável por URL direta mesmo sem intenção de divulgação ampla;
- usuários comuns não encontram o Console pela navegação;
- não há decisão explícita no HTML sobre “público” versus “somente revisão interna”.

**Recomendação:** decidir uma das opções: (a) link público rotulado “Prévia do Console — somente demonstração”; ou (b) remover o arquivo do artefato Pages até haver aprovação. Não tratar URL não descoberta como controle de acesso.

### 6.4 Claims técnicos de privacidade não são prova de runtime

A política raiz contém detalhes fortes — AES-GCM-256 para novas mídias (`privacy_policy.html:52-60` e `:88-98`), Hive/AES-256 para perfil e ABC (`:63-85`), PBKDF2-HMAC-SHA256 para PIN (`:119-128`), exclusão de backup automático (`:150-162`) — enquanto `site/privacy.html` fornece apenas resumo genérico (`:13`). A auditoria de HTML não confirma que esses algoritmos, chaves, exclusão de backups, exportações e revogação funcionam no APK atual.

**Recomendação:** manter detalhes técnicos somente se houver evidência de versão/build e teste recente; do contrário, rotular como “implementação prevista” ou publicar uma política canônica alinhada ao comportamento validado. Não usar a política como prova de conformidade, como a própria página RH corretamente evita (`site/rh/index.html:60`).

## 7. Política de privacidade: divergência e alcance

Há duas políticas distintas:

| Arquivo | Estado no Pages | Atualização declarada | Conteúdo principal |
|---|---|---:|---|
| `privacy_policy.html` | Fora do artefato porque está na raiz | 21/09/2026 (`:32-33`) | Política longa com categorias de dados, algoritmos, permissões, PIN, backup, exclusão e contato GitHub (`:35-176`) |
| `site/privacy.html` | Dentro do artefato Pages e vinculada pelo site | 23/09/2026 (`:13`) | Resumo curto; local-first, mídia, ABC, PIN, RH, exportação e apagamento na mesma linha HTML (`:13`) |

Observações objetivas:

- `site/index.html:84`, `site/portal.html:75` e `site/rh/index.html:60` levam a `site/privacy.html`, não à política raiz.
- A política raiz diz que o app é para crianças com TEA e que ajuda famílias/profissionais a acompanhar desenvolvimento (`privacy_policy.html:35-41`); a política pública é mais ampla e não repete essa caracterização clínica (`site/privacy.html:13`). Isso merece decisão editorial e de produto.
- A versão raiz detalha permissões de câmera, microfone e fotos (`:101-117`), enquanto a versão Pages resume permissões em uma frase (`site/privacy.html:13`).
- A raiz descreve backup/transferência e a opção “Apagar todos os dados” com chaves/PIN (`privacy_policy.html:150-162`); a versão Pages resume apagamento, sem o mesmo detalhe (`site/privacy.html:13`).
- A raiz informa contato via GitHub Issues (`:172-176`), assim como a versão Pages (`site/privacy.html:13`), mas a homepage oferece e-mail e WhatsApp (`site/index.html:156-158`). Não está claro qual canal é o responsável por privacidade/solicitações.

**Bloqueador de publicação:** escolher uma fonte canônica, revisar a data e as afirmações técnicas, e garantir que o arquivo canônico esteja no diretório efetivamente publicado ou seja apontado por link público válido.

## 8. Acessibilidade e UX

### Pontos positivos

- skip links no site, portal, RH e Console (`site/index.html:12`, `site/portal.html:12`, `site/rh/index.html:12`, `site/console-preview.html:143`);
- títulos, `main`, `nav` com rótulo e `aria-current` no Console;
- labels explícitas em inputs/selects do Console (`site/console-preview.html:237-240`);
- `aria-live` para o resultado da simulação (`:243`);
- `aria-label` em navegações e regiões relevantes;
- foco visível, contraste de foco e preferência de movimento reduzido nos CSS principais;
- tabela RH com cabeçalho e região de rolagem horizontal (`site/rh/index.html:45-49`, `site/rh/styles.css:2`).

### Gaps concretos

1. **Políticas sem skip link:** `site/privacy.html:1-16` não tem skip link. `privacy_policy.html:1-180` também não tem skip link, `<main>`, `<header>` ou landmarks; é uma sequência direta no `<body>`. Para uma política longa e sensível, isso prejudica navegação por teclado/leitor de tela.
2. **Símbolos decorativos não uniformemente ocultos:** no portal, símbolos como `＋`, `□`, `◌` e `✦` aparecem em `site/portal.html:49-71` sem `aria-hidden="true"`; no Console alguns ícones já estão ocultos (`:148-150`, `:173-175`), mas a prática não é consistente. Validar se leitores de tela anunciam ruído ou caracteres irrelevantes.
3. **Botões no-op em prévias:** o portal tem vários `<button>` sem estado desabilitado, embora o aviso diga que não executam ações (`site/portal.html:36`, `:47`, `:59`, `:69-71`). Isso é aceitável para uma maquete se declarado, mas é uma affordance enganosa para teclado/usuários de tecnologia assistiva. Usar links para conteúdo ilustrativo, ou desabilitar/rotular “somente demonstração”.
4. **Aviso sintético ocultado em mobile no RH:** `site/rh/styles.css:2` aplica `.environment-badge{display:none}` até 650px. O texto principal ainda menciona prévia, mas o marcador mais imediato “Protótipo • dados sintéticos” desaparece justamente em telas pequenas. Manter um aviso equivalente visível.
5. **Validação real ausente:** não foi possível afirmar ordem de foco, contraste efetivo, zoom 200/400%, teclado virtual, leitor de tela, rotação ou ausência de overflow nos dispositivos-alvo. O CSS tem breakpoints, mas isso é cobertura estática, não validação de uso.

## 9. Bloqueadores objetivos

1. **Política canônica não publicada:** `privacy_policy.html` está fora de `path: site`; a página pública usa outro resumo. Bloqueia afirmar que a política detalhada é a política pública oficial.
2. **Conteúdo local não corresponde necessariamente ao conteúdo publicado:** workflow, testes e cinco arquivos estão modificados ou não rastreados. Sem commit/merge/deploy — todos proibidos nesta auditoria — não há base para dizer que essas mudanças chegaram ao Pages.
3. **Serviços anunciados não estão implementados nas páginas auditadas:** portal, RH e Console são HTML estático; botões, convites, permissões, exportação, cobrança e lotes não executam ações persistentes.
4. **Nenhum canal público de download:** a FAQ informa que o APK não foi testado/distribuído. O site não deve ser lido como app disponível para famílias sem um canal oficial e controles de piloto.
5. **Entrada pública do Console indefinida:** o arquivo está no artefato, mas não há link institucional; URL direta não é mecanismo de autenticação nem de restrição.

## 10. Recomendações priorizadas

### P0 — antes de qualquer publicação/uso como referência oficial

1. **Escolher e publicar uma política canônica.** Integrar o conteúdo necessário de `privacy_policy.html` em `site/privacy.html` ou mover o arquivo canônico para `site/`, revisar datas e claims técnicos, e criar uma verificação que impeça divergência.
2. **Separar estado local de estado publicável.** Não considerar alterações em `.github/workflows/site-pages.yml`, `site/index.html`, `site/portal.html`, `site/portal.css`, `site/console-preview.html` ou `tests/` como publicadas. Registrar em revisão qual commit é a fonte do Pages.
3. **Adicionar um aviso global de estágio.** Na homepage, portal, RH e Console: “Demonstração/prévia; sem download público; sem backend/conta/pagamento; dados sintéticos”. Na homepage, reduzir “Sempre disponível” para uma promessa condicionada à validação.
4. **Decidir o alcance do Console.** Linkar explicitamente como prévia pública, ou retirar `console-preview.html` do artefato até aprovação. Se público, documentar o caminho estável e o seu caráter não funcional.

### P1 — antes de piloto controlado

5. **Implementar e testar controles reais antes de usar dados reais:** autenticação, autorização por organização/finalidade/escopo/prazo, consentimento, revogação, isolamento, retenção, auditoria e proteção contra reidentificação.
6. **Alinhar claims institucionais:** marcar clínicas, escolas, patrocinadores, indicadores agregados e “portal contratado” como “planejado” até haver backend e contrato revisados.
7. **Tornar prévias não ambíguas para teclado:** desabilitar botões não funcionais ou rotulá-los “somente demonstração”; manter aviso sintético no mobile; ocultar símbolos puramente decorativos.
8. **Publicar um canal de contato de privacidade real e canônico**, com instruções sobre correção, exclusão e incidentes, em vez de depender somente de GitHub Issues.

### P2 — validação de qualidade

9. Executar testes de link/âncora no CI em uma cópia limpa do commit publicável; adicionar teste para impedir referências quebradas ao arquivo de política canônico e para confirmar que a página pública não afirma disponibilidade antes do release.
10. Fazer auditoria de acessibilidade com teclado, leitor de tela, zoom, contraste e reduced motion em Chromium/Firefox/Safari e Android/iOS; validar tabelas, focus order, FAQ, modal/menus quando existirem e os avisos de protótipo.
11. Fazer teste de dispositivo Android real e piloto sintético/controlado: instalação, áudio, offline, permissões, exportação, apagamento, backup/transferência e comportamento após revogação. Só então atualizar a FAQ e a política com fatos de build/teste.

## 11. Validações futuras de dispositivo e piloto

Estas validações não podem ser substituídas por leitura de HTML:

- instalar o APK em ao menos um telefone e um tablet Android representativos;
- verificar comunicação sem internet após reinício e sem conta;
- validar voz/TTS, cartões, mídia, PIN, exportação, apagar todos os dados e comportamento de backup;
- usar leitor de tela, teclado físico/virtual, zoom, rotação, modo escuro/alto contraste e reduced motion;
- testar links de e-mail/WhatsApp e links GitHub em uma cópia publicada, sem inserir dados pessoais;
- em piloto RH/portal, usar somente dados sintéticos, autorizações controladas, consentimento explícito, prazo e revogação, e confirmar que patrocinador não consegue inferir condição clínica;
- registrar build, dispositivo, OS, navegador, data e resultado antes de alterar as afirmações públicas.

## 12. Matriz final de classificação

| Superfície | Funciona agora | Estado real | Risco principal |
|---|---|---|---|
| Homepage `site/index.html` | HTML/CSS estático, navegação local e FAQ | Apresentação; sem canal público de download | Claims de disponibilidade podem ser lidos como oferta atual |
| `site/privacy.html` | Página estática vinculada pelo site | Resumo público de privacidade | Diverge da política raiz e não tem skip link |
| `privacy_policy.html` | HTML estático no checkout | Não entra no artefato Pages | Pode ser tratada como “política pública” apesar de não ser alcançável pelo Pages |
| Portal `site/portal.html` | Maquete visual com aviso sintético | Protótipo sem ações/backend | Botões sensíveis parecem operacionais; “piloto” é ambíguo |
| RH `site/rh/index.html` | Maquete, tabela e limites administrativos | Protótipo com dados sintéticos | Backend, contratos, retenção e LGPD ainda faltam; badge some no mobile |
| Console `site/console-preview.html` | Maquete e simulação local | Protótipo não funcional | Está no artefato Pages, mas sem decisão de discoverability |

## 13. Arquivos de evidência

- `AGENTS.md`
- `.github/workflows/site-pages.yml`
- `site/index.html`
- `site/styles.css`
- `site/privacy.html`
- `site/portal.html`
- `site/portal.css`
- `site/rh/index.html`
- `site/rh/styles.css`
- `site/console-preview.html`
- `privacy_policy.html`
- `tests/public-site.test.mjs`
- `tests/creator-console.test.mjs`
- Histórico Git local dos commits `2fd02b4`, `6f5faf9`, `7587a6a`, `62ef379`, `70537c7`, `cc96eaf`, além das correções de contato `f545f2b`, `1feaac5` e `a1b0e05`.

**Resultado geral:** aprovado como **apresentação estática/protótipo com boa transparência interna**, não aprovado como evidência de serviço funcional, piloto em produção, política canônica publicada ou validação de dispositivo/acessibilidade completa.
