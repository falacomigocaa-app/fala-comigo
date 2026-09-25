# Protocolo de retomada para agentes de IA

## Regra principal

A continuidade atual começa em `recovery/pr29-with-current-web` no commit `0d950ab`. Não escolher outra branch por conveniência.

Essa branch contém o Android baseado na PR #29 (`3c107f3`), que abriu no aparelho, e a Web atual copiada da `main`.

## Antes de programar

O agente deve executar:

```bash
git fetch origin --prune
git checkout recovery/pr29-with-current-web
git pull --ff-only origin recovery/pr29-with-current-web
git status --short --branch
git log -3 --oneline --decorate
```

Se a branch não estiver limpa, parar e relatar. Não apagar mudanças locais.

## Não fazer

- Não partir da `main` para gerar APK Android de teste.
- Não fazer merge amplo da `main` na baseline.
- Não escolher a branch com o nome mais recente sem ler este protocolo.
- Não misturar APK Debug/Profile com Release AOT.
- Não tentar recuperar todas as funcionalidades perdidas em um único commit.
- Não remover arquivos de `site/` durante uma correção Android.
- Não declarar que o app está validado apenas porque o CI passou.
- Não apagar branches de produto Web/RH ou segurança sem decisão explícita.

## Como fazer uma mudança

1. Criar branch a partir de `recovery/pr29-with-current-web`.
2. Alterar uma área pequena.
3. Adicionar ou atualizar teste correspondente.
4. Executar `git diff --check` e revisar o diff.
5. Executar CI.
6. Gerar APK Debug.
7. Testar abertura no aparelho.
8. Testar apenas o fluxo afetado.
9. Registrar branch, commit, APK, SHA-256 e resultado.
10. Abrir PR; não fazer merge direto na `main`.

## Web

A Web publicada está em `main` e em `https://falacomigocaa-app.github.io/fala-comigo/`. A estrutura atual inclui a página institucional, privacidade, segurança/MobSF, planos, instituições, Portal RH e seus estilos. Qualquer alteração Web deve preservar essa estrutura e passar pelo workflow `.github/workflows/site-pages.yml`.

## Rollback

Se o APK fechar, voltar para `recovery/pr29-with-current-web`, comparar o commit e descartar somente a branch experimental. A baseline é o ponto de retorno; não corrigir vários suspeitos simultaneamente.

## Evidência mínima no handoff

Registrar sempre: data, branch, commit, objetivo, arquivos alterados, comandos de validação, resultado, APK/hash e próximo passo. Nunca registrar credenciais ou dados reais.
