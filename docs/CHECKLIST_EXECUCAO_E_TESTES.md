# Checklist de execução, testes e prontidão

**Objetivo:** registrar o que foi implementado, o que foi realmente testado, quais evidências existem e o que ainda bloqueia a próxima etapa.

## Como usar

Cada item deve receber uma evidência concreta: log de CI, captura de tela, vídeo, APK/AAB, relatório MobSF, caso de teste ou observação assinada pelo responsável pelo teste. Não marcar como concluído apenas porque existe documentação ou código.

Legenda: `[ ]` pendente · `[x]` validado com evidência · `[~]` parcialmente validado · `[!]` bloqueado ou com risco conhecido.

## 1. Ambiente e reprodutibilidade

- [x] Flutter 3.38.0 instalado no ambiente de desenvolvimento.
- [x] `flutter pub get` concluído.
- [x] Formatação verificada sem alterações pendentes.
- [x] `flutter analyze --no-fatal-infos --no-fatal-warnings` executado.
- [x] `flutter test` executado; 84 testes passaram.
- [x] CI remoto executou qualidade, testes e build Web com sucesso em `main`.
- [x] Build Web release reproduzido localmente e servido na URL temporária da Manus.
- [x] Build Android debug reproduzido; APK gerado em `build/app/outputs/flutter-apk/app-debug.apk`.
- [x] Build Android release/AAB assinado reproduzido em ambiente controlado com chave temporária isolada.
- [x] Build limpa após `flutter clean` reproduziu APK e AAB release.

## 2. Comunicação essencial offline

- [ ] Instalação limpa abre a grade CAA.
- [ ] Cartões padrão funcionam sem internet.
- [ ] Filtro por categoria funciona.
- [ ] Frase pode ser montada, alterada e limpa.
- [ ] Cartão pode falar sem adicionar, adicionar sem falar ou fazer os dois.
- [ ] TTS funciona ou apresenta fallback compreensível.
- [ ] Tela permanece utilizável em paisagem.
- [ ] Semântica, foco, contraste e tamanho de toque foram revisados.
- [ ] Falhas de áudio não encerram o aplicativo.

## 3. Área do responsável e dados locais

- [ ] PIN inicial e alteração de PIN funcionam.
- [ ] Tentativas inválidas e bloqueio progressivo funcionam.
- [ ] Sessão parental expira.
- [ ] Retorno do segundo plano exige autenticação quando aplicável.
- [ ] Cartões personalizados persistem após reiniciar.
- [ ] Perfil e configurações persistem após reiniciar.
- [ ] Registro ABC funciona e usa minimização.
- [ ] Exportação local gera o formato esperado.
- [ ] Exclusão completa remove dados, mídia, licença, credenciais e chaves.
- [ ] Backup e restauração foram testados, se fizerem parte do piloto.

## 4. Mídia e alertas

- [ ] Seleção de imagem funciona no Android.
- [ ] Permissão negada é tratada sem crash.
- [ ] Áudio gravado pode ser salvo e reproduzido.
- [ ] Arquivo ausente, corrompido ou incompatível gera fallback.
- [ ] Alertas podem ser criados, editados e excluídos.
- [ ] Notificação agendada aparece no horário esperado.
- [ ] Toque na notificação abre o alerta correto.
- [ ] Reinicialização do dispositivo não quebra alertas suportados.
- [ ] Notificações não exibem conteúdo familiar sensível.
- [ ] Mídia privada não é enviada para terceiros sem ação explícita.

## 5. Web

- [ ] Aplicação Web abre em navegador compatível.
- [ ] Grade, frases, filtros, TTS e área parental funcionam no Web.
- [ ] Fallback de mídia Web é compreensível.
- [ ] Recursos deliberadamente não suportados no Web não aparecem como disponíveis.
- [ ] Layout e acessibilidade foram verificados em largura pequena e grande.
- [ ] Site institucional e política de privacidade abrem.
- [ ] Nenhuma credencial ou dado real aparece no bundle Web.

## 6. Android, segurança e release

- [ ] Manifest e permissões foram revisados.
- [ ] `minSdk` foi decidido com base na matriz de aparelhos do piloto.
- [ ] Achado CBC/PKCS5/PKCS7 do MobSF foi resolvido ou formalmente aceito com mitigação.
- [ ] Migração de dados locais foi testada após mudança criptográfica.
- [ ] Receivers e exportação foram revisados.
- [ ] Armazenamento externo e arquivos temporários foram revisados.
- [ ] Busca de segredos concluída.
- [ ] Novo APK foi submetido ao MobSF após correções.
- [ ] Análise dinâmica e revisão manual MASVS/MASTG concluídas.
- [ ] AAB de produção usa assinatura real protegida fora do repositório.

## 7. Diagnóstico e suporte de testes

- [x] Captura global de erros estruturada adicionada ao aplicativo.
- [x] Eventos são limitados, sanitizados e armazenados localmente.
- [x] Relatório JSON pode ser gerado para suporte.
- [x] Tela parental para revisar/copiar relatório técnico foi adicionada.
- [x] Falha crítica de inicialização passou a exibir tela de diagnóstico em vez de encerrar silenciosamente.
- [ ] Política de consentimento e retenção do diagnóstico foi aprovada.
- [ ] Usuários do piloto foram instruídos a não incluir conteúdo de crianças no relato.
- [ ] Cada erro recebido contém versão, plataforma, fluxo e passos para reproduzir.
- [ ] Processo de triagem classifica erro como bloqueador, alto, médio ou baixo.
- [ ] Dados de teste e relatórios são apagados após a análise conforme a política definida.

## 8. Backend, organizações e piloto RH

- [ ] Modelo de dados classifica cada campo por sensibilidade.
- [ ] Autenticação remota implementada.
- [ ] Autorização server-side implementada.
- [ ] Isolamento multi-organização testado.
- [ ] Família, clínica, escola e RH têm escopos separados.
- [ ] Acesso elevado exige finalidade, aprovação, expiração e revogação.
- [ ] Conteúdo familiar/clínico é inacessível ao RH.
- [ ] Auditoria minimizada e retenção implementadas.
- [ ] Dados agregados respeitam limiar mínimo.
- [ ] Sincronização é opt-in e não bloqueia o núcleo offline.
- [ ] Piloto usa dados sintéticos ou possui aprovação formal para dados reais.
- [ ] LGPD, suporte, incidentes e encerramento do piloto estão definidos.

## 9. Gate atual

**Gate recomendado agora:** validar o MVP offline em Web e Android antes de iniciar backend conectado.

**Bloqueadores conhecidos:** o MobSF reportou achados altos; não há backend real; o AVD da Manus não concluiu o boot sem KVM e foi encerrado por falta de memória em uma tentativa, portanto o teste Android manual deve ser feito em aparelho físico ou emulador com aceleração; o APK debug pode ser alertado pelo Play Protect por não usar assinatura de produção.

**Próxima evidência esperada:** matriz manual preenchida, resultado do APK corrigido em aparelho físico e relatório técnico copiado pelo usuário caso a falha continue.
