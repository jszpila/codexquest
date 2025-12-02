extends RefCounted
class_name GridUtilities

## Static utility functions for grid-related operations
## Extracted from Main.gd to improve code organization

static func is_in_bounds(cell: Vector2i, grid_size: Vector2i) -> bool:
	"""Check if a cell is within grid bounds"""
	return cell.x >= 0 and cell.y >= 0 and cell.x < grid_size.x and cell.y < grid_size.y

static func is_in_interior(cell: Vector2i, grid_size: Vector2i) -> bool:
	"""Check if a cell is in the interior (not on border)"""
	return cell.x >= 1 and cell.y >= 1 and cell.x < grid_size.x - 1 and cell.y < grid_size.y - 1

static func bresenham(a: Vector2i, b: Vector2i) -> Array[Vector2i]:
	"""Bresenham line algorithm - returns array of points"""
	var points: Array[Vector2i] = []
	bresenham_to_buffer(a, b, points)
	return points

static func bresenham_to_buffer(a: Vector2i, b: Vector2i, buffer: Array[Vector2i]) -> void:
	"""Bresenham line algorithm - writes to provided buffer for performance"""
	buffer.clear()
	var x0: int = a.x
	var y0: int = a.y
	var x1: int = b.x
	var y1: int = b.y
	var dx: int = abs(x1 - x0)
	var sx: int = (1 if x0 < x1 else -1)
	var dy: int = -abs(y1 - y0)
	var sy: int = (1 if y0 < y1 else -1)
	var err: int = dx + dy
	while true:
		buffer.append(Vector2i(x0, y0))
		if x0 == x1 and y0 == y1:
			break
		var e2: int = 2 * err
		if e2 >= dy:
			err += dy
			x0 += sx
		if e2 <= dx:
			err += dx
			y0 += sy

