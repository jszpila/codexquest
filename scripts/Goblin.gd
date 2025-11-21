class_name Goblin
extends Enemy

const GOBLIN_TEX: Texture2D = preload("res://assets/goblin-1.png")
const DEAD_TEX: Texture2D = preload("res://assets/goblin-2.png")

func _ready() -> void:
	enemy_type = &"goblin"
	if corpse_texture == null:
		corpse_texture = DEAD_TEX
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		if sprite.texture == null:
			sprite.texture = GOBLIN_TEX
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func setup(cell: Vector2i) -> void:
	enemy_type = &"goblin"
	configure(cell, 1, DEAD_TEX)
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		sprite.texture = GOBLIN_TEX

func take_turn(player_cell: Vector2i, rng: RandomNumberGenerator, can_step: Callable) -> void:
	if not alive:
		return
	if rng.randf() > 0.75:
		return
	var dirs: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]
	var dir := dirs[rng.randi_range(0, dirs.size() - 1)]
	var dest := grid_cell + dir
	if not can_step.call(dest, self):
		return
	set_cell(dest)
