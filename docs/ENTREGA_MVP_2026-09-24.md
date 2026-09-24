# Entrega do MVP Fala Comigo

**Data:** 24 de setembro de 2026  
**Branch:** `work/qa-observability-and-emulator`

## Escopo entregue

Esta entrega consolida o MVP local-first do Fala Comigo para Android e Web. O núcleo de comunicação funciona sem depender de conta, internet ou plano pago. O pacote inclui a grade CAA, cartões padrão, montagem de frases, área parental, PIN, persistência local protegida, recursos de mídia, alertas de transição, rotinas e controles locais de licença.

A inicialização foi reorganizada para desenhar uma tela controlada imediatamente. O bootstrap prepara o armazenamento essencial e libera a interface principal somente depois dessa etapa. TTS e notificações são opcionais e inicializados depois da primeira tela, para que uma falha nesses plugins não bloqueie a comunicação.

Falhas de inicialização exibem uma tela técnica em vez de um encerramento silencioso quando a falha ocorre no Flutter. Crashes nativos anteriores à execução do Flutter continuam dependendo do log do Android para diagnóstico.

## Artefatos gerados

| Artefato | Caminho | Estado |
|---|---|---|
| APK Android Release | `build/app/outputs/flutter-apk/app-release.apk` | gerado |
| Android App Bundle Release | `build/app/outputs/bundle/release/app-release.aab` | gerado |
| Web Release | `build/web/` | gerado |

O APK Release tem aproximadamente 55 MB e o AAB aproximadamente 43 MB. A diferença para o APK Debug de aproximadamente 152 MB é esperada: Debug inclui conteúdo de depuração, enquanto Release usa otimização e AOT.

## Evidências de engenharia

A formatação, análise Flutter, matriz automatizada de testes, build Web, APK Debug, APK Release, AAB Release e build limpa foram executadas anteriormente nesta branch. A última validação da alteração de inicialização também concluiu com sucesso a análise e a geração do APK Release.

A assinatura local do APK/AAB usa uma chave temporária de diagnóstico. A chave de produção deve permanecer fora do Git e ser fornecida somente pelo fluxo de distribuição protegido, como Codemagic.

## Escopo que não faz parte deste MVP

O backend conectado, portal multi-organização, autenticação remota, autorização server-side, sincronização clínica, cobrança real, painel corporativo de produção e publicação comercial não estão implementados neste pacote. Existem contratos, modelos e documentação para orientar uma fase futura, mas eles não devem ser tratados como recursos já disponíveis.

A validação humanizada com famílias, profissionais, celulares e tablets deve ser feita como etapa de operação do MVP. Ela não altera o escopo do produto entregue; serve para descobrir correções de experiência e compatibilidade após a entrega.

## Continuidade

A próxima etapa de produto pode começar a partir deste MVP com correções encontradas no uso humanizado. Não iniciar backend, cobrança ou compartilhamento de dados de crianças antes de definir autorização server-side, consentimento, retenção, incidentes e isolamento entre organizações.
