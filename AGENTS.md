# Instruções de desenvolvimento do Fala Comigo

## Leitura obrigatória antes de qualquer mudança

Antes de alterar código, leia nesta ordem:

1. `AGENTS.md`;
2. `docs/PROTOCOLO_RETOMADA_IA.md`;
3. `docs/BASELINE_ANDROID_FUNCIONAL_PR29.md`;
4. `PROJECT_HANDOFF.md`;
5. o documento específico da tarefa.

A linha de continuidade oficial é `recovery/pr29-with-current-web`, commit `0d950ab`. Ela combina o Android da PR #29, commit `3c107f3`, que abriu no aparelho, com o site atual da `main`.

## Autonomia de execução

O responsável autorizou o programador a executar decisões técnicas reversíveis sem solicitar confirmação a cada passo. O programador deve trabalhar em branch, implementar mudanças pequenas, adicionar ou atualizar testes, executar validações disponíveis, revisar o diff, criar commit e abrir Pull Request quando a mudança estiver pronta.

## Linhas oficiais

- `main`: publicação oficial e integração revisada; contém o site publicado.
- `recovery/pr29-with-current-web`: base Android + Web para a continuidade atual.
- `fix/android-kotlin-plugin`: referência histórica somente; não criar novos commits nela.

Não usar branches `ci/*`, `diagnostics/*`, `baseline/*` ou branches documentais antigas como base de produto. Não fazer merge amplo da `main` na baseline. Funcionalidades posteriores devem voltar uma por vez.

## Separação Android e Web

Para mudanças Android, partir de `recovery/pr29-with-current-web`. Para mudanças Web, preservar `site/index.html`, `site/styles.css`, `site/privacy.html`, `site/rh/index.html`, `site/rh/styles.css`, `site/favicon.png` e o workflow de Pages. O site publicado deve continuar sendo controlado pela `main` até uma integração revisada.

Nunca substituir a Web atual por uma cópia antiga apenas porque o Android está sendo recuperado.

## Regras de build Android

A baseline Android validada é Debug/Profile. O APK Debug reconstruído a partir da PR29 abriu no aparelho. A build Release AOT de aproximadamente 57 MB apresentou crash de inicialização e está bloqueada como baseline até investigação específica.

Não misturar Debug/Profile com Release AOT na comparação. Cada APK deve registrar branch, commit, modo de build e SHA-256. Se uma build fechar, retornar à baseline e não tentar corrigir várias partes ao mesmo tempo.

## Fluxo obrigatório

```text
objetivo → branch baseada na continuidade → mudança pequena → teste → diff → CI → APK Debug → teste de abertura → PR
```

Após cada etapa, verificar:

```bash
git status --short --branch
git diff --check
git log -3 --oneline --decorate
```

Não declarar uma etapa concluída sem evidência recente. CI verde prova compilação/checagens do CI, não prova que o app abriu no aparelho.

## Ordem de prioridade

1. Corrigir falhas que interrompam a comunicação.
2. Proteger privacidade, armazenamento local, exclusão e autorização.
3. Preservar acessibilidade, previsibilidade e uso offline.
4. Aumentar testes e reprodutibilidade.
5. Evoluir o site e o portal Web sem remover a estrutura publicada.
6. Preparar publicação e operação.

## Restrições do produto

O aplicativo local-first deve continuar útil sem internet. A comunicação básica não pode depender de conta, servidor ou plano pago. Dados sensíveis não devem ser vendidos, usados para publicidade ou expostos a patrocinadores. O portal conectado só pode conceder acesso quando existir organização, vínculo, finalidade, consentimento, prazo e autorização no servidor.

## Quando interromper e pedir decisão

Pedir decisão somente para ação externa de alto impacto, alteração irreversível, nova credencial, cobrança, domínio, contratação, exclusão de dados, publicação ampla ou mudança de produto que altere materialmente a intenção do responsável.

Nunca registrar segredos, tokens, senhas, chaves privadas ou dados reais de crianças no Git, logs, issues ou screenshots.
