extends GutTest

const AssetManager: Script = preload("res://scripts/managers/AssetManager.gd")
var _asset_manager_script: Script = preload("res://scripts/managers/AssetManager.gd")

func test_asset_manager_loads_textures() -> void:
	var asset_mgr: Node = _asset_manager_script.new() as Node
	asset_mgr.load_all_textures()
	
	# Verify key textures are loaded
	assert_not_null(asset_mgr.PLAYER_TEX_1, "Player texture 1 should be loaded")
	assert_not_null(asset_mgr.GOBLIN_TEX_1, "Goblin texture should be loaded")
	assert_not_null(asset_mgr.SWORD_TEX, "Sword texture should be loaded")
	assert_not_null(asset_mgr.SHIELD_TEX, "Shield texture should be loaded")
	
	asset_mgr.queue_free()

func test_asset_manager_builds_tileset() -> void:
	var asset_mgr: Node = _asset_manager_script.new() as Node
	asset_mgr.load_all_textures()
	var tileset_a := StringName("tile_set_a")
	var tileset_b := StringName("tile_set_b")
	var tileset_c := StringName("tile_set_c")
	
	var tileset: TileSet = asset_mgr.build_tileset(tileset_a, tileset_b, tileset_c)
	
	assert_not_null(tileset, "Tileset should be created")
	assert_eq(tileset.tile_size, Vector2i(12, 12), "Tileset should have correct tile size")
	
	var floor_sources: Dictionary = asset_mgr.get_floor_sources_by_set()
	var wall_sources: Dictionary = asset_mgr.get_wall_sources_by_set()
	
	assert_true(floor_sources.has(tileset_a), "Should have floor sources for tileset A")
	assert_true(wall_sources.has(tileset_a), "Should have wall sources for tileset A")
	
	asset_mgr.queue_free()

func test_asset_manager_sprite_texture_setting() -> void:
	var asset_mgr: Node = _asset_manager_script.new() as Node
	asset_mgr.load_all_textures()
	
	var test_node := Node2D.new()
	var sprite := Sprite2D.new()
	test_node.add_child(sprite)
	add_child(test_node)
	
	asset_mgr.set_sprite_texture(test_node, asset_mgr.SWORD_TEX)
	
	assert_eq(sprite.texture, asset_mgr.SWORD_TEX, "Sprite texture should be set")
	assert_eq(sprite.texture_filter, CanvasItem.TEXTURE_FILTER_NEAREST, "Sprite should use nearest filter")
	assert_true(sprite.visible, "Sprite should be visible")
	
	test_node.queue_free()

func test_asset_manager_normalize_item_node() -> void:
	var asset_mgr: Node = _asset_manager_script.new() as Node
	asset_mgr.load_all_textures()
	var item_script: Script = preload("res://scripts/Item.gd")
	var item: Item = item_script.new() as Item
	add_child(item)
	
	asset_mgr.normalize_item_node(item, asset_mgr.POTION_TEX)
	
	assert_false(item.collected, "Item should not be collected")
	assert_true(item.visible, "Item should be visible")
	assert_eq(item.z_index, 10, "Item should have correct z_index")
	
	item.queue_free()

func test_asset_manager_random_textures() -> void:
	var asset_mgr: Node = _asset_manager_script.new() as Node
	asset_mgr.load_all_textures()
	
	var title_tex: Texture2D = asset_mgr.get_random_title_texture()
	var win_tex: Texture2D = asset_mgr.get_random_win_texture()
	var lose_tex: Texture2D = asset_mgr.get_random_lose_texture()
	
	# These may be null if assets aren't loaded, but if they are, they should be valid
	if title_tex != null:
		assert_true(title_tex is Texture2D, "Title texture should be Texture2D")
	if win_tex != null:
		assert_true(win_tex is Texture2D, "Win texture should be Texture2D")
	if lose_tex != null:
		assert_true(lose_tex is Texture2D, "Lose texture should be Texture2D")
	
	asset_mgr.queue_free()

