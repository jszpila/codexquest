class_name Trap
extends Node2D

var grid_cell: Vector2i = Vector2i.ZERO
var sprite: Sprite2D

func setup(cell: Vector2i, tex: Texture2D) -> void:
	grid_cell = cell
	global_position = Grid.cell_to_world(cell)
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.centered = false
		add_child(sprite)
	sprite.texture = tex
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
