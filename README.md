# Netetive — Documentação do Projeto

> Jogo educativo de cibersegurança em Godot 4, inspirado em *Papers, Please*. O jogador assume o papel de alguém que precisa identificar ameaças digitais (phishing, sites maliciosos, perfis falsos etc.) durante o expediente de trabalho.

---

## Sumário

1. [Escritório (cena inicial)](#1-escritório-cena-inicial)
2. [Quadro de Avisos](#2-quadro-de-avisos)
3. [Tela de Gameplay](#3-tela-de-gameplay)
   - [3.1 Visão geral e sistemas principais](#31-visão-geral-e-sistemas-principais)
   - [3.2 Módulo de Inspeção](#32-módulo-de-inspeção)
   - [3.3 Livro de Ajuda](#33-livro-de-ajuda-livrodicas)
4. [Estado Geral do Projeto](#4-estado-geral-do-projeto)
5. [Observações Gerais para Desenvolvimento Futuro](#5-observações-gerais-para-desenvolvimento-futuro)
6. [Refatoração do Sistema de Alvos de Inspeção](#6-refatoração-do-sistema-de-alvos-de-inspeção)

---

## 1. Escritório (cena inicial)

### Visão Geral

A cena do Escritório é a tela inicial de gameplay do Netetive. Ela serve como ponto de partida do dia de trabalho do jogador, apresentando o ambiente e oferecendo os primeiros pontos de interação. Por enquanto, sua função principal é redirecionar o jogador para o loop central de gameplay através do **Quadro de Avisos**.

### Estrutura da Cena

```
Node2D
├── Sprite2D
│   └── TextureRect          ← Fundo visual do escritório (pixel art)
├── Quadro_avisos            ← Botão interativo: abre o Quadro de tarefas
└── Cafeteira                ← Elemento decorativo/interativo
	└── Label                ← Texto "Comece o dia!" exibido na tela
```

> **Engine:** Godot 4  
> **Arquivo da cena:** `res://Scenes/Escritorio.tscn` *(ou equivalente)*

### Nós e Funções

#### `Node2D` — Raiz da cena
Nó raiz da cena. Não possui script próprio; serve apenas como contêiner dos elementos filhos.

#### `Sprite2D > TextureRect` — Fundo do escritório
Exibe o background em pixel art do escritório (sala com mesa, computador, janela com vista da cidade, etc.). Não possui lógica de script.

#### `Quadro_avisos` — `TextureButton`
**Script:** `texture_button-Quadro.gd`

Botão interativo representado visualmente pelo quadro de cortiça na parede. Ao ser clicado, leva o jogador para a cena do Quadro de tarefas, iniciando o loop de gameplay.

```gdscript
extends TextureButton

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Quadro.tscn")
```

| Evento | Ação |
|---|---|
| Clique do jogador | Troca de cena para `Quadro.tscn` |

#### `Cafeteira` — Nó interativo (com Label)
Elemento presente no canto esquerdo da tela. Exibe o texto **"Comece o dia!"** via nó `Label` filho. Atualmente funciona como dica visual para o jogador iniciar a partida.

> **Observação:** O script `Iniciar.gd` (associado a um `TextureButton`) também realiza troca de cena, redirecionando para `res://Scenes/Tela.tscn`. Pode estar vinculado à Cafeteira ou a outro botão de início presente na cena.

```gdscript
extends TextureButton

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Tela.tscn")
```

### Fluxo de Navegação

```
[Escritório]
	 │
	 │  Jogador clica no Quadro_avisos
	 ▼
[Quadro.tscn]  ←── início do loop de gameplay
```

---

## 2. Quadro de Avisos

### Visão Geral

A cena do **Quadro** é uma tela de consulta **fora do loop de gameplay**. Ela centraliza informações de apoio ao jogador: controles, guias de como jogar, configurações iniciais, etc. É o espaço de onboarding do jogo — o jogador aprende as mecânicas aqui antes de entrar nos eventos do dia.

> O Quadro **não** instrui sobre como agir durante os eventos; isso faz parte do próprio gameplay.

### Estrutura da Cena

```
Node2D                        ← Script geral da cena (Script_geral_quadro.gd)
├── Sprite2D
│   └── TextureRect           ← Fundo visual: foto do quadro de cortiça
├── TB_Tutorial_1             ← Botão interativo: abre o tutorial (tb_tutorial_1.gd)
└── Layer_Tutorial_1          ← CanvasLayer que contém o painel do tutorial
	└── TextureRect           ← Conteúdo visual do tutorial (instruções, controles, etc.)
```

> **Engine:** Godot 4  
> **Arquivo da cena:** `res://Scenes/Quadro.tscn`

### Nós e Funções

#### `Node2D` — Raiz da cena
**Script:** `Script_geral_quadro.gd`

Gerencia toda a lógica da cena: conecta o botão de tutorial, controla visibilidade do `CanvasLayer` e trata inputs globais (teclado e mouse).

```gdscript
extends Node2D

@export var botao_tutorial: TextureButton
@export var layer_tutorial: CanvasLayer

func _ready() -> void:
	# Garante que o tutorial começa oculto
	if layer_tutorial != null:
		layer_tutorial.hide()
	# Conecta o sinal do botão manualmente (evita dupla conexão)
	if botao_tutorial != null and not botao_tutorial.pressed.is_connected(_on_botao_tutorial_pressionado):
		botao_tutorial.pressed.connect(_on_botao_tutorial_pressionado)

func _on_botao_tutorial_pressionado() -> void:
	if layer_tutorial != null:
		layer_tutorial.show()

func _input(event: InputEvent) -> void:
	# Atalho de teclado: Barra de Espaço abre o tutorial
	if event.is_action_pressed("ui_accept"):
		if layer_tutorial != null:
			layer_tutorial.show()
	# Clique direito: fecha tutorial SE aberto, senão volta ao escritório
	if event.is_action_pressed("clique_direito"):
		if layer_tutorial != null and layer_tutorial.visible:
			layer_tutorial.hide()
			get_viewport().set_input_as_handled()
		else:
			voltar_para_escritorio()

func voltar_para_escritorio() -> void:
	get_tree().change_scene_to_file("res://Scenes/Escritorio.tscn")
```

| Ação do jogador | Resultado |
|---|---|
| Clica em `TB_Tutorial_1` | Abre `Layer_Tutorial_1` |
| Pressiona `Espaço` | Abre `Layer_Tutorial_1` |
| Clique direito (tutorial aberto) | Fecha `Layer_Tutorial_1` |
| Clique direito (tutorial fechado) | Volta para `Escritorio.tscn` |

#### `Sprite2D > TextureRect` — Fundo do Quadro
Exibe a imagem do quadro de cortiça com o papel "Política de qualidade" fixado. Apenas visual, sem script.

#### `TB_Tutorial_1` — `TextureButton`
**Script:** `tb_tutorial_1.gd`

Botão visível sobre o quadro (representando o papel fixado). Ao ser pressionado, exibe o `Layer_Tutorial_1`.

```gdscript
extends TextureButton

@onready var layer_tutorial: CanvasLayer = $"../Layer_Tutorial_1"

func _on_pressed() -> void:
	if layer_tutorial != null:
		layer_tutorial.show()
```

> **Nota:** Este botão acessa o `CanvasLayer` via caminho relativo `$"../Layer_Tutorial_1"`. O script geral da cena também conecta este botão via `@export` — ambos produzem o mesmo efeito. Futuramente pode ser unificado para evitar redundância.

#### `Layer_Tutorial_1` — `CanvasLayer`
Camada de sobreposição que exibe o conteúdo do tutorial por cima da cena. Começa **oculto** (`hide()` no `_ready`) e é exibido apenas quando o jogador interage.

- Filho: `TextureRect` com o visual do tutorial (controles, guias, etc.)
- Fechado com **clique direito** pelo handler de `_input` no script geral.

### Fluxo de Navegação

```
[Escritório]
	 │  Clica no Quadro_avisos
	 ▼
[Quadro]  ──── Clica em TB_Tutorial_1 ou pressiona Espaço ────► [Layer_Tutorial_1 visível]
	 │                                                                    │
	 │                                                         Clique direito
	 │                                                                    │
	 │◄───────────────────────────────────────────────────────────────────┘
	 │
	 │  Clique direito (tutorial fechado)
	 ▼
[Escritório]
```

---

## 3. Tela de Gameplay

### 3.1 Visão geral e sistemas principais

A cena **Tela** (`res://Scenes/Tela.tscn`) é onde o loop principal de gameplay ocorre. O jogador visualiza um site suspeito na tela do computador e interage com ele para identificar problemas de segurança. A cena é composta por vários sistemas independentes que se comunicam por sinais e referências exportadas.

#### Estrutura da Cena

```
Node2D                         ← Script principal (Main_select_script.gd)
├── Sprite2D
│   ├── Tela                   ← Imagem da tela do computador (fundo visual)
│   └── TextureRect            ← Sobreposição visual (site exibido na tela)
├── Lembrete                   ← Post-it clicável com tarefas aleatórias (lembrete.gd)
├── GerenciadorTrabalho        ← Coordena abertura do painel de tarefas (gerenciador_trabalho.gd)
├── PainelTrabalho             ← UI de detalhes da tarefa aceita/ignorada (painel_trabalho.gd)
├── TimerLembrete              ← Timer para controlar ciclo dos lembretes
├── BtnAbrirLivro              ← Botão que abre/fecha o LivroDicas (btn_abrir_livro.gd)
└── CanvasLayer                ← Camada de sobreposição para elementos UI
	├── CenterContainer        ← Centraliza o LivroDicas na tela
	└── ModuloInspecao         ← Contém toda a lógica de inspeção de elementos
		├── AreaCliqueInspecao ← Captura cliques na tela (area_clique_inspecao.gd)
		├── GerenciadorInspecao← Lógica central de inspeção (gerenciador_inspecao.gd)
		│   ├── NovaAba        ← Menu contextual de clique (nova_aba_script.gd)
		│   ├── MensagemModal  ← Resultado da inspeção (mensagem_modal_scpt.gd)
		│   ├── Alvo1          ← ColorRect oculto: região suspeita real (CaixaDeSelecao.gd)
		│   ├── Alvo2          ← ColorRect neutro (não suspeito)
		│   └── Alvo3          ← ColorRect neutro (não suspeito)
		└── PainelModal        ← Versão alternativa do modal (mensagem_modal.gd)
```

> **Arquivo da cena:** `res://Scenes/Tela.tscn`

#### Sistema de Lembretes (Tarefas)

Os **Lembretes** são post-its fixados na tela do computador que representam tarefas recebidas pelo jogador. Cada um sorteia seus dados aleatoriamente a partir de `DadosJogo.banco_de_trabalhos` (Autoload).

##### `Lembrete` — `TextureButton`
**Script:** `lembrete.gd`

```gdscript
signal foi_clicado(titulo, descricao, recompensa, lembrete_clicado)
```

| Comportamento | Detalhe |
|---|---|
| Ao entrar na cena | Sorteia título, descrição e recompensa aleatória (`valor_base ± randi_range(-15, 25)`) |
| Clique esquerdo | Emite `foi_clicado` com os dados do trabalho |
| Clique direito | Esconde o post-it (`hide()`) |
| `z_index` | 100 — garante que fique sobre o fundo |

##### `GerenciadorTrabalho` — `Node`
**Script:** `gerenciador_trabalho.gd`

Recebe o sinal `foi_clicado` do Lembrete e repassa os dados ao `PainelTrabalho`.

```gdscript
func _on_lembrete_foi_clicado(titulo, descricao, recompensa, lembrete_clicado):
	painel_trabalho.abrir(lembrete_clicado, titulo, descricao, recompensa)
```

##### `PainelTrabalho` — `Panel`
**Script:** `painel_trabalho.gd`

Painel centralizado na tela que exibe os detalhes do trabalho sorteado.

```gdscript
signal trabalho_aceito(recompensa: int)
```

| Ação do jogador | Resultado |
|---|---|
| Clica em **Aceitar** | Emite `trabalho_aceito`, fecha painel, remove o post-it da cena (`queue_free`) |
| Clica em **Ignorar** | Fecha o painel, post-it permanece na tela |
| Clique direito sobre o painel | Fecha o painel (`fechar()`) |

- Posicionamento: calculado dinamicamente para sempre aparecer no centro da viewport.
- `z_index = 101` — fica acima do Lembrete (`z_index 100`).

#### Sistema do Livro de Dicas (acesso)

O **Livro de Dicas** é um guia in-game de consulta durante o gameplay (diferente do tutorial do Quadro, que é pré-gameplay). Ele é instanciado dinamicamente e exibido centralizado na tela. *(conteúdo detalhado na seção [3.3](#33-livro-de-ajuda-livrodicas))*

##### `BtnAbrirLivro` — `TextureButton`
**Script:** `btn_abrir_livro.gd`

| Comportamento | Detalhe |
|---|---|
| 1º clique | Instancia `LivroInstrucao.tscn` dentro do `CenterContainer` e chama `abrir_livro()` |
| 2º clique (livro aberto) | Destroi a instância com `queue_free()` |
| `@export` necessários | `cena_livro: PackedScene` e `container_central: CenterContainer` devem ser atribuídos no Inspetor |

##### `LivroDicas` — `TextureRect`
**Script:** `livro_dicas.gd` | **class_name:** `LivroDicas`

Livro paginado carregado a partir de `res://Scripts/conteudo_livro.gd`. Cada página tem `titulo`, `descricao` e `solucao`.

| Elemento | Função |
|---|---|
| `BtnAnterior` / `BtnProximo` | Navega entre páginas; se escondem na primeira/última página |
| `abrir_livro()` | Reseta para página 0, ativa `MOUSE_FILTER_STOP` e exibe |
| Clique direito | Fecha o livro e reativa `MOUSE_FILTER_IGNORE` |
| Tamanho | 80% da viewport (`custom_minimum_size = tamanho_tela * 0.8`) |

#### Sistema de Inspeção (visão geral)

É o sistema central de gameplay. O jogador clica em regiões do site exibido para inspecioná-las e descobrir elementos suspeitos. *(estrutura detalhada na seção [3.2](#32-módulo-de-inspeção))*

##### `AreaCliqueInspecao` — `Control`
**Script:** `area_clique_inspecao.gd`

Camada invisível sobre o site que captura todos os cliques do jogador.

| Input | Comportamento |
|---|---|
| Clique esquerdo (popup fechado) | Registra posição e abre `NovaAba` via `GerenciadorInspecao` |
| Clique esquerdo (popup aberto) | Ignora — deixa o clique passar para o popup |
| Clique direito | Fecha todos os popups abertos |

##### `GerenciadorInspecao` — `Node`
**Script:** `gerenciador_inspecao.gd`

Coordena toda a lógica de inspeção: abertura da `NovaAba`, verificação de colisão com alvos e exibição do resultado.

**Fluxo de inspeção:**
```
Jogador clica na área
		│
		▼
AreaCliqueInspecao.registrar_clique_na_area(pos)
		│
		▼
NovaAba aparece próxima ao clique
		│
Jogador clica em "Inspecionar"
		│
		▼
_on_botao_inspecionar_pressed()
  ├── Verifica se pos está sobre Alvo1 (suspeito) ou Alvo2/3 (neutros)
  ├── MensagemModal.mostrar(resultado)
  │     ├── Exibe "🔍 Verificando..." por 2s
  │     └── Exibe "⚠️ Alvo detectado!" ou "Nenhum alvo encontrado." por 2s, depois fecha
  └── Após 4s: se acertou, Alvo1 muda de cor para vermelho semitransparente
```

| Nó | Tipo | Papel |
|---|---|---|
| `Alvo1` | `ColorRect` | Região suspeita real — invisível até ser detectada |
| `Alvo2`, `Alvo3` | `ColorRect` | Regiões neutras — não geram alerta |

##### `NovaAba` — `TextureRect`
**Script:** `nova_aba_script.gd`

Menu contextual que aparece próximo ao clique do jogador com o botão "Inspecionar".

```gdscript
signal inspecionar_pressionado
```

- Fecha automaticamente se o jogador clicar fora dela.
- Emite `inspecionar_pressionado` ao confirmar a inspeção.

##### `MensagemModal` — `Control`
**Script:** `mensagem_modal_scpt.gd`

Overlay de resultado da inspeção. Opera com sequência assíncrona via `await`:

```
mostrar(intersectou)
  → "🔍 Verificando..." (2s)
  → "⚠️ Alvo detectado!" ou "Nenhum alvo encontrado." (2s)
  → esconder()
```

- `mouse_filter = MOUSE_FILTER_IGNORE` — não bloqueia input durante exibição.
- `z_index = 100`.

#### Script Principal da Cena

**Script:** `Main_select_script.gd` — `extends Node2D`

Script raiz da cena. Atualmente atua como ponto de entrada e delegador: os gerenciadores filhos cuidam de toda a lógica.

```gdscript
func _on_btn_abrir_livro_pressed() -> void:
	var instancia_livro = cena_livro.instantiate()
	add_child(instancia_livro)
	instancia_livro.abrir_livro()
```

> **Nota:** `_on_botao_inspecionar_pressed()` está vazio no script principal — a lógica de inspeção foi migrada para o `GerenciadorInspecao`.

#### Fluxo Geral da Cena

```
[Tela carrega]
	  │
	  ├── PainelTrabalho ─── hide()
	  ├── LivroDicas ─────── hide() (instanciado sob demanda)
	  ├── NovaAba ─────────── hide()
	  └── MensagemModal ───── hide()

[Durante o gameplay]

  Post-it (Lembrete) clicado
	  │
	  └─► GerenciadorTrabalho → PainelTrabalho.abrir()
			   ├── Aceitar → trabalho_aceito + post-it some
			   └── Ignorar → painel fecha

  Clique na tela (AreaCliqueInspecao)
	  │
	  └─► NovaAba aparece → "Inspecionar"
			   └─► GerenciadorInspecao verifica alvos
						└─► MensagemModal exibe resultado (4s total)
								 └─► Alvo1 muda de cor se acertou

  BtnAbrirLivro clicado
	  └─► LivroDicas instanciado/destruido no CenterContainer
```

---

### 3.2 Módulo de Inspeção

O **ModuloInspecao** é a camada invisível posicionada na frente da tela do computador (site exibido). Ela não é visualmente exibida em condições normais — existe apenas para detectar onde o jogador clica e avaliar se aquela região corresponde a um problema de segurança real.

Atualmente a cena trabalha com **3 alvos fixos** (`Alvo1`, `Alvo2`, `Alvo3`), mas a intenção de design é que tanto a **quantidade de alvos** quanto **quais deles são "problemáticos"** variem de acordo com a dificuldade do trabalho sorteado.

#### Estrutura da Cena (detalhada)

```
ModuloInspecao
└── AreaCliqueInspecao         ← Captura cliques do jogador na tela (Control)
	└── GerenciadorInspecao    ← Lógica de verificação dos alvos (Node)
		├── NovaAba            ← Menu contextual "Inspecionar" (TextureRect)
		│   └── VBoxContainer
		│       └── Button     ← Botão que confirma a inspeção
		├── MensagemModal      ← Feedback textual da inspeção (Control)
		│   └── Label          ← Texto: "Verificando...", "Alvo detectado!", etc.
		├── Alvo1               ← ColorRect: alvo suspeito (ou neutro, dependendo do sorteio)
		├── Alvo2               ← ColorRect: alvo neutro
		├── Alvo3               ← ColorRect: alvo neutro
		└── CaixaSelecao        ← ColorRect auxiliar (script vazio; ver seção 3.1)
```

> Esta estrutura corresponde exatamente ao que já foi documentado na seção 3.1 (scripts `area_clique_inspecao.gd`, `gerenciador_inspecao.gd`, `nova_aba_script.gd`, `mensagem_modal_scpt.gd`, `CaixaDeSelecao.gd`). Esta seção foca no **papel de design** dos alvos dentro do módulo.

#### Lógica dos Alvos

| Nó | Papel atual | Comportamento ao ser inspecionado corretamente |
|---|---|---|
| `Alvo1` | Alvo suspeito (problema real) | Aparece visualmente e muda de cor para vermelho semitransparente (`Color(1, 0, 0, 0.35)`) |
| `Alvo2` | Alvo neutro | Nenhuma alteração visual — inspecioná-lo retorna "Nenhum alvo encontrado." |
| `Alvo3` | Alvo neutro | Mesmo comportamento de `Alvo2` |

- Todos os alvos são `ColorRect` **invisíveis por padrão** — só ficam visíveis quando o jogador acerta a inspeção sobre um alvo problemático.
- A verificação é feita por colisão de retângulos (`get_global_rect().has_point(...)`) entre a posição do clique e a área do alvo.

#### Design Futuro: Variação por Dificuldade

A estrutura atual com `Alvo1`, `Alvo2`, `Alvo3` fixos é o caso-base (dificuldade inicial). O plano de design prevê:

| Aspecto | Comportamento planejado |
|---|---|
| **Quantidade de alvos** | Aumenta conforme a dificuldade do trabalho (mais áreas clicáveis = mais lugares para checar) |
| **Quantidade de alvos problemáticos** | Pode haver mais de 1 alvo suspeito em trabalhos mais difíceis |
| **Distribuição/sorteio** | Provavelmente precisará de um sistema que sorteie dinamicamente quais `ColorRect` são "problemáticos" a cada rodada, em vez de fixar isso na cena |

> **Implicação técnica:** o array `alvos_neutros` em `gerenciador_inspecao.gd` (atualmente fixo como `[$Alvo2, $Alvo3]`) provavelmente precisará ser refatorado para algo dinâmico — por exemplo, receber a lista de alvos problemáticos vs. neutros a partir dos dados do trabalho sorteado (`DadosJogo.banco_de_trabalhos`), em vez de hardcoded por nome de nó.

---

### 3.3 Livro de Ajuda (LivroDicas)

O **Livro de Ajuda** é um manual de consulta disponível durante o expediente, na cena **Tela**, acessado por um botão no canto inferior direito (`BtnAbrirLivro`). Diferente do tutorial do Quadro (que ensina controles e mecânicas), este livro contém o **catálogo dos problemas de segurança** que o jogador pode encontrar durante o trabalho — cada capítulo é dividido em três partes: nome do problema, como identificar e como resolver.

O jogador pode abrir e fechar o livro **quantas vezes quiser** durante o expediente, sem penalidade.

> A estrutura técnica do botão (`btn_abrir_livro.gd`) e do componente (`livro_dicas.gd`) já foi documentada na seção 3.1. Esta seção foca no **conteúdo** do livro, detalhado pelo arquivo `conteudo_livro.gd`.

#### Estrutura Interna do Livro

```
LivroDicas (TextureRect)
├── LabelTitulo      ← Nome do problema (ex: "Capítulo 1 — Phishing")
├── LabelProblema     ← Texto explicando como identificar o problema
├── LabelSolucao      ← Texto explicando como agir/resolver
├── BtnProximo        ← Avança para o próximo capítulo
└── BtnAnterior       ← Volta para o capítulo anterior
```

Cada página é populada a partir de um dicionário com três chaves: `titulo`, `descricao` (identificação do problema) e `solucao` (como agir).

#### Fonte de Dados — `conteudo_livro.gd`

**Classe:** `ConteudoLivro` (`extends RefCounted`)

Contém o array `PAGINAS: Array[Dictionary]` com **10 capítulos** atualmente implementados, cobrindo temas de segurança digital:

| # | Capítulo | Tema |
|---|---|---|
| 1 | Phishing | E-mails falsos pedindo dados/ação urgente |
| 2 | Perfil Falso | Identificação de contas falsas em redes sociais |
| 3 | Site Malicioso | Verificação de URLs e cadeado de segurança |
| 4 | Ransomware | Sequestro de arquivos por malware |
| 5 | Engenharia Social | Manipulação via telefone/mensagem se passando por suporte |
| 6 | Senha Fraca | Boas práticas de criação de senha |
| 7 | Wi-Fi Público | Riscos de redes abertas e uso de VPN |
| 8 | Atualização Ignorada | Importância de manter sistemas atualizados |
| 9 | Permissões Excessivas | Revisão de permissões de apps |
| 10 | Vazamento de Dados | Resposta a vazamentos (ex: haveibeenpwned) |

Cada capítulo segue o padrão narrativo: contextualização do problema em tom de conversa ("Sabe aquele e-mail que parece ser do seu banco...") seguido de um bloco prático "Como agir:" com passos objetivos.

> **Observação:** apesar do comentário no código mencionar "12 capítulos estruturados", o array contém atualmente **10 capítulos** (índices 0–9).

#### Relação com o Sistema de Inspeção

Atualmente, os capítulos do livro (problemas de segurança como phishing, perfil falso, site malicioso etc.) são conceitualmente diferentes dos "trabalhos" do `DadosJogo.banco_de_trabalhos`, que tratam de manutenção técnica genérica (remover vírus, limpar disco, atualizar drivers). Os dois bancos de dados ainda não compartilham uma referência cruzada direta:

| Sistema | Fonte | Conteúdo |
|---|---|---|
| Lembretes/Trabalhos | `DadosJogo.banco_de_trabalhos` | Tarefas de manutenção (título, descrição, recompensa) |
| Livro de Ajuda | `ConteudoLivro.PAGINAS` | Catálogo educativo de ameaças de segurança (título, problema, solução) |

> **Nota de design:** pode ser interessante, no futuro, vincular cada `Alvo` problemático do Módulo de Inspeção a um capítulo específico do livro — assim o jogador consulta exatamente o capítulo relevante para o problema que está enfrentando, em vez de navegar por todos os 10 capítulos.

---

## 4. Estado Geral do Projeto

### 1. Escritório

| Funcionalidade | Status |
|---|---|
| Fundo visual do escritório | ✅ Implementado |
| Quadro de avisos interativo | ✅ Implementado |
| Transição para loop de gameplay | ✅ Implementado |
| Cafeteira com texto de boas-vindas | ✅ Implementado |
| Outras interações no escritório | 🔲 A implementar |

### 2. Quadro de Avisos

| Funcionalidade | Status |
|---|---|
| Fundo visual do quadro | ✅ Implementado |
| Botão para abrir tutorial | ✅ Implementado |
| Tutorial como CanvasLayer | ✅ Implementado |
| Fechar tutorial com clique direito | ✅ Implementado |
| Atalho de teclado (Espaço) | ✅ Implementado |
| Voltar ao escritório com clique direito | ✅ Implementado |
| Conteúdo do tutorial (textos de controles/guias) | 🔲 A expandir |
| Mais papéis/botões no quadro | 🔲 A implementar |

### 3.1 Tela de Gameplay

| Funcionalidade | Status |
|---|---|
| Site suspeito exibido na tela | ✅ Implementado |
| Post-its com tarefas aleatórias | ✅ Implementado |
| Painel de detalhes do trabalho | ✅ Implementado |
| Aceitar/Ignorar tarefa | ✅ Implementado |
| Sistema de clique e inspeção | ✅ Implementado e validado (ver [seção 6](#6-refatoração-do-sistema-de-alvos-de-inspeção)) |
| Menu contextual (NovaAba) | ✅ Implementado |
| Feedback de inspeção com delay | ✅ Implementado |
| Alvo suspeito com mudança de cor | ✅ Implementado |
| Livro de Dicas paginado | ✅ Implementado |
| Post-it aceita trabalho → monta alvos na tela | 🔴 Quebrado — ver pendência do `Lembrete` na [seção 6](#6-refatoração-do-sistema-de-alvos-de-inspeção); contornado com atalho de teste temporário |
| Múltiplos alvos suspeitos por cena | 🔶 Infraestrutura pronta, não testado com múltiplos suspeitos reais |
| Pontuação / recompensa visível ao jogador | 🔲 A implementar |
| TimerLembrete (ciclo de novos post-its) | 🔲 A implementar |
| Condição de fim de dia / loop completo | 🔲 A implementar |

### 3.2 Módulo de Inspeção

| Funcionalidade | Status |
|---|---|
| 3 alvos fixos (1 suspeito + 2 neutros) | ✅ Substituído — ver [seção 6](#6-refatoração-do-sistema-de-alvos-de-inspeção) |
| Detecção de clique por colisão de retângulo | ✅ Implementado (agora via `Area2D`/`Rect2`, não mais `ColorRect` fixo) |
| Feedback visual ao acertar o alvo suspeito | ✅ Implementado |
| Alvos dinâmicos via Resource (`AlvoInspecao`) | ✅ Implementado |
| Variação de quantidade de alvos por dificuldade | 🔶 Infraestrutura pronta (array de alvos por trabalho); ainda não usado com dificuldade variável de verdade |
| Variação de quais alvos são problemáticos por dificuldade | 🔶 Infraestrutura pronta; só 1 trabalho tem alvo calibrado |
| Sorteio dinâmico de alvos suspeitos/neutros | 🔲 A implementar — hoje os alvos de cada trabalho são fixos, não sorteados |

### 3.3 Livro de Ajuda

| Funcionalidade | Status |
|---|---|
| Estrutura paginada do livro (título, problema, solução) | ✅ Implementado |
| 10 capítulos de conteúdo educativo | ✅ Implementado |
| Navegação entre páginas (anterior/próximo) | ✅ Implementado |
| Abrir/fechar livremente durante o expediente | ✅ Implementado |
| Vínculo entre capítulos do livro e alvos da inspeção | 🔲 A implementar |
| Expansão para 12+ capítulos (mencionado em comentário) | 🔲 A implementar |

---

## 5. Observações Gerais para Desenvolvimento Futuro

### Escritório
- Pode receber mais elementos interativos conforme o jogo evolui (ex: computador, telefone, documentos na mesa).
- O `Label` "Comece o dia!" na Cafeteira pode futuramente ser substituído por um sistema de diálogo ou tutorial introdutório.
- Avaliar se `Iniciar.gd` e `texture_button-Quadro.gd` devem ser unificados ou mantidos separados conforme a cena `Tela.tscn` for desenvolvida.

### Quadro de Avisos
- O conteúdo do `Layer_Tutorial_1 > TextureRect` pode ser expandido para incluir múltiplas páginas (ex: paginação com setas, como o `LivroDicas`).
- O atalho de teclado `ui_accept` (Espaço/Enter) pode ser removido ou rebatizado quando o jogo tiver um sistema de input customizado consolidado.
- Avaliar se a dupla conexão do botão (via `@export` no script geral + `@onready` no script do botão) deve ser simplificada para uma única abordagem.

### Tela de Gameplay
- `button-inspecionar.gd` é uma versão anterior do sistema de inspeção (acessa `caixa_selecao` diretamente e usa `$NovaAba` por caminho). Pode ser removido quando o `GerenciadorInspecao` estiver consolidado.
- `CaixaDeSelecao.gd` está intencionalmente vazio — toda lógica de posição/dimensão fica no `GerenciadorInspecao`. Isso é correto e deve ser mantido.
- O `TimerLembrete` aparece na árvore mas ainda não tem script documentado.
- `DadosJogo` (Autoload com `banco_de_trabalhos`) merece uma seção própria quando o sistema de dados for expandido.

### Módulo de Inspeção
- Ao implementar a variação por dificuldade, considerar gerar os `ColorRect` dinamicamente via código (`instantiate()` em loop) em vez de manter nós fixos na cena, já que a quantidade será variável.
- O `gerenciador_inspecao.gd` precisará receber a informação de dificuldade do trabalho atual (provavelmente vinda do `Lembrete` sorteado) para decidir quantos alvos problemáticos gerar.
- Vale revisar se `CaixaSelecao` continuará sem uso ou se será reaproveitada quando o sistema de múltiplos alvos for implementado.

### Livro de Ajuda
- Avaliar se vale unificar `DadosJogo.banco_de_trabalhos` e `ConteudoLivro.PAGINAS` em uma estrutura só, já que ambos representam "tipos de problema" — isso facilitaria a vinculação direta entre o trabalho sorteado, os alvos gerados na inspeção e o capítulo correspondente no livro.
- O comentário "12 capítulos" no código sugere que mais 2 capítulos estavam planejados; vale confirmar se serão adicionados.
- Como o livro pode ser aberto quantas vezes o jogador quiser, ele funciona como uma mecânica de "consulta sem penalidade" — isso deve ser levado em conta no balanceamento de dificuldade (ex: se haverá um custo de tempo ou recompensa reduzida por consultar o livro).

---

## 6. Refatoração do Sistema de Alvos de Inspeção

> Refatoração realizada para substituir os alvos fixos (`Alvo1`, `Alvo2`, `Alvo3`) por um sistema orientado a dados usando `Resource`, permitindo que a quantidade e a posição dos alvos variem por trabalho/dificuldade sem editar a cena manualmente.

### 6.1 Motivação

O sistema antigo (documentado nas seções 3.1/3.2) dependia de nós `ColorRect` fixos na cena (`$Alvo1`, `$Alvo2`, `$Alvo3`), com o array `alvos_neutros` apontando pra eles por nome. Isso tornava impossível variar a quantidade de alvos por trabalho sem editar a cena `Tela.tscn` manualmente a cada vez — bloqueando o item "Design Futuro: Variação por Dificuldade" já previsto na seção 3.2 original.

### 6.2 Novos Scripts

| Arquivo | Tipo | Papel |
|---|---|---|
| `alvo_inspecao.gd` (`class_name AlvoInspecao`) | `Resource` | Dado puro de um alvo: `tipo` (enum `Tipo.SUSPEITO`/`Tipo.NEUTRO`), `posicao`, `tamanho`, `capitulo_relacionado` (índice em `ConteudoLivro.PAGINAS`, -1 = nenhum) |
| `trabalho_inspecao.gd` (`class_name TrabalhoInspecao`) | `Resource` | Empacota um trabalho completo: `titulo`, `descricao`, `recompensa_base`, `imagem_site` (`Texture2D`), `alvos` (`Array[AlvoInspecao]`) |
| `area_alvo.gd` (`class_name AreaAlvo`) | `Area2D` (nó real) | Criado dinamicamente em runtime por `GerenciadorInspecao`; carrega uma propriedade `dados: AlvoInspecao` tipada, evitando `set_meta`/`get_meta` não tipado |

`AlvoInspecao` e `TrabalhoInspecao` não são nós — não aparecem na árvore de cena, não têm `_ready()`. `AreaAlvo` é o único nó real, criado via `AreaAlvo.new()` dentro de `GerenciadorInspecao._criar_area_para_alvo()`, um por alvo, agrupado em `"alvo_dinamico"` (grupo usado para achar todos os alvos ativos sem depender de nome de nó).

### 6.3 `gerenciador_inspecao.gd` — reescrito

Funções principais (mantendo os nomes que o resto do projeto já chamava, para não quebrar `area_clique_inspecao.gd`):

| Função | Papel |
|---|---|
| `montar_alvos(trabalho: TrabalhoInspecao)` | Limpa alvos antigos e cria um `AreaAlvo` por `AlvoInspecao` da lista do trabalho |
| `_criar_area_para_alvo(dados: AlvoInspecao)` | Cria o `Area2D` + `CollisionShape2D` com a posição/tamanho do Resource |
| `limpar_alvos()` | Remove todos os nós do grupo `"alvo_dinamico"` antes de montar um novo trabalho |
| `registrar_clique_na_area(pos)` | Recebida do `AreaCliqueInspecao`; posiciona e mostra a `NovaAba` |
| `fechar_todos_os_popups()` | Esconde `NovaAba` e `MensagemModal` (nome preservado do script original) |
| `esta_com_popup_aberto()` | Usado por `AreaCliqueInspecao` para decidir se deixa o clique passar (nome preservado do script original) |
| `verificar_clique(pos)` | Percorre o grupo `"alvo_dinamico"`, monta `Rect2(area.global_position, dados.tamanho)` e testa `has_point(pos)` |
| `_on_botao_inspecionar_pressed()` | Fluxo principal: fecha popups, verifica clique, aciona `MensagemModal`, revela o alvo se acertou |

**Ponto de atenção herdado do script original:** `_ready()` precisa esconder tanto `nova_aba` quanto `mensagem_modal` — esquecer de esconder `mensagem_modal` faz `esta_com_popup_aberto()` retornar `true` desde o início do jogo, bloqueando todo clique silenciosamente (sem erro no console).

### 6.4 Migração de `DadosJogo.gd`

`banco_de_trabalhos` mudou de `Array[Dictionary]` para `Array[TrabalhoInspecao]`. Duas formas possíveis de popular o array (ambas documentadas, só a primeira adotada até agora):

- **Opção A (adotada):** trabalhos montados em código, no `_ready()` do `DadosJogo`, via funções `_criar_trabalho_*()` que fazem `AlvoInspecao.new()`/`TrabalhoInspecao.new()` e preenchem os campos diretamente.
- **Opção B (não adotada ainda):** trabalhos salvos como arquivos `.tres` no editor (`res://Resources/Trabalhos/`), carregados via `preload()`. Requer ter a arte do site pronta antes, pra calibrar a posição dos alvos olhando a imagem.

**Estado atual dos 5 trabalhos:** apenas "Remover Cavalo de Tróia" tem o alvo suspeito com posição calibrada de verdade (`Posicao (101, 45)`, `Tamanho (432, 70)`, obtida sobrepondo um `ColorRect` de referência à arte e lendo os valores no Inspetor). Os outros 4 trabalhos ainda têm posições de exemplo/placeholder que não correspondem a nenhuma arte real.

Cada `Lembrete` (post-it) não sobrescreve `trabalho.recompensa_base` — a variação aleatória de recompensa (`± randi_range(-15, 25)`) fica numa variável local da instância do post-it, porque `Resource`s são compartilhados por referência entre todos os `Lembrete`s que sorteiam o mesmo trabalho.

### 6.5 Sinais atualizados (assinatura mudou)

| Sinal | Assinatura nova | Emitido por | Escutado por |
|---|---|---|---|
| `foi_clicado` | `(trabalho: TrabalhoInspecao, titulo: String, descricao: String, recompensa: int, lembrete_clicado: TextureButton)` | `lembrete.gd` | `gerenciador_trabalho.gd` |
| `trabalho_aceito` | `(trabalho: TrabalhoInspecao, recompensa: int)` | `painel_trabalho.gd` | `Main_select_script.gd` |

`Main_select_script.gd` é o único ponto que conhece tanto `PainelTrabalho` quanto `GerenciadorInspecao` — ao receber `trabalho_aceito`, ele troca `site_textura.texture` por `trabalho.imagem_site` e chama `gerenciador_inspecao.montar_alvos(trabalho)`. Essa ponte foi colocada propositalmente aqui, e não dentro de `PainelTrabalho` nem de `GerenciadorTrabalho`, pra manter esses dois scripts sem conhecimento do módulo de inspeção.

### 6.6 Bug de engine descoberto: `_gui_input` sobrescrito quebra `TextureButton`

Durante a depuração, o clique esquerdo no `Lembrete` parou de emitir `pressed` (e portanto `foi_clicado`) sem nenhum erro no console. Causa: `lembrete.gd` sobrescrevia o método virtual `_gui_input()` só pra detectar clique direito — mas isso substitui completamente a lógica interna do `TextureButton` que gera o sinal `pressed`, matando a detecção de clique esquerdo.

**Correção aplicada:** trocado o `override` do método virtual `_gui_input()` por uma conexão ao **sinal** `gui_input` (`gui_input.connect(_on_gui_input)` no `_ready()`), que roda em paralelo ao processamento interno do botão em vez de substituí-lo. Vale revisar `painel_trabalho.gd` se algum botão dele parar de responder no futuro — mesmo padrão de causa.

### 6.7 Pendência conhecida: `Lembrete` ainda não abre o `PainelTrabalho`

Mesmo depois da correção da seção 6.6, o clique no post-it continua não disparando `_on_pressed` (confirmado com `print()` de depuração — nada aparecia no Output). Causa raiz ainda não identificada; próximos pontos a investigar: `mouse_filter` do `Lembrete`, outro nó sobrepondo-o na árvore, ou ordem de `z_index`.

**Contorno temporário adotado:** `Main_select_script._ready()` chama uma função `_testar_montagem_direta()` que monta `DadosJogo.banco_de_trabalhos[0]` direto na tela, sem depender do fluxo post-it → painel → aceitar. Está marcada com comentário `TEMPORÁRIO` no código e deve ser removida quando o sistema de trabalho (`Lembrete`/`GerenciadorTrabalho`/`PainelTrabalho`) for remodelado — remodelagem essa que ficou planejada para uma sessão futura, possivelmente revisando a arquitetura inteira desses três scripts em vez de só corrigir o bug pontual do clique.

### 6.8 Lição: duas fontes de dados podem desalinhar

Durante a calibração, um `AlvoInspecao` foi criado como `.tres` avulso no editor (posição `101,45`/tamanho `432,70`, calibrada visualmente com um `ColorRect` de referência) — mas o trabalho "Remover Cavalo de Tróia" em `DadosJogo.gd` continuava usando as coordenadas de exemplo escritas em código (`Vector2(300, 150)`). Resultado: a detecção de clique "funcionava" (sem erro), mas nunca reconhecia cliques na área visualmente calibrada, porque os dois retângulos não se sobrepunham. Lição: ao trabalhar com múltiplas fontes de dados equivalentes (Resource avulso no editor vs. dado escrito em código), confirmar sempre qual delas está de fato conectada ao fluxo em execução antes de investigar bugs de coordenada.

### 6.9 Itens de limpeza pendentes (baixa prioridade)

- Remover os `print()` de depuração temporários adicionados em `area_clique_inspecao.gd`, `gerenciador_inspecao.gd` e `lembrete.gd` durante a investigação (a maioria já foi removida; conferir se sobrou algum).
- Calibrar posição/tamanho dos alvos dos 4 trabalhos restantes em `DadosJogo.gd` (hoje com posições de exemplo).
- Preencher `imagem_site` dos `TrabalhoInspecao` com artes reais (hoje comentado/vazio).
- `Alvo1`, `Alvo2`, `Alvo3`, `CaixaSelecao` continuam existindo como nós na cena `modulo_inspecao.tscn`, mas não são mais usados pelo `GerenciadorInspecao` novo — candidatos a remoção após validação completa.
- Remover `_testar_montagem_direta()` de `Main_select_script.gd` quando o sistema de trabalho for remodelado (ver seção 6.7).
