# Netetive — Histórico de Versões

> Changelog rápido de consulta. Para detalhes técnicos completos (código, arquitetura, pendências), ver `netetive.md`, `netetive_status.md` e `netetive_scripts.md`.
>
> **Última atualização deste documento:** 26/08/2026
>
> ⚠️ **Nota sobre as datas:** as versões v0–v3 abaixo foram todas desenvolvidas na mesma sessão de trabalho documentada aqui — não tenho acesso ao histórico real de commits/datas do projeto pra saber em que dia cada versão foi de fato codificada. Deixei um campo `**Data:**` em cada versão pra você preencher manualmente (ex: puxando do `git log`, se o projeto estiver versionado, ou da sua própria memória de quando trabalhou em cada parte).

---

## v0 — Sistema original (post-it)

**Data:** _(preencher)_

Sistema inicial de tarefas, hoje totalmente substituído.

- `Lembrete` (post-it clicável) sorteava trabalho de `DadosJogo.banco_de_trabalhos` (na época, `Array[Dictionary]`).
- `GerenciadorTrabalho` (versão antiga) repassava pro `PainelTrabalho`, que tinha Aceitar/Ignorar.
- Inspeção usava 3 `ColorRect` fixos na cena (`Alvo1` suspeito, `Alvo2`/`Alvo3` neutros), detecção por `get_global_rect().has_point()`.
- Feedback de acerto/erro era **imediato** — sem diagnóstico, sem veredito diferido.

**Status:** ramo inteiro (`Lembrete` + `GerenciadorTrabalho` antigo + `TimerLembrete`) ainda existe fisicamente na árvore de `Tela.tscn`, solto e sem uso — ver "Achados de limpeza" no final deste documento.

---

## v1 — Sistema de expedição + alvos dinâmicos + diagnóstico na lista

**Data:** _(preencher)_

Primeira grande refatoração: trocou post-it por agenda do dia, e `ColorRect` fixos por `Area2D` dinâmicos.

**Arquitetura nova introduzida:**
- `GerenciadorExpediente` — relógio simulado (8h–17h), libera trabalhos da agenda (`DadosJogo.sortear_agenda_do_dia()`).
- `GerenciadorTrabalho` (novo) — menu com `VBoxDisponiveis`/`VBoxAtivos`, substitui `Lembrete`/`PainelTrabalho`.
- `CoordenadorTrabalho` — ponte entre `GerenciadorTrabalho` e `GerenciadorInspecao`.
- `AlvoInspecao`/`TrabalhoInspecao` (Resources) + `AreaAlvo` (`Area2D`) — substituem os `ColorRect` fixos. Alvos tinham `posicao`/`tamanho` livres em pixels.
- `banco_de_trabalhos` em `DadosJogo` migrou de `Array[Dictionary]` pra `Array[TrabalhoInspecao]`.

**Sistema de diagnóstico (design fechado nesta versão):**
- Diagnóstico por **múltipla escolha** (2–4 opções), não texto livre.
- UI: `PainelDiagnostico` (`Control` separado), acessado por um botão **"Diagnosticar" na lista de trabalhos ativos** — terceiro botão ao lado de "Título/Selecionar" e "Terminar trabalho".
- "Terminar trabalho" só habilitava depois de diagnosticar.
- Regra de acerto: achar o alvo suspeito **E** diagnosticar certo — os dois exigidos.
- Resultado (certo/errado) fica em `ResultadoTrabalho`, guardado em `DadosJogo.resultados_pendentes` até "Terminar trabalho", depois move pra `resultados_do_dia` — **revelado só no fim do expediente**, nunca durante o trabalho.

**Bugs corrigidos:**
- `Export type can only be built-in...` — `ResultadoTrabalho.agendado` não podia ter `@export` (`TrabalhoAgendado` é `RefCounted`).
- `Cannot find member "PAGINAS"` — `ConteudoLivro.PAGINAS` precisou virar `const` pra acesso estático.
- `Class "PainelDiagnostico" hides a global script class` — duas cópias do mesmo `class_name`, resolvido apagando a duplicata.
- `UNUSED_SIGNAL` — `GerenciadorInspecao.inspecao_concluida` era declarado mas nunca emitido.

---

## v2 — Diagnóstico movido pro popup de clique (design descontinuado)

**Data:** _(preencher)_

Tentativa intermediária: tirar o diagnóstico da lista de trabalhos e colocar dentro do popup de clique (`NovaAba`), mais perto fisicamente de onde o jogador acha o problema.

