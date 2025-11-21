class_name Item
extends Node2D

@export var item_type: StringName = &"item"
var grid_cell: Vector2i = Vector2i.ZERO
var collected: bool = false

func place(cell: Vector2i) -> void:
	grid_cell = cell
	global_position = Grid.cell_to_world(cell)
	collected = false
	visible = true

func collect() -> void:
	collected = true
	visible = false
