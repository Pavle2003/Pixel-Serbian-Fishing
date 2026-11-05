extends Node

# Niz u kojem čuvamo sve upecane ribe (naša čuvarka)
var cuvarka: Array = []

# Funkcija koja prima čvor upecane ribe, računa kilograme, zlato, XP i meso, pa je smešta u čuvarku
func dodaj_ribu_u_cuvarku(fish_node: Node) -> Dictionary:
	if not is_instance_valid(fish_node):
		return {}
		
	# 1. Izračunavanje težine na osnovu scale-a ribe
	var scale_x = fish_node.scale.x
	var tezina_kg = snappedf(scale_x * 12.0, 0.01) # Npr. scale 0.1 je ~1.20 kg
	
	# 2. Proračun nagrada srazmerno težini
	var zlato = int(tezina_kg * 15)
	var xp = int(tezina_kg * 25)
	var meso = int(tezina_kg * 2)
	
	# 3. Kreiramo rečnik (podatke) o upecanoj ribi
	var ulovljeni_podatci = {
		"naziv": "Šaran", # Možeš kasnije dinamički povlačiti ako imaš više vrsta
		"tezina": tezina_kg,
		"zlato": zlato,
		"xp": xp,
		"meso": meso,
		"scale": scale_x
	}
	
	# Dodajemo u globalnu čuvarku
	cuvarka.append(ulovljeni_podatci)
	print("Uspesno sacuvano u cuvarku! Ukupno riba: ", cuvarka.size())
	
	return ulovljeni_podatci