- `NovaAba` ganhou um segundo "modo": depois de achar o alvo certo, reabria mostrando só **Diagnosticar** e **Ignorar/Designorar** (escondendo o Inspecionar).
- **Descontinuado nesta mesma sessão:** essa regra travava o trabalho indefinidamente se o jogador nunca achasse o alvo certo (Diagnosticar só existia nesse segundo modo).

---

## v3 — Popup único + sistema de grid

**Data:** _(preencher)_

Resolve o travamento da v2 e troca o posicionamento de alvos inteiro.

**Popup unificado (`NovaAba`):**
- Os 4 botões — **Inspecionar, Diagnosticar, Ignorar/Designorar, Encerrar** — ficam sempre visíveis juntos no mesmo popup.
- **Diagnosticar** só fica desabilitado até **algum** alvo suspeito ser achado em **qualquer ponto** do trabalho (não precisa ser o ponto clicado agora) — nunca trava de vez.
- **Ignorar/Designorar** — marcação por quadrante, disponível mesmo sem inspecionar; não afeta o veredito.
- **Encerrar** substitui de vez o antigo "Terminar trabalho" da lista de trabalhos (que foi removido). Abre um `ConfirmationDialog` mostrando o diagnóstico atualmente escolhido (ou avisando que nenhum foi feito), e ao confirmar: fecha o trabalho, limpa a tela (alvos revelados + imagem do site) e mostra um toast "Trabalho encerrado." por 2s — sem revelar o resultado.
- `PainelDiagnostico` (da v1) foi **descontinuado**, sem uso.

**Sistema de grid (substitui posição/tamanho livre):**
- `AlvoInspecao.posicao`/`tamanho` **removidos** → viraram `quadrante: int` (índice `linha*3 + coluna`) + `altura_real: float`.
- Grade fixa de **3 colunas × N linhas** (5 por padrão, via `TrabalhoInspecao.linhas_grid`). Largura sempre 1/3 fixo; altura por linha com **compensação adaptativa** (linhas sem alvo forçado dividem o espaço restante).
- Quadrantes sem `AlvoInspecao` explícito viram `NEUTRO` automático — os 15 quadrantes são todos clicáveis.
- Novo `@export var area_referencia: Control` em `GerenciadorInspecao`, apontando pro `TextureRect` `ImagemBase` (define o retângulo real que a grade cobre).

**Módulo de dados separado:**
- `banco_de_trabalhos.gd` (novo, `class_name BancoDeTrabalhos`, `static func`) — extraído de `DadosJogo.gd`. `DadosJogo` ficou só com estado em runtime.
- **4 dos 5 trabalhos removidos temporariamente** (Limpeza de Disco, Otimizar Inicialização, Atualizar Drivers, Substituir Pasta Térmica) — usavam o sistema antigo de posição livre e não têm arte de site calibrada pro grid ainda. Só "Remover Cavalo de Tróia" está migrado (com `quadrante`/`altura_real` ainda em recalibração).

**Bugs corrigidos:**
- Clique bloqueado no alvo revelado — `ColorRect` de feedback nascia com `mouse_filter` padrão (`STOP`); corrigido com `MOUSE_FILTER_IGNORE`.
- Quadrado revelado + imagem do site antiga persistindo após "Encerrar" — `_on_confirmar_encerramento()` não limpava nada; corrigido com `limpar_alvos()` + `site_textura.texture = null`.
- `Cannot infer the type of "linha"` + `INTEGER_DIVISION` — `mapa_alvos` (Dictionary sem tipo) devolvia `Variant` nas chaves; corrigido com cast explícito pra `int` + `@warning_ignore`.

---

## v3.1 — Botão Investigar + correção de origem do grid (atual)

**Data:** 11/08/2026

Refinamento sobre a v3, sem mudar a arquitetura de base — adiciona uma nova ferramenta de ajuda ao jogador e corrige um bug de alinhamento visual do grid que só apareceu ao testar com a arte real do site.

**Botão Investigar (5º botão da `NovaAba`):**
- Disponível a qualquer momento, em qualquer quadrante clicado, independente de já ter sido inspecionado.
- 3 respostas possíveis, dependendo do estado do quadrante: *"Preciso investigar."* (não inspecionado), *"Nada de interessante nesta parte."* (neutro já checado), ou o texto de `AlvoInspecao.dica` (suspeito já encontrado).
- Consome um limite de **1 uso por trabalho** — mas só quando revela uma dica real (o 3º caso); os outros dois são "grátis", por não entregarem informação nenhuma.
- Limite persistido em `TrabalhoAgendado.investigar_usado` (não no `AreaAlvo`, que é recriado a cada troca de trabalho ativo).
- Resposta exibida via `MensagemModal.mostrar_texto()` (novo método, instantâneo — sem a etapa "Verificando...").

