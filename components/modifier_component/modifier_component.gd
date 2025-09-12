extends Node3D
class_name ModifierComponent

signal modifiers_changed()

@export var target : Ship


#func _ready():
	#target.armor_inventory.slotref_changed.connect(_on_slotref_changed)
	#target.accessory_inventory.slotref_changed.connect(_on_slotref_changed)


func add_modifier(scene : PackedScene) -> void :
	var mod := scene.instantiate() as Modifier
	add_child(mod)
	mod.enable()
	mod.update_bonuses()
	modifiers_changed.emit()


func remove_modifier(id : StringName) -> void :
	for child in get_children():
		if child.id == id:
			child.disable()
			child.update_bonuses()
			child.queue_free()
			await child.tree_exited
			modifiers_changed.emit()


#func _on_slotref_changed(old_ref : SlotRef, new_ref : SlotRef) -> void :
	#if is_instance_valid(old_ref):
		#for child in get_children():
			#if StringName(old_ref.itemref.ref_id) == child.id:
				#remove_modifier(child.id)
				#break
	## check if removed slotref is here and delete it, then check if new slotref isn't here, and add it
	#if is_instance_valid(new_ref):
		#for child in get_children():
			#if StringName(new_ref.itemref.ref_id) == child.id:
				#return
		#add_modifier(new_ref.itemref.modifier_scene)
