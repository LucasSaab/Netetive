extends Node2D
class_name DesenhoLabirinto

const COR_PAREDE := Color(1.0, 0.25, 0.25)
const ESPESSURA := 4.0

var _segmentos: Array = []


func atualizar_segmentos(segmentos: Array) -> void:
	_segmentos = segmentos
	queue_redraw()


func _draw() -> void:
	for seg in _segmentos:
		var alpha: float = seg.get("alpha", 1.0)
		draw_line(seg.inicio, seg.fim, Color(COR_PAREDE.r, COR_PAREDE.g, COR_PAREDE.b, alpha), ESPESSURA)