**Novo campo em `AlvoInspecao`:**
- `dica: String` — texto curto, próprio de cada alvo suspeito, mostrado pelo Investigar. Independente do conteúdo do `LivroDicas`/`ConteudoLivro` (uma versão intermediária cogitou puxar a dica do campo `descricao` do capítulo relacionado, mas foi descartada em favor de um texto específico do contexto do site).

**Bug corrigido:**
- **Grid não seguia a posição real de `ImagemBase`** — `montar_alvos()` calculava todos os quadrantes a partir de `(0, 0)`, ignorando a `Position` real do `TextureRect` na cena (`-385, -286` no caso observado, já que `ImagemBase` não nascia na origem do mundo). Como `Stretch Mode` já estava correto (`Scale`) e o `Size` também batia, a causa real era só a origem do cálculo. Corrigido somando `area_referencia.global_position` a cada posição de quadrante calculada.

---

## v3.5 — HUD de Dinheiro/Fama + Trabalhos de Scareware e Ransomware (atual)

**Data:** 26/08/2026

Traz duas features desenvolvidas em branches paralelas (`score_system` e `trabalho_malware`) pra dentro da `Sistema-upgrade`, adaptadas à arquitetura atual em vez de mescladas diretamente — as duas branches partiram de um ponto bem anterior do projeto (antes do grid, do Investigar e dos upgrades) e não dava pra fazer merge direto sem reescrever boa parte dos arquivos.

**HUD de Dinheiro/Fama (portado de `score_system`, adaptado):**
- `hud_manager.gd` e `icone_dinheiro.gd` trazidos da branch `score_system`, mas reescritos pra ler `DadosJogo.dinheiro_jogador`/`DadosJogo.fama_jogador` em vez do autoload `Global` (`money`/`fame`) que a branch original criava.
- **`Global` (autoload) descartado por completo** — não foi adicionado ao `project.godot`. O papel dele já é coberto por `DadosJogo`, que é autoload único do projeto; ter os dois ao mesmo tempo duplicaria o estado de dinheiro/fama.
- Como `DadosJogo` não emite nenhum sinal quando `dinheiro_jogador`/`fama_jogador` mudam (diferente do `Global`, que tinha `altered_money`/`fame_received`), o HUD passou a fazer **polling em `_process()`**, comparando o valor atual com o último valor visto e só atualizando o texto/ícone quando muda.
- **Efeito colateral esperado, não é bug:** como o crédito de dinheiro/fama só acontece uma vez, dentro de `RelatorioDia.montar_relatorio()` no fim do expediente, o HUD fica parado o dia inteiro e só salta pro valor final quando o relatório é gerado — não é mais "ao vivo" a cada trabalho concluído, como era na `score_system`. Isso é intencional (mantém o veredito escondido até o fim do dia).
- Cena `Scores.tscn` reaproveitada como instância dentro de `Escritorio.tscn` (nó `Score`), com `Editable Children` habilitado pra ajustes internos.

**Bug corrigido durante a integração do HUD:**
- `Node not found` nos dois `@onready` de `hud_manager.gd` — o caminho relativo original (`$control/container/container_dinheiro/...`) não batia com a estrutura real da cena copiada manualmente, que não tinha o nível `container` (`MarginContainer`) intermediário. Corrigido ajustando o caminho pra `$control/container_dinheiro/...`. Ver "Achados de limpeza técnica" abaixo pra recomendação de longo prazo.

