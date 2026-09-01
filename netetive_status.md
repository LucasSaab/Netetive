# Netetive — Status do Projeto

> Documento de acompanhamento detalhado: o que já foi feito e o que ainda falta implementar, com base no `netetive.md` e no desenvolvimento em andamento.
>
> **Última atualização deste documento:** 26/08/2026

---

## ✅ Feito

### 1. Escritório

- **Fundo visual (pixel art)** — `Sprite2D > TextureRect` exibe o cenário do escritório (mesa, computador, janela com vista da cidade). É puramente visual, sem lógica de script associada.
- **`Quadro_avisos` (TextureButton)** — botão representado pelo quadro de cortiça na parede. Ao ser clicado, executa `get_tree().change_scene_to_file("res://Scenes/Quadro.tscn")`, levando o jogador para o loop de gameplay. É o único ponto de entrada documentado para sair do Escritório.
- **Cafeteira com Label "Comece o dia!"** — elemento decorativo no canto esquerdo da tela com um `Label` filho fixo, funcionando como dica visual estática para o jogador começar a jogar.
- **`Iniciar.gd`** — script separado (também `extends TextureButton`) que troca a cena para `res://Scenes/Tela.tscn`. Ainda não está claro no código se está vinculado à Cafeteira ou a outro botão de início; é um ponto de ambiguidade a resolver (ver seção de limpeza técnica).

### 2. Quadro de Avisos

- **Fundo visual** — `Sprite2D > TextureRect` mostra a imagem do quadro de cortiça com o papel "Política de qualidade" fixado, sem lógica própria.
- **`TB_Tutorial_1` abre `Layer_Tutorial_1`** — botão sobreposto ao papel fixado no quadro. Ao pressionar, chama `layer_tutorial.show()`. O `CanvasLayer` começa oculto (`hide()` no `_ready()` do script geral da cena, `Script_geral_quadro.gd`).
- **Atalho de teclado (Espaço)** — o script geral escuta `_input()` e, ao detectar `ui_accept` (Espaço/Enter), também chama `layer_tutorial.show()`, funcionando como atalho alternativo ao clique no botão.
- **Clique direito fecha tutorial ou volta ao Escritório** — comportamento contextual: se `layer_tutorial.visible` for `true`, o clique direito esconde o tutorial e marca o input como tratado (`set_input_as_handled()`); se estiver fechado, o clique direito chama `voltar_para_escritorio()`, que troca a cena de volta para `Escritorio.tscn`.
- **Conexão de sinal duplicada** — o botão `pressed` é conectado tanto via `@export var botao_tutorial` no script geral da cena (com checagem `is_connected()` para evitar dupla conexão) quanto via `@onready` diretamente no próprio script do botão (`tb_tutorial_1.gd`, usando `$"../Layer_Tutorial_1"`). Ambos os caminhos produzem o mesmo efeito hoje, mas representam redundância de arquitetura — funciona, mas não é limpo.

### 3.1 Tela de Gameplay (histórico — sistema de post-it substituído)

> O sistema descrito nesta subseção (Lembrete/PainelTrabalho) foi **substituído** pelo sistema de expedição/diagnóstico documentado em "3.4" mais abaixo. Mantido como registro histórico.

- **Site suspeito exibido na tela** — a cena `Tela.tscn` tem um `Sprite2D` com a imagem da "tela do computador" e um `TextureRect` sobreposto representando o site que o jogador precisa investigar.
- **Sistema de Lembretes (post-its)** — o nó `Lembrete` (`TextureButton`, script `lembrete.gd`) sorteava, ao entrar na cena, um título, descrição e valor de recompensa a partir de `DadosJogo.banco_de_trabalhos` (Autoload). Substituído pelo menu Disponíveis/Ativos.
- **`PainelTrabalho`** — `Panel` que exibia os detalhes do trabalho sorteado. Substituído pelo aceite direto no menu de trabalhos.
- **`BtnAbrirLivro`** — botão (script `btn_abrir_livro.gd`) que, no primeiro clique, instancia a cena `LivroInstrucao.tscn` dentro do `CenterContainer` e chama `abrir_livro()`; no segundo clique (com o livro já aberto), destrói a instância com `queue_free()`. Depende de duas referências `@export`: `cena_livro` (PackedScene) e `container_central` (CenterContainer), que precisam estar atribuídas no Inspetor do Godot. **Ainda em uso**, não foi afetado pela refatoração do sistema de trabalho.

### 3.2 Módulo de Inspeção (arquitetura dinâmica atual — sistema de grid, v3)

> ⚠️ **Atualizado:** o sistema descrito abaixo com `posicao`/`tamanho` livres em pixels foi **substituído** pelo sistema de grid (3 colunas fixas × N linhas). Ver seção 3.4 para os detalhes completos e o `gerenciador_inspecao.gd` reescrito.

- **`AlvoInspecao`** (`Resource`) — encapsula metadados de um alvo individual: `tipo` (`SUSPEITO`/`NEUTRO`), `quadrante: int` (índice `linha*3 + coluna`), `altura_real: float` (força a altura da linha; `0` = automática), `capitulo_relacionado` (índice em `ConteudoLivro.PAGINAS`). Campos `posicao`/`tamanho` **removidos**.
- **`TrabalhoInspecao`** (`Resource`) — agrupa `titulo`, `descricao`, `recompensa_base`, `dificuldade`, `recompensa_fama`, `imagem_site`, `alvos: Array[AlvoInspecao]` e o novo `linhas_grid: int` (padrão 5).
- **`AreaAlvo`** (`Area2D`) — carrega `dados: AlvoInspecao` e, novo nesta versão, `tamanho_quadrante: Vector2` (calculado pelo grid, não vem do Resource), `foi_encontrado: bool`, `ignorado: bool`, `ja_inspecionado_negativo: bool`.
- **`GerenciadorInspecao.montar_alvos(trabalho)`** — calcula a grade inteira (largura fixa em 1/3 da área de referência; altura por linha com compensação adaptativa entre linhas fixas/livres) e cria um `AreaAlvo` por quadrante (15 por padrão), incluindo os `NEUTRO` automáticos onde não há `AlvoInspecao` explícito no `TrabalhoInspecao.alvos`.
- **`@export var area_referencia: Control`** (novo) — define o retângulo que a grade cobre; deve apontar pro `TextureRect` `ImagemBase`, senão cai no viewport inteiro como fallback e o grid fica maior que a imagem do site.
- **Fluxo de inspeção (v3):**
  1. Jogador clica na tela → `AreaCliqueInspecao.registrar_clique_na_area(pos)`.
  2. `NovaAba` abre com os 4 botões (Inspecionar/Diagnosticar/Ignorar/Encerrar), estados calculados por `registrar_clique_na_area()`.
  3. Ao clicar em Inspecionar, `_on_botao_inspecionar_pressed()` chama `verificar_clique()`.
  4. `MensagemModal.mostrar(resultado.acertou)` exibe o feedback textual de sempre.
  5. Após 4s: se acertou, `_revelar_alvo()` (agora com `mouse_filter = IGNORE`, corrigindo o bug de clique bloqueado) e libera Diagnosticar globalmente; se neutro, marca `ja_inspecionado_negativo` naquele quadrante.
