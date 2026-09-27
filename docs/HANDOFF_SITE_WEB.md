# Handoff — site público e acessibilidade Web

**Atualizado:** 27/09/2026.
**Branch:** `site/visual-a11y-phase1`
**Commit base da PR:** `0f52447a47c2b6fcbfe71676657c9f4a377c512c`
**PR:** [#83](https://github.com/falacomigocaa-app/fala-comigo/pull/83) — aberta; check `Validar site estático` passou e `Flutter quality checks` segue pendente; revisão GitHub ainda não registrada.

## O que foi feito nesta fase

- Corrigidos destinos inválidos da navegação institucional, adicionado acesso à FAQ e direcionado “Empresas e RH” à página existente.
- Implementado menu nativo recolhível para viewport até 1100 px, fechando após navegação. Em telas baixas, o menu tem altura limitada e rolagem própria.
- Escurecidos os tokens de texto e eyebrows no site/portal/RH para atingir contraste AA nas combinações claras avaliadas.
- A política de privacidade passou a ter skip link com foco programático no conteúdo. O contato deixou de apontar para issues públicas e instrui explicitamente a não incluir dados sensíveis de crianças em mensagens ou canais públicos.
- Removido da prévia do portal um link para o Markdown interno que não integra o artefato do GitHub Pages.
- Criado `tools/check_static_site.py`; verificação passa a ocorrer em PRs e antes de montar o artefato Pages.

## Evidências executadas localmente

- `python3 tools/check_static_site.py`: aprovado; links locais/âncoras resolvidos e contraste AA avaliado.
- Playwright/Chromium nos tamanhos 320×800, 390×844, 768×1024, 1024×900 e 1440×1000: sem overflow horizontal; estado do menu compatível com a breakpoint; menu fecha depois de navegar.
- Janela baixa 390×320: menu rolável, com o último link alcançável.
- Teclado: skip link do site e da política transferem foco para `<main>`.
- `git diff --check`: aprovado.
- Revisões independentes de design/acessibilidade e privacidade: aprovadas após correções para viewport baixa e linguagem do contato.

## Limites e decisão pendente

- A PR #83 atualiza o workflow Pages: **mesclá-la publicará a nova versão em `https://falacomigocaa-app.github.io/fala-comigo/`**. Não fazer merge/publicação sem a autorização explícita do responsável, pois a mudança é visível ao público.
- A redação da política minimiza risco, mas não é parecer jurídico formal. Confirmar futuramente se o canal de contato divulgado é o desejado.
- Não houve validação com TalkBack/leitor de tela em dispositivo real, navegação por browser em todos os motores, nem testes com pessoas usuárias.
- Esta etapa não altera o app Flutter, API ou banco Supabase.

## Próximos passos seguros

1. Consultar checks/revisões da PR #83. Se aprovados, solicitar autorização para merge porque ela aciona publicação pública.
2. Com autorização, integrar a PR e verificar visualmente o endpoint oficial, desktop e mobile, sem confundir deployment bem-sucedido com validação de acessibilidade por usuários.
3. Em paralelo, retomar as PRs Android/C AA #79–#81 em branches isoladas: revalidar CI dependente da #82, separar escopos cumulativos, gerar APK identificado por commit e registrar teste manual no Realme C71. Flutter/adb não estavam disponíveis localmente.
4. Não aplicar migrations nem conectar login ao Supabase encontrado: há um projeto ativo chamado “Fala comigo CAA” em `us-east-1`, enquanto o handoff aponta para `fala-comigo-staging` em São Paulo. Confirmar primeiro o ref e o ambiente exatos com o responsável.
5. Manter login real, backend e portal conectados separados do GitHub Pages; o repositório documenta a necessidade de decidir infraestrutura própria antes de implementar autenticação persistente.
