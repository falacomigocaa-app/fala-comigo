# Proposta — Espaço do Criador para planos e licenças

**Estado:** proposta e protótipo visual estático; sem implementação funcional.
**Atualizado:** 27/09/2026.
**Princípio inegociável:** o proprietário não acessa dados clínicos, diagnósticos, prontuários, conteúdo de comunicação, mídias ou outras informações sensíveis das famílias. O console deve ficar tecnicamente separado dessas áreas. Dados comerciais de organizações (por exemplo, nome de uma clínica ou empresa) e metadados administrativos são uma categoria diferente; o que você quer ver disso ainda pode ser escolhido.

## Resumo da recomendação

Começar por um console privado e separado com duas funções: **gerir versões do catálogo de planos** e **emitir/revogar lotes de licenças**. Não haverá pagamentos nesta versão, lista de contas de famílias/usuários nem acesso a conteúdo clínico. O painel mostrará o catálogo e totais agregados; nome/contato comercial de organização só entra se você decidir que é necessário.

Esta proposta se encaixa na sequência já documentada para um console do proprietário sem dados clínicos. É coerente com os modelos de plano/licença existentes, mas ainda é só um desenho: o staging Supabase continua vazio e não há login próprio implementado.

## O que você não verá no painel

- Por padrão, nome, e-mail, telefone, foto, perfil ou conta de família/beneficiário.
- Lista/pesquisa de usuários finais ou página individual de beneficiário no console.
- Quem ativou/resgatou cada licença, identificadores vinculáveis a uma conta ou histórico individual de uso.
- Diagnósticos, prontuários, conteúdos de comunicação, cartões utilizados, tarefas, registros ABC, fotos, vídeos ou documentos.
- Atividade individual ou relatório que permita reconhecer uma pessoa.

O painel pode precisar de uma conta administrativa para **você** poder entrar com segurança. Essa identidade é separada das contas de famílias ou usuários. Clarificação importante: sua exigência absoluta é não ver dados clínicos nem conteúdo sensível; isso não implica automaticamente proibir dados administrativos/comerciais de uma organização. Por segurança, a primeira versão ainda não terá telas para consultar contas individuais.

## Telas sugeridas para o primeiro protótipo

### 1. Visão geral

Quatro ou cinco números operacionais em agregado: versões publicadas; quantidade de licenças emitidas; lotes válidos; lotes vencendo; lotes revogados. Sem nomes de clientes, destinatários ou organizações. Até existir volume suficiente, ocultar também os totais que revelem grupos pequenos.

### 2. Planos e preços

- Editar um **rascunho**, comparar com a versão vigente e só aplicar após uma ação explícita de publicar.
- Guardar versões anteriores; novas mudanças entram em vigor para novas emissões, sem reescrever contratos/licenças já criados.
- Separar preço público, moeda, periodicidade e validade da oferta de qualquer referência comercial interna. Não publicar preço até você definir o que significa “valor interno” e os custos/preços terem sido avaliados.
- Mostrar sempre “**Sem cobrança nesta versão**”. O preço é informativo enquanto não houver implementação de pagamento aprovada.
- Publicar para o site apenas os campos comerciais que você aprovou. Não conectar publicação automática nem guardar token do GitHub no console.

### 3. Gerar lote de licenças

Assistente simples: escolher modalidade (**particular/família**, **clínica/escola** ou **patrocínio/empresa**), versão do plano, quantidade e validade; revisar resumo; então gerar. Não preencher nome de destinatário ou usuário/beneficiário. O nome da instituição/empresa é dado comercial, não clínico, e pode ser um campo opcional se for útil para administrar a venda corporativa; por enquanto, usar referência automática do lote.

Depois, o painel mostra somente o resultado agregado, como “20 códigos gerados; 20 disponíveis para entrega”. Os códigos são segredos de acesso, não nomes ou dados pessoais: devem ser aleatórios, não sequenciais e mostrados/baixados uma única vez. Não devem ir para logs, analytics, histórico visível, URL ou suporte. Se forem perdidos, o painel não os reexibe; o procedimento recomendado é revogar o lote e emitir outro.