- **`CaixaDeSelecao.gd` intencionalmente vazio** — sem mudanças, continua correto.

### 3.3 Livro de Ajuda

- **`LivroDicas` paginado** — `TextureRect` com script `livro_dicas.gd` (`class_name LivroDicas`). Cada página é populada a partir de um dicionário com três chaves: `titulo`, `descricao` (como identificar o problema) e `solucao` (como resolver).
- **10 capítulos implementados** via `ConteudoLivro.PAGINAS`:
  1. Phishing, 2. Perfil Falso, 3. Site Malicioso, 4. Ransomware, 5. Engenharia Social, 6. Senha Fraca, 7. Wi-Fi Público, 8. Atualização Ignorada, 9. Permissões Excessivas, 10. Vazamento de Dados.
- **Navegação anterior/próximo** — botões `BtnAnterior` e `BtnProximo`.
- **Abre/fecha livremente, sem penalidade.**
- **Tamanho: 80% da viewport.**
- **`PAGINAS` alterado de `var` para `const`** — necessário para permitir acesso estático (`ConteudoLivro.PAGINAS`) a partir de `DadosJogo.gd`, sem precisar instanciar `ConteudoLivro`.

### 3.4 Sistema de Trabalho, Diagnóstico e Veredito Diferido (v3.1 — atual)

O sistema passou por 3 iterações de design principais, mais um refinamento (v3.1) ao longo do desenvolvimento (histórico completo em `netetive.md` seção 3.4 e `netetive_changelog.md`). Este documento reflete só o estado **atual**.

- **Design fechado com o usuário, na versão atual:**
  - Diagnóstico por **múltipla escolha simples** (2–4 opções por trabalho), não texto livre.
  - Todo o ciclo (Inspecionar/Investigar/Diagnosticar/Ignorar/Encerrar) acontece dentro de **um único popup** (`NovaAba`), aberto no ponto de clique — não mais na lista de trabalhos.
  - **Diagnosticar** fica desabilitado só até algum alvo suspeito ser encontrado em **qualquer ponto** do trabalho (não precisa ser o mesmo ponto clicado agora) — nunca trava de vez, mesmo que o jogador nunca ache o alvo certo (nesse caso, `diagnostico_correto` fica `false` por padrão e o trabalho conta como errado).
  - **Investigar** (v3.1) — dá uma dica textual sobre o quadrante clicado, limitada a 1 uso por trabalho, com 3 respostas possíveis dependendo do estado do quadrante (ver detalhes abaixo).
  - "Acertar" o trabalho exige **os dois**: achar o alvo suspeito **e** escolher a categoria certa.
  - **Ignorar/Designorar** por quadrante clicado — marcação visual pro jogador, não afeta o veredito.
  - **Encerrar** (substituiu "Terminar trabalho" da lista) abre um `ConfirmationDialog` mostrando o diagnóstico atualmente escolhido (ou avisando que nenhum foi feito), antes de fechar o trabalho de vez.

- **Sistema de posicionamento de alvos trocado por grid** — `AlvoInspecao.posicao`/`tamanho` (pixels livres) foram **removidos**; agora usa `quadrante: int` (índice `linha*3 + coluna`, grid de 3 colunas fixas × N linhas), `altura_real: float` (força a altura da linha inteira; `0` = automática/compensada) e `dica: String` (v3.1 — texto do botão Investigar). Quadrantes sem `AlvoInspecao` explícito viram `NEUTRO` automaticamente — os 15 quadrantes (com `linhas_grid = 5` padrão) são todos clicáveis.

- **Botão Investigar (v3.1)** — 5º botão da `NovaAba`, disponível a qualquer momento em qualquer quadrante:
  | Estado do quadrante | Resposta |
  |---|---|
  | Não inspecionado ainda | "Preciso investigar." |
  | Neutro, já checado sem sucesso | "Nada de interessante nesta parte." |
  | Suspeito, já encontrado | Texto de `AlvoInspecao.dica` |
  
  Só o terceiro caso consome o limite de 1 dica por trabalho (`TrabalhoAgendado.investigar_usado`) — os outros dois são "grátis" por não revelarem informação nenhuma. Resposta exibida via `MensagemModal.mostrar_texto()` (novo método, instantâneo, sem a etapa "Verificando...").

- **`TrabalhoAgendado`** (v3.1) — ganhou `investigar_usado: bool`, guardado na ocorrência do trabalho (não no `AreaAlvo`/`GerenciadorInspecao`, que são recriados a cada `montar_alvos()`) pra persistir corretamente mesmo se o jogador trocar de trabalho ativo e voltar depois.

- **`resultado_trabalho.gd`** (`Resource`, `class_name ResultadoTrabalho`) — sem mudanças desde a v1. Guarda `agendado`, `achou_alvo_correto`, `diagnostico_escolhido`, `diagnostico_correto`, `acertou_no_geral`, `recompensa`, e `finalizar()`.
  - Campo `agendado` **sem** `@export`, porque `TrabalhoAgendado` é `RefCounted` (não `Resource`).

- **`painel_diagnostico.gd`** — 🗑️ **descontinuado**. Existia como `Control` separado com `abrir(agendado)`/sinal `diagnostico_escolhido(agendado, opcao)`, mas o diagnóstico migrou pra dentro da própria `NovaAba` (v2/v3). Arquivo continua no projeto sem uso — candidato a remoção.

