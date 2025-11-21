class_name Minotaur
extends Enemy

const MINO_TEX_1: Texture2D = preload("res://assets/minotaur-1.png")
const MINO_TEX_2: Texture2D = preload("res://assets/minotaur-2.png")

func _ready() -> void:
	enemy_type = &"minotaur"
	if corpse_texture == null:
		corpse_texture = MINO_TEX_2
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		if sprite.texture == null:
			sprite.texture = MINO_TEX_1
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func setup(cell: Vector2i) -> void:
	enemy_type = &"minotaur"
	configure(cell, 2, MINO_TEX_2)
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		sprite.texture = MINO_TEX_1
