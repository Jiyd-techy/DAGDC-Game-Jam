extends CanvasLayer

## Optimize at some point to only work when inventoryBus changes


@onready var label = $Label
@onready var primary = $primary
@onready var usePrimary =$usePrimary


var swingDown = false

var meleeAttacking = false
var attackSpeed = 0.5

var primaryType :String 

var rangeAttacking = false
var spawnBullet = false
var bulletType

func _process(_delta):
	label.text = "Inventory: " + str(InventoryBus.inventory)
	if InventoryBus.primary != null:
		var item_scene = load(InventoryBus.primary)
		var item_instance = item_scene.instantiate()
		var sprite = item_instance.get_node_or_null("Sprite3D")
		if sprite:
			# Convert Sprite3D texture to something the 2D sprite can use
			# For Sprite3D, the texture is in the sprite, we need to extract it
			primary.texture = sprite.texture
			usePrimary.texture = sprite.texture
			primaryType = sprite.type
			attackSpeed = sprite.attackSpeed
			
		# Free the instance (we only needed it to get the texture)
			item_instance.free()
	else:
		primary.texture = null
	
	
	if Input.is_action_just_pressed("attack") and InventoryBus.primary != null and primaryType == "melee":
		meleeAttacking = true
	if meleeAttacking:
		print_debug(usePrimary.rotation_degrees)
		if usePrimary.rotation_degrees <=100 and not swingDown:
			usePrimary.rotate(_delta *10 * attackSpeed)
			
		elif usePrimary.rotation_degrees >=1 and not Input.is_action_pressed("attack"):
			swingDown =true
			usePrimary.rotate(_delta *-40 * attackSpeed)
		elif not Input.is_action_pressed("attack"):
			usePrimary.rotation = 0
			swingDown = false
			meleeAttacking = false
	
	if Input.is_action_just_pressed("attack") and InventoryBus.primary != null and primaryType == "ranged":
		rangeAttacking=true
		
	if rangeAttacking:
		if usePrimary.rotation_degrees <=40 and not swingDown:
			usePrimary.rotate(_delta *50 * attackSpeed)
			
		elif usePrimary.rotation_degrees >=1 and not Input.is_action_pressed("attack"):
			swingDown =true
			usePrimary.rotate(_delta *-10 * attackSpeed)
		elif not Input.is_action_pressed("attack"):
			swingDown = false
			rangeAttacking = false
## not in use but use later plz for FPS sake

func _find_sprite(node) -> Sprite3D:
	if node is Sprite3D:
		return node
	
	for child in node.get_children():
		var result = _find_sprite(child)
		if result:
			return result
	
	return null