- **`banco_de_trabalhos.gd`** (novo módulo, `class_name BancoDeTrabalhos`, `static func`) — extraído de `DadosJogo.gd` pra separar dados estáticos (definição dos trabalhos) de estado em runtime. `DadosJogo._ready()` agora chama `BancoDeTrabalhos.criar_todos()`. Não precisa ser Autoload.
  - **Só 1 dos 5 trabalhos originais foi migrado** pro sistema de grid ("Remover Cavalo de Tróia", com `quadrante`/`altura_real`/`dica` calibrados/preenchidos). Os outros 4 foram **removidos temporariamente** — usavam `posicao`/`tamanho`, que não existe mais em `AlvoInspecao`, e dependem de arte de site ainda não produzida.

- **`DadosJogo.gd`** — ficou mais enxuto, cuidando só de estado: `dinheiro_jogador`, `trabalhos_do_dia`, `resultados_pendentes`/`resultados_do_dia`, e os métodos `iniciar_resultado_pendente()`, `finalizar_trabalho()`, `resetar_resultados_do_dia()`, `titulo_capitulo_correto()`, `gerar_opcoes_diagnostico()` (sem mudança de assinatura desde a v1). Uma versão intermediária cogitou adicionar `obter_dica_capitulo()` pra alimentar o Investigar a partir do `ConteudoLivro`, mas essa ideia foi descartada em favor do campo `dica` próprio em `AlvoInspecao` — `DadosJogo.gd` nunca chegou a ter essa função na versão final.

- **`nova_aba_script.gd`** — reescrito por completo. Ganhou `VBoxPadrao` (com `BtnInspecionar`, `BtnInvestigar`, `BtnDiagnosticar`, `BtnIgnorar`, `BtnEncerrar` sempre visíveis juntos) e `VBoxDiagnostico` (submenu populado em runtime, posicionado ao lado do menu principal). Sinais: `inspecionar_pressionado`, `investigar_pressionado` (v3.1), `diagnostico_pressionado`, `diagnostico_escolhido(opcao)`, `ignorar_pressionado`, `designorar_pressionado`, `encerrar_pressionado`.

- **`gerenciador_inspecao.gd`** — reescrito por completo:
  - `montar_alvos()` agora calcula o grid inteiro (largura fixa em 1/3, altura por linha com compensação adaptativa) e cria um `AreaAlvo` por quadrante, incluindo os `NEUTRO` automáticos. A origem do cálculo agora soma `area_referencia.global_position` (v3.1, correção de bug — ver abaixo).
  - `registrar_clique_na_area()` decide o estado dos 5 botões do popup (`diagnostico_disponivel`, `ignorado`, `inspecionar_disponivel`, `investigar_disponivel`) e repassa pra `NovaAba.mostrar_em()`.
  - Novo campo `_algum_alvo_suspeito_encontrado: bool`, setado quando qualquer alvo suspeito é achado — controla a liberação global do botão Diagnosticar.
  - Novo campo `AreaAlvo.ja_inspecionado_negativo`, setado quando um alvo `NEUTRO` é inspecionado sem sucesso — desabilita o "Inspecionar" nesse ponto específico em cliques futuros.
  - `_revelar_alvo()` agora força `mouse_filter = MOUSE_FILTER_IGNORE` no `ColorRect` de feedback (correção de bug, ver abaixo).
  - Novos sinais: `encerrar_solicitado` e `investigar_usado` (v3.1), ambos escutados por `CoordenadorTrabalho`.
  - Nova função `_on_investigar_pressionado()` (v3.1) com as 3 respostas do Investigar.
  - Novo `definir_investigar_disponivel()` (v3.1), chamado externamente ao trocar de trabalho ativo.

- **`coordenador_trabalho.gd`** — reescrito por completo:
  - `_on_diagnostico_escolhido(opcao)` — assinatura mudou (antes recebia `agendado` também; agora só `opcao`, porque quem sabe o trabalho atual é `_agendado_atual`).
  - Novo `ConfirmationDialog` criado em `_ready()`, com texto dinâmico montado em `_on_encerrar_solicitado()` a partir do `diagnostico_escolhido` do resultado pendente.
  - `_on_confirmar_encerramento()` chama `finalizar_trabalho()`, `marcar_trabalho_concluido()`, `gerenciador_inspecao.limpar_alvos()` + `site_textura.texture = null` (correção de bug) + mostra um toast "Trabalho encerrado." por 2s via `Label` criado em `_ready()`.
  - Novo `_on_investigar_usado()` (v3.1), persiste `agendado.investigar_usado = true` quando o sinal chega.
  - `_on_trabalho_selecionado()` agora também chama `gerenciador_inspecao.definir_investigar_disponivel(not agendado.investigar_usado)` (v3.1).
  - Campo `@export var painel_diagnostico` **removido** (não é mais necessário).

- **`gerenciador_trabalho.gd`** — simplificado:
  - `_adicionar_item_ativo()` agora cria só **1** botão por item ativo (título/seleção) — os botões "Diagnosticar" e "Terminar trabalho" saíram da lista.
  - `habilitar_botao_terminar()` e `_on_diagnosticar_pressionado()` **removidos** — não fazem mais sentido nesse arquivo.
  - `@export var painel_diagnostico` **removido**.

- **`mensagem_modal_scpt.gd`** (v3.1) — novo método `mostrar_texto(texto)`, reaproveitando `$Label`/`z_index` de `mostrar()` mas sem a etapa "Verificando..." — usado exclusivamente pelo botão Investigar.

### Ciclo do Dia — Iniciar Dia + Relatório de Fim de Expediente (v3.2 — novo)

O loop de gameplay agora fecha de ponta a ponta: `Escritório (Iniciar Dia) → Tela.tscn (expediente rodando) → RelatorioDia.tscn (resumo + crédito de dinheiro) → Escritório`.

