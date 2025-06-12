class_name NPCController
extends Node2D

# NPC表情纹理
@export var expression_neutral: Texture2D
@export var expression_doubt: Texture2D
@export var expression_angry: Texture2D
@export var expression_smile: Texture2D

@onready var npc_sprite: Sprite2D = $NPCSprite
@onready var glasses_effect: Sprite2D = $GlassesEffect
@onready var audio_player: AudioStreamPlayer = $AudioPlayer
@onready var question_label: Label = $QuestionBubble/QuestionLabel
@onready var question_bubble: Control = $QuestionBubble

var current_expression: String = "neutral"
var is_speaking: bool = false

func _ready():
	# 加载表情纹理
	load_expressions()
	set_expression("neutral")
	setup_question_bubble()

func load_expressions():
	# 加载机场素材中的表情图片
	expression_neutral = load("res://机场素材/海关表情【平静】.png")
	expression_smile = load("res://机场素材/海关表情【微笑】.png")
	expression_angry = load("res://机场素材/海关表情【警告】.png")
	# 怀疑表情可以复用警告表情
	expression_doubt = expression_angry
	
	if expression_neutral:
		npc_sprite.texture = expression_neutral
	else:
		print("警告: 无法加载NPC表情纹理")

func setup_question_bubble():
	# 设置问题气泡
	if question_bubble:
		question_bubble.hide()
	if question_label:
		question_label.text = ""
		question_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		question_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		question_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func ask_question(question_text: String):
	set_expression("neutral")
	show_question_bubble(question_text)
	
	# 播放问题音频 (如果有)
	# audio_player.play()
	
	# 添加说话动画
	animate_speaking()

func show_question_bubble(text: String):
	if question_label and question_bubble:
		question_label.text = text
		question_bubble.show()
		
		# 气泡出现动画
		var tween = create_tween()
		question_bubble.modulate.a = 0.0
		question_bubble.scale = Vector2(0.8, 0.8)
		tween.parallel().tween_property(question_bubble, "modulate:a", 1.0, 0.3)
		tween.parallel().tween_property(question_bubble, "scale", Vector2(1.0, 1.0), 0.3)
		tween.tween_interval(3.0)
		tween.tween_property(question_bubble, "modulate:a", 0.7, 0.2)

func hide_question_bubble():
	if question_bubble:
		var tween = create_tween()
		tween.tween_property(question_bubble, "modulate:a", 0.0, 0.2)
		tween.tween_callback(question_bubble.hide)

func animate_speaking():
	is_speaking = true
	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(npc_sprite, "scale", Vector2(1.05, 0.95), 0.2)
	tween.tween_property(npc_sprite, "scale", Vector2(1.0, 1.0), 0.2)
	tween.tween_callback(func(): is_speaking = false)

func show_reaction(passed: bool):
	hide_question_bubble()
	
	if passed:
		set_expression("smile")
		if glasses_effect:
			glasses_effect.modulate.a = 0.0  # 眼镜不反光
		animate_approval()
	else:
		set_expression("angry")
		if glasses_effect:
			glasses_effect.modulate.a = 0.8  # 眼镜强烈反光
		animate_disapproval()

func animate_approval():
	var tween = create_tween()
	# 点头动画
	tween.tween_property(npc_sprite, "rotation", deg_to_rad(5), 0.2)
	tween.tween_property(npc_sprite, "rotation", deg_to_rad(-5), 0.2)
	tween.tween_property(npc_sprite, "rotation", 0, 0.2)
	
	# 轻微放大效果
	tween.parallel().tween_property(npc_sprite, "scale", Vector2(1.1, 1.1), 0.3)
	tween.tween_property(npc_sprite, "scale", Vector2(1.0, 1.0), 0.3)

func animate_disapproval():
	var tween = create_tween()
	# 摇头动画
	tween.tween_property(npc_sprite, "rotation", deg_to_rad(-10), 0.15)
	tween.tween_property(npc_sprite, "rotation", deg_to_rad(10), 0.15)
	tween.tween_property(npc_sprite, "rotation", deg_to_rad(-5), 0.15)
	tween.tween_property(npc_sprite, "rotation", 0, 0.15)
	
	# 眼镜反光效果
	if glasses_effect:
		tween.parallel().tween_property(glasses_effect, "modulate:a", 1.0, 0.2)
		tween.tween_property(glasses_effect, "modulate:a", 0.8, 0.2)

func set_expression(expression: String):
	current_expression = expression
	
	match expression:
		"neutral":
			if expression_neutral:
				npc_sprite.texture = expression_neutral
		"smile":
			if expression_smile:
				npc_sprite.texture = expression_smile
		"angry":
			if expression_angry:
				npc_sprite.texture = expression_angry
		"doubt":
			if expression_doubt:
				npc_sprite.texture = expression_doubt
		_:
			print("未知表情: ", expression)

func show_success():
	set_expression("smile")
	hide_question_bubble()
	
	# 播放盖章动画
	var tween = create_tween()
	tween.tween_property(npc_sprite, "scale", Vector2(1.2, 1.2), 0.3)
	tween.tween_property(npc_sprite, "scale", Vector2(1.0, 1.0), 0.3)
	
	# 成功特效
	if glasses_effect:
		glasses_effect.modulate.a = 0.0
	
	# 旋转庆祝
	tween.parallel().tween_property(npc_sprite, "rotation", deg_to_rad(360), 1.0)
	tween.tween_property(npc_sprite, "rotation", 0, 0.1)

func show_failure():
	set_expression("angry")
	hide_question_bubble()
	
	# 失败动画
	var tween = create_tween()
	# 强烈摇头
	tween.tween_property(npc_sprite, "rotation", deg_to_rad(-15), 0.1)
	tween.tween_property(npc_sprite, "rotation", deg_to_rad(15), 0.1)
	tween.tween_property(npc_sprite, "rotation", deg_to_rad(-15), 0.1)
	tween.tween_property(npc_sprite, "rotation", deg_to_rad(15), 0.1)
	tween.tween_property(npc_sprite, "rotation", 0, 0.2)
	
	# 眼镜强烈反光
	if glasses_effect:
		glasses_effect.modulate.a = 1.0
		tween.parallel().tween_property(glasses_effect, "modulate:a", 0.5, 0.2)
		tween.tween_property(glasses_effect, "modulate:a", 1.0, 0.2)

func reset_npc():
	set_expression("neutral")
	hide_question_bubble()
	npc_sprite.rotation = 0
	npc_sprite.scale = Vector2(1.0, 1.0)
	if glasses_effect:
		glasses_effect.modulate.a = 0.0
	is_speaking = false
