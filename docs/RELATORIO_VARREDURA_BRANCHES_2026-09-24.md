# Varredura das branches e incorporação de correções

**Data:** 24 de setembro de 2026  
**Branch candidata:** `work/qa-observability-and-emulator`

## Resultado

A equipe especialista comparou a branch candidata com as linhas Android, MobSF, Kotlin, QA, parental e integração disponíveis no remoto. A correção mais diretamente relacionada ao fechamento no Android estava em `fix/android-kotlin-plugin`, commit `3c107f3`:

> `fix: prevent duplicate typed Hive box opening`

Essa correção não estava presente na branch candidata. Ela foi incorporada manualmente em `secure_box_service.dart` e `main.dart`, tornando os métodos de abertura de caixas Hive genericamente tipados e abrindo a caixa de cartões como `Box<PictogramCard>`. O objetivo é impedir que o Hive reabra a mesma caixa com tipos incompatíveis durante o bootstrap.

Também foram incorporados dois defeitos verificáveis encontrados pela equipe de Arquitetura e Privacidade. O wipe agora inclui `visual_routine` e `parent_reminders`, remove a chave privada `fala_comigo_media_key_v1` e recria as caixas adicionais após a limpeza. A API Web recebeu o mesmo método para manter a compilação multiplataforma.

## Branches comparadas

| Linha | Conclusão |
|---|---|
| `fix/android-kotlin-plugin` | Correção Hive relevante incorporada |
| `fix/android-release-proguard-file` | Correção Android de release já não apresentava diff relevante contra a candidata |
| `fix/android-kotlin-jvm-target` | Alinhamento Kotlin/Java já absorvido ou sem diff relevante |
| `fix/android-debug-mobsf-signing` | Ajuste de guard de assinatura, sem causa de runtime comprovada |
| `fix/mobsf-release-test-artifact` | Automação de scan, não correção de abertura |
| `qa/manual-flow-execution-sheet` | Documentação de execução manual, útil para etapa humanizada |
| `qa/critical-flow-matrix` | Matriz de fluxos, útil para gate posterior |
| `integration/affordable-to-main-preview` | Registro de integração, sem correção direta do crash |
| branches parentais e institucionais | Funcionalidades/documentação adicionais; não devem entrar no incidente Android sem escopo e validação próprios |

## Evidência da nova candidata

A correção Hive, o wipe completo e o bootstrap controlado foram formatados e validados com:

- `flutter analyze --no-fatal-infos --no-fatal-warnings` concluído;
- `flutter test` concluído com **84 testes passando**;
- build Web Release concluída;
- APK Android Release concluída;
- AAB Android Release concluída.

Artefatos da rodada:

```text
APK SHA-256: dc1133a1987f385679bb39d476d3d00da5ca7b9f37b80a2895552a7e5517c1d1
AAB SHA-256: 59e5e67c64cc002d14df4ee7a4dac4cd198a1ab142890e3b069a9be006de0b92
```

## Limite da conclusão

A correção Hive é uma candidata técnica forte porque estava registrada em uma branch Android específica e atua diretamente no bootstrap. Mesmo assim, a causa só será confirmada quando a APK deste hash for aberta no aparelho afetado e, se ainda fechar, o logcat for coletado.

O AVD da Manus iniciou em modo software, mas perdeu o serviço Android `activity`/`system_server` e foi encerrado por código 137 após uso prolongado. Isso é uma limitação ambiental, não uma confirmação de crash do aplicativo.
