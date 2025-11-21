class_name Zombie
extends Enemy

const ZOMBIE_TEX_1: Texture2D = preload("res://assets/zombie-1.png")
const ZOMBIE_TEX_2: Texture2D = preload("res://assets/zombie-2.png")

func _ready() -> void:
	enemy_type = &"zombie"
	if corpse_texture == null:
		corpse_texture = ZOMBIE_TEX_2
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		if sprite.texture == null:
			sprite.texture = ZOMBIE_TEX_1
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func setup(cell: Vector2i) -> void:
	enemy_type = &"zombie"
	configure(cell, 1, ZOMBIE_TEX_2)
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		sprite.texture = ZOMBIE_TEX_1
