extends Node
class_name AssetManager

## Manages all asset loading, texture creation, and tileset building
## Extracted from Main.gd to improve code organization

const SPRITESHEET_PATH: String = "res://assets/spritesheet.png"
const SHEET_CELL: int = 13
const SHEET_SPRITE_SIZE: Vector2i = Vector2i(12, 12)

# Texture variables - exposed as properties
var PLAYER_TEX_1: Texture2D
var PLAYER_TEX_2: Texture2D
var PLAYER_TEX_3: Texture2D
var PLAYER_TEX_4: Texture2D
var PLAYER_TEX_WAND: Texture2D
var PLAYER_TEX_BOW: Texture2D
var PLAYER_TEX_TORCH: Texture2D
var PLAYER_TEX_DEAD: Texture2D
var HEART_TEX: Texture2D
var GOBLIN_TEX_1: Texture2D
var DEAD_GOBLIN_TEX: Texture2D
var ZOMBIE_TEX_1: Texture2D
var ZOMBIE_TEX_2: Texture2D
var MINO_TEX_1: Texture2D
var MINO_TEX_2: Texture2D
var IMP_TEX: Texture2D
var IMP_DEAD_TEX: Texture2D
var SKELETON_TEX_1: Texture2D
var SKELETON_TEX_2: Texture2D
var DOOR_TEX_1: Texture2D
var DOOR_TEX_2: Texture2D
var DOOR_TEX_3: Texture2D
var KEY_TEX_1: Texture2D
var KEY_TEX_2: Texture2D
var KEY_TEX_3: Texture2D
var SWORD_TEX: Texture2D
var SHIELD_TEX: Texture2D
var ARMOR_TEX: Texture2D
var POTION_TEX: Texture2D
var CODEX_TEX: Texture2D
var CROWN_TEX: Texture2D
var RUNE1_TEX: Texture2D
var RUNE2_TEX: Texture2D
var RUNE3_TEX: Texture2D
var RUNE4_TEX: Texture2D
var TORCH_TEX: Texture2D
var RING_TEX: Texture2D
var CHEESE_TEX: Texture2D
var ARMOR_ICON_TEX: Texture2D
var TRAP_TEX_A: Texture2D
var TRAP_TEX_B: Texture2D
var TRAP_WEB_TEX: Texture2D
var BRAZIER_TEX: Texture2D = null
var WAND_TEX: Texture2D = null
var BOW_TEX: Texture2D = null
var ARROW_TEX: Texture2D = null
var MOUSE_TEX: Texture2D = null
var BONE_TEXTURES: Array[Texture2D] = []
var SPIDERWEB_TEXTURES: Dictionary = {}
var FLOOR_TEXTURES_A: Array[Texture2D] = []
var FLOOR_TEXTURES_B: Array[Texture2D] = []
var FLOOR_TEXTURES_C: Array[Texture2D] = []
var FLOOR_TEXTURES_SHARED: Array[Texture2D] = []
var WALL_TEXTURES_A: Array[Texture2D] = []
var WALL_TEXTURES_B: Array[Texture2D] = []
var WALL_TEXTURES_C: Array[Texture2D] = []
var _title_textures: Array[Texture2D] = []
var _win_textures: Array[Texture2D] = []
var _lose_textures: Array[Texture2D] = []

# Internal state
var _sheet_image: Image
var _sheet_tex_cache: Dictionary = {}
var _tileset: TileSet
var _floor_sources_by_set: Dictionary = {}
var _wall_sources_by_set: Dictionary = {}
var _shared_floor_sources: Array[int] = []

func _sheet() -> Image:
	if _sheet_image == null:
		var tex: Texture2D = load(SPRITESHEET_PATH)
		if tex == null:
			push_error("Spritesheet not found at %s" % SPRITESHEET_PATH)
			return Image.new()
		_sheet_image = tex.get_image()
	return _sheet_image

func _sheet_tex(key: StringName, pos: Vector2i, mask_black: bool) -> Texture2D:
	if _sheet_tex_cache.has(key):
		return _sheet_tex_cache[key]
	var region := Rect2i(pos + Vector2i.ONE, SHEET_SPRITE_SIZE)
	var img := _sheet().get_region(region)
	if mask_black:
		img.convert(Image.FORMAT_RGBA8)
		for y in range(img.get_height()):
			for x in range(img.get_width()):
				var c := img.get_pixel(x, y)
				if c.r <= 0.01 and c.g <= 0.01 and c.b <= 0.01:
					c.a = 0.0
				img.set_pixel(x, y, c)
	var tex := ImageTexture.create_from_image(img)
	_sheet_tex_cache[key] = tex
	return tex

