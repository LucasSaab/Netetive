class_name GeradorLabirinto
extends RefCounted

const LADOS := ["norte", "sul", "leste", "oeste"]
const OPOSTO := {"norte": "sul", "sul": "norte", "leste": "oeste", "oeste": "leste"}


static func gerar(linhas: int, colunas: int) -> Dictionary:
	var paredes: Dictionary = {}
	for l in range(linhas):
		for c in range(colunas):
			var indice := l * colunas + c
			paredes[indice] = {"norte": true, "sul": true, "leste": true, "oeste": true}

	var visitados: Dictionary = {}
	var pilha: Array = []
	var inicio := randi() % (linhas * colunas)
	visitados[inicio] = true
	pilha.append(inicio)

	while not pilha.is_empty():
		var atual: int = pilha.back()
		@warning_ignore("integer_division")
		var l: int = atual / colunas
		var c: int = atual % colunas

		var candidatos_bons: Array = []
		var candidatos_de_reserva: Array = []

		for lado in LADOS:
			var vl := l
			var vc := c
			match lado:
				"norte": vl -= 1
				"sul": vl += 1
				"leste": vc += 1
				"oeste": vc -= 1

			if vl < 0 or vl >= linhas or vc < 0 or vc >= colunas:
				continue

			var indice_vizinho_candidato := vl * colunas + vc
			if visitados.has(indice_vizinho_candidato):
				continue

			var candidato := {"indice": indice_vizinho_candidato, "lado": lado}
			var abre_demais := _abriria_demais(paredes, atual, lado, l, c, linhas, colunas) \
				or _abriria_demais(paredes, indice_vizinho_candidato, OPOSTO[lado], vl, vc, linhas, colunas)


			if abre_demais:
				candidatos_de_reserva.append(candidato)
			else:
				candidatos_bons.append(candidato)

		# Conectividade nunca é sacrificada pela regra estética — só usa
		# um candidato "de reserva" quando não sobra NENHUM bom.
		var pool: Array = candidatos_bons if not candidatos_bons.is_empty() else candidatos_de_reserva

		if pool.is_empty():
			pilha.pop_back()
			continue

		var escolhido: Dictionary = pool[randi() % pool.size()]
		var vizinho_indice: int = escolhido.indice
		var lado: String = escolhido.lado

		paredes[atual][lado] = false
		paredes[vizinho_indice][OPOSTO[lado]] = false

		visitados[vizinho_indice] = true
		pilha.append(vizinho_indice)

	return paredes


static func _abriria_demais(paredes: Dictionary, indice: int, _lado: String, l: int, c: int, linhas: int, colunas: int) -> bool:
	var lados_disponiveis := 0
	var abertos_atuais := 0

	for lado_check in LADOS:
		var vl := l
		var vc := c
		match lado_check:
			"norte": vl -= 1
			"sul": vl += 1
			"leste": vc += 1
			"oeste": vc -= 1

		if vl < 0 or vl >= linhas or vc < 0 or vc >= colunas:
			continue

		lados_disponiveis += 1
		if not paredes[indice][lado_check]:
			abertos_atuais += 1

	return (abertos_atuais + 1) >= lados_disponiveis