### 4. Lotes e contagens

O painel pode exibir estado agregado por lote: quantidade emitida, válida, resgatada, expirada ou revogada. Não deve revelar quais códigos foram resgatados, em que conta/dispositivo ou por quem. Uma identificação comercial do lote (clínica/empresa) pode ser opcional, sem ligá-la a uma pessoa ou família. A revogação inicial pode atuar sobre **um lote inteiro**, com aviso do número de códigos afetados e confirmação explícita.

### 5. Histórico administrativo

Registrar apenas as ações de administração necessárias: quem (você), quando, ação (por exemplo, publicou versão ou revogou lote), versão/lote e motivo curto opcional. Nunca registrar código completo, destinatário, dados de cliente, conteúdo ou payload clínico. O histórico é para responsabilizar mudanças do console, não para acompanhar comportamento de usuário.

## Uma diferença importante sobre códigos de resgate

Para impedir o uso repetido de um código, o servidor precisa saber se ele já foi resgatado. É possível fazer isso **sem saber quem resgatou**: guardar hash/HMAC, estado e datas mínimas, sem nome, e-mail ou dado clínico. O painel só mostra totais. Ainda assim, isso é um registro técnico pseudônimo por código, não uma ficha de pessoa.

Se a licença remota for ligada a uma conta para habilitar recursos em vários dispositivos, algum serviço poderá precisar guardar essa relação mínima. O console pode ser projetado sem acesso a ela, mas não devemos prometer que o backend não a terá. Alternativa mais restrita: código local sem conta; perde-se confirmação central de resgate, revogação individual e sincronização. Essa escolha só será feita depois de você ver as diferenças.

Se a sua regra for **não permitir que exista nem esse registro técnico individual**, então não podemos garantir uso único, indicar quantos códigos foram resgatados, fazer revogação seletiva ou impedir compartilhamento. Nesse modelo, no máximo geramos códigos assinados e revogamos lotes inteiros por versão; a licença funciona localmente e não acompanha ativação. Nenhum sistema pode oferecer simultaneamente “sem estado individual algum” e “uso único/contagem individual confiável”.

**Padrão recomendado:** permitir ao servidor guardar apenas hash e estado do código, jamais a identidade ou conta da pessoa; restringir o console a números agregados. Isso atende ao objetivo de você não ver dados dos usuários, mas precisa da sua concordância quanto ao registro técnico por código.

## Dados mínimos previstos — se essa proposta for aprovada

| Registro | O que pode conter | O que não pode conter |
|---|---|---|
| Versão de plano | código/nome do plano, recursos, moeda, preço público opcional, periodicidade e vigência | Identidade ou atividade de clientes |
| Lote | identificador automático, categoria, plano/versão, quantidade, datas e estado agregado; opcionalmente nome comercial/contato institucional, se você aprovar | Destinatário, beneficiário, conta individual ou dado clínico |
| Estado de licença | HMAC/hash opaco, estado e datas mínimas, sem acesso pelo painel a detalhe individual | Código em claro, nome/e-mail, conta de cliente, dispositivo ou conteúdo sensível |
| Auditoria administrativa | identidade do proprietário, ação, data, versão/lote e motivo mínimo | Códigos, payloads, busca de usuário ou dados clínicos |

Não criar no console uma tela ou endpoint de busca/listagem de famílias, beneficiários, usuários finais, contas, conteúdo clínico ou licenças por pessoa. Se for útil para venda corporativa, uma tabela separada de organizações e contatos estritamente comerciais pode ser avaliada; não deve se relacionar a diagnósticos, perfis ou conteúdo das famílias.

## Controles técnicos previstos