**Dois trabalhos novos em `banco_de_trabalhos.gd` (recriados a partir da ideia da `trabalho_malware`, no formato de grid atual):**
- **"Identificar Scareware"** — imagem de uma falsa tela de "vírus detectado" com botão de download disfarçado de "Safe Browser". `capitulo_relacionado` aponta pro novo capítulo "Scareware" (ver abaixo). Substitui o antigo trabalho "Remover ransomware" da branch `trabalho_malware`, que na verdade retratava scareware (isca), não ransomware em si — ver discussão de design abaixo.
- **"Remover Ransomware"** — imagem nova, redesenhada durante esta rodada pra retratar ransomware de verdade (lista de arquivos criptografados, valor de resgate em Bitcoin, endereço de carteira, instruções de pagamento), diferente da primeira imagem que era só a isca. `capitulo_relacionado` aponta pro capítulo "Ransomware" já existente (índice 3), que agora bate literalmente com o conteúdo.
- Os dois usam `quadrante`/`altura_real` como **estimativa inicial**, calculados a partir de proporção da imagem original (fração da largura/altura, não pixels absolutos) — ainda não calibrados em jogo com o processo padrão (`print()` temporário em `montar_alvos()`).
- **Nenhuma das duas reaproveitou a cena solta `Tela_baixar_ransomware.tscn`** da branch `trabalho_malware` — ela tinha os `@export` do `CoordenadorTrabalho` vazios e usava a arquitetura antiga; só o asset de imagem foi aproveitado, o trabalho em si foi recriado do zero como dado em `banco_de_trabalhos.gd`.

**Decisão de design — por que dois trabalhos, não um:**
- A imagem original da `trabalho_malware` (scareware disfarçado de alerta de vírus) e uma nota de resgate de ransomware de verdade são duas etapas diferentes do mesmo golpe — a isca e a consequência. Em vez de forçar as duas num único trabalho ambíguo, viraram dois trabalhos separados, com dois capítulos de diagnóstico diferentes.
- **Capítulo "Senha Fraca" removido do livro, substituído por "Scareware"** — ver `ConteudoLivro.PAGINAS`, índice `5`. Conteúdo antigo de Senha Fraca ainda não tem novo destino definido (candidato a virar um 11º capítulo futuro, se quiser recuperar o conteúdo em vez de descartar).

**Bugs de conteúdo herdados da `trabalho_malware`, evitados nesta integração:**
- A função de trabalho antiga (`_criar_trabalho_remover_ransomware()`) existia no código-fonte da branch mas **nunca tinha sido incluída** no array retornado por `_ready()` — o trabalho nunca era de fato sorteado no jogo. Confirmado que as duas funções novas (`_criar_trabalho_scareware()`/`_criar_trabalho_ransomware()`) estão de fato dentro do array de `criar_todos()` desta vez.

---

## v3.4 — Sistema de Fama

**Data:** 14/08/2026

Fecha o sistema de trabalho ligando a quantidade de trabalhos do dia à progressão do jogador. Fama é um recurso permanente novo, paralelo ao dinheiro — não é gasto em nada, só cresce, e controla quantos trabalhos aparecem por dia.

**Design fechado com o usuário:**
- Base mínima: **6 trabalhos/dia** com 0 de fama.
- Quanto mais fama, mais trabalhos aparecem — mas **não linearmente**: crescimento rápido com pouca fama, cada vez mais lento conforme a fama sobe (retornos decrescentes).
- Curva escolhida: raiz quadrada (`base + floor(sqrt(fama) * fator)`) — essa forma já entrega o comportamento pedido sozinha, sem nenhuma lógica condicional extra (a derivada de `sqrt(x)` cai naturalmente conforme `x` cresce).

**Arquivo novo:**
- `calculadora_fama.gd` (`class_name CalculadoraFama`, `extends RefCounted`, `static func`, sem nó) — só a fórmula. `calcular_quantidade_trabalhos_dia(fama, base)`, com `TRABALHOS_BASE_PADRAO := 6` e `FATOR_CRESCIMENTO := 1.0` como constantes ajustáveis pra calibrar a curva sem mexer em mais nada.

**Arquivos modificados:**
- `DadosJogo.gd` — novo `var fama_jogador: int = 0`, ao lado de `dinheiro_jogador`.
- `resultado_trabalho.gd` — novo campo `fama_ganha: int = 0`, calculado dentro de `finalizar()` junto com `recompensa` (`fama_ganha = agendado.trabalho.recompensa_fama if acertou_no_geral else 0`). Como `finalizar()` já é chamado por todo caminho que usa `DadosJogo.finalizar_trabalho()` (jogador manual, Assistente), esses dois ganham fama automaticamente sem nenhuma mudança adicional.
- `gerenciador_expediente.gd` — `@export var quantidade_trabalhos_dia` renomeado pra `trabalhos_base_dia` (valor mínimo/base, não mais o total fixo). `iniciar_expediente()` agora calcula a quantidade real do dia via `CalculadoraFama.calcular_quantidade_trabalhos_dia(DadosJogo.fama_jogador, trabalhos_base_dia)` antes de chamar `DadosJogo.sortear_agenda_do_dia()`. Print de log também passou a mostrar quantidade do dia e fama atual.
- `gerenciador_ia_noturna.gd` — `_resolver_trabalho()` agora também define `resultado.fama_ganha`, aplicando a mesma % de Eficiência que já reduz o dinheiro (trabalho malfeito rende menos reputação também, não só menos grana).
- `relatorio_dia.gd` — reestruturado com 3 labels em vez de 1: `LabelResumo` (texto fixo "Dia concluído"), `LabelDinheiro` (só o valor ganho no dia, `"R$ %d"`), `LabelFama` (só o valor ganho no dia, `"+%d fama"`). O cálculo interno (soma de `resultado.fama_ganha`, crédito em `DadosJogo.fama_jogador`) continua igual — fama não tem upkeep, só dinheiro é descontado pela manutenção. `ScrollContainer`/`VBoxResultados` e `BtnVoltar` não mudaram.

