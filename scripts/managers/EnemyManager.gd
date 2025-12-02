extends Node
class_name EnemyManager

## Manages all enemy spawning, movement, AI, and lifecycle
## Extracted from Main.gd to improve code organization

# Scene references
const GOBLIN_SCENE: PackedScene = preload("res://scenes/Goblin.tscn")
const ZOMBIE_SCENE: PackedScene = preload("res://scenes/Zombie.tscn")
const MINOTAUR_SCENE: PackedScene = preload("res://scenes/Minotaur.tscn")
const IMP_SCENE: PackedScene = preload("res://scenes/Imp.tscn")
const SKELETON_SCENE: PackedScene = preload("res://scenes/Skeleton.tscn")
const MOUSE_SCENE: PackedScene = preload("res://scenes/Mouse.tscn")
const TRAP_SCENE: PackedScene = preload("res://scenes/Trap.tscn")

# Type imports
const Enemy: Script = preload("res://scripts/Enemy.gd")
const Goblin: Script = preload("res://scripts/Goblin.gd")
const Zombie: Script = preload("res://scripts/Zombie.gd")
const Minotaur: Script = preload("res://scripts/Minotaur.gd")
const Imp: Script = preload("res://scripts/Imp.gd")
const Mouse: Script = preload("res://scripts/Mouse.gd")
const Skeleton: Script = preload("res://scripts/Skeleton.gd")
const Trap: Script = preload("res://scripts/Trap.gd")

# Enemy collections
var _goblins: Array[Goblin] = []
var _zombies: Array[Zombie] = []
var _minotaurs: Array[Minotaur] = []
var _imps: Array[Imp] = []
var _skeletons: Array[Skeleton] = []
var _mice: Array[Mouse] = []
var _traps: Array[Trap] = []

# Enemy registry for quick position lookups
var _enemy_map: Dictionary = {}

# Reference to main for accessing shared resources and systems
var _main: Node2D
var _asset_manager: AssetManager

func _init(main_node: Node2D, asset_manager: AssetManager) -> void:
	_main = main_node
	_asset_manager = asset_manager

## Enemy spawning functions
func spawn_goblin_at(cell: Vector2i) -> void:
	var node: Goblin = GOBLIN_SCENE.instantiate() as Goblin
	node.setup(cell, _asset_manager.GOBLIN_TEX_1, _asset_manager.DEAD_GOBLIN_TEX)
	_main.add_child(node)
	_register_enemy(node)
	_goblins.append(node)

func spawn_zombie_at(cell: Vector2i) -> void:
	var node: Zombie = ZOMBIE_SCENE.instantiate() as Zombie
	node.setup(cell, _asset_manager.ZOMBIE_TEX_1, _asset_manager.ZOMBIE_TEX_2)
	_main.add_child(node)
	_register_enemy(node)
	_zombies.append(node)

func spawn_minotaur_at(cell: Vector2i) -> void:
	var node: Minotaur = MINOTAUR_SCENE.instantiate() as Minotaur
	node.setup(cell, _asset_manager.MINO_TEX_1, _asset_manager.MINO_TEX_2)
	_main.add_child(node)
	_register_enemy(node)
	_minotaurs.append(node)

func spawn_imp_at(cell: Vector2i) -> void:
	var node: Imp = IMP_SCENE.instantiate() as Imp
	node.setup(cell, _asset_manager.IMP_TEX, _asset_manager.IMP_DEAD_TEX)
	_main.add_child(node)
	_register_enemy(node)
	_imps.append(node)

func spawn_mouse_at(cell: Vector2i) -> void:
	var node: Mouse = MOUSE_SCENE.instantiate() as Mouse
	var tex: Texture2D = _asset_manager.MOUSE_TEX if _asset_manager else null
	node.setup(cell, tex)
	_main.add_child(node)
	_mice.append(node)

func spawn_skeleton_at(cell: Vector2i) -> void:
	var node: Skeleton = SKELETON_SCENE.instantiate() as Skeleton
	node.setup(cell, _asset_manager.SKELETON_TEX_1, _asset_manager.SKELETON_TEX_2)
	_main.add_child(node)
	_register_enemy(node)
	_skeletons.append(node)
	# Log action through main - will be refactored when HUDManager is extracted
	_main._log_action("AHHHHH!!!!")