- Autenticação forte para o Espaço do Criador e sem cadastro público. Isso protege o console; não cria nem gerencia contas de clientes.
- Permissões mínimas no servidor e RLS de negação por padrão. O site/browser não contém `service_role` nem segredo privilegiado.
- Serviço seguro gera e verifica códigos; aplicar uso único, rate limiting e proteção contra tentativa de adivinhar códigos. Guardar HMAC/hash com chave apenas no servidor.
- Console separado da área familiar e de qualquer futuro portal clínico/institucional. Não conceder ao console acesso SQL/API de usuários, conteúdo ou Storage.
- Relatórios posteriores, se aprovados: somente períodos amplos e agregados, com sugestão inicial de no mínimo 10 licenças por grupo e supressão de totais complementares. Mesmo esse limite não garante anonimato se filtros permitirem subtração; evitar filtros ad hoc e recortes por organização.
- Testar explicitamente que o console não consegue listar ou consultar usuários/clientes, nem mesmo com URL/endpoints alterados; testar acesso anônimo, sessão expirada e chave de cliente. Usar dados sintéticos.
- Manter o plano Essencial, comunicação offline, acessibilidade, controles parentais e dados locais mesmo que uma licença conectada expire ou seja revogada.

## Fora do primeiro MVP

Checkout, cartão, faturas, cobrança, gateway, renovação automática, conciliação, reembolso, cadastro/diretório de famílias, busca individual, suporte com acesso a contas ou conteúdo, uso individual, portal de clínica, compartilhamento clínico, prontuários, armazenamento remoto de mídia e piloto com dados reais. Um cadastro comercial de organização (empresa/clínica), sem dados das famílias, é uma decisão separada. Uma licença empresarial **não** autoriza acessar dados clínicos ou da família.

## Decisões que preciso confirmar com você

1. **Registro de resgate:** você aceita que o servidor guarde hash/estado técnico de cada código, sem identidade, e que você veja apenas contagens agregadas? **Minha recomendação: sim**, pois permite uso único e gestão básica sem revelar quem resgatou.
2. **Revogação:** podemos começar revogando lotes inteiros, não licenças individuais?
3. **Preços:** quando diz “alterar valores de planos”, você quer editar preço que o público verá, uma referência interna de custo/negociação, ou ambos em campos separados? (O catálogo atual não inclui pagamento real.)
4. **Entrega:** prefere baixar uma vez um arquivo de códigos para entregar à empresa/clínica ou distribuí-los por outro processo fora do sistema? O MVP não envia e-mail automaticamente.
5. **Organizações:** é útil identificar no painel o nome comercial de clínicas, escolas ou empresas para organizar contratos/lotes, desde que não apareçam dados de famílias?
6. **Dados administrativos de resgate:** se alguma função remota precisar vincular licença à conta, você prefere não ter esse recurso, ou aceita que o sistema guarde esse vínculo mínimo sem que o seu console permita consultá-lo?

## Etapas propostas

1. Aprovar ou ajustar as decisões acima. Nada muda no banco enquanto isso.
2. Fazer um protótipo estático somente visual, com exemplos inventados e avisos “sem pagamento/dados reais”, e te mostrar uma prévia antes de implementar login ou persistência.
3. Revisar a experiência e os controles com você; publicar o site público apenas se houver aprovação separada.
4. Só então escrever o esquema/RLS, mostrar exatamente o que será criado e testar em staging com dados sintéticos.
5. Não conectar conteúdo clínico ou dados reais das famílias. Qualquer relação mínima entre licença e conta, se necessária, só será desenhada após uma decisão específica e com o console impedido de consultá-la.

A implementação visual e os dados do protótipo não devem ser tratados como login funcional ou segurança validada.


## Prévia visual criada

O primeiro protótipo estático está em `site/console-preview.html`. A URL de prévia temporária é `https://4174-iqpj1o8qmwmk8nx17twm5-3af4165c.us1.manus.computer/console-preview.html`. A página usa valores DEMO inventados, não acessa Supabase, não usa login, não cria licenças, não envia códigos e não faz pagamentos. O botão apenas demonstra uma mensagem local. Foi verificada em larguras 1440, 768, 390, 360 e 320 px, sem rolagem horizontal ou erros JavaScript. Essa prévia não está publicada no site oficial e a URL temporária pode expirar.

Os dados comerciais de organizações (nome/contato de clínica, escola ou empresa) continuam uma decisão separada; a prévia atual omite esses campos. O veto absoluto confirmado pelo responsável é a exposição de dados clínicos e conteúdo sensível.