- **Correção do clique duplo pra entrar no trabalho** — `gerenciador_trabalho.gd._on_disponivel_pressionado()` agora emite `trabalho_selecionado.emit(agendado)` direto ao aceitar um trabalho disponível, sem precisar de um segundo clique no item da lista de Ativos. `DadosJogo.iniciar_resultado_pendente()` foi removido desse arquivo (migrou pra `coordenador_trabalho.gd`).
- **`ResultadoTrabalho`** ganhou `tentativas_certas`/`tentativas_erradas` (conta toda inspeção, não só a que acha o alvo), `hora_inicio`/`hora_fim` (do relógio simulado) e os métodos `registrar_tentativa()`/`tempo_gasto_minutos()`.
- **`DadosJogo.gd`**: `iniciar_resultado_pendente()` e `finalizar_trabalho()` ganharam parâmetro `hora_atual: float = 0.0`; novo `registrar_tentativa_inspecao(agendado, acertou)`.
- **`coordenador_trabalho.gd`**: novo `@export var gerenciador_expediente: Node` (precisa ser atribuído no Inspetor) + `_hora_atual()` pra ler o relógio simulado com segurança. `_on_trabalho_selecionado()` agora abre o resultado pendente (migrado de `gerenciador_trabalho.gd`, com guarda contra recriação em reentrada); `_on_inspecao_concluida()` registra toda tentativa; `_on_confirmar_encerramento()` fecha `hora_fim`.
- **`relatorio_dia.gd`** (`class_name RelatorioDia`, novo arquivo) — itera `DadosJogo.resultados_do_dia`, monta uma linha por trabalho com veredito, alvo encontrado, diagnóstico (e se correto), tentativas certas/erradas, tempo gasto e recompensa. **Credita `DadosJogo.dinheiro_jogador` aqui**, não durante o expediente — mantém o resultado escondido do jogador até o fim do dia, decisão de design que já estava em aberto desde a v1.
- **`RelatorioDia.tscn`** (nova cena, raiz `Control`) — estrutura: `LabelResumo` (Label) + `ScrollContainer > VBoxResultados` (VBoxContainer) + `BtnVoltar` (Button). Nós lidos via `get_node_or_null()` em vez de `$caminho`, então um nome/caminho errado gera `push_warning()` específico em vez de travar a cena inteira.
- **`Main_select_script.gd`** conecta `gerenciador_expediente.expediente_encerrado` a `_on_expediente_encerrado()`, que troca a cena pra `RelatorioDia.tscn`.
- **Botão "Iniciar Dia"** — reaproveitado `Iniciar.gd` (já existia, já trocava pra `Tela.tscn`); nenhuma mudança de código foi necessária, porque `Main_select_script._ready()` já chamava `iniciar_expediente()` → `sortear_agenda_do_dia()` a cada carregamento da cena, resetando o estado do dia automaticamente.
- **Duração real de 1 dia**: com `minutos_por_segundo_real = 4.0` (padrão) e expediente 8h–17h (9h simuladas), um dia inteiro dura **~2min15s em tempo real**. Ajustável no Inspetor do `GerenciadorExpediente`, sem mexer em código.

### Sistema de Fama (v3.4 — novo)

Recurso permanente novo, paralelo ao dinheiro — não é gasto em nada, só cresce, e controla a quantidade de trabalhos que aparecem por dia. Fecha o sistema de trabalho ligando a progressão do jogador ao ritmo de novos casos.

- **`calculadora_fama.gd`** (`class_name CalculadoraFama`, `extends RefCounted`, `static func`, sem nó) — `calcular_quantidade_trabalhos_dia(fama, base)`, curva de raiz quadrada (`base + floor(sqrt(fama) * fator)`). Constantes `TRABALHOS_BASE_PADRAO := 6` e `FATOR_CRESCIMENTO := 1.0` isoladas pra calibrar sem mexer em mais nada.
- **`DadosJogo.gd`** — novo `var fama_jogador: int = 0`.
- **`resultado_trabalho.gd`** — novo `fama_ganha: int = 0`, calculado em `finalizar()` junto com `recompensa`. Qualquer caminho que já chama `DadosJogo.finalizar_trabalho()` (jogador manual, Assistente) ganha fama automaticamente, sem precisar de nenhuma mudança adicional nesses arquivos.
- **`gerenciador_expediente.gd`** — `quantidade_trabalhos_dia` virou `trabalhos_base_dia` (mínimo/base, não mais fixo). `iniciar_expediente()` calcula a quantidade real do dia via `CalculadoraFama` antes de sortear a agenda.
- **`gerenciador_ia_noturna.gd`** — `fama_ganha` também sofre a % de Eficiência, mesma lógica já aplicada ao dinheiro (trabalho malfeito rende menos reputação, não só menos grana).
- **`relatorio_dia.gd`** — reestruturado com 3 labels: `LabelResumo` (texto fixo "Dia concluído"), `LabelDinheiro` (`"R$ %d"`, só o ganho do dia), `LabelFama` (`"+%d fama"`, só o ganho do dia). Cálculo interno (soma, crédito em `DadosJogo.fama_jogador`, upkeep só no dinheiro) continua o mesmo — mudou só a exibição.

**Curva de referência** (fator 1.0, base 6): fama 0 → 6 trabalhos/dia | fama 25 → 11 | fama 100 → 16 | fama 400 → 26 | fama 900 → 36. Cada +5 trabalhos exige progressivamente mais fama.

**Bug corrigido:** `max(0, fama)` em `calculadora_fama.gd` gerava warning tratado como erro (`inferred from a Variant value`) — o `max()` built-in do GDScript pode devolver `Variant` dependendo dos tipos dos argumentos. Corrigido tipando explicitamente.

---

### Sistema de Upgrades — PC, Assistente e IA (v3.3 — novo)

Acessível só no Escritório (`BtnUpgrades` → `PainelUpgrades`), fora do loop de expediente. 5 linhas, 4 tiers sequenciais cada, compra única por tier, persiste pra sempre via `DadosJogo.upgrades`.

