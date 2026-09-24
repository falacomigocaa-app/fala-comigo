# Contrato técnico do portal RH e autorizações

**Status:** contrato de referência para protótipo e backend futuro
**Versão:** 1.0
**Regra:** este documento define limites técnicos; não representa backend implementado nem parecer jurídico.

## 1. Objetivo

O portal RH administra um programa patrocinado sem acessar o conteúdo familiar. O servidor deve separar autenticação, organização, contrato, licença, convite, auditoria e qualquer eventual autorização de cuidado. Esconder uma tela na interface não é autorização: toda decisão deve ser repetida no servidor.

Uma organização pode possuir somente o produto administrativo RH. A existência desse produto não cria licença familiar, vínculo clínico ou consentimento para compartilhamento.

## 2. Entidades mínimas

| Entidade | Finalidade | Pode conter | Não pode conter por padrão |
| --- | --- | --- | --- |
| `User` | identidade individual | id, e-mail, estado da conta, fatores de autenticação | diagnóstico, conteúdo da família ou perfil da criança |
| `Organization` | isolamento de uma empresa, clínica, escola ou família | id, tipo, nome administrativo, estado | dados de outra organização |
| `OrganizationMembership` | vínculo de usuário com organização | userId, organizationId, papel, estado, validade | acesso global fora do vínculo |
| `BenefitProgram` | configuração administrativa do benefício | organizationId, nome, período, quantidade, finalidade administrativa | conteúdo clínico ou de comunicação |
| `BenefitLicense` | concessão administrativa | programId, beneficiaryRef, estado, issuedAt, expiresAt, transitionUntil | nome da criança, diagnóstico, uso ou mídia |
| `Invitation` | adesão individual | programId, destinatário, expiração, estado, finalidade | motivo clínico ou informação ao gestor sobre recusa |
| `CareAuthorization` | compartilhamento opcional | familyOrgId, recipientOrgId, purpose, scope, issuedAt, expiresAt, revokedAt | autorização ampla por cargo ou patrocinador |
| `AuditEvent` | rastreabilidade | ator, organização, operação, recurso, motivo, data, resultado | conteúdo clínico em texto livre ou mídia |

`beneficiaryRef` é um identificador técnico não interpretável. O portal RH não deve permitir transformar essa referência em uma busca sobre criança, diagnóstico, escola, clínica ou frequência.

## 3. Produtos e entitlements

Os produtos devem ser tratados como conjuntos independentes de permissões:

- `organizationPortal`: entrar no espaço administrativo da organização;
- `benefitAdministration`: criar e administrar programas e licenças;
- `aggregateReporting`: visualizar somente indicadores agregados com limiar mínimo;
- `sponsoredLicense`: conceder recursos de uma licença familiar patrocinada;
- `careNetwork`: operar vínculos de cuidado somente quando a família autorizar;
- `offlineCommunication`, `parentalControls`, `accessibility` e `localStorage`: núcleo que nunca depende de pagamento.

O servidor deve negar combinações indevidas. `benefitAdministration` não implica `sponsoredLicense`, e `sponsoredLicense` não implica `organizationPortal`.

## 4. Operações do portal RH

### Permitidas após autorização

- criar ou atualizar um `BenefitProgram` dentro da própria organização;
- emitir convite individual com prazo;
- consultar o estado administrativo de uma `BenefitLicense` própria;
- cancelar ou revogar a própria concessão dentro das regras do contrato;
- consultar contagens agregadas que respeitem limiar anti-reidentificação;
- registrar e consultar eventos administrativos da própria organização;
- abrir atendimento sem acesso a conteúdo familiar.

### Negadas por padrão

- consultar uma criança por nome, diagnóstico, escola ou clínica;
- abrir cartões, frases, fotos, vídeos, áudios ou registros ABC;
- consultar frequência ou horário de uso individual;
- exportar conteúdo familiar ou clínico;
- criar consentimento clínico em nome da família;
- acessar outra organização;
- inferir adesão ou diagnóstico pela recusa de um convite;
- alterar, apagar ou bloquear dados locais da família;
- usar cargo administrativo como autorização global.