func spawn_trap_at(cell: Vector2i, trap_type: StringName = StringName()) -> void:
	var node: Trap = TRAP_SCENE.instantiate() as Trap
	var resolved_type := trap_type
	if resolved_type == StringName():
		var is_web: bool = _main._rng.randf() < 0.33 and _asset_manager.TRAP_WEB_TEX != null
		resolved_type = (&"spiderweb" if is_web else &"spike")
	var tex: Texture2D = null
	if resolved_type == &"spiderweb":
		tex = _asset_manager.TRAP_WEB_TEX
	else:
		tex = (_asset_manager.TRAP_TEX_A if _main._rng.randf() < 0.5 else _asset_manager.TRAP_TEX_B)
	node.setup(cell, tex, resolved_type)
	_main.add_child(node)
	_traps.append(node)

## Enemy registry functions
func _register_enemy(enemy: Enemy) -> void:
	_enemy_map[enemy.grid_cell] = enemy

func set_enemy_cell(enemy: Enemy, cell: Vector2i) -> void:
	if _enemy_map.get(enemy.grid_cell, null) == enemy:
		_enemy_map.erase(enemy.grid_cell)
	enemy.grid_cell = cell
	_enemy_map[cell] = enemy

func remove_enemy_from_map(enemy: Enemy) -> void:
	if _enemy_map.get(enemy.grid_cell, null) == enemy:
		_enemy_map.erase(enemy.grid_cell)

func get_enemy_at(cell: Vector2i) -> Enemy:
	var enemy: Enemy = _enemy_map.get(cell, null)
	return enemy

## Enemy cleanup functions
func clear_enemies() -> void:
	for child: Goblin in _goblins:
		child.queue_free()
	for child: Zombie in _zombies:
		child.queue_free()
	for child: Minotaur in _minotaurs:
		child.queue_free()
	for child: Imp in _imps:
		child.queue_free()
	for child: Skeleton in _skeletons:
		child.queue_free()
	_goblins.clear()
	_zombies.clear()
	_minotaurs.clear()
	_imps.clear()
	_skeletons.clear()
	_enemy_map.clear()
	clear_mice()
	clear_traps()
	# Corpse clearing will be handled through main for now
	_main._clear_corpses()

func clear_mice() -> void:
	for m in _mice:
		m.queue_free()
	_mice.clear()

func clear_traps() -> void:
	for t in _traps:
		t.queue_free()
	_traps.clear()

## Getters for enemy collections (for external access)
func get_goblins() -> Array[Goblin]:
	return _goblins

func get_zombies() -> Array[Zombie]:
	return _zombies

func get_minotaurs() -> Array[Minotaur]:
	return _minotaurs

func get_imps() -> Array[Imp]:
	return _imps

func get_skeletons() -> Array[Skeleton]:
	return _skeletons

func get_mice() -> Array[Mouse]:
	return _mice

func get_traps() -> Array[Trap]:
	return _traps

func is_enemy_map_empty() -> bool:
	return _enemy_map.is_empty()

func get_all_enemies() -> Array:
	return _enemy_map.values()

## Enemy movement and AI functions
func enemy_can_act(enemy: Enemy) -> bool:
	if enemy == null:
		return false
	if enemy.web_stuck_turns > 0:
		enemy.web_stuck_turns = max(0, enemy.web_stuck_turns - 1)
		return false
	return true

func advance_enemies_and_update(skip_skeletons_from: int) -> void:
	var prev_dash_cd: int = _main._rune4_dash_cooldown
	# 75% chance each goblin attempts to move 1 step in a random dir
	var dirs: Array[Vector2i] = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	for goblin: Goblin in _goblins:
		if goblin.alive and enemy_can_act(goblin) and _main._rng.randf() <= 0.75:
			var d: Vector2i = dirs[_main._rng.randi_range(0, dirs.size() - 1)]
			move_goblin(goblin, d)
	for mouse: Mouse in _mice:
		if mouse.alive and enemy_can_act(mouse) and _main._rng.randf() <= 0.75:
			var d2: Vector2i = dirs[_main._rng.randi_range(0, dirs.size() - 1)]
			move_mouse(mouse, d2)
	# Move zombie (one per level) with low accuracy towards player, less accurate at distance
	for zombie: Zombie in _zombies:
		if zombie.alive and enemy_can_act(zombie):
			move_homing_enemy(zombie)
			update_facing_to_player(zombie)
	for i in range(_skeletons.size()):
		var skeleton := _skeletons[i]
		if i >= skip_skeletons_from:
			continue
		if skeleton.alive and enemy_can_act(skeleton):
			move_homing_enemy(skeleton)
	# Move minotaur (zero on L1, one on L2) with higher accuracy towards player
	for mino: Minotaur in _minotaurs:
		if mino.alive and enemy_can_act(mino):
			move_homing_enemy(mino)
	for imp: Imp in _imps:
		if imp.alive and enemy_can_act(imp):
			imp_take_turn(imp)
	# Only update FOV if dirty (player moved or explicitly requested)
	if _main._fov_dirty:
		_main._update_fov()
		_main._fov_dirty = false
	if _main._rune4_dash_cooldown > 0:
		_main._rune4_dash_cooldown = max(0, _main._rune4_dash_cooldown - 1)
	if prev_dash_cd != _main._rune4_dash_cooldown:
		_main._update_hud_icons()