func _make_tile_source(tex: Texture2D) -> TileSetAtlasSource:
	var src := TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = SHEET_SPRITE_SIZE
	return src

func load_all_textures() -> void:
	"""Load all spritesheet textures"""
	PLAYER_TEX_1 = _sheet_tex(&"player1", Vector2i(1352, 0), true)
	PLAYER_TEX_2 = _sheet_tex(&"player2", Vector2i(1456, 0), true)
	PLAYER_TEX_3 = _sheet_tex(&"player3", Vector2i(1937, 0), true)
	PLAYER_TEX_4 = _sheet_tex(&"player4", Vector2i(1989, 0), true)
	PLAYER_TEX_WAND = _sheet_tex(&"player_wand", Vector2i(1625, 0), true)
	PLAYER_TEX_BOW = _sheet_tex(&"player_bow", Vector2i(2028, 0), true)
	PLAYER_TEX_TORCH = _sheet_tex(&"player_torch", Vector2i(1898, 0), true)
	PLAYER_TEX_DEAD = _sheet_tex(&"player_dead", Vector2i(2613, 0), true)
	HEART_TEX = _sheet_tex(&"heart", Vector2i(1014, 481), true)
	GOBLIN_TEX_1 = _sheet_tex(&"goblin1", Vector2i(1352, 52), true)
	DEAD_GOBLIN_TEX = _sheet_tex(&"goblin_dead", Vector2i(2613, 52), true)
	ZOMBIE_TEX_1 = _sheet_tex(&"zombie1", Vector2i(2626, 117), true)
	ZOMBIE_TEX_2 = _sheet_tex(&"zombie2", Vector2i(2613, 117), true)
	MINO_TEX_1 = _sheet_tex(&"mino1", Vector2i(1352, 208), true)
	MINO_TEX_2 = _sheet_tex(&"mino2", Vector2i(2613, 208), true)
	IMP_TEX = _sheet_tex(&"imp", Vector2i(2028, 260), true)
	IMP_DEAD_TEX = _sheet_tex(&"imp_dead", Vector2i(2613, 260), true)
	SKELETON_TEX_1 = _sheet_tex(&"skeleton1", Vector2i(1352, 130), true)
	SKELETON_TEX_2 = _sheet_tex(&"skeleton_dead", Vector2i(2613, 130), true)
	MOUSE_TEX = _sheet_tex(&"mouse", Vector2i(39, 182), true)
	DOOR_TEX_1 = _sheet_tex(&"door1", Vector2i(156, 13), false)
	DOOR_TEX_2 = _sheet_tex(&"door2", Vector2i(143, 13), false)
	DOOR_TEX_3 = _sheet_tex(&"door3", Vector2i(260, 26), false)
	KEY_TEX_1 = _sheet_tex(&"key1", Vector2i(117, 585), true)
	KEY_TEX_2 = _sheet_tex(&"key2", Vector2i(13, 585), true)
	KEY_TEX_3 = _sheet_tex(&"key3", Vector2i(39, 585), true)
	SWORD_TEX = _sheet_tex(&"sword", Vector2i(351, 78), true)
	SHIELD_TEX = _sheet_tex(&"shield", Vector2i(364, 156), true)
	ARMOR_TEX = _sheet_tex(&"armor", Vector2i(351, 143), true)
	POTION_TEX = _sheet_tex(&"potion", Vector2i(481, 52), true)
	CODEX_TEX = _sheet_tex(&"codex", Vector2i(91, 481), true)
	CROWN_TEX = _sheet_tex(&"crown", Vector2i(351, 299), true)
	RUNE1_TEX = _sheet_tex(&"rune1", Vector2i(338, 221), true)
	RUNE2_TEX = _sheet_tex(&"rune2", Vector2i(351, 221), true)
	RUNE3_TEX = _sheet_tex(&"rune3", Vector2i(364, 221), true)
	RUNE4_TEX = _sheet_tex(&"rune4", Vector2i(455, 221), true)
	TORCH_TEX = _sheet_tex(&"torch", Vector2i(52, 546), true)
	RING_TEX = _sheet_tex(&"ring", Vector2i(156, 559), true)
	CHEESE_TEX = _sheet_tex(&"cheese", Vector2i(91, 221), true)
	ARMOR_ICON_TEX = _sheet_tex(&"armor_icon", Vector2i(338, 156), true)
	TRAP_TEX_A = _sheet_tex(&"trap_a", Vector2i(364, 273), true)
	TRAP_TEX_B = _sheet_tex(&"trap_b", Vector2i(390, 273), true)
	TRAP_WEB_TEX = _sheet_tex(&"trap_web", Vector2i(52, 507), true)
	BRAZIER_TEX = _sheet_tex(&"brazier", Vector2i(351, 286), true)
	WAND_TEX = _sheet_tex(&"wand", Vector2i(544, 169), true)
	BOW_TEX = _sheet_tex(&"bow", Vector2i(351, 130), true)
	ARROW_TEX = _sheet_tex(&"arrow", Vector2i(429, 130), true)
	_title_textures = [
		load("res://assets/CoB-title.png"),
		load("res://assets/cob-title-mb.png"),
		load("res://assets/cob-title-comic.png")
	]
	_win_textures = [
		load("res://assets/codex-quest-win.png"),
		load("res://assets/win-mb.png"),
		load("res://assets/win-comic.png")
	]
	_lose_textures = [
		load("res://assets/codex-quest-lose.png"),
		load("res://assets/lose-mb.png"),
		load("res://assets/lose-comic.png")
	]
	BONE_TEXTURES = [
		_sheet_tex(&"bone1", Vector2i(0, 494), true),
		_sheet_tex(&"bone2", Vector2i(13, 494), true),
		_sheet_tex(&"bone3", Vector2i(26, 494), true),
	]
	SPIDERWEB_TEXTURES = {
		&"top_left": _sheet_tex(&"spiderweb_top_left", Vector2i(0, 507), true),
		&"top_right": _sheet_tex(&"spiderweb_top_right", Vector2i(13, 507), true),
		&"bottom_left": _sheet_tex(&"spiderweb_bottom_left", Vector2i(26, 507), true),
		&"bottom_right": _sheet_tex(&"spiderweb_bottom_right", Vector2i(39, 507), true),
	}
	FLOOR_TEXTURES_A = [
		_sheet_tex(&"tile_set_a_floor_1", Vector2i(130, 65), false),
		_sheet_tex(&"tile_set_a_floor_2", Vector2i(143, 65), false),
		_sheet_tex(&"tile_set_a_floor_3", Vector2i(156, 65), false),
		_sheet_tex(&"tile_set_a_floor_4", Vector2i(117, 65), false),
	]
	WALL_TEXTURES_A = [
		_sheet_tex(&"tile_set_a_wall_1", Vector2i(0, 26), false),
		_sheet_tex(&"tile_set_a_wall_2", Vector2i(13, 26), false),
		_sheet_tex(&"tile_set_a_wall_3", Vector2i(65, 26), false),
		_sheet_tex(&"tile_set_a_wall_4", Vector2i(78, 26), false),
		_sheet_tex(&"tile_set_a_wall_5", Vector2i(91, 26), false),
	]
	FLOOR_TEXTURES_B = [
		_sheet_tex(&"tile_set_b_floor_1", Vector2i(52, 65), false),
		_sheet_tex(&"tile_set_b_floor_2", Vector2i(65, 65), false),
		_sheet_tex(&"tile_set_b_floor_3", Vector2i(78, 65), false),
		_sheet_tex(&"tile_set_b_floor_4", Vector2i(91, 65), false),
	]
	WALL_TEXTURES_B = [
		_sheet_tex(&"tile_set_b_wall_1", Vector2i(39, 0), false),
		_sheet_tex(&"tile_set_b_wall_2", Vector2i(52, 0), false),
		_sheet_tex(&"tile_set_b_wall_3", Vector2i(65, 0), false),
		_sheet_tex(&"tile_set_b_wall_4", Vector2i(78, 0), false),
	]
	FLOOR_TEXTURES_C = [
		_sheet_tex(&"tile_set_c_floor_1", Vector2i(78, 78), false),
		_sheet_tex(&"tile_set_c_floor_2", Vector2i(91, 78), false),
		_sheet_tex(&"tile_set_c_floor_3", Vector2i(130, 78), false),
		_sheet_tex(&"tile_set_c_floor_4", Vector2i(143, 78), false),
	]
	WALL_TEXTURES_C = [
		_sheet_tex(&"tile_set_c_wall_1", Vector2i(0, 39), false),
		_sheet_tex(&"tile_set_c_wall_2", Vector2i(13, 39), false),
		_sheet_tex(&"tile_set_c_wall_3", Vector2i(26, 39), false),
		_sheet_tex(&"tile_set_c_wall_4", Vector2i(156, 39), false),
	]
	FLOOR_TEXTURES_SHARED = [
		_sheet_tex(&"old_bones_floor_1", Vector2i(0, 91), false),
		_sheet_tex(&"old_bones_floor_2", Vector2i(13, 91), false),
		_sheet_tex(&"old_bones_floor_3", Vector2i(26, 91), false),
	]