**Bug corrigido durante a integração:**
- `calculadora_fama.gd` — warning tratado como erro (`The variable type is being inferred from a Variant value`) numa linha com `max(0, fama)`; o `max()` built-in do GDScript pode devolver `Variant` dependendo dos tipos dos argumentos. Corrigido tipando explicitamente os operandos/variável.

---

## v3.3 — Sistema de Upgrades: PC, Assistente e IA

**Data:** 13/08/2026

Primeira versão do sistema de upgrades, acessível só no Escritório. Design fechado com o usuário ao longo de várias rodadas — a versão final tem **5 linhas** em 3 categorias, cada linha com **4 tiers sequenciais**:

| Categoria | Linha | Efeito por tier | Upkeep/dia |
|---|---|---|---|
| PC | única | reduz o tempo do popup de verificação (4s → 3s → 2s → 1s → **instantâneo**) | não |
| Assistente | Quantidade | **linha de entrada** (sem pré-requisito) — nº de assistentes simultâneos (1→2→3→4→5) | não |
| Assistente | Treinamento | 🔒 bloqueada até Quantidade tier 1 — tempo por trabalho (120→105→90→75 min) e taxa de sucesso (70%→80%→90%→100%) | sim, upkeep base × nº de assistentes |
| IA | Capacidade | linha de entrada — nº de trabalhos processados por noite (1→2→3→4) | sim, fixo por tier |
| IA | Eficiência | 🔒 bloqueada até Capacidade tier 1 — % da recompensa entregue (35%→50%→65%→80%→95%) | sim, fixo por tier |

Taxa de sucesso da IA fixa em 75% (não sobe por tier — só Eficiência muda o quanto ela entrega).

**Arquivos novos:**
- `tier_upgrade.gd` (`Resource`) — um degrau (preço/efeito/upkeep), dumb data.
- `linha_upgrade.gd` (`Resource`) — progressão + `tier_atual` do jogador; helpers `valor_efeito_atual()`, `proximo_tier()`, `upkeep_atual()`.
- `banco_de_upgrades.gd` (`static func`, mesmo padrão de `BancoDeTrabalhos`) — os 5 `LinhaUpgrade` com valores fechados.
- `gerenciador_assistente.gd` (`Node`, novo filho de `ModuloTrabalho`) — fila de trabalhos delegados, com tempo simulado por trabalho e resolução automática por taxa de sucesso.
- `gerenciador_ia_noturna.gd` (`static func`, sem nó) — varre `trabalhos_do_dia` por agendados sobrados (nunca aceitos ou abandonados) ao encerrar o expediente, resolve cada um com taxa fixa de 75% e aplica a % de Eficiência sobre a recompensa.
- `calculadora_upkeep.gd` (`static func`, sem nó) — soma o upkeep diário de Assistente (Treinamento × Quantidade) + IA (Capacidade + Eficiência).
- `painel_upgrades.gd` (`Panel`, novo em `Escritorio.tscn`) — desenha as 5 linhas dinamicamente, delega compra pra `DadosJogo.comprar_upgrade()`.
- `btn_upgrades.gd` (`TextureButton`, novo em `Escritorio.tscn`) — abre o `PainelUpgrades`.