- **`tier_upgrade.gd`** (`Resource`) — um degrau: `preco`, `valor_efeito`, `valor_efeito_secundario` (só usado pelo Treinamento), `upkeep`, `descricao`. Dumb data, sem lógica.
- **`linha_upgrade.gd`** (`Resource`) — agrupa os tiers de uma progressão + `tier_atual` (progresso do jogador). Helpers: `esta_no_maximo()`, `proximo_tier()`, `tier_comprado(indice)`, `valor_efeito_atual(valor_base)`, `valor_efeito_secundario_atual(valor_base)`, `upkeep_atual()`. `chave_pre_requisito` guarda a chave de outra linha que precisa ter `tier_atual >= 1` antes desta poder ser comprada (vazio = sem pré-requisito).
- **`banco_de_upgrades.gd`** (`class_name BancoDeUpgrades`, `static func`, mesmo padrão de `BancoDeTrabalhos`) — monta as 5 `LinhaUpgrade` com valores fechados. Constantes `CHAVE_*` identificam cada linha globalmente.
- **`DadosJogo.gd`** — novo `var upgrades: Dictionary` (`String -> LinhaUpgrade`), populado por `BancoDeUpgrades.criar_todas()` no `_ready()`. Novo `comprar_upgrade(chave)` — única porta de entrada pra avançar um tier: valida existência da linha → tier máximo → pré-requisito → saldo, nessa ordem, só então debita e incrementa `tier_atual`. Novo `obter_linha_upgrade(chave)` — helper de leitura pra UI.
- **`gerenciador_assistente.gd`** (`Node`, novo filho de `ModuloTrabalho`, irmão de `GerenciadorExpediente`/`GerenciadorTrabalho`/`CoordenadorTrabalho`) — fila de trabalhos delegados. `delegar(agendado)` processa direto se há slot livre (capacidade = linha Quantidade) ou enfileira (FIFO). Tick em `_process()` compara `hora_atual` do relógio simulado com o horário de conclusão previsto de cada item; ao vencer, sorteia acerto pela taxa de sucesso do Treinamento e fecha o `ResultadoTrabalho` direto (sem passar pela `NovaAba`). Todos os valores (tempo, taxa, capacidade) lidos sob demanda de `DadosJogo.obter_linha_upgrade()` — nunca cacheados.
- **`gerenciador_trabalho.gd`** — cada item de `VBoxAtivos` virou um `HBoxContainer` com 2 botões: título (comportamento igual antes) + **Delegar** (novo). Delegar nasce desabilitado se Treinamento ainda não tem tier 1; ao clicar, desabilita o botão (feedback otimista) e emite `delegar_solicitado(agendado)` — não conhece `GerenciadorAssistente` diretamente.
- **`coordenador_trabalho.gd`** — novo `@export var gerenciador_assistente`. `_on_delegar_solicitado()` chama `gerenciador_assistente.delegar()`; se o trabalho delegado era o que estava aberto na inspeção, limpa a tela. `_on_assistente_concluido()` remove o item de `VBoxAtivos` (via `marcar_trabalho_concluido()`) e mostra um toast próprio ("Assistente: ... concluído com sucesso/erro"). Toast refatorado num `_mostrar_feedback(texto)` genérico, reaproveitado pelo encerramento manual e pelo Assistente.
- **`gerenciador_ia_noturna.gd`** (`class_name GerenciadorIANoturna`, `extends RefCounted`, `static func`, sem nó na árvore) — `processar_noite(hora_fim_expediente)` varre `DadosJogo.trabalhos_do_dia` por agendados "sobrados" (apareceram mas nunca foram aceitos, OU foram aceitos e nunca concluídos — excluindo qualquer um que já tenha resultado pendente em outro lugar, ex: fila do Assistente), sorteia acerto a 75% fixo, aplica a % de Eficiência sobre a recompensa, e grava direto em `resultados_do_dia`. Chamado uma única vez por `Main_select_script._on_expediente_encerrado()`, antes de trocar pra `RelatorioDia.tscn`.
- **`calculadora_upkeep.gd`** (`class_name CalculadoraUpkeep`, `static func`, sem nó) — `calcular_total()` soma upkeep(Treinamento) × quantidade de assistentes + upkeep(IA-Capacidade) + upkeep(IA-Eficiência). Isola a fórmula do `RelatorioDia`.
- **`relatorio_dia.gd`** — `montar_relatorio()` agora desconta `CalculadoraUpkeep.calcular_total()` antes de creditar (`dinheiro_jogador += total_dinheiro - upkeep_total`), podendo deixar o saldo negativo de propósito. Resumo mostra ganhos/manutenção/saldo separados.
- **`mensagem_modal_scpt.gd`** — `mostrar()` lê `LinhaUpgrade.valor_efeito_atual(4.0)` da linha PC em vez do `create_timer(2.0)` fixo × 2 etapas; tier 4 (valor 0.0) pula os `await` inteiramente, verificação instantânea. Novo `tempo_total_atual()` público.
- **`gerenciador_inspecao.gd`** — `_on_botao_inspecionar_pressed()` troca o `await create_timer(4.0)` fixo por `_tempo_verificacao_atual()`, que prioriza ler `mensagem_modal.tempo_total_atual()` (com fallback pra ler a linha PC direto), sincronizando a revelação do quadrante com o fechamento do popup.
- **`painel_upgrades.gd`** (`Panel`, novo em `Escritorio.tscn`) — desenha as 5 linhas dinamicamente (ordem fixa via `ORDEM_EXIBICAO`), mostrando tier atual/máximo, cadeado se bloqueada por pré-requisito, ou botão de compra com preço (desabilitado se saldo insuficiente). Delega toda compra pra `DadosJogo.comprar_upgrade()` e remonta a lista inteira depois (atualiza saldo/desbloqueios/próximo preço de uma vez).
- **`btn_upgrades.gd`** (`TextureButton`, novo em `Escritorio.tscn`) — abre o `PainelUpgrades`, mesmo padrão de `Quadro_avisos`/`Iniciar.gd` (conectado ao sinal `pressed` pelo editor, método `_on_pressed()`).

**Decisão de design revisada em runtime:** pré-requisito entre as duas linhas do Assistente foi invertido depois de testar em jogo — fechado primeiro como "Quantidade bloqueada até Treinamento", trocado pelo usuário pra "Treinamento bloqueado até Quantidade" (Quantidade virou linha de entrada). Mudança de dado pura em `banco_de_upgrades.gd`, sem impacto em nenhum outro arquivo (a validação de pré-requisito é genérica).

**Bugs corrigidos durante a integração desta rodada:**
- Sinal `pressed()` do `BtnUpgrades` conectado ao nó errado (`../Quadro_avisos` em vez do próprio nó) — clique não executava nada, sem erro no console.
- `CoordenadorTrabalho` criado fora de `ModuloTrabalho` (filho direto da raiz da cena) — movido pra dentro, junto dos outros três gerenciadores.
- `GerenciadorAssistente` sem `gerenciador_expediente` atribuído no Inspetor — warning no `_ready()`.
- `PainelUpgrades` com tamanho 0x0 na viewport — `show()` rodava sem erro, mas nada aparecia; corrigido redimensionando o `Panel`/`ScrollContainer` no editor.
- Tempo do popup de verificação não respeitava o tier do PC — a implementação em `mensagem_modal_scpt.gd` só veio bem depois do design ter sido fechado; ficou pendente até ser notado em teste.
- Revelação da cor do quadrante ainda fixa em 4s mesmo após corrigir o popup — `gerenciador_inspecao.gd` tinha seu próprio timer hardcoded, independente do `MensagemModal`; corrigido lendo o mesmo valor publicamente exposto.

---

