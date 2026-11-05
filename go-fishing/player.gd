extends CharacterBody2D

const SPEED = 50.0
const GRAVITY = 900.0

@onready var shop_ui: Control = get_node("../CanvasLayer/ShopUI")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fishing_line: Line2D = $FishingLine 
@onready var rod_tip: Marker2D = $AnimatedSprite2D/RodTip 
@onready var depth_label: Label = get_node_or_null("../CanvasLayer/DepthUI/DepthLabel") 

# UI elementi za mini-igru pecanja
@onready var fishing_minigame_ui: Control = get_node_or_null("../CanvasLayer/FishingMinigameUI")
@onready var bar_background: ColorRect = get_node_or_null("../CanvasLayer/FishingMinigameUI/BarBackground")
@onready var cursor_line: ColorRect = get_node_or_null("../CanvasLayer/FishingMinigameUI/BarBackground/CursorLine")
@export var catch_popup_ui: Control

var target_depth: float = 1.0 
var in_shop_area = false
var is_fishing: bool = false
var current_float = null

# Varijable za mini-igru i borbu sa ribom
var minigame_active: bool = false
var cursor_position: float = 50.0 # Pozicija crtice na traci (0 do 100)
var cursor_dir: float = 1.0       
var cursor_speed: float = 65.0    

var catch_progress: float = 30.0  # Procenat privlačenja ribe (0% do 100%)
var active_fish = null            
var float_start_x: float = 0.0
var float_target_x: float = 0.0   

const FLOAT_SCENE = preload("res://float.tscn")

func _ready() -> void:
	fishing_line.visible = false
	add_to_group("player") 
	
	if fishing_minigame_ui:
		fishing_minigame_ui.visible = false
		
	update_depth_display()

func _physics_process(delta: float) -> void:
	if is_fishing:
		velocity.x = 0
		velocity.y = 0
		
		if current_float:
			fishing_line.clear_points()
			fishing_line.add_point(fishing_line.to_local(rod_tip.global_position))
			fishing_line.add_point(fishing_line.to_local(current_float.global_position))
			
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction > 0
		animated_sprite.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animated_sprite.play("idle")

	move_and_slide()

func _on_shop_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		in_shop_area = true
		print("Usao si u shop! Pritisni E.")

func _on_shop_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		in_shop_area = false
		print("Izasao si iz shopa.")

func _input(event: InputEvent) -> void:
	# Klik mišem tokom mini-igre
	if minigame_active and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Ako klikneš dok je crtica u zelenoj zoni (20 do 80), uspešno vučeš ribu napred!
		if cursor_position >= 20.0 and cursor_position <= 80.0:
			catch_progress += 8.0  
		else:
			# Ako klikneš u crvenom polju, riba se otima i gubiš napredak
			catch_progress -= 10.0
			
		return

	if in_shop_area and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			shop_ui.visible = !shop_ui.visible
			print("Shop je uspesno otvoren!")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if minigame_active:
			return
			
		if not is_fishing:
			print("Trenutna X pozicija igrača je: ", global_position.x)
			
			if global_position.x >= -120.0 and global_position.x <= -70.0:
				cast_rod(event.position)
			else:
				print("Moraš da priđeš bliže obali!")
		else:
			pull_rod()

func cast_rod(click_pos: Vector2) -> void:
	var min_x = 10.0
	var max_x = 270.0
	var min_y = 250.0
	var max_y = 260.0
	
	if click_pos.x >= min_x and click_pos.x <= max_x and click_pos.y >= min_y and click_pos.y <= max_y:
		is_fishing = true
		animated_sprite.play("cast")
		print("Igrač je zamahnuo štapom...")
		
		await get_tree().create_timer(0.9).timeout
		
		if not is_fishing:
			return
		
		current_float = FLOAT_SCENE.instantiate()
		current_float.global_position = click_pos
		current_float.target_depth = target_depth
		get_tree().current_scene.add_child(current_float)
		
		fishing_line.visible = true
		print("Plovak je zabačen na površinu vode nakon animacije: ", click_pos)
	else:
		print("Ciljaj samo površinu vode!")

func pull_rod() -> void:
	minigame_active = false
	if fishing_minigame_ui:
		fishing_minigame_ui.visible = false
		
	is_fishing = false
	
	if active_fish and is_instance_valid(active_fish):
		active_fish.queue_free()
		active_fish = null
		
	if current_float and is_instance_valid(current_float):
		current_float.queue_free()
		current_float = null
	
	fishing_line.visible = false
	animated_sprite.play("idle")
	print("Štap je vraćen.")

