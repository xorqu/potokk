extends Node3D

var t = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta
	$Node3D/Angel0.rotate_x(0.02)
	
	$Node3D/Angel1.rotate_x(+0.010)
	$Node3D/Angel1.rotate_z(+0.004)
	$Node3D/Angel1.rotate_y(-0.026)

	$Node3D/Angel2.rotate_x(-0.022)
	$Node3D/Angel2.rotate_z(+0.004)
	$Node3D/Angel2.rotate_y(-0.024)
	
	$Node3D/Angel3.rotate_x(-0.002)
	$Node3D/Angel3.rotate_z(-0.024)
	$Node3D/Angel3.rotate_y(+0.006)

	$Node3D.set_position(Vector3(0,sin(t)*1,0))
	print($Node3D.get_position())
