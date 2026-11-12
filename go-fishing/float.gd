extends Node2D

@onready var underwater_line: Line2D = $UnderwaterLine
@onready var hook_and_bait: Area2D = $HookAndBait
@onready var worm_sprite: AnimatedSprite2D = $HookAndBait/AnimatedSprite2D

var target_depth: float = 1.0 
var fish_hooked: bool = false

func _ready() -> void:
	if worm_sprite and worm_sprite.sprite_frames:
		if worm_sprite.sprite_frames.has_animation("hookWorm"):
			worm_sprite.play("hookWorm")
	
	update_depth(target_depth)
	
	# Povezujemo signale za sudar sa ribom u jezeru
	if hook_and_bait:
		hook_and_bait.body_entered.connect(_on_hook_body_entered)
		hook_and_bait.area_entered.connect(_on_hook_area_entered)

func update_depth(new_depth: float) -> void:
	target_depth = new_depth
	var visual_pixels = target_depth * 14.0  
	var end_point = Vector2(0, visual_pixels)
	
	if hook_and_bait:
		hook_and_bait.position = end_point
		
	if underwater_line:
		underwater_line.clear_points()
		underwater_line.add_point(Vector2(0, 0))
		underwater_line.add_point(hook_and_bait.position)

# Detekcija kada riba (CharacterBody2D ili RigidBody2D) udari u udicu
func _on_hook_body_entered(body: Node2D) -> void:
	if fish_hooked:
		return
		
	# Proveravamo da li je u pitanju riba (ako je u grupi "fish" ili ime sadrži "fish")
	if body.is_in_group("fish") or "fish" in body.name.to_lower():
		trigger_bite(body)

# Detekcija kada riba (Area2D) udari u udicu
func _on_hook_area_entered(area: Area2D) -> void:
	if fish_hooked:
		return
		
	if area.is_in_group("fish") or "fish" in area.name.to_lower():
		trigger_bite(area)

func trigger_bite(fish_node: Node) -> void:
	if fish_hooked:
		return
	fish_hooked = true
	print("Riba je udarila u mamac i zakačena je!")
	
	_attach_fish_deferred.call_deferred(fish_node)

func _attach_fish_deferred(fish_node: Node) -> void:
	if not is_instance_valid(fish_node):
		return
		
	# Isključujemo njeno samostalno kretanje i kolizije da ne nestane
	if fish_node.has_method("set_physics_process"):
		fish_node.set_physics_process(false)
		
	for child in fish_node.find_children("*", "CollisionShape2D"):
		child.disabled = true
		
	# Čuvamo skalu da se riba ne smanji/poveća
	var saved_scale = fish_node.scale
	
	# Prebacujemo je pod udicu i fiksiramo joj poziciju tačno na udicu
	if fish_node.get_parent():
		fish_node.get_parent().remove_child(fish_node)
	
	hook_and_bait.add_child(fish_node)
	fish_node.global_position = hook_and_bait.global_position + Vector2(0, 10)
	fish_node.scale = saved_scale
	
	# Pokrećemo mini-igru kod igrača
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("start_fishing_minigame"):
		player.start_fishing_minigame(fish_node)

# Funkcija koja privlači ceo plovak i zakačenu ribu u desno (ka obali i igraču)
func pull_float_towards_player(delta: float) -> void:
	global_position.x += 40.0 * delta # Plus ide ka desnoj obali