**Arquivos modificados:**
- `DadosJogo.gd` — novo `var upgrades: Dictionary` (populado por `BancoDeUpgrades.criar_todas()` no `_ready()`) + `comprar_upgrade(chave)` (única porta de entrada pra avançar um tier: valida existência, tier máximo, pré-requisito e saldo, nessa ordem, antes de debitar).
- `gerenciador_trabalho.gd` — cada item de `VBoxAtivos` ganhou um segundo botão **Delegar**, ao lado do título; só emite `delegar_solicitado(agendado)`, não conhece `GerenciadorAssistente`.
- `coordenador_trabalho.gd` — novo `@export var gerenciador_assistente`; escuta `delegar_solicitado` (chama `gerenciador_assistente.delegar()`) e `trabalho_assistente_concluido` (remove da lista + toast próprio, "Assistente: ... concluído").
- `Main_select_script.gd` — `_on_expediente_encerrado()` chama `GerenciadorIANoturna.processar_noite()` antes de trocar pra `RelatorioDia.tscn`.
- `relatorio_dia.gd` — desconta `CalculadoraUpkeep.calcular_total()` do saldo do dia, podendo deixar `dinheiro_jogador` negativo de propósito (dívida realista); resumo mostra ganhos, manutenção e saldo final separados.
- `mensagem_modal_scpt.gd` — `mostrar()` lê `DadosJogo.obter_linha_upgrade(CHAVE_PC).valor_efeito_atual(4.0)` em vez do `create_timer(2.0)` fixo × 2; novo `tempo_total_atual()` público, pra sincronizar com `gerenciador_inspecao.gd`.
- `gerenciador_inspecao.gd` — `_on_botao_inspecionar_pressed()` troca o `await create_timer(4.0)` fixo por `_tempo_verificacao_atual()`, que lê o mesmo valor de `mensagem_modal.tempo_total_atual()` — revelação do quadrante e fechamento do popup ficam sincronizados, incluindo o caso instantâneo (tier 4 do PC).

**Decisão de design revisada em runtime:** a relação de pré-requisito entre Assistente — Quantidade e Assistente — Treinamento foi **invertida** depois do design inicial. Fechado primeiro como "Quantidade bloqueada até Treinamento tier 1"; testado em jogo e trocado pelo usuário pra "Treinamento bloqueado até Quantidade tier 1" (Quantidade virou a linha de entrada). Mudança de dado pura em `banco_de_upgrades.gd` — como `chave_pre_requisito` é lido genericamente por `DadosJogo.comprar_upgrade()` e `painel_upgrades.gd`, nenhum outro arquivo precisou mudar.

**Bugs corrigidos durante a integração:**
- **Sinal `pressed()` do `BtnUpgrades` conectado ao nó errado** — ao conectar pelo editor, a seleção de nó-alvo ficou em `../Quadro_avisos` em vez do próprio `BtnUpgrades`, então o clique não executava nada (nenhum erro, só nenhuma ação). Corrigido reconectando ao próprio nó.
- **`CoordenadorTrabalho` fora de `ModuloTrabalho`** — acabou como filho direto da raiz da cena em vez de dentro de `ModuloTrabalho`, junto dos outros três gerenciadores. Não quebrava os `@export` (Godot permite arrastar qualquer nó da cena, não só irmãos), mas quebrava a organização documentada; movido pra dentro de `ModuloTrabalho`.
- **`GerenciadorAssistente` sem `gerenciador_expediente` atribuído** — warning no `_ready()`; corrigido arrastando o nó `GerenciadorExpediente` (irmão) pro campo `@export` no Inspetor.
- **`PainelUpgrades` não abria (tamanho 0x0)** — o `Panel` nasceu sem `Size` definido na viewport, então `show()` rodava sem erro mas nada aparecia na tela. Corrigido redimensionando o `Panel` e os containers internos (`ScrollContainer`) na viewport do editor.
- **Tempo do popup de verificação não mudava com o upgrade do PC** — o efeito do PC foi desenhado no início da sessão, mas a implementação em `mensagem_modal_scpt.gd` só veio bem mais tarde; até lá, o popup ficava fixo em 4s independente do tier comprado. Corrigido lendo `LinhaUpgrade.valor_efeito_atual()` em vez do `create_timer(2.0)` fixo.
- **Cor do quadrante revelado ainda demorava 4s mesmo com o popup mais rápido** — `gerenciador_inspecao.gd` tinha seu próprio `await create_timer(4.0)`, independente do timer interno do `MensagemModal`; a correção anterior só tinha mexido no modal. Corrigido lendo o mesmo `tempo_total_atual()` exposto publicamente pelo `MensagemModal`, sincronizando os dois.

---

## v3.2 — Ciclo do Dia: Iniciar Dia + Relatório de Fim de Expediente

**Data:** 12/08/2026

Fecha o loop de gameplay de ponta a ponta: agora existe um caminho completo `Escritório → expediente → relatório → Escritório`, com dados suficientes acumulados por trabalho pra montar um resumo detalhado do dia.

