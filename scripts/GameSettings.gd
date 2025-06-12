class_name GameSettings
extends Node

# 游戏设置信号
signal settings_changed(setting_name: String, new_value)
signal language_changed(new_language: String)
signal difficulty_changed(new_difficulty: int)

# 游戏基础设置
var game_language: String = "zh_CN"  # 游戏语言
var game_difficulty: int = 1  # 游戏难度 (1-简单, 2-中等, 3-困难)
var question_count: int = 5  # 每局问题数量
var time_limit_enabled: bool = true  # 是否启用时间限制
var voice_input_enabled: bool = true  # 是否启用语音输入
var auto_next_question: bool = false  # 是否自动进入下一题
var show_hints: bool = true  # 是否显示提示
var show_progress: bool = true  # 是否显示进度

# 显示设置
var fullscreen_enabled: bool = false  # 全屏模式
var window_size: Vector2i = Vector2i(1024, 768)  # 窗口大小
var ui_scale: float = 1.0  # UI缩放
var font_size: int = 16  # 字体大小
var high_contrast: bool = false  # 高对比度模式
var colorblind_friendly: bool = false  # 色盲友好模式

# 输入设置
var mouse_sensitivity: float = 1.0  # 鼠标灵敏度
var keyboard_repeat_delay: float = 0.5  # 键盘重复延迟
var touch_enabled: bool = true  # 触摸输入

# 语音设置
var voice_recognition_language: String = "zh-CN"  # 语音识别语言
var voice_sensitivity: float = 0.5  # 语音识别灵敏度
var noise_suppression: bool = true  # 噪音抑制
var echo_cancellation: bool = true  # 回声消除

# 游戏数据设置
var save_progress: bool = true  # 保存游戏进度
var auto_save: bool = true  # 自动保存
var statistics_enabled: bool = true  # 启用统计
var analytics_enabled: bool = false  # 启用分析

# 开发者设置
var debug_mode: bool = false  # 调试模式
var show_fps: bool = false  # 显示FPS
var log_level: int = 1  # 日志级别 (0-关闭, 1-错误, 2-警告, 3-信息, 4-调试)

# 设置文件路径
const SETTINGS_FILE = "user://game_settings.cfg"

# 支持的语言列表
const SUPPORTED_LANGUAGES = {
    "zh_CN": "简体中文",
    "zh_TW": "繁體中文",
    "en_US": "English",
    "ja_JP": "日本語",
    "ko_KR": "한국어"
}

# 难度设置
const DIFFICULTY_SETTINGS = {
    1: {
        "name": "简单",
        "description": "基础问题，充足时间",
        "time_multiplier": 1.5,
        "question_types": ["basic"],
        "hint_enabled": true
    },
    2: {
        "name": "中等",
        "description": "标准问题，正常时间",
        "time_multiplier": 1.0,
        "question_types": ["basic", "intermediate"],
        "hint_enabled": true
    },
    3: {
        "name": "困难",
        "description": "复杂问题，限制时间",
        "time_multiplier": 0.7,
        "question_types": ["basic", "intermediate", "advanced"],
        "hint_enabled": false
    }
}

func _ready():
    load_settings()
    apply_settings()

# 加载设置
func load_settings():
    var config = ConfigFile.new()
    var err = config.load(SETTINGS_FILE)
    
    if err != OK:
        print("无法加载设置文件，使用默认设置")
        save_settings()  # 创建默认设置文件
        return
    
    # 游戏设置
    game_language = config.get_value("game", "language", game_language)
    game_difficulty = config.get_value("game", "difficulty", game_difficulty)
    question_count = config.get_value("game", "question_count", question_count)
    time_limit_enabled = config.get_value("game", "time_limit_enabled", time_limit_enabled)
    voice_input_enabled = config.get_value("game", "voice_input_enabled", voice_input_enabled)
    auto_next_question = config.get_value("game", "auto_next_question", auto_next_question)
    show_hints = config.get_value("game", "show_hints", show_hints)
    show_progress = config.get_value("game", "show_progress", show_progress)
    
    # 显示设置
    fullscreen_enabled = config.get_value("display", "fullscreen", fullscreen_enabled)
    window_size.x = config.get_value("display", "window_width", window_size.x)
    window_size.y = config.get_value("display", "window_height", window_size.y)
    ui_scale = config.get_value("display", "ui_scale", ui_scale)
    font_size = config.get_value("display", "font_size", font_size)
    high_contrast = config.get_value("display", "high_contrast", high_contrast)
    colorblind_friendly = config.get_value("display", "colorblind_friendly", colorblind_friendly)
    
    # 输入设置
    mouse_sensitivity = config.get_value("input", "mouse_sensitivity", mouse_sensitivity)
    keyboard_repeat_delay = config.get_value("input", "keyboard_repeat_delay", keyboard_repeat_delay)
    touch_enabled = config.get_value("input", "touch_enabled", touch_enabled)
    
    # 语音设置
    voice_recognition_language = config.get_value("voice", "recognition_language", voice_recognition_language)
    voice_sensitivity = config.get_value("voice", "sensitivity", voice_sensitivity)
    noise_suppression = config.get_value("voice", "noise_suppression", noise_suppression)
    echo_cancellation = config.get_value("voice", "echo_cancellation", echo_cancellation)
    
    # 数据设置
    save_progress = config.get_value("data", "save_progress", save_progress)
    auto_save = config.get_value("data", "auto_save", auto_save)
    statistics_enabled = config.get_value("data", "statistics_enabled", statistics_enabled)
    analytics_enabled = config.get_value("data", "analytics_enabled", analytics_enabled)
    
    # 开发者设置
    debug_mode = config.get_value("developer", "debug_mode", debug_mode)
    show_fps = config.get_value("developer", "show_fps", show_fps)
    log_level = config.get_value("developer", "log_level", log_level)