### Bugs corrigidos ao longo das iterações (v2/v3/v3.1)

- **Clique bloqueado no alvo revelado** — `_revelar_alvo()` criava um `ColorRect` com `mouse_filter` padrão (`STOP`), bloqueando cliques futuros sobre o alvo já encontrado. Corrigido com `mouse_filter = Control.MOUSE_FILTER_IGNORE`.
- **Quadrado revelado + imagem do site antiga persistindo após "Encerrar"** — `_on_confirmar_encerramento()` não limpava os alvos nem resetava a textura do site. Corrigido chamando `limpar_alvos()` e `site_textura.texture = null`.
- **`Cannot infer the type of "linha"`** — `mapa_alvos` é `Dictionary` sem tipo declarado, então `mapa_alvos.keys()` devolve `Variant`; `var linha := indice / COLUNAS_GRID` não conseguia inferir tipo. Corrigido com `var linha: int = int(indice) / COLUNAS_GRID`.
- **`INTEGER_DIVISION` warning** — mesma linha acima; divisão intencional de dois `int`, silenciado com `@warning_ignore("integer_division")`.
- **Encerrar "não fazia nada" (sintoma investigado, não era bug de código)** — resultado esperado do design (veredito escondido até fim do dia); resolvido com um toast de confirmação visual em vez de mudança de lógica.
- **Grid não seguia a posição real de `ImagemBase` (v3.1)** — `montar_alvos()` calculava todos os quadrantes a partir de `(0, 0)`, ignorando a `Position` real de `ImagemBase` na cena (`-385, -286` no caso observado). Corrigido somando `area_referencia.global_position` como origem do cálculo de posição.

Ao investigar por que apareciam **dois** nós `GerenciadorTrabalho` na cena `Tela.tscn`, descobrimos um ramo inteiro do sistema antigo de post-it ainda presente na árvore, solto no nível raiz (irmão de `BtnAbrirLivro`/`ModuloInspecao`/`ModuloTrabalho`):

```
Node2D
├── Sprite2D
├── Lembrete                ← legado, sistema de post-it substituído
├── GerenciadorTrabalho     ← legado — script DIFERENTE do usado hoje
├── TimerLembrete           ← legado, nunca teve lógica implementada
├── BtnAbrirLivro
├── CanvasLayer
├── ModuloInspecao
└── ModuloTrabalho
    ├── GerenciadorExpediente
    ├── GerenciadorTrabalho  ← este é o real, usado por Main_select_script.gd
    │   ├── BtnAbrirMenuTrabalho
    │   └── MenuTrabalhos
    │       ├── VBoxDisponiveis
    │       └── VBoxAtivos
    ├── CoordenadorTrabalho
    └── PainelDiagnostico
```

- **Confirmado por `Main_select_script.gd`:** `@onready var gerenciador_expediente: Node = $ModuloTrabalho/GerenciadorExpediente` — o ponto de entrada do jogo só enxerga (e só chama `iniciar_expediente()` em) o que está dentro de `ModuloTrabalho`. O ramo solto no topo nunca é referenciado por nenhum script ativo.
- **Não são o mesmo arquivo fisicamente**, apesar de aparecerem com o mesmo nome curto na lista de scripts do editor (`gerenciador_trabalho.gd`). Confirmado abrindo o script do nó solto: a aba mostra `Tela/gerenciador_trabal...` e o conteúdo é a versão **antiga** (`@export var painel_trabalho: Panel`, `_on_lembrete_foi_clicado()`, `_on_trabalho_iniciado()`) — nada do sistema de diagnóstico/veredito diferido. Ou seja, existem **dois arquivos `gerenciador_trabalho.gd` em pastas diferentes do projeto** (provavelmente `res://Scripts/Tela/gerenciador_trabalho.gd` vs. algo como `res://Scripts/ModuloTrabalho/gerenciador_trabalho.gd`), o que é o mesmo tipo de armadilha de nomenclatura já catalogada antes no projeto (nomes iguais, pastas diferentes, fácil de confundir ao navegar pela lista de scripts).
- **Recomendação:** apagar o ramo inteiro (`Lembrete` + `GerenciadorTrabalho` solto + `TimerLembrete`) da árvore de `Tela.tscn`. Os três são legado confirmado do sistema de post-it substituído (seção 3.1 de `netetive.md`), sem nenhuma referência ativa apontando pra eles.

## 🧹 Scripts órfãos confirmados (achados nesta rodada)

- **`caixa_selecao.gd`** (minúsculo) — confirmado **não anexado** a nenhum nó ativo. O nó `CaixaSelecao` (dentro de `ModuloInspecao`) usa de fato `res://Scripts/Tela/CaixaDeSelecao.gd` (o script vazio, documentado desde o início como intencional). `caixa_selecao.gd` era só uma aba aberta no editor, sobra de uma versão anterior do sistema de clique (fazia o mesmo trabalho que `area_clique_inspecao.gd` faz hoje). Seguro remover após uma busca rápida por `clicou_em` (nome do sinal que ele emite) pra garantir que nada mais ficou conectado a ele.
- **`menu_trabalhos.gd`** — ainda **não confirmado** se está anexado a algum nó ativo. Referencia `DadosJogo.trabalhos_disponiveis`/`trabalhos_ativos`/`trabalho_atual`, que não existem no `DadosJogo.gd` real — se estiver de fato anexado a algum nó, vai quebrar em runtime assim que `atualizar()` for chamado. Pendente de verificação (mesmo processo usado para confirmar `caixa_selecao.gd`: selecionar o nó suspeito e conferir o script no Inspector).

---

### HUD de Dinheiro/Fama + Trabalhos de Scareware/Ransomware (v3.5 — novo)

Trouxe features de duas branches paralelas (`score_system` e `trabalho_malware`) pra dentro da `Sistema-upgrade`, adaptadas em vez de mescladas diretamente — as duas partiram de um ponto do projeto anterior ao grid/Investigar/upgrades.