## 5. Regras de decisão no servidor

Uma requisição administrativa só pode ser aceita se todas as condições forem verdadeiras:

```text
sessão válida
→ conta ativa
→ organização da sessão corresponde ao recurso
→ membership válido
→ papel possui entitlement específico
→ finalidade compatível
→ escopo compatível
→ prazo não expirado
→ consentimento válido quando houver cuidado compartilhado
→ operação permitida para o tipo de recurso
→ evento auditável sem conteúdo sensível em log
```

Qualquer ausência ou inconsistência deve produzir negação segura. A interface não deve revelar se o recurso existe em outra organização.

## 6. Matriz de testes negativos obrigatórios

| Caso | Resultado esperado |
| --- | --- |
| usuário sem sessão | negar com `unauthenticated` |
| conta desativada | negar com `account_inactive` |
| membership de outra organização | negar com `organization_scope_mismatch` |
| papel RH sem `benefitAdministration` | negar com `entitlement_missing` |
| licença familiar usada para acessar console RH | negar com `product_scope_mismatch` |
| convite expirado | negar ativação com `invitation_expired` |
| convite já utilizado | negar nova aceitação com `invitation_consumed` |
| recusa de convite consultada pelo gestor | negar e não revelar estado clínico |
| relatório abaixo do limiar mínimo | negar ou devolver somente resultado suprimido |
| exportação de conteúdo pelo RH | negar com `operation_not_allowed` |
| acesso a mídia sem autorização específica | negar com `scope_missing` |
| autorização revogada | negar imediatamente com `authorization_revoked` |
| finalidade divergente | negar com `purpose_mismatch` |
| prazo vencido | negar com `authorization_expired` |
| organização clínica tentando usar papel corporativo | negar por organização e produto |
| suporte sem motivo, prazo ou auditoria | negar com `elevated_access_requirements` |

Os testes devem comprovar a negação no servidor, não somente a ausência do botão no navegador.

## 7. Estados e transições

`BenefitLicense` utiliza os estados `invited`, `active`, `grace`, `suspended`, `expired` e `revoked`. Toda transição deve registrar ator, origem, data, motivo e evento de auditoria.

- `invited → active`: somente por aceitação individual válida;
- `invited → expired`: após o prazo do convite;
- `active → grace`: início de transição documentada;
- `active/grace → suspended`: regra administrativa registrada;
- `active/grace/suspended → expired`: fim do prazo;
- qualquer estado não revogado → revoked`: revogação autorizada e auditada.

A transição da licença patrocinada nunca deve apagar conta, cartão, mídia, PIN ou dados locais. O plano Essencial continua disponível.

## 8. Observabilidade e LGPD

Logs técnicos devem conter apenas identificadores técnicos, organização, operação, resultado, motivo e timestamps necessários. Não registrar em logs frases, nomes de crianças, diagnósticos, fotos, áudio, vídeo ou observações clínicas.

Antes de produção, o contrato deve ser acompanhado de definição de controlador e operador, finalidade, base legal, retenção, canal de titulares, encarregado, resposta a incidentes, exclusão, portabilidade e contrato com empresas patrocinadoras. A revisão jurídica e de privacidade deve avaliar risco de reidentificação em grupos pequenos e métricas agregadas.

## 9. Exemplo sintético de resposta segura

```json
{
  "programId": "program-demo-2026",
  "licenseState": "active",
  "validUntil": "2026-12-31",
  "scope": "benefit_administration",
  "clinicalContent": null,
  "individualUsage": null,
  "auditId": "audit-demo-0007"
}
```

O exemplo não autoriza que o portal consulte o aplicativo. Ele representa somente o estado administrativo mínimo que pode ser exibido ao administrador do programa.

## 10. Próximo gate técnico

Antes de construir endpoints reais, implementar testes automatizados de autorização com duas organizações isoladas, papéis RH e família, convites expirados, revogação imediata, limiar de agregação e tentativa de exportação. O backend só poderá avançar quando as negações estiverem verdes e o aplicativo local continuar independente.
