extends Node

var cuvarka: Array = []
var maksimalni_kapacitet: int = 5

func izbaci_ribu_iz_cuvarke(index: int) -> void:
	if index >= 0 and index < cuvarka.size():
		cuvarka.remove_at(index)
		print("Riba uklonjena iz čuvarke na indeksu: ", index)

func dodaj_ribu_u_cuvarku(fish_node: Node) -> Dictionary:
	if not is_instance_valid(fish_node):
		return {}
		
	# Proveravamo da li je čuvarka puna
	if cuvarka.size() >= maksimalni_kapacitet:
		print("Čuvarka je puna! Maksimalno može " + str(maksimalni_kapacitet) + " riba.")
		return {"puna": true}
		
	var scale_x = fish_node.scale.x
	var tezina_kg = snappedf(remap(scale_x, 0.1, 0.3, 1.0, 12.0), 0.01)
	
	var zlato = int(tezina_kg * 15)
	var xp = int(tezina_kg * 25)
	var meso = int(tezina_kg * 2)
	
	# Treba nam i tekstura/slika ribe da bismo je kasnije prikazali u rancu!
	var fish_texture = null
	var fish_anim_sprite = fish_node.find_child("AnimatedSprite2D", true, false)
	if not fish_anim_sprite:
		fish_anim_sprite = fish_node.find_child("Swim", true, false)
		
	if fish_anim_sprite and fish_anim_sprite.sprite_frames:
		var current_anim = fish_anim_sprite.animation
		if current_anim:
			fish_texture = fish_anim_sprite.sprite_frames.get_frame_texture(current_anim, 0)

	var ulovljeni_podatci = {
		"naziv": "Šaran",
		"tezina": tezina_kg,
		"zlato": zlato,
		"xp": xp,
		"meso": meso,
		"scale": scale_x,
		"tekstura": fish_texture
	}
	
	cuvarka.append(ulovljeni_podatci)
	print("Uspešno sačuvano u čuvarku! Ukupno riba: ", cuvarka.size(), "/", maksimalni_kapacitet)
	
	return ulovljeni_podatci
