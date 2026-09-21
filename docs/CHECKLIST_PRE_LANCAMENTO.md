# Checklist de pré-lançamento — Fala Comigo

## Objetivo

Este checklist evita que uma versão tecnicamente protegida seja apresentada como clinicamente validada sem evidência suficiente. O Fala Comigo é uma ferramenta de Comunicação Alternativa e Aumentativa (CAA) para uso sob orientação de responsáveis e profissionais. Ele não diagnostica, não substitui terapia e não deve prometer resultados clínicos.

## Controles já implementados

| Área | Estado atual | Evidência no repositório |
| --- | --- | --- |
| PIN parental | Implementado com PBKDF2-HMAC-SHA256, salt aleatório, atraso progressivo e bloqueio temporário | `lib/core/services/parental_pin_service.dart` e testes Flutter |
| Sessão parental | Implementada com expiração e bloqueio ao sair do fluxo protegido | `lib/core/services/parental_session_service.dart` e testes Flutter |
| Dados locais | Caixas Hive sensíveis usam cifra AES-256 e migração de caixas antigas | `lib/core/services/secure_box_service.dart` |
| Mídia | Fotos, vídeos e áudios novos usam AES-GCM-256; caminhos, extensões e tamanho são validados | `lib/core/services/media_storage_service.dart` |
| Exclusão | O responsável pode apagar caixas, mídias, chave local e PIN | `lib/core/services/data_wipe_service.dart` |
| Backup | Android declara regras para evitar backup automático de dados sensíveis | `android/app/src/main/AndroidManifest.xml` e regras XML |
| Notificações | Conteúdo da notificação é genérico e a visibilidade é privada | `lib/core/services/transition_alert_service.dart` |
| Exportação | PDF ABC é minimizado por padrão e dados identificadores exigem escolha explícita | `lib/features/parental_area/presentation/screens/behavior_log_screen.dart` |
| AAC | Modos falar, adicionar e falar+adicionar são configuráveis e anunciados semanticamente | `lib/features/aac_grid` |
| Política | A política de privacidade descreve armazenamento local, criptografia e exportação | `privacy_policy.html` |
| CI | Formatação, análise estática, assinatura segura e testes são executados no GitHub Actions | `.github/workflows/flutter.yml` |

## Gates antes de distribuir uma versão pública

### Validação funcional

A equipe deve testar o aplicativo em pelo menos um celular Android e um tablet Android, em orientação suportada, com permissões concedidas e negadas. Cada teste deve ser repetido com o dispositivo offline. A lista mínima inclui primeira execução, criação do PIN, troca do PIN, bloqueio após tentativas inválidas, retorno do segundo plano, criação de cartão, reprodução de imagem, áudio e vídeo, montagem de frase, modo somente adicionar, modo somente falar, alertas de transição, exportação minimizada e apagamento completo.

O teste deve confirmar que uma falha de permissão não apaga dados, que um arquivo de mídia corrompido não encerra o app e que a criança consegue continuar na tela AAC sem ser forçada a abrir a Área do Responsável.

### Validação de acessibilidade e TEA

A versão deve ser observada por famílias e, quando possível, por profissionais com experiência em autismo e CAA. O objetivo não é medir obediência ou normalizar comportamento. Deve-se observar se a criança entende a relação entre imagem, palavra e voz, se o tempo de resposta é suficiente, se o feedback não causa sobrecarga e se o responsável consegue ajustar o modo de interação.

A avaliação deve cobrir contraste, tamanho dos alvos, leitura por TalkBack e VoiceOver, foco previsível, linguagem concreta, ausência de animações obrigatórias, uso sem internet e recuperação após interrupções. Nenhum dado real de criança deve entrar em issues, commits, screenshots ou testes automatizados.

### Validação de segurança e privacidade

A equipe deve instalar uma versão limpa e confirmar que não há PIN padrão. Deve tentar abrir uma mídia fora da pasta privada, alterar um arquivo cifrado, compartilhar um vídeo, exportar um PDF e apagar os dados. O resultado esperado é bloqueio ou confirmação clara, sem revelar exceções, IDs internos ou caminhos do dispositivo.

O responsável deve revisar a política de privacidade, o texto de consentimento e a lista de permissões antes da publicação. A função de apagar dados deve ser descrita como exclusão local; ela não remove cópias exportadas para outros aplicativos ou serviços.

### Limites clínicos e legais

Antes de apresentar o aplicativo a uma clínica ou escola, a organização deve definir responsável pelo tratamento de dados, finalidade, retenção, canal de atendimento e procedimento para revogação. O portal multi-organização não deve ser ativado apenas com alterações no Flutter. Ele exige backend com isolamento por organização, autorização no servidor, consentimento versionado, URLs temporárias para mídia, auditoria e testes de negação.

A classificação de suporte não deve ser usada para inferir prognóstico, capacidade ou valor da criança. O aplicativo deve apresentar o campo como informação fornecida pelo responsável e deve evitar qualquer recomendação clínica automática baseada nele.

## Critério de decisão

Uma versão pode ser distribuída para teste controlado quando os controles implementados estiverem verdes, os gates funcionais não apresentarem bloqueadores e pelo menos um responsável conseguir completar os fluxos principais sem assistência técnica. O lançamento amplo deve esperar a validação de acessibilidade, a revisão de textos por profissionais e a definição de suporte e resposta a incidentes.

A integração com clínicas e escolas só pode avançar depois que o modelo de autorização documentado em `docs/MODELO_AUTORIZACAO_CLINICAS_ESCOLAS.md` tiver uma implementação no servidor e testes negativos automatizados. Até lá, o aplicativo permanece local-first e sem sincronização clínica.

## Referências

[1]: ../RELATORIO_AUDITORIA_SEGURANCA_PROFUNDA.md "Relatório de auditoria de segurança profunda"
[2]: ../RELATORIO_PESQUISA_RECURSOS_TEA.md "Relatório de pesquisa sobre recursos para TEA"
[3]: MODELO_AUTORIZACAO_CLINICAS_ESCOLAS.md "Modelo de autorização para clínicas e escolas"
