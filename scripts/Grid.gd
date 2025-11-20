class_name Grid
extends Node

const CELL_SIZE := 12

static func world_to_cell(pos: Vector2) -> Vector2i:
    return Vector2i(floor(pos.x / CELL_SIZE), floor(pos.y / CELL_SIZE))

static func cell_to_world(cell: Vector2i) -> Vector2:
    return Vector2(cell.x * CELL_SIZE, cell.y * CELL_SIZE)

