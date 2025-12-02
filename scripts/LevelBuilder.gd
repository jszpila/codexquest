class_name LevelBuilder
extends RefCounted

var _rng: RandomNumberGenerator

func _init(rng: RandomNumberGenerator) -> void:
	_rng = rng

func build_test_map(
	floor_map: TileMap,
	walls_map: TileMap,
	grid_size: Vector2i,
	sources_floor: Array[int],
	sources_wall: Array[int],
	tile_floor: Vector2i,
	tile_wall: Vector2i,
	floor_alpha_min: float,
	floor_alpha_max: float
) -> void:
	var ts: TileSet = floor_map.tile_set
	if ts == null:
		push_warning("TileSet missing on Floor TileMap")
		return
	for sid in sources_floor:
		var srcf: TileSetAtlasSource = ts.get_source(sid)
		if srcf != null and not srcf.has_tile(tile_floor):
			srcf.create_tile(tile_floor)
	for sid in sources_wall:
		var srcw: TileSetAtlasSource = ts.get_source(sid)
		if srcw != null and not srcw.has_tile(tile_wall):
			srcw.create_tile(tile_wall)
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var fsid: int = sources_floor[_rng.randi_range(0, sources_floor.size() - 1)]
			var c := Vector2i(x, y)
			floor_map.set_cell(0, c, fsid, tile_floor)
			_randomize_floor_wall_transform(floor_map, c)
			_set_random_tile_opacity(floor_map, c, floor_alpha_min, floor_alpha_max)
	for x in range(grid_size.x):
		var wsid_top: int = sources_wall[_rng.randi_range(0, sources_wall.size() - 1)]
		var wsid_bottom: int = sources_wall[_rng.randi_range(0, sources_wall.size() - 1)]
		var ctop := Vector2i(x, 0)
		var cbottom := Vector2i(x, grid_size.y - 1)
		walls_map.set_cell(0, ctop, wsid_top, tile_wall)
		_randomize_floor_wall_transform(walls_map, ctop)
		walls_map.set_cell(0, cbottom, wsid_bottom, tile_wall)
		_randomize_floor_wall_transform(walls_map, cbottom)
	for y in range(grid_size.y):
		var wsid_left: int = sources_wall[_rng.randi_range(0, sources_wall.size() - 1)]
		var wsid_right: int = sources_wall[_rng.randi_range(0, sources_wall.size() - 1)]
		var cleft := Vector2i(0, y)
		var cright := Vector2i(grid_size.x - 1, y)
		walls_map.set_cell(0, cleft, wsid_left, tile_wall)
		_randomize_floor_wall_transform(walls_map, cleft)
		walls_map.set_cell(0, cright, wsid_right, tile_wall)
		_randomize_floor_wall_transform(walls_map, cright)

func place_random_inner_walls(
	grid_size: Vector2i,
	walls_map: TileMap,
	sources_wall: Array[int],
	tile_wall: Vector2i,
	is_blocked: Callable
) -> void:
	var count := _rng.randi_range(50, 250)
	var placed := 0
	var attempts := 0
	while placed < count and attempts < count * 20:
		attempts += 1
		var c := random_interior_cell(grid_size)
		if is_blocked.call(c):
			continue
		if walls_map.get_cell_source_id(0, c) != -1:
			continue
		var wsid: int = sources_wall[_rng.randi_range(0, sources_wall.size() - 1)]
		walls_map.set_cell(0, c, wsid, tile_wall)
		placed += 1

func random_interior_cell(grid_size: Vector2i) -> Vector2i:
	var x := _rng.randi_range(1, grid_size.x - 2)
	var y := _rng.randi_range(1, grid_size.y - 2)
	return Vector2i(x, y)

func pick_free_interior_cell(
	grid_size: Vector2i,
	exclude: Array[Vector2i],
	is_free: Callable,
	has_free_neighbor: Callable,
	require_neighbor: bool = true
) -> Vector2i:
	var pool: Array[Vector2i] = []
	for y in range(1, grid_size.y - 1):
		for x in range(1, grid_size.x - 1):
			var c := Vector2i(x, y)
			if exclude.has(c):
				continue
			if not is_free.call(c):
				continue
			if require_neighbor and not has_free_neighbor.call(c):
				continue
			pool.append(c)
	if pool.is_empty() and require_neighbor:
		return pick_free_interior_cell(grid_size, exclude, is_free, has_free_neighbor, false)
		if pool.is_empty():
			for y in range(1, grid_size.y - 1):
				for x in range(1, grid_size.x - 1):
					var c2 := Vector2i(x, y)
					if exclude.has(c2):
						continue
					if not is_free.call(c2):
						continue
					pool.append(c2)
			if pool.is_empty():
				var fallback_x: int = clamp(int(grid_size.x / 2), 1, max(grid_size.x - 2, 1))
				var fallback_y: int = clamp(int(grid_size.y / 2), 1, max(grid_size.y - 2, 1))
				return Vector2i(fallback_x, fallback_y)
	return pool[_rng.randi_range(0, pool.size() - 1)]

func _randomize_floor_wall_transform(tm: TileMap, cell: Vector2i) -> void:
	var choice := _rng.randi_range(0, 5)
	var flip_h := false
	var flip_v := false
	var transpose := false
	match choice:
		0:
			pass
		1:
			transpose = true
			flip_h = true
		2:
			flip_h = true
			flip_v = true
		3:
			transpose = true
			flip_v = true
		4:
			flip_h = true
		5:
			flip_v = true
	var td := tm.get_cell_tile_data(0, cell)
	if td != null:
		td.flip_h = flip_h
		td.flip_v = flip_v
		td.transpose = transpose

func _set_random_tile_opacity(tm: TileMap, cell: Vector2i, min_alpha: float, max_alpha: float) -> void:
	var td := tm.get_cell_tile_data(0, cell)
	if td == null:
		return
	var alpha := _rng.randf_range(min_alpha, max_alpha)
	var modulate_color := td.modulate
	modulate_color.a = alpha
	td.modulate = modulate_color
