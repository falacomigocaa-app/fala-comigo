# Plano de segurança móvel: OWASP MASVS e MobSF

**Status:** primeira varredura estática concluída em APK release de teste; achados em revisão. Não é certificação nem auditoria independente.

## Objetivo

O Fala Comigo passará por uma avaliação técnica baseada no [OWASP MASVS](https://mas.owasp.org/MASVS/), complementada pelos testes e técnicas do [OWASP MASTG](https://mas.owasp.org/MASTG). A primeira evidência automatizada será produzida com o [MobSF](https://github.com/MobSF/Mobile-Security-Framework-MobSF), usando um APK de release não publicado e sem dados reais.

O MASVS organiza os controles nas áreas **Storage**, **Cryptography**, **Authentication and Authorization**, **Network Communication**, **Platform Interaction**, **Code Quality**, **Resilience** e **Privacy**. A avaliação deve registrar evidência, limitação e resultado por controle; uma varredura automatizada não substitui revisão manual, teste dinâmico ou auditoria independente.

## Escopo da primeira execução

| Item | Definição |
| --- | --- |
| Artefato | APK Android de release, assinado somente com chave de teste ou artefato controlado |
| Dados | fixtures sintéticas; nenhum nome, diagnóstico, mídia ou registro de criança |
| Análise estática | MobSF Static Analyzer e revisão do Android Manifest, permissões, armazenamento, criptografia, logs, URLs, componentes exportados e bibliotecas |
| Análise de código | `flutter analyze`, testes Flutter, revisão de dependências e busca de segredos no repositório |
| Análise dinâmica | etapa posterior, em emulador/dispositivo de teste, com tráfego e contas descartáveis |
| Evidência | relatório versionado sem APK, keystore, token, dados pessoais ou dump sensível |

## Critérios de segurança para este aplicativo

A revisão deve prestar atenção especial a:

- PIN parental, sessão protegida e armazenamento no Keystore/Keychain;
- caixas Hive, mídias AES-GCM e migrações sem deixar cópia legível;
- regras de backup e exclusão local;
- notificações genéricas, screenshots e conteúdo em segundo plano;
- permissões de câmera, microfone, mídia, notificações e alarmes;
- componentes Android exportados, intents, deep links e compartilhamento de arquivos;
- TLS e endpoints, quando houver backend futuro;
- ausência de segredos no APK e no repositório;
- minimização de exportações PDF e prevenção de conteúdo familiar em logs;
- limites do portal RH e bloqueio de conteúdo clínico/familiar.

## Como executar quando o ambiente Android estiver pronto

A execução deve ser feita em ambiente isolado. O MobSF oficial oferece imagem Docker e API; o repositório oficial documenta a imagem `opensecurity/mobile-security-framework-mobsf` e o acesso local. O APK deve ser construído com uma chave de teste descartável, nunca com a chave de produção.

O repositório agora contém o workflow manual `.github/workflows/mobsf-security-scan.yml`. Ele usa `workflow_dispatch`, cria uma chave efêmera exclusiva da execução, gera um APK **release de teste** (não é distribuição e não usa a chave de produção), inicia o MobSF em container isolado, envia o APK pela API oficial e publica JSON/PDF e o SHA-256 como artefatos da execução. A execução deve ser disparada conscientemente no GitHub Actions e o relatório deve ser revisado antes de qualquer divulgação.

Exemplo operacional, a ser executado somente em ambiente autorizado:

```bash
flutter build apk --release
sha256sum build/app/outputs/flutter-apk/app-release.apk
# iniciar MobSF localmente em ambiente isolado
# enviar o APK pela interface/API local
# salvar o relatório sanitizado em security/reports/mobsf-<sha>.json ou .html
```

Para a execução reprodutível, usar o workflow manual em vez de copiar o APK para um serviço externo. A chave é criada e apagada dentro do runner; ela não é a chave de produção. O relatório deve distinguir achados do empacotamento de teste, como assinatura e configuração de debug, de achados aplicáveis ao release real.

O resultado deve ser revisado manualmente. Achados críticos ou altos bloqueiam distribuição; achados médios precisam de plano e prazo; falsos positivos devem ser justificados por escrito. O SHA-256 do artefato deve acompanhar o relatório para garantir rastreabilidade.

## Transparência pública

O site pode explicar que o projeto usa MASVS como referência e MobSF como ferramenta de varredura. Após o primeiro relatório, deve usar o estado **“varredura concluída; achados em revisão”**. Não usar “certificado”, “100% seguro”, “aprovado pela OWASP” ou “auditado” sem evidência formal correspondente.

O aplicativo mostra apenas uma mensagem curta de confiança em **Privacidade e dados**. Detalhes técnicos, limitações, escopo e resultados pertencem ao site e ao repositório, para não sobrecarregar a experiência de comunicação.

## Limitações e próximos gates

A varredura MobSF é evidência estática automatizada. Ela não comprova segurança do backend futuro, isolamento multi-organização, resistência a abuso, adequação jurídica LGPD, acessibilidade ou segurança operacional. Antes do piloto com dados reais, ainda são necessários revisão manual MASVS/MASTG, testes dinâmicos, threat model, revisão de dependências, validação de permissões, análise de privacidade e aprovação do responsável pelo tratamento.

### Referências

- [OWASP MASVS](https://mas.owasp.org/MASVS/)
- [Como usar o MASVS](https://mas.owasp.org/MASVS/03-Using_the_MASVS/)
- [OWASP MASTG](https://mas.owasp.org/MASTG/)
- [MobSF — repositório oficial](https://github.com/MobSF/Mobile-Security-Framework-MobSF)
- [MobSF — documentação de API](https://mobsf.live/api_docs)