- **HUD permanente (`Scores.tscn` instanciada em `Escritorio.tscn`)** — mostra `DadosJogo.dinheiro_jogador`/`fama_jogador` sempre visível no Escritório, diferente do `RelatorioDia` que só mostra uma vez no fim do dia.
- **`hud_manager.gd`/`icone_dinheiro.gd`** — reescritos a partir da versão da `score_system`: trocado o autoload `Global` (`money`/`fame`, com sinais próprios) por leitura direta de `DadosJogo`, via polling em `_process()` (comparando com o último valor visto), já que `DadosJogo` não emite sinal de mudança.
- **`Global` (autoload) descartado** — não entrou no `project.godot`. Papel já coberto por `DadosJogo`, evitando duas fontes de verdade pro mesmo dado.
- **Comportamento esperado, não bug:** HUD fica parado o expediente inteiro, só atualiza quando `RelatorioDia.montar_relatorio()` credita no fim do dia — não é mais "ao vivo" trabalho a trabalho como era na `score_system`.
- **Capítulo "Scareware"** substitui "Senha Fraca" em `ConteudoLivro.PAGINAS` (índice 5).
- **Dois trabalhos novos** em `banco_de_trabalhos.gd`: `_criar_trabalho_scareware()` (imagem de falso alerta de vírus, `capitulo_relacionado = 5`) e `_criar_trabalho_ransomware()` (imagem redesenhada de nota de resgate real, `capitulo_relacionado = 3`, já existente). Substituem o único trabalho ambíguo que a `trabalho_malware` tinha tentado criar (imagem de scareware associada ao capítulo Ransomware).
- **Bug corrigido:** `Node not found` em `hud_manager.gd` — caminho relativo original (`$control/container/container_dinheiro/...`) não batia com a estrutura real da cena (sem o nível `container` intermediário). Corrigido ajustando pra `$control/container_dinheiro/...`.
- **Bug evitado (herdado da `trabalho_malware`, não repetido):** a função de trabalho original nunca tinha sido incluída no array de `criar_todos()`/`_ready()` — confirmado que as duas funções novas estão de fato no array desta vez.

---

## 🔲 Falta fazer

### HUD de Dinheiro/Fama + Trabalhos de Scareware/Ransomware (v3.5)

- **`quadrante`/`altura_real` dos dois trabalhos novos são só estimativa** — calculados por proporção da imagem original (fração de largura/altura), ainda não calibrados em jogo com `print()` temporário em `montar_alvos()`.
- **Conteúdo antigo do capítulo "Senha Fraca" sem novo destino** — foi removido do array ativo pra dar lugar a "Scareware", mas o texto original não foi descartado; candidato a virar um 11º capítulo, se quiser recuperá-lo.
- **HUD ainda usa `$caminho` relativo** em vez de Unique Names (`%contador_dinheiro`/`%contador_fama`) — mesmo padrão de fragilidade já visto antes no projeto; já causou um `Node not found` real nesta rodada.
- **Ainda faltam 2 dos 5 trabalhos originais** ("Limpeza de Disco"/"Otimizar Inicialização"/"Atualizar Drivers"/"Substituir Pasta Térmica" — 2 dos 4 continuam de fora mesmo após Scareware/Ransomware entrarem).

### Sistema de Fama (v3.4)

- **`FATOR_CRESCIMENTO` é placeholder** — fechado por design conversado, não testado em jogo real com vários dias seguidos. Provável que precise de ajuste depois de mais playtesting (curva pode crescer rápido/devagar demais na prática).
- **Sem exibição de fama fora do `RelatorioDia`** — o jogador só vê o total de fama no relatório de fim de dia; não há indicador permanente (ex: no Escritório, junto do saldo de dinheiro).
- **`quantidade_trabalhos_iniciais` não escala com fama** — só o total do dia (`trabalhos_base_dia`) usa `CalculadoraFama`; quantos trabalhos já aparecem prontos às 8h continua fixo, independente da fama. Pode valer revisitar se, na prática, o jogador sentir que a maioria dos trabalhos extras "atrasa" demais no dia.
- **Trabalhos delegados ao Assistente sempre rendem fama cheia (100% se acertar)** — diferente da IA, que tem a fama reduzida pela Eficiência. Decisão implícita (Assistente não tem upgrade de "qualidade" que afete a fama), vale confirmar se é o comportamento desejado.

### Sistema de Upgrades (v3.3)

- **Valores de preço/upkeep são placeholder** — fechados em rodadas de design sem playtesting real; esperado precisar de balanceamento depois que o jogo tiver mais trabalhos calibrados pra testar a progressão de ganhos vs. custo.
- **`gerenciador_assistente.gd` não persiste a fila entre sessões** — se o jogador fechar o jogo com trabalhos na fila do Assistente, esse estado se perde (mesma limitação que já existe pra `resultados_pendentes` em geral, não é regressão nova).
- **Sem indicador visual de "quantos assistentes estão ocupados agora"** na UI — o jogador só descobre que um trabalho foi delegado com sucesso pelo toast; não há um contador tipo "2/3 assistentes ocupados" em nenhum lugar da tela.
- **`GerenciadorIANoturna` não tem feedback próprio no Escritório** — os resultados da IA aparecem misturados aos do jogador/Assistente no `RelatorioDia`, sem nenhuma marcação visual além do texto "Resolvido pela IA (noturno)" no campo Diagnóstico. Pode valer destacar visualmente (ícone, cor) se ficar confuso em jogo.
- **Sem upgrade de "Precisão" pra IA** — cogitado no design mas não implementado; a taxa de 75% fixa da IA não sobe por tier nenhum hoje (só a Eficiência muda o quanto ela entrega de recompensa).

### Sistema de Trabalho / Diagnóstico (v3.1) / Ciclo do Dia (v3.2)

