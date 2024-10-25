extends Resource
class_name BonusManager

@export var multiplicative := true ## Decides if bonus should start at 1.

var bonuses : Dictionary = {} ## Name and value of bonus.
var fines : Dictionary = {} ## Name and value of fine.


func add_bonus(id : String, value : float) -> void : ## Percentage bonus.
	bonuses[id] = value


func add_fine(id : String, value : float) -> void : ## Percentage fine.
	fines[id] = value


func remove_bonus(id : String) -> bool : ## Returns true if successful, false if not.
	return bonuses.erase(id)


func remove_fine(id : String) -> bool : ## Returns true if successful, false if not.
	return fines.erase(id)


func has_bonus(id : String) -> bool :
	return bonuses.has(id)


func has_fine(id : String) -> bool :
	return fines.has(id)


func get_total() -> float : ## Add up all bonuses and subtract fines.
	if bonuses.is_empty() and fines.is_empty():
		return 1.0 if multiplicative else 0.0
	var total := 1.0 if multiplicative else 0.0
	for bonus in bonuses:
		total += bonuses[bonus]
	for fine in fines:
		total -= fines[fine]
	return maxf(total, 0.0) # should't be negative, would probably break things