# 保存设置
func save_settings():
    var config = ConfigFile.new()
    
    # 游戏设置
    config.set_value("game", "language", game_language)
    config.set_value("game", "difficulty", game_difficulty)
    config.set_value("game", "question_count", question_count)
    config.set_value("game", "time_limit_enabled", time_limit_enabled)
    config.set_value("game", "voice_input_enabled", voice_input_enabled)
    config.set_value("game", "auto_next_question", auto_next_question)
    config.set_value("game", "show_hints", show_hints)
    config.set_value("game", "show_progress", show_progress)
    
    # 显示设置
    config.set_value("display", "fullscreen", fullscreen_enabled)
    config.set_value("display", "window_width", window_size.x)
    config.set_value("display", "window_height", window_size.y)
    config.set_value("display", "ui_scale", ui_scale)
    config.set_value("display", "font_size", font_size)
    config.set_value("display", "high_contrast", high_contrast)
    config.set_value("display", "colorblind_friendly", colorblind_friendly)
    
    # 输入设置
    config.set_value("input", "mouse_sensitivity", mouse_sensitivity)
    config.set_value("input", "keyboard_repeat_delay", keyboard_repeat_delay)
    config.set_value("input", "touch_enabled", touch_enabled)
    
    # 语音设置
    config.set_value("voice", "recognition_language", voice_recognition_language)
    config.set_value("voice", "sensitivity", voice_sensitivity)
    config.set_value("voice", "noise_suppression", noise_suppression)
    config.set_value("voice", "echo_cancellation", echo_cancellation)
    
    # 数据设置
    config.set_value("data", "save_progress", save_progress)
    config.set_value("data", "auto_save", auto_save)
    config.set_value("data", "statistics_enabled", statistics_enabled)
    config.set_value("data", "analytics_enabled", analytics_enabled)
    
    # 开发者设置
    config.set_value("developer", "debug_mode", debug_mode)
    config.set_value("developer", "show_fps", show_fps)
    config.set_value("developer", "log_level", log_level)
    
    config.save(SETTINGS_FILE)

# 应用设置
func apply_settings():
    apply_display_settings()
    apply_input_settings()
    apply_language_settings()
    
    # 发送设置变更信号
    settings_changed.emit("all", null)

# 应用显示设置
func apply_display_settings():
    # 设置窗口模式
    if fullscreen_enabled:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        DisplayServer.window_set_size(window_size)
    
    # 设置UI缩放
    get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_CANVAS_ITEMS, SceneTree.STRETCH_ASPECT_KEEP, window_size)

# 应用输入设置
func apply_input_settings():
    # 设置鼠标灵敏度
    Input.set_default_cursor_shape(Input.CURSOR_ARROW)
    
    # 设置触摸输入
    if not touch_enabled:
        Input.set_use_accumulated_input(false)

# 应用语言设置
func apply_language_settings():
    # 设置游戏语言
    if game_language in SUPPORTED_LANGUAGES:
        TranslationServer.set_locale(game_language)
        language_changed.emit(game_language)

# 设置游戏语言
func set_language(language: String):
    if language in SUPPORTED_LANGUAGES:
        game_language = language
        apply_language_settings()
        save_settings()
        settings_changed.emit("language", language)

