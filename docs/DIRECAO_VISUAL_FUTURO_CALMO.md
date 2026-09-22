# Fala Comigo — Direção visual: futuro calmo

## Decisão

A identidade visual do Fala Comigo adotará um **futurismo calmo, humano e acessível**. O resultado deve parecer atual e tecnológico sem usar estética cyberpunk agressiva, excesso de neon, movimento permanente, menus experimentais ou efeitos que dificultem a compreensão.

A linguagem visual será compartilhada pelo site institucional, Flutter Web, Área do Responsável e futuro portal institucional. A tela de comunicação da criança terá a mesma base cromática, mas preservará simplicidade, alvos grandes e baixo estímulo visual.

## O que a pesquisa indicou

As referências atuais destacam profundidade, gradientes, elementos imersivos e navegação experimental como tendências de 2026. A mesma referência recomenda que acessibilidade, navegação compreensível, suporte a leitor de tela, teclado, voz e redução de excesso visual sejam tratados como padrão, não como acabamento [1].

O Material 3 recomenda esquemas tonais com papéis explícitos de cor, contraste controlado e suporte a tema claro/escuro; no Android 12 ou superior, cores dinâmicas podem partir do papel de parede, mas a interface precisa manter fallback de alto contraste [2]. As orientações da Apple reforçam que uma interface acessível deve ser intuitiva, perceptível por mais de um sentido e adaptável a preferências de tamanho, contraste e movimento. Também recomendam evitar movimento rápido, flashes, autoplay e elementos que desaparecem antes de a pessoa conseguir processá-los [3].

## Sistema visual escolhido

| Elemento | Decisão |
| --- | --- |
| Base | Azul-noite e superfícies azul-acinzentadas, com versão clara para leitura prolongada |
| Acentos | Ciano suave para ação, lilás para organização e coral para atenção; nunca depender somente da cor |
| Profundidade | Gradientes discretos, bordas translúcidas e sombras suaves; sem blur pesado em conteúdo funcional |
| Composição | Cartões modulares, blocos assimétricos leves e bastante espaço de respiro |
| Tipografia | Sans-serif limpa, títulos fortes, corpo confortável e suporte a aumento de texto |
| Navegação | Barra e seções familiares; experimentalidade apenas em decoração, nunca em ações essenciais |
| Movimento | Entrada curta com `ease-out`, resposta de toque entre 100–160 ms e respeito a `prefers-reduced-motion` |
| Mídia | Sem autoplay, sem flashes e com controles explícitos |
| Acessibilidade | Foco visível, contraste AA, semântica, teclado, leitor de tela, alvos grandes e informação redundante além da cor |

## Site institucional

O site usará um herói com fundo azul-noite, uma malha gráfica discreta e um conjunto de cartões luminosos que representam comunicação. As seções de instituições usarão cartões com acentos suaves. A navegação continuará textual e direta, com links para famílias, privacidade, instituições, planos, FAQ e contato.

O efeito futurista deve apoiar a narrativa: o visitante percebe uma plataforma contemporânea, mas entende rapidamente o que é o produto, para quem serve e quais são seus limites. Não serão usados menus escondidos ou rolagem obrigatória para descobrir informações essenciais.

## Aplicativo e Flutter Web

O aplicativo manterá a comunicação como prioridade visual. A grade continuará com cartões claros, alvos amplos e vocabulário visível. O futurismo aparecerá principalmente em:

- tema profissional da Área do Responsável;
- superfícies com profundidade e contraste;
- estados de seleção e foco;
- visualizações de evolução;
- telas de plano e portal;
- transições curtas e opcionais.

A tela infantil não terá animações contínuas nem fundos carregados. O responsável poderá preferir tema claro, tema escuro ou alto contraste quando essa configuração estiver disponível. O Flutter Web seguirá os mesmos tokens de cor e espaçamento, sem depender de `dart:io` ou de mídia externa.

## Regras que não serão sacrificadas

A estética não poderá:

- reduzir contraste para parecer futurista;
- esconder a navegação em gestos desconhecidos;
- exigir animação para entender o estado;
- usar flashing ou parallax obrigatório;
- tocar áudio ou vídeo sem ação explícita;
- substituir texto por ícones ambíguos;
- expor dados clínicos para criar uma demonstração visual;
- bloquear o modo offline ou a comunicação básica.

## Implementação incremental

1. Aplicar os tokens compartilhados no site institucional.
2. Ajustar a identidade do tema Flutter e da Área do Responsável.
3. Revisar a grade infantil sem aumentar estímulo ou reduzir alvos.
4. Criar componentes de painel, status e gráficos para portal.
5. Validar contraste, TalkBack, teclado, escala de texto e redução de movimento.
6. Fazer revisão visual com o colégio, a clínica e responsáveis antes do piloto.

## Referências

[1]: https://www.figma.com/resource-library/web-design-trends/ "Top Web design trends for 2026 — Figma"
[2]: https://developer.android.com/develop/ui/compose/designsystems/material3 "Material 3 design systems and accessibility — Android Developers"
[3]: https://developer.apple.com/design/human-interface-guidelines/accessibility "Accessibility — Apple Human Interface Guidelines"