**Correção do "clique duplo" pra entrar no trabalho:**
- Bug: aceitar um trabalho em Disponíveis só criava o item em Ativos — era preciso clicar de novo no item ativo pra `trabalho_selecionado` ser emitido e a inspeção abrir de fato.
- Corrigido em `gerenciador_trabalho.gd`: `_on_disponivel_pressionado()` agora emite `trabalho_selecionado.emit(agendado)` diretamente ao aceitar, eliminando o clique extra.
- Como consequência, a chamada de `DadosJogo.iniciar_resultado_pendente()` foi **removida** de `gerenciador_trabalho.gd` — ela migrou pra dentro de `coordenador_trabalho.gd._on_trabalho_selecionado()`, que é onde faz mais sentido abrir o resultado pendente já com `hora_inicio` marcada (ver abaixo). Evita duplicidade: `gerenciador_trabalho.gd` não sabe mais nada sobre `ResultadoTrabalho`.

**`ResultadoTrabalho` — campos novos pro relatório detalhado:**
- `tentativas_certas: int` / `tentativas_erradas: int` — conta toda inspeção feita no trabalho, não só a que acertou o alvo suspeito.
- `hora_inicio: float` / `hora_fim: float` — hora do relógio simulado (`GerenciadorExpediente.hora_atual`) no momento em que o trabalho foi selecionado e no momento em que foi encerrado.
- Novo método `registrar_tentativa(acertou: bool)` e `tempo_gasto_minutos()` (calcula `(hora_fim - hora_inicio) * 60`, com `max(0.0, ...)` de proteção).

**`DadosJogo.gd` — assinaturas ajustadas + método novo:**
- `iniciar_resultado_pendente(agendado, hora_atual: float = 0.0)` — parâmetro novo, grava `resultado.hora_inicio`.
- `finalizar_trabalho(agendado, hora_atual: float = 0.0)` — parâmetro novo, grava `resultado.hora_fim` antes de chamar `resultado.finalizar()`.
- Novo `registrar_tentativa_inspecao(agendado, acertou: bool)` — repassa pro `ResultadoTrabalho.registrar_tentativa()` correspondente, se houver resultado pendente pra esse agendado.

**`coordenador_trabalho.gd` — integração com o relógio:**
- Novo `@export var gerenciador_expediente: Node` — precisa ser atribuído no Inspetor do nó `CoordenadorTrabalho` (mesmo padrão dos outros `@export`).
- Novo `_hora_atual()` — lê `gerenciador_expediente.hora_atual` com segurança (`"hora_atual" in gerenciador_expediente`); retorna `0.0` e avisa uma vez no `_ready()` se não atribuído.
- `_on_trabalho_selecionado()` agora chama `DadosJogo.iniciar_resultado_pendente(agendado, _hora_atual())` — com uma guarda (`if DadosJogo.resultados_pendentes.has(agendado): return`) pra não recriar o resultado se o jogador reentra no mesmo trabalho ativo mais de uma vez.
- `_on_inspecao_concluida()` agora chama `DadosJogo.registrar_tentativa_inspecao(_agendado_atual, acertou)` **antes** de checar se acertou — toda tentativa conta pro relatório, certa ou errada.
- `_on_confirmar_encerramento()` agora passa `_hora_atual()` pra `DadosJogo.finalizar_trabalho()`, fechando `hora_fim`.

**`RelatorioDia` — cena e script novos:**
- `relatorio_dia.gd` (`class_name RelatorioDia`, `extends Control`) — itera `DadosJogo.resultados_do_dia`, monta uma linha por trabalho (veredito ✅/❌, alvo encontrado, diagnóstico escolhido + se estava correto, tentativas certas/erradas, tempo gasto, recompensa) dentro de um `VBoxContainer` rolável.
- **Dinheiro é creditado aqui**, não durante o expediente: `DadosJogo.dinheiro_jogador += total_dinheiro` roda dentro de `montar_relatorio()`, mantendo o veredito escondido até o fim do dia (decisão de design já prevista desde a v1, agora resolvida).
- Estrutura de cena exigida (`res://Scenes/RelatorioDia.tscn`, raiz `Control`):
  ```
  RelatorioDia (Control)
  ├── LabelResumo (Label)
  ├── ScrollContainer (ScrollContainer)
  │   └── VBoxResultados (VBoxContainer)
  └── BtnVoltar (Button)
  ```
