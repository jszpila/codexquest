#!/usr/bin/env -S godot4 --headless --path . --script
extends SceneTree

# Lightweight test runner (no external deps). Run with:
# godot4 --headless --path . --script res://tests/run_tests.gd

var _failures: Array[String] = []

func _init() -> void:
	_run()
	quit(0 if _failures.is_empty() else 1)

func _run() -> void:
	_test_grid_round_trip()
	_test_weighted_floor_sources()
	_test_enemy_registry()
	_test_bresenham_line()
	_test_player_sprite_ranged_switch()
	_test_melee_only_level_one_visibility()
	_test_imp_targeting()
	_test_imp_miss_curve()
	if not _failures.is_empty():
		for f in _failures:
			printerr(f)
	else:
		print("All tests passed (%d)" % 8)

func _assert_true(cond: bool, msg: String) -> void:
	if not cond:
		_failures.append(msg)

func _assert_eq(a, b, msg: String) -> void:
	if a != b:
		_failures.append("%s (expected=%s actual=%s)" % [msg, str(b), str(a)])

func _test_grid_round_trip() -> void:
	var cell := Vector2i(5, 7)
	var world := Grid.cell_to_world(cell)
	var back := Grid.world_to_cell(world)
	_assert_eq(back, cell, "Grid round-trip should return original cell")

func _test_weighted_floor_sources() -> void:
	var main_script: Script = load("res://scripts/Main.gd")
	var main: Node = main_script.new()
	var base: Array = [1, 2]
	var shared: Array = [3]
	var weighted: Array = main._build_weighted_floor_sources(base, shared, 0.25)
	_assert_eq(weighted.size(), 100, "Weighted floor sources should have 100 buckets")
	var shared_count := 0
	for id in weighted:
		if id == 3:
			shared_count += 1
	_assert_true(shared_count >= 20 and shared_count <= 30, "Shared bucket count should be near 25%% (got %d)" % shared_count)
	main.queue_free()

func _test_enemy_registry() -> void:
	var main_script: Script = load("res://scripts/Main.gd")
	var goblin_script: Script = load("res://scripts/Goblin.gd")
	var main: Node = main_script.new()
	var goblin: Node2D = goblin_script.new()
	goblin.grid_cell = Vector2i(1, 1)
	main._register_enemy(goblin)
	_assert_eq(main._get_enemy_at(Vector2i(1, 1)), goblin, "Enemy should be retrievable after register")
	main._set_enemy_cell(goblin, Vector2i(2, 2))
	_assert_true(main._get_enemy_at(Vector2i(1, 1)) == null, "Old enemy cell should be cleared after move")
	_assert_eq(main._get_enemy_at(Vector2i(2, 2)), goblin, "Enemy should move in registry with set")
	main._remove_enemy_from_map(goblin)
	_assert_true(main._get_enemy_at(Vector2i(2, 2)) == null, "Enemy should be removed from registry")
	goblin.queue_free()
	main.queue_free()

func _test_bresenham_line() -> void:
	var main_script: Script = load("res://scripts/Main.gd")
	var main: Node = main_script.new()
	var pts: Array = main._bresenham(Vector2i.ZERO, Vector2i(3, 3))
	_assert_eq(pts.front(), Vector2i.ZERO, "Bresenham should start at origin")
	_assert_eq(pts.back(), Vector2i(3, 3), "Bresenham should end at destination")
	for i in range(1, pts.size()):
		var step: Vector2i = pts[i] - pts[i - 1]
		_assert_true(abs(step.x) <= 1 and abs(step.y) <= 1, "Bresenham steps should move at most 1 per axis")
	main.queue_free()