func move_goblin(goblin: Goblin, dir: Vector2i) -> void:
	var dest: Vector2i = goblin.grid_cell + dir
	if not can_enemy_step(dest, goblin):
		return
	var player_cell := Grid.world_to_cell(_main.player.global_position)
	# If goblin would move onto player, do one combat round and don't move into that cell
	if dest == player_cell and goblin.alive and not _main._game_over:
		_main._combat_round_enemy(goblin)
		return
	set_enemy_cell(goblin, dest)
	var trap: Trap = _main._trap_at(dest)
	if trap != null:
		_main._handle_enemy_hit_by_trap(goblin, trap)

func move_mouse(mouse: Mouse, dir: Vector2i) -> void:
	var dest: Vector2i = mouse.grid_cell + dir
	if not _main._in_interior(dest) or _main._is_wall(dest):
		return
	# avoid stacking on hostile enemies or other mice
	if get_enemy_at(dest) != null:
		return
	for m in _mice:
		if m != mouse and m.alive and m.grid_cell == dest:
			return
	var trap: Trap = _main._trap_at(dest)
	if trap != null:
		# mice are immune
		return
	mouse.set_cell(dest)

func move_homing_enemy(enemy: Enemy) -> void:
	var ecell := enemy.grid_cell
	var player_cell := Grid.world_to_cell(_main.player.global_position)
	var delta: Vector2i = player_cell - ecell
	var dist: int = abs(delta.x) + abs(delta.y)
	# Determine desired direction towards player
	var cand: Array[Vector2i] = []
	if delta.x != 0:
		cand.append(Vector2i(1 if delta.x > 0 else -1, 0))
	if delta.y != 0:
		cand.append(Vector2i(0, 1 if delta.y > 0 else -1))
	# Accuracy: minotaur more accurate; zombie/skeleton less, and decreases with distance
	var p_towards := 0.7
	if enemy.enemy_type == &"zombie" or enemy.enemy_type == &"skeleton":
		# Make zombies/skeletons track more aggressively, but still below minotaur accuracy
		p_towards = clamp(0.88 - 0.035 * float(dist), 0.35, 0.9)
	else:
		p_towards = clamp(0.95 - 0.02 * float(dist), 0.5, 0.95)
	var dir := Vector2i.ZERO
	if _main._rng.randf() < p_towards and cand.size() > 0:
		dir = cand[_main._rng.randi_range(0, cand.size() - 1)]
	else:
		# Pick a random direction; slight bias away from player
		var dirs: Array[Vector2i] = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
		dirs.shuffle()
		for d in dirs:
			var newd := ecell + d
			if abs((player_cell - newd).x) + abs((player_cell - newd).y) > dist:
				dir = d
				break
		if dir == Vector2i.ZERO:
			dir = dirs[0]
	var dest: Vector2i = ecell + dir
	if not can_enemy_step(dest, enemy):
		return
	# If moving onto player, do one combat round and don't step
	if dest == player_cell and not _main._game_over:
		var trap: Trap = _main._trap_at(dest)
		if trap != null:
			_main._handle_enemy_hit_by_trap(enemy, trap)
			return
		_main._combat_round_enemy(enemy)
		return
	# Move
	set_enemy_cell(enemy, dest)
	var trap2: Trap = _main._trap_at(dest)
	if trap2 != null:
		_main._handle_enemy_hit_by_trap(enemy, trap2)

