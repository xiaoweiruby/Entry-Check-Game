class_name MainUI
extends Control

signal start_game_pressed
signal restart_game_pressed

# UI界面引用
@onready var start_screen: Control = $StartScreen
@onready var game_screen: Control = $GameScreen
@onready var success_screen: Control = $SuccessScreen
@onready var failure_screen: Control = $FailureScreen

# 游戏界面元素
@onready var question_label: Label = $GameScreen/QuestionPanel/QuestionLabel
@onready var feedback_panel: Panel = $GameScreen/FeedbackPanel
@onready var feedback_label: Label = $GameScreen/FeedbackPanel/FeedbackLabel
@onready var voice_input_area: Control = $GameScreen/QuestionPanel/VoiceInputArea

# 按钮引用
@onready var start_button: Button = $StartScreen/StartButton
@onready var restart_button: Button = $SuccessScreen/RestartButton
@onready var retry_button: Button = $FailureScreen/RetryButton

# 语音录制器引用
var voice_recorder: VoiceRecorder

func _ready():
	# 连接按钮信号
	start_button.pressed.connect(_on_start_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	retry_button.pressed.connect(_on_retry_button_pressed)
	
	# 初始化界面
	show_start_screen()
	
	# 获取语音录制器引用
	voice_recorder = get_node("../VoiceRecorder")
	if voice_recorder:
		setup_voice_input_ui()

func setup_voice_input_ui():
	# 将语音录制器的UI元素添加到游戏界面
	if voice_recorder and voice_input_area:
		# 重新设置语音录制器UI的父节点
		for child in voice_recorder.get_children():
			if child is Control:
				voice_recorder.remove_child(child)
				voice_input_area.add_child(child)
				
				# 调整UI布局
				if child is LineEdit:
					child.anchors_preset = Control.PRESET_HCENTER_WIDE
					child.anchor_left = 0.0
					child.anchor_right = 1.0
					child.anchor_top = 0.0
					child.anchor_bottom = 1.0
					child.offset_left = 10
					child.offset_right = -10
					child.offset_top = 10
					child.offset_bottom = -10
				elif child is Button:
					child.anchors_preset = Control.PRESET_CENTER
					child.anchor_left = 0.5
					child.anchor_right = 0.5
					child.anchor_top = 0.5
					child.anchor_bottom = 0.5
					child.offset_left = -75
					child.offset_right = 75
					child.offset_top = -20
					child.offset_bottom = 20
				elif child is Label:
					child.anchors_preset = Control.PRESET_CENTER_TOP
					child.anchor_left = 0.5
					child.anchor_right = 0.5
					child.anchor_top = 0.0
					child.anchor_bottom = 0.0
					child.offset_left = -150
					child.offset_right = 150
					child.offset_top = 5
					child.offset_bottom = 25

func _on_start_button_pressed():
	start_game_pressed.emit()

func _on_restart_button_pressed():
	restart_game_pressed.emit()

func _on_retry_button_pressed():
	restart_game_pressed.emit()

func show_start_screen():
	hide_all_screens()
	start_screen.show()
	
	# 开始界面动画
	var tween = create_tween()
	start_screen.modulate.a = 0.0
	tween.tween_property(start_screen, "modulate:a", 1.0, 0.5)

func show_game_screen():
	hide_all_screens()
	game_screen.show()
	feedback_panel.hide()
	
	# 游戏界面动画
	var tween = create_tween()
	game_screen.modulate.a = 0.0
	tween.tween_property(game_screen, "modulate:a", 1.0, 0.3)

func show_success_screen():
	hide_all_screens()
	success_screen.show()
	
	# 成功界面动画
	var tween = create_tween()
	success_screen.modulate.a = 0.0
	success_screen.scale = Vector2(0.8, 0.8)
	tween.parallel().tween_property(success_screen, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(success_screen, "scale", Vector2(1.0, 1.0), 0.5)
	
	# 播放成功音效 (如果有)
	# AudioManager.play_success_sound()

func show_failure_screen():
	hide_all_screens()
	failure_screen.show()
	
	# 失败界面动画
	var tween = create_tween()
	failure_screen.modulate.a = 0.0
	tween.tween_property(failure_screen, "modulate:a", 1.0, 0.5)
	
	# 播放失败音效 (如果有)
	# AudioManager.play_failure_sound()

func hide_all_screens():
	start_screen.hide()
	game_screen.hide()
	success_screen.hide()
	failure_screen.hide()
	feedback_panel.hide()

func show_question(question_text: String):
	show_game_screen()
	question_label.text = question_text
	feedback_panel.hide()
	
	# 问题显示动画
	var tween = create_tween()
	question_label.modulate.a = 0.0
	question_label.scale = Vector2(0.9, 0.9)
	tween.parallel().tween_property(question_label, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(question_label, "scale", Vector2(1.0, 1.0), 0.3)

func show_feedback(message: String, is_correct: bool):
	feedback_label.text = message
	
	# 设置反馈颜色
	if is_correct:
		feedback_label.modulate = Color.GREEN
		feedback_panel.modulate = Color(0.8, 1.0, 0.8, 0.9)
	else:
		feedback_label.modulate = Color.RED
		feedback_panel.modulate = Color(1.0, 0.8, 0.8, 0.9)
	
	feedback_panel.show()
	
	# 反馈显示动画
	var tween = create_tween()
	feedback_panel.modulate.a = 0.0
	feedback_panel.scale = Vector2(0.8, 0.8)
	tween.parallel().tween_property(feedback_panel, "modulate:a", 0.9, 0.3)
	tween.parallel().tween_property(feedback_panel, "scale", Vector2(1.0, 1.0), 0.3)
	
	# 延迟隐藏反馈面板
	tween.tween_interval(2.0)
	tween.tween_callback(hide_feedback_panel)

func update_progress(current: int, total: int):
	# 更新进度显示
	var progress_label = get_node_or_null("../GameScene/ProgressArea/ProgressLabel")
	var progress_bar = get_node_or_null("../GameScene/ProgressArea/ProgressBar")
	
	if progress_label:
		progress_label.text = "问题 %d/%d" % [current + 1, total]
	
	if progress_bar:
		progress_bar.value = current
		
		# 进度条动画
		var tween = create_tween()
		tween.tween_property(progress_bar, "value", current, 0.3)

func show_hint(hint_text: String):
	# 显示提示信息
	var hint_label = Label.new()
	hint_label.text = hint_text
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.modulate = Color.YELLOW
	
	# 添加到游戏界面
	game_screen.add_child(hint_label)
	hint_label.anchors_preset = Control.PRESET_CENTER
	hint_label.anchor_left = 0.5
	hint_label.anchor_right = 0.5
	hint_label.anchor_top = 0.3
	hint_label.anchor_bottom = 0.3
	hint_label.offset_left = -200
	hint_label.offset_right = 200
	hint_label.offset_top = -25
	hint_label.offset_bottom = 25
	
	# 提示动画
	var tween = create_tween()
	hint_label.modulate.a = 0.0
	tween.tween_property(hint_label, "modulate:a", 1.0, 0.3)
	# 延迟隐藏提示标签
	tween.tween_interval(3.0)
	tween.tween_callback(hide_hint_label)

func hide_feedback_panel():
	if feedback_panel:
		feedback_panel.hide()

func hide_hint_label():
	# Iterate through children of game_screen to find and remove the hint label
	# This is a simple way, assuming only one hint label is added at a time
	# and it's a direct child of game_screen.
	# For more complex scenarios, you might need a more robust way to track hint labels.
	for child in game_screen.get_children():
		if child is Label and child.text.begins_with("提示：") or child.modulate == Color.YELLOW: # A way to identify the hint label
			child.queue_free()
			break # Assuming only one hint label to remove

func enable_voice_input():
	if voice_recorder:
		voice_recorder.show_recording_ui()

func disable_voice_input():
	if voice_recorder:
		voice_recorder.hide_all_ui()

# 辅助函数：获取当前显示的界面
func get_current_screen() -> String:
	if start_screen.visible:
		return "start"
	elif game_screen.visible:
		return "game"
	elif success_screen.visible:
		return "success"
	elif failure_screen.visible:
		return "failure"
	else:
		return "none"