# 设置游戏难度
func set_difficulty(difficulty: int):
    if difficulty in DIFFICULTY_SETTINGS:
        game_difficulty = difficulty
        save_settings()
        difficulty_changed.emit(difficulty)
        settings_changed.emit("difficulty", difficulty)

# 设置问题数量
func set_question_count(count: int):
    question_count = clamp(count, 1, 20)
    save_settings()
    settings_changed.emit("question_count", question_count)

# 切换全屏模式
func toggle_fullscreen():
    fullscreen_enabled = not fullscreen_enabled
    apply_display_settings()
    save_settings()
    settings_changed.emit("fullscreen", fullscreen_enabled)

# 设置UI缩放
func set_ui_scale(scale: float):
    ui_scale = clamp(scale, 0.5, 2.0)
    apply_display_settings()
    save_settings()
    settings_changed.emit("ui_scale", ui_scale)

# 设置字体大小
func set_font_size(size: int):
    font_size = clamp(size, 12, 32)
    save_settings()
    settings_changed.emit("font_size", font_size)

# 切换语音输入
func toggle_voice_input():
    voice_input_enabled = not voice_input_enabled
    save_settings()
    settings_changed.emit("voice_input", voice_input_enabled)

# 切换时间限制
func toggle_time_limit():
    time_limit_enabled = not time_limit_enabled
    save_settings()
    settings_changed.emit("time_limit", time_limit_enabled)

# 切换提示显示
func toggle_hints():
    show_hints = not show_hints
    save_settings()
    settings_changed.emit("hints", show_hints)

# 切换调试模式
func toggle_debug_mode():
    debug_mode = not debug_mode
    save_settings()
    settings_changed.emit("debug_mode", debug_mode)

# 获取当前难度设置
func get_difficulty_settings() -> Dictionary:
    return DIFFICULTY_SETTINGS.get(game_difficulty, DIFFICULTY_SETTINGS[1])

# 获取支持的语言列表
func get_supported_languages() -> Dictionary:
    return SUPPORTED_LANGUAGES

# 获取当前语言名称
func get_current_language_name() -> String:
    return SUPPORTED_LANGUAGES.get(game_language, "简体中文")

# 获取当前难度名称
func get_current_difficulty_name() -> String:
    var difficulty_info = get_difficulty_settings()
    return difficulty_info.get("name", "简单")

# 重置所有设置为默认值
func reset_to_defaults():
    game_language = "zh_CN"
    game_difficulty = 1
    question_count = 5
    time_limit_enabled = true
    voice_input_enabled = true
    auto_next_question = false
    show_hints = true
    show_progress = true
    
    fullscreen_enabled = false
    window_size = Vector2i(1024, 768)
    ui_scale = 1.0
    font_size = 16
    high_contrast = false
    colorblind_friendly = false
    
    mouse_sensitivity = 1.0
    keyboard_repeat_delay = 0.5
    touch_enabled = true
    
    voice_recognition_language = "zh-CN"
    voice_sensitivity = 0.5
    noise_suppression = true
    echo_cancellation = true
    
    save_progress = true
    auto_save = true
    statistics_enabled = true
    analytics_enabled = false
    
    debug_mode = false
    show_fps = false
    log_level = 1
    
    apply_settings()
    save_settings()
    settings_changed.emit("reset", null)

# 获取所有设置的字典
func get_all_settings() -> Dictionary:
    return {
        "game": {
            "language": game_language,
            "difficulty": game_difficulty,
            "question_count": question_count,
            "time_limit_enabled": time_limit_enabled,
            "voice_input_enabled": voice_input_enabled,
            "auto_next_question": auto_next_question,
            "show_hints": show_hints,
            "show_progress": show_progress
        },
        "display": {
            "fullscreen": fullscreen_enabled,
            "window_size": window_size,
            "ui_scale": ui_scale,
            "font_size": font_size,
            "high_contrast": high_contrast,
            "colorblind_friendly": colorblind_friendly
        },
        "input": {
            "mouse_sensitivity": mouse_sensitivity,
            "keyboard_repeat_delay": keyboard_repeat_delay,
            "touch_enabled": touch_enabled
        },
        "voice": {
            "recognition_language": voice_recognition_language,
            "sensitivity": voice_sensitivity,
            "noise_suppression": noise_suppression,
            "echo_cancellation": echo_cancellation
        },
        "data": {
            "save_progress": save_progress,
            "auto_save": auto_save,
            "statistics_enabled": statistics_enabled,
            "analytics_enabled": analytics_enabled
        },
        "developer": {
            "debug_mode": debug_mode,
            "show_fps": show_fps,
            "log_level": log_level
        }
    }