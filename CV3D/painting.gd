extends Node3D

#The painting will use the camera vector to determine where to look to when popping out
@export var player_camera: Camera3D
@export var jobId: int = -1

var cameraPin: Marker3D
var is_looking = false
var is_spinning = false

var currentZRot = 0:
	get:
		return currentZRot
	set(value):
		currentZRot = value

@export var popped_out = false

func _init():
	cameraPin = $CameraPin

func _process(_delta):
	if(player_camera):
		if(global_position.distance_to(player_camera.global_position) < 40):
			if(!is_spinning):
				is_spinning = true
				tween_spin(true)
			
			#tween_look_at(_delta)
			
			is_looking = true
			#$PopUpPainting.visible = true
			if(!popped_out):
				popped_out = true
				$AnimationPlayer.play("zoom_out")

		else:
			is_looking = false
			if(popped_out):
				tween_spin(false)
				popped_out = false
				$AnimationPlayer.play_backwards("zoom_out")

func tween_spin(isPopOut):
	var subject = $PopUpPainting
	var dummy = Node3D.new()
	self.add_child(dummy)
	dummy.global_transform.origin = subject.global_transform.origin
	if(isPopOut):
		if(currentZRot < 360):
			var tween = self.create_tween()
			tween.finished.connect(_on_spin_ended)
			tween.tween_property(self, "currentZRot", 360, 0.5)
	else:
		subject.rotation_degrees.z = 360
		currentZRot = 0
		dummy.rotation_degrees.z = 0
		var tween = self.create_tween()
		tween.finished.connect(_on_spin_ended)
		tween.tween_property(subject, "rotation_degrees", dummy.rotation_degrees, 0.5)
		
		
	
func _on_spin_ended():
	print("spin ended")
	is_spinning = false
	
#func tween_look_at(delta):
	#var subject = $PopUpPainting
	#var object = player_camera
#
	#var dummy = Node3D.new()
	#self.add_child(dummy)
#
	#dummy.global_transform.origin = subject.global_transform.origin
	#
	#var newUp = Vector3(0,1,0).rotated(Vector3(0,0,1),deg_to_rad(currentZRot))
	#print("newUp:", newUp)
	#print("currentZRot: ", deg_to_rad(currentZRot))
#
	#subject.look_at(object.global_transform.origin, newUp, true)
	##var tween = self.create_tween()
	##tween.tween_property(
			##subject,
			##"rotation_degrees",
			##dummy.rotation_degrees,
			##0.5)

func _on_area_3d_body_entered(body):
	get_tree().call_group("gallery","showPrompt",true, $CameraPin, jobId)
	

func _on_area_3d_body_exited(body):
	get_tree().call_group("gallery","showPrompt",false, $CameraPin)