- ~~**Tela de resumo de fim de expediente**~~ — ✅ implementada (`RelatorioDia.tscn`/`relatorio_dia.gd`, v3.2). Itera `DadosJogo.resultados_do_dia`, exibe veredito, alvo encontrado, diagnóstico, tentativas e tempo por trabalho.
- ~~**Crédito de `dinheiro_jogador`**~~ — ✅ resolvido: creditado dentro de `RelatorioDia.montar_relatorio()`, ao abrir a tela de resumo (v3.2).
- **Melhoria pendente (v3.2):** `Main_select_script._on_expediente_encerrado()` carrega a cena de relatório por caminho de string (`"res://Scenes/RelatorioDia.tscn"`) — já causou um erro de "Cannot open file" por divergência de nome/pasta. Recomendação: trocar por `@export var cena_relatorio: PackedScene` (arrastando a cena no Inspetor), evitando esse tipo de erro se o arquivo for movido/renomeado no futuro.
- **Recriar os 4 trabalhos removidos** — "Limpeza de Disco", "Otimizar Inicialização", "Atualizar Drivers de Vídeo" e "Substituir Pasta Térmica" foram tirados de `banco_de_trabalhos.gd` por dependerem de arte de site ainda não produzida e usarem o sistema antigo (`posicao`/`tamanho`). Precisam ser recriados com `quadrante`/`altura_real`/`dica` calibrados/preenchidos manualmente assim que a arte de cada um estiver pronta.
- **Múltiplos alvos suspeitos por trabalho** — `titulo_capitulo_correto()` e `gerar_opcoes_diagnostico()` ainda assumem um único alvo `SUSPEITO` por `TrabalhoInspecao` (usam o primeiro que encontrarem). Isso também afeta o Investigar — cada alvo suspeito precisaria da sua própria `dica`.
- **Texto do `MensagemModal`** ("Alvo detectado!"/"Nenhum alvo encontrado.") pode confundir o jogador agora que achar o alvo não fecha mais o trabalho — vale revisar a redação.
- **`painel_diagnostico.gd` órfão** — descontinuado desde a v2/v3, sem uso, candidato a remoção.
- **Estado por quadrante não persiste ao trocar de trabalho ativo** (v3.1) — `foi_encontrado`/`ignorado`/`ja_inspecionado_negativo` vivem no `AreaAlvo`, recriado do zero a cada `montar_alvos()`. Se o jogador trocar de trabalho e voltar, esse progresso visual reseta silenciosamente (só `investigar_usado` está protegido, por morar em `TrabalhoAgendado`). Solução futura: migrar esses três campos pra um dicionário indexado por quadrante dentro do próprio `TrabalhoAgendado`.
- ~~**Confirmar `Stretch Mode` de `ImagemBase`**~~ — ✅ confirmado como `Scale`, não é a causa de nenhum desalinhamento. O bug real era a origem do grid não considerar `area_referencia.global_position` — já corrigido (ver "Bugs corrigidos" acima).

### Design / gameplay (herdado)

- ~~**Quantidade de alvos variar por dificuldade**~~ — ✅ resolvido pelo sistema de grid: todo trabalho tem 15 quadrantes clicáveis (3×5), controlável por `TrabalhoInspecao.linhas_grid`.
- **Mais de 1 alvo suspeito por trabalho** — ver item acima sobre `titulo_capitulo_correto()`.
- **`GerenciadorInspecao` receber info de dificuldade** — ainda não implementado; poderia controlar `linhas_grid` ou a proporção de quadrantes `SUSPEITO`/`NEUTRO`.
- **`TimerLembrete` sem script** — nó legado do sistema de post-it antigo; ver seção "🧹 Árvore de cena" — recomendação é apagar junto com o resto do ramo legado.
- **Condição de fim de dia / loop completo** — ainda não existe um mecanismo que encerre o expediente e dispare a tela de resumo.
- **Expandir livro de 10 para 12 capítulos** — comentário no código de `ConteudoLivro.gd` ainda menciona "12 capítulos estruturados"; confirmar se os 2 capítulos extras seguem planejados.
- **Definir custo de consulta ao livro** — ainda sem custo de tempo/recompensa por abrir o `LivroDicas`.
- **Corrigir "and" em inglês no Capítulo 5** do `conteudo_livro.gd` (linha do texto de Engenharia Social).

### Limpeza técnica (dívida conhecida)

- **`Main_select_script.gd` vs. `btn_abrir_livro.gd`** — possível lógica duplicada de abrir/fechar o livro; ainda não confirmado se foi resolvido.
- **Dois scripts de modal concorrentes** (`mensagem_modal_scpt.gd` ativo vs. `mensagem_modal.gd`/`PainelModal` aparentemente não usado) — ainda pendente de confirmação/remoção.
- **`button-inspecionar.gd`** — versão anterior do sistema de inspeção, candidata a remoção. Referencia `caixa_selecao` sem declará-la no script (quebraria em runtime se ainda estivesse ativo) — mais um indício de que é seguro remover.
- **Caminho hardcoded em `Para_inicial.gd`** — confirmado nesta rodada: aponta pra `res://Scenes/inicio.tscn` (minúsculo), diferente do `res://Scenes/Escritorio.tscn` usado no resto do projeto. Confirmar se é a mesma cena com nome inconsistente ou uma cena de fato diferente.
- **Unificar `Iniciar.gd` e `texture_button-Quadro.gd`** — ainda pendente.
- **Simplificar dupla conexão do botão de tutorial no Quadro** — ainda pendente.
- **Bug de script duplicado (`class_name` colidindo)** — apareceu com `PainelDiagnostico` duplicado em dois arquivos `.gd` diferentes, gerando o erro `Class "PainelDiagnostico" hides a global script class`. Resolvido apagando a cópia não usada — hoje o próprio `PainelDiagnostico` está descontinuado (ver seção 3.4), então esse ponto específico não é mais relevante, mas o padrão de bug (conferir duplicatas de `class_name` antes de criar scripts novos) continua valendo.
- **Ramo legado duplicado na árvore de `Tela.tscn`** (confirmado nesta rodada) — `Lembrete` + `GerenciadorTrabalho` (versão antiga) + `TimerLembrete` soltos no nível raiz, paralelos ao `ModuloTrabalho` real. Ver seção "🧹 Árvore de cena" acima para detalhes; recomendação é apagar o ramo inteiro.
- **Dois arquivos `gerenciador_trabalho.gd` em pastas diferentes** (confirmado nesta rodada) — `res://Scripts/Tela/gerenciador_trabalho.gd` (antigo, sistema de post-it) e o script real usado por `ModuloTrabalho/GerenciadorTrabalho` (sistema novo). Mesmo nome de arquivo, pastas diferentes — fonte de confusão ao navegar pela lista de scripts do editor, já que o Godot mostra só o nome curto. Considerar renomear o antigo (ex: `gerenciador_trabalho_LEGADO.gd`) antes de apagar, ou apagar direto já que o nó que o usa também será removido.
- **`caixa_selecao.gd`** (confirmado órfão nesta rodada) — não anexado a nenhum nó ativo; nome quase idêntico a `CaixaDeSelecao.gd` (que é o real, usado pelo nó `CaixaSelecao`). Seguro remover após busca por `clicou_em` no projeto.
- **`menu_trabalhos.gd`** (suspeita ainda não confirmada) — referencia campos de `DadosJogo` que não existem (`trabalhos_disponiveis`, `trabalhos_ativos`, `trabalho_atual`). Pendente de verificação se está anexado a algum nó ativo, usando o mesmo processo que confirmou `caixa_selecao.gd` como órfão.
