extends CharacterBody2D 
var SPEED = 300.0
var GRAVITY = 800
const JUMP_VELOCITY = -350.0
var looking = false
var idle = false
var last_jump_time = 0.0
var fly = false
var logic = 1
var selected;
var sneaking = false
var hub_screen = preload("res://ui/hub_screen.tscn").instantiate()
@onready var hotbar: ItemList = hub_screen.find_child("hotbar", true, false)
@onready var inventory = $Hub/Survival




func _ready():

	Global.selected = 1
	inventory.visible = false
	add_child(hub_screen)
	print("Children of hub_screen:", hub_screen.get_children())
	print("Hub Screen Parent:", hub_screen.get_parent())
				
	$AnimationPlayer.play("edle")

func _physics_process(delta):
	# Áp dụng trọng lực
	if Input.is_action_just_pressed("inventory"):
		inventory.visible = !inventory.visible
	if fly == false and not is_on_floor():
		velocity.y += GRAVITY * delta
	if fly == true and not is_on_floor():
		velocity.y = 0
	# Xử lý nhảy
	if logic % 2 == 0:
		fly = true
	else:
		fly = false
	if Input.is_action_just_pressed("ui_accept"):
		var current_time = Time.get_ticks_msec() / 1000.0  # Thời gian hiện tại tính bằng giây
		if current_time - last_jump_time <= 0.3 and not is_on_floor():
			print("fly check:")
			logic += 1
			print(logic)
			if logic == 5:
				logic = 1
		last_jump_time = current_time  # Cập nhật thời gian nhấn mới
	# Di chuyển nhân vật
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var direction := Input.get_axis("move_left", "move_right")
	var vertical_direction = Input.get_axis("move_up", "move_down")
	if fly == true:
		velocity.y = vertical_direction * SPEED
		if vertical_direction > 0 or vertical_direction < 0:
			$AnimationPlayer.play("edle")
	velocity.x = direction * SPEED
	if Input.is_action_just_pressed("move_down") and is_on_floor():
		$AnimationPlayer.play("edle")
	if Input.is_action_pressed("left_mouse") or Input.is_action_pressed("right_mouse"):  # Nhân vật đang đứng yên trên mặt đất
		if looking == false:
			$AnimationPlayer.play("left_break")
		else:
			$AnimationPlayer.play("right_break")
	elif direction == 0:  # Nhân vật đang đứng yên trên mặt đất
		$AnimationPlayer.play("edle")
	elif direction != 0:  # Nhân vật đang đi bộ
		$AnimationPlayer.play("run")  # Đảm bảo bạn tạo animation "walk"
	elif velocity.y > 0 and not $AnimationPlayer.is_playing():
			$AnimationPlayer.play("edle")  # Gọi animation "fall" khi nhân vật đang rơi
	#chuột phải theo hướng
	# Lật các sprite khi di chuyển 
	if direction < 0:
		looking = true
		$head.flip_h = true
		$LeftHand.flip_h = true
		$body.flip_h = true
		$RightArm.flip_h = true
		$LeftArm.flip_h = true
		$RightHand.flip_h = true
	elif direction > 0:
		looking = false
		$head.flip_h = false
		$LeftHand.flip_h = false
		$body.flip_h = false
		$RightArm.flip_h = false
		$LeftArm.flip_h = false
		$RightHand.flip_h = false
	move_and_slide()
func sneak():
	$head.rotation = 180
func _on_hotbar_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		get_viewport().set_input_as_handled()  # Chặn sự kiện chuột tiếp tục lan xuống dưới