func update_facing_to_player(enemy: Enemy) -> void:
	if enemy == null:
		return
	var player_cell := Grid.world_to_cell(_main.player.global_position)
	var spr := enemy.get_node_or_null("Sprite2D") as Sprite2D
	if spr == null:
		return
	spr.flip_h = player_cell.x > enemy.grid_cell.x

func move_enemy_away_from_player(enemy: Enemy) -> void:
	var player_cell := Grid.world_to_cell(_main.player.global_position)
	var start_dist: int = abs(enemy.grid_cell.x - player_cell.x) + abs(enemy.grid_cell.y - player_cell.y)
	var dirs: Array[Vector2i] = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	var best: Array[Vector2i] = []
	var best_dist: int = start_dist
	for d in dirs:
		var dest := enemy.grid_cell + d
		if not can_enemy_step(dest, enemy):
			continue
		var trap: Trap = _main._trap_at(dest)
		if trap != null:
			# Running away: don't intentionally step into traps
			continue
		var dist: int = abs(dest.x - player_cell.x) + abs(dest.y - player_cell.y)
		if dist > best_dist:
			best_dist = dist
			best = [dest]
		elif dist == best_dist:
			best.append(dest)
	if best.is_empty():
		move_homing_enemy(enemy)
		return
	var pick := best[_main._rng.randi_range(0, best.size() - 1)]
	set_enemy_cell(enemy, pick)

func can_enemy_step(cell: Vector2i, mover: Enemy) -> bool:
	if not _main._in_interior(cell) or _main._is_wall(cell):
		return false
	if _main.is_cell_blocked(cell):
		return false
	var occupant := get_enemy_at(cell)
	if occupant != null and occupant != mover:
		return false
	var mouse: Mouse = _main._mouse_at(cell)
	if mouse != null and mouse != mover:
		return false
	return true

## Imp AI functions
func imp_targeting_data(origin: Vector2i, target: Vector2i) -> Dictionary:
	var dx := target.x - origin.x
	var dy := target.y - origin.y
	var dist: int = max(abs(dx), abs(dy))
	if dist < 1 or dist > 4:
		return {}
	var dir := Vector2i(sign(dx), sign(dy))
	var aligned: bool = (dx == 0 or dy == 0 or abs(dx) == abs(dy))
	if not aligned or dir == Vector2i.ZERO:
		return {}
	return {"dir": dir, "dist": dist}

func imp_line_clear(origin: Vector2i, dir: Vector2i, dist: int) -> bool:
	for i in range(1, dist + 1):
		var cell := origin + dir * i
		if not _main._in_interior(cell):
			return false
		if _main._is_wall(cell):
			return false
		if i < dist:
			if get_enemy_at(cell) != null:
				return false
			if _main._trap_at(cell) != null:
				return false
	return true

func imp_miss_chance(dist: int) -> float:
	return clampf(0.15 * float(max(0, dist - 1)), 0.0, 0.6)

func imp_fire_shot(imp: Imp, dir: Vector2i, dist: int, player_cell: Vector2i) -> void:
	if imp == null or not imp.alive:
		return
	var origin := imp.grid_cell
	var end_cell := origin + dir * dist
	_main._fire_projectile(origin, end_cell, Color(0.9, 0.2, 0.2, 1))
	imp.arrows = max(0, imp.arrows - 1)
	imp.cooldown = 2
	if _main._rng.randf() < imp_miss_chance(dist):
		_main._log_action("That was close!")
		return
	_main._set_death_cause_enemy(&"imp")
	_main._apply_player_damage(1)
	_main._log_action("Imp hits you!")

func imp_take_turn(imp: Imp) -> void:
	if imp == null or not imp.alive:
		return
	imp.cooldown = max(0, imp.cooldown - 1)
	var player_cell := Grid.world_to_cell(_main.player.global_position)
	var targeting := imp_targeting_data(imp.grid_cell, player_cell)
	if imp.arrows > 0 and imp.cooldown == 0 and not targeting.is_empty():
		var dir: Vector2i = targeting["dir"]
		var dist: int = targeting["dist"]
		if imp_line_clear(imp.grid_cell, dir, dist):
			imp_fire_shot(imp, dir, dist, player_cell)
			return
	if imp.arrows <= 0:
		move_enemy_away_from_player(imp)
	else:
		move_homing_enemy(imp)