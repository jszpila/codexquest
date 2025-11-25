class_name Goblin
extends Enemy

func _ready() -> void:
	enemy_type = &"goblin"
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func setup(cell: Vector2i, live_tex: Texture2D, corpse_tex: Texture2D) -> void:
	enemy_type = &"goblin"
	configure(cell, 1, corpse_tex)
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite and live_tex:
		sprite.texture = live_tex
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

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