func _test_player_sprite_ranged_switch() -> void:
	var main_script: Script = load("res://scripts/Main.gd")
	var main: Node = main_script.new()
	main._player_sprite = Sprite2D.new()
	var img := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	var tex_wand := ImageTexture.create_from_image(img)
	var tex_bow := ImageTexture.create_from_image(img)
	main.PLAYER_TEX_WAND = tex_wand
	main.PLAYER_TEX_BOW = tex_bow
	main.PLAYER_TEX_1 = ImageTexture.create_from_image(img)
	main._sword_collected = false
	main._shield_collected = false
	main._wand_collected = true
	main._bow_collected = true
	main._active_ranged_weapon = main.RANGED_WAND
	main._update_player_sprite_appearance()
	_assert_eq(main._player_sprite.texture, tex_wand, "Player sprite should show wand when wand is active")
	main._active_ranged_weapon = main.RANGED_BOW
	main._update_player_sprite_appearance()
	_assert_eq(main._player_sprite.texture, tex_bow, "Player sprite should show bow when bow is active")
	main.PLAYER_TEX_WAND = null
	main.PLAYER_TEX_BOW = null
	main.PLAYER_TEX_1 = null
	main._player_sprite.queue_free()
	main.queue_free()
	main = null

func _test_melee_only_level_one_visibility() -> void:
	var main_script: Script = load("res://scripts/Main.gd")
	var main: Node = main_script.new()
	main.floor_map = TileMap.new()
	main.walls_map = TileMap.new()
	main.player = Node2D.new()
	main._decor = Node2D.new()
	main._sword_node = Item.new()
	main._shield_node = Item.new()
	main._sword_cell = Vector2i(2, 2)
	main._shield_cell = Vector2i(3, 3)
	main._sword_collected = false
	main._shield_collected = false
	main._level = 2
	main._enforce_melee_first_level_only()
	_assert_eq(main._sword_cell, Vector2i(-1, -1), "Sword cell should be cleared on levels >1")
	_assert_eq(main._shield_cell, Vector2i(-1, -1), "Shield cell should be cleared on levels >1")
	main._set_world_visible(true)
	_assert_true(not main._sword_node.visible and not main._shield_node.visible, "Sword/Shield should be hidden on levels >1")
	main._level = 1
	main._sword_cell = Vector2i(4, 4)
	main._shield_cell = Vector2i(5, 5)
	main._enforce_melee_first_level_only()
	_assert_eq(main._sword_cell, Vector2i(4, 4), "Sword cell should persist on level 1")
	_assert_eq(main._shield_cell, Vector2i(5, 5), "Shield cell should persist on level 1")
	main._set_world_visible(true)
	_assert_true(main._sword_node.visible and main._shield_node.visible, "Sword/Shield should be visible on level 1 when uncollected")
	main._sword_node.queue_free()
	main._shield_node.queue_free()
	main.floor_map.queue_free()
	main.walls_map.queue_free()
	main.player.queue_free()
	main._decor.queue_free()
	main.queue_free()

func _test_imp_targeting() -> void:
	var main_script: Script = load("res://scripts/Main.gd")
	var main: Node = main_script.new()
	main.walls_map = TileMap.new()
	main._grid_size = Vector2i(10, 10)
	var origin := Vector2i(4, 4)
	var target := Vector2i(4, 7)
	var data: Dictionary = main._imp_targeting_data(origin, target)
	_assert_true(not data.is_empty(), "Imp should find target aligned within range")
	_assert_eq(data.get("dir", Vector2i.ZERO), Vector2i(0, 1), "Imp direction should point toward player")
	_assert_eq(data.get("dist", 0), 3, "Imp distance should match grid delta")
	var far_target := Vector2i(4, 9)
	_assert_true(main._imp_targeting_data(origin, far_target).is_empty(), "Imp should ignore targets past range")
	var off_axis := Vector2i(5, 7)
	_assert_true(main._imp_targeting_data(origin, off_axis).is_empty(), "Imp should ignore unaligned targets")
	main.walls_map.queue_free()
	main.queue_free()

func _test_imp_miss_curve() -> void:
	var main_script: Script = load("res://scripts/Main.gd")
	var main: Node = main_script.new()
	var close: float = main._imp_miss_chance(1)
	var mid: float = main._imp_miss_chance(3)
	var far: float = main._imp_miss_chance(4)
	_assert_true(close <= mid and mid <= far, "Imp miss chance should not decrease with distance")
	_assert_true(far <= 0.6, "Imp miss chance should clamp at or below 60%")
	main.queue_free()