- Nós lidos via `get_node_or_null()` (não `$caminho` direto) — se algum nó estiver com nome/caminho errado na cena, o script avisa qual falta (`push_warning`) em vez de travar o jogo inteiro com um erro fatal de `Node not found`.

**`Main_select_script.gd` — dispara o relatório ao fim do expediente:**
- `_ready()` conecta `gerenciador_expediente.expediente_encerrado` a um novo `_on_expediente_encerrado()`, que troca de cena pra `RelatorioDia.tscn`.

**Botão "Iniciar Dia" no Escritório:**
- Reaproveitado o `Iniciar.gd` já existente (`res://Scenes/Escritorio.tscn`), sem mudanças — ele já trocava a cena pra `Tela.tscn`, e `Main_select_script._ready()` já chamava `gerenciador_expediente.iniciar_expediente()` a cada carregamento da cena, que por sua vez já chamava `DadosJogo.sortear_agenda_do_dia()` (resetando `trabalhos_do_dia`/`trabalhos_concluidos_hoje` automaticamente). Não foi necessário criar um botão novo.

**Bugs corrigidos durante a integração:**
- `Node not found: "ScrollContainer/VBoxResultados"` — `relatorio_dia.gd` foi inicialmente anexado a um nó dentro da árvore de `Tela.tscn` (raiz `Node2D`) em vez de numa cena própria com raiz `Control`. Corrigido criando `RelatorioDia.tscn` como cena separada, com a hierarquia de nós documentada acima.
- `Cannot open file 'res://Scenes/RelatorioDia.tscn'` — a cena ainda não tinha sido salva nesse caminho exato (nome/pasta divergente) quando `Main_select_script._on_expediente_encerrado()` tentou carregá-la. Corrigido salvando a cena no caminho correto; ver `netetive_status.md` para a recomendação de usar `@export var cena_relatorio: PackedScene` em vez de string de caminho, evitando esse tipo de erro no futuro.

**Duração real do dia (referência):** com `GerenciadorExpediente.minutos_por_segundo_real = 4.0` (padrão) e expediente de `8h` a `17h` (9 horas simuladas), um dia completo dura **~2 minutos e 15 segundos em tempo real**. Ajustável no Inspetor sem mexer em código.

---

## Achados de limpeza técnica (não são bugs de versão, são dívida acumulada)

- **Ramo legado duplicado na árvore de `Tela.tscn`** — `Lembrete` + `GerenciadorTrabalho` (script antigo, `res://Scripts/Tela/gerenciador_trabalho.gd`) + `TimerLembrete`, soltos no nível raiz, paralelos ao `ModuloTrabalho` real. Confirmado que são dois arquivos `.gd` fisicamente diferentes com o mesmo nome curto. Recomendação: apagar o ramo inteiro.
- **`caixa_selecao.gd`** (minúsculo) — confirmado órfão, não anexado a nenhum nó. Nome quase idêntico a `CaixaDeSelecao.gd` (o real, vazio de propósito).
- **`menu_trabalhos.gd`** — suspeita não confirmada de ser um sistema paralelo/órfão; referencia campos de `DadosJogo` que não existem (`trabalhos_disponiveis`, `trabalhos_ativos`, `trabalho_atual`).
- **`painel_diagnostico.gd`** — órfão desde a v2/v3, candidato a remoção.
- **`button-inspecionar.gd`, `lembrete.gd`, `painel_trabalho.gd`, `mensagem_modal.gd`** — legado do sistema v0, candidatos a remoção.
- **`Para_inicial.gd`** — aponta pra `res://Scenes/inicio.tscn`, inconsistente com `res://Scenes/Escritorio.tscn` usado no resto do projeto.

---

## Próxima versão (planejada, não implementada)

- Tela de resumo de fim de expediente, iterando `DadosJogo.resultados_do_dia`.
- Definir onde `dinheiro_jogador` é creditado (hoje nenhum crédito acontece durante o expediente, de propósito).
- Recriar os 4 trabalhos removidos, calibrados pro grid (incluindo `dica`), conforme a arte de cada site ficar pronta.
- Suporte a múltiplos alvos suspeitos por trabalho (hoje `titulo_capitulo_correto()`/`gerar_opcoes_diagnostico()` assumem só 1 — e cada alvo precisaria da sua própria `dica`).
- Persistir `foi_encontrado`/`ignorado`/`ja_inspecionado_negativo` por quadrante em `TrabalhoAgendado` (hoje vivem no `AreaAlvo`, que é recriado a cada troca de trabalho ativo, perdendo esse progresso).