# --- UPRAVLJANJE DUBINOM ---
func increase_depth() -> void:
	target_depth = min(4.0, target_depth + 1.0)
	update_depth_display()

func decrease_depth() -> void:
	target_depth = max(1.0, target_depth - 1.0)
	update_depth_display()

func update_depth_display() -> void:
	if depth_label:
		depth_label.text = "Dubina: " + str(int(target_depth)) + "m"
	
	if current_float and current_float.has_method("update_depth"):
		current_float.update_depth(target_depth)

# --- LOGIKA MINI-IGRE ---
func start_fishing_minigame(fish_node = null) -> void:
	minigame_active = true
	cursor_position = 50.0  # Crtica uvek kreće tačno sa sredine!
	cursor_dir = 1.0        
	catch_progress = 30.0   # Početni napredak da riba ne pobegne odmah
	active_fish = fish_node
	
	if current_float:
		float_start_x = current_float.global_position.x
		float_target_x = current_float.global_position.x + 120.0 
	
	if active_fish and is_instance_valid(active_fish):
		var fish_size = active_fish.scale.x 
		var normalized_size = (fish_size - 0.1) / (0.3 - 0.1) 
		cursor_speed = 50.0 + (normalized_size * 25.0) # Prilagođena brzina da možeš da je pratiš
	else:
		cursor_speed = 60.0
	
	if fishing_minigame_ui:
		fishing_minigame_ui.visible = true
	print("Borba je počela! Klikći u zelenom da privučeš ribu.")

func _process(delta: float) -> void:
	if minigame_active:
		# 1. Glatko kretanje plave crtice levo-desno
		cursor_position += cursor_dir * cursor_speed * delta
		
		# Odbijanje od ivica bara (0 i 100)
		if cursor_position <= 0.0:
			cursor_position = 0.0
			cursor_dir = 1.0
		elif cursor_position >= 100.0:
			cursor_position = 100.0
			cursor_dir = -1.0
		
		if bar_background and cursor_line:
			var max_x = bar_background.size.x - cursor_line.size.x
			cursor_line.position.x = (cursor_position / 100.0) * max_x
		
		# 2. Riba vuče nazad ako ne klikćeš
		catch_progress -= 8.0 * delta 
		catch_progress = clamp(catch_progress, 0.0, 100.0)
		
		# 3. Kretanje plovka u desno (ka obali)
		if current_float and is_instance_valid(current_float):
			var progress_ratio = catch_progress / 100.0
			var new_x = lerp(float_start_x, float_target_x, progress_ratio)
			current_float.global_position.x = new_x

		# Vizuelno praćakanje ribe na udici
		if active_fish and is_instance_valid(active_fish):
			var wiggle = sin(Time.get_ticks_msec() * 0.03) * 3.0
			active_fish.position = Vector2(0, 10 + wiggle)

		# 4. Kraj igre: uspeh ili neuspeh
		if catch_progress >= 100.0 or (current_float and current_float.global_position.x >= float_target_x - 5.0):
			succeed_fishing()
		elif catch_progress <= 0.0:
			fail_fishing()

func succeed_fishing() -> void:
	minigame_active = false
	if fishing_minigame_ui:
		fishing_minigame_ui.visible = false
		
	print("DEBAGING: Ušli smo u succeed_fishing")
	
	if catch_popup_ui:
		print("DEBAGING: catch_popup_ui POSTOJI!")
		if catch_popup_ui.has_method("prikazi_ulov"):
			print("DEBAGING: Pozivamo prikazi_ulov...")
			catch_popup_ui.prikazi_ulov(active_fish)
		else:
			print("DEBAGING: GRESKA - Nema metodu prikazi_ulov!")
	else:
		print("DEBAGING: GRESKA - catch_popup_ui je NULL!")
		
	if active_fish and is_instance_valid(active_fish):
		active_fish.queue_free()
		active_fish = null
		
	pull_rod()

func fail_fishing() -> void:
	minigame_active = false
	if fishing_minigame_ui:
		fishing_minigame_ui.visible = false
		
	if active_fish and is_instance_valid(active_fish):
		active_fish.queue_free()
		active_fish = null
		
	print("Šteta, riba se otela i pobegla!")
	pull_rod()

func show_catch_popup() -> void:
	if catch_popup_ui and catch_popup_ui.has_method("prikazi_ulov"):
		catch_popup_ui.prikazi_ulov(active_fish)
	else:
		print("GREŠKA: CatchPopupUI nije povezan ili nema funkciju prikazi_ulov!")