func set_sprite_texture(node: Node, tex: Texture2D) -> void:
	"""Set texture on a node's Sprite2D child"""
	if node == null or tex == null:
		return
	var s := node.get_node_or_null("Sprite2D") as Sprite2D
	if s:
		s.texture = tex
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.modulate = Color(1, 1, 1, 1)
		s.visible = true
		s.z_index = 50
		s.z_as_relative = false
		s.position = Vector2.ZERO

func normalize_item_node(item: Item, tex: Texture2D) -> void:
	"""Normalize an item node with texture"""
	if item == null:
		return
	item.collected = false
	item.visible = true
	item.modulate = Color(1, 1, 1, 1)
	item.z_index = 10
	item.z_as_relative = false
	item.global_position = Grid.cell_to_world(item.grid_cell)
	set_sprite_texture(item, tex)

func build_tileset(tileset_a: StringName, tileset_b: StringName, tileset_c: StringName) -> TileSet:
	"""Build tileset from loaded textures"""
	_tileset = TileSet.new()
	_tileset.tile_size = Vector2i(12, 12)
	_floor_sources_by_set.clear()
	_wall_sources_by_set.clear()
	_shared_floor_sources.clear()
	var tilesets: Array = [
		{
			"id": tileset_a,
			"floors": FLOOR_TEXTURES_A,
			"walls": WALL_TEXTURES_A
		},
		{
			"id": tileset_b,
			"floors": FLOOR_TEXTURES_B,
			"walls": WALL_TEXTURES_B
		},
		{
			"id": tileset_c,
			"floors": FLOOR_TEXTURES_C,
			"walls": WALL_TEXTURES_C
		},
	]
	var next_source_id := 0
	for ts in tilesets:
		var floor_sources: Array[int] = []
		for tex: Texture2D in ts["floors"]:
			var src := _make_tile_source(tex)
			_tileset.add_source(src, next_source_id)
			floor_sources.append(next_source_id)
			next_source_id += 1
		_floor_sources_by_set[ts["id"]] = floor_sources
		var wall_sources: Array[int] = []
		for tex2: Texture2D in ts["walls"]:
			var src2 := _make_tile_source(tex2)
			_tileset.add_source(src2, next_source_id)
			wall_sources.append(next_source_id)
			next_source_id += 1
		_wall_sources_by_set[ts["id"]] = wall_sources
	for shared_tex in FLOOR_TEXTURES_SHARED:
		var shared_src := _make_tile_source(shared_tex)
		_tileset.add_source(shared_src, next_source_id)
		_shared_floor_sources.append(next_source_id)
		next_source_id += 1
	return _tileset

func get_tileset() -> TileSet:
	"""Get the built tileset"""
	return _tileset

func get_floor_sources_by_set() -> Dictionary:
	"""Get floor sources organized by tileset"""
	return _floor_sources_by_set

func get_wall_sources_by_set() -> Dictionary:
	"""Get wall sources organized by tileset"""
	return _wall_sources_by_set

func get_shared_floor_sources() -> Array[int]:
	"""Get shared floor sources"""
	return _shared_floor_sources

func get_random_title_texture() -> Texture2D:
	"""Get a random title screen texture"""
	if _title_textures.is_empty():
		return null
	return _title_textures[randi() % _title_textures.size()]

func get_random_win_texture() -> Texture2D:
	"""Get a random win screen texture"""
	if _win_textures.is_empty():
		return null
	return _win_textures[randi() % _win_textures.size()]

func get_random_lose_texture() -> Texture2D:
	"""Get a random lose screen texture"""
	if _lose_textures.is_empty():
		return null
	return _lose_textures[randi() % _lose_textures.size()]

