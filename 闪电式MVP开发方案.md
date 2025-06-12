# 闪电式MVP开发方案 - 入境检查Demo

## 🚀 闪电式开发核心理念

### 验证优先原则
- **不追求完美，追求可用**: 48小时内完成可演示的核心功能
- **用户价值驱动**: 专注解决"入境问答练习"这一核心痛点
- **快速迭代**: 先做出来，再优化体验
- **技术实用主义**: 选择最快实现路径，避免过度工程

### MVP核心假设验证
1. **用户愿意通过游戏化方式练习口语** ✓ (通过Landing Page验证)
2. **语音识别+关键词匹配能有效评分** ✓ (技术可行性验证)
3. **压力反馈机制能提升学习效果** ✓ (教育心理学支撑)
4. **用户愿意为此付费订阅** ? (需要MVP验证)

## 📋 最小可行功能清单 (MVP Scope)

### ✅ 必须实现 (P0功能)

#### 1. 核心游戏循环 (30%工作量)
```
开始游戏 → 海关提问 → 语音回答 → 评分反馈 → 下一题/结束
```

#### 2. 语音识别系统 (25%工作量)
- **主方案**: Godot-Whisper插件
- **备用方案**: 文本输入框 (技术兜底)
- **评分算法**: 关键词匹配 (简化版)

#### 3. 基础UI界面 (20%工作量)
- 海关场景背景
- NPC表情切换 (4种状态)
- 话筒录音UI
- 评分反馈显示

#### 4. 核心题库 (15%工作量)
- **3个核心问题**:
  1. "What's the purpose of your visit?"
  2. "Where will you stay?"
  3. "How long will you stay?"
- **关键词库**: 每题5-8个正确关键词
- **评分规则**: 简化的二元评分 (通过/不通过)

#### 5. 通关机制 (10%工作量)
- 3题全对 = 通关成功
- 2题错误 = 游戏结束
- 基础成就系统

### ⚠️ 暂缓实现 (V2功能)
- 复杂的语音评分算法
- 多场景切换
- 用户数据持久化
- 订阅付费系统
- 详细的学习报告
- 社交分享功能

## 🛠️ Godot 4.4.1 技术实现方案

### 项目结构设计
```
EntryCheckDemo/
├── scenes/
│   ├── Main.tscn              # 主场景
│   ├── GameScene.tscn         # 游戏场景
│   └── UI/
│       ├── QuestionUI.tscn    # 问答界面
│       ├── FeedbackUI.tscn    # 反馈界面
│       └── ResultUI.tscn      # 结果界面
├── scripts/
│   ├── GameManager.gd         # 游戏管理器
│   ├── VoiceRecorder.gd       # 语音录制
│   ├── AnswerEvaluator.gd     # 答案评估
│   └── NPCController.gd       # NPC控制
├── assets/
│   ├── images/                # 美术资源
│   ├── audio/                 # 音频资源
│   └── data/
│       └── questions.json     # 题库数据
└── addons/
    └── whisper/               # 语音识别插件
```

### 核心代码实现

#### 1. 游戏管理器 (GameManager.gd)
```gdscript
class_name GameManager
extends Node

# 游戏状态
enum State { READY, ASKING, LISTENING, EVALUATING, FEEDBACK, COMPLETE }
var current_state: State = State.READY
var current_question: int = 0
var score: int = 0
var wrong_count: int = 0

# 组件引用
@onready var npc: NPCController = $NPCController
@onready var voice: VoiceRecorder = $VoiceRecorder
@onready var evaluator: AnswerEvaluator = $AnswerEvaluator
@onready var ui: Control = $UI

# 题库数据
var questions = [
    {
        "text": "What's the purpose of your visit?",
        "keywords": ["tourism", "tourist", "vacation", "holiday", "study", "business"],
        "forbidden": ["work", "job", "immigrate", "permanent"]
    },
    {
        "text": "Where will you stay?",
        "keywords": ["hotel", "hilton", "marriott", "booking", "reservation"],
        "forbidden": ["friend", "relative", "permanently"]
    },
    {
        "text": "How long will you stay?",
        "keywords": ["day", "week", "month", "1", "2", "3", "4", "5"],
        "forbidden": ["forever", "permanent", "long time"]
    }
]

func _ready():
    start_game()

func start_game():
    current_state = State.ASKING
    ask_question()

func ask_question():
    if current_question >= questions.size():
        game_complete()
        return
    
    var question = questions[current_question]
    npc.ask_question(question.text)
    ui.show_question(question.text)
    
    # 开始录音
    current_state = State.LISTENING
    voice.start_recording()

func on_answer_received(answer_text: String):
    current_state = State.EVALUATING
    
    var question = questions[current_question]
    var result = evaluator.evaluate_answer(answer_text, question)
    
    show_feedback(result)
    
    if result.passed:
        score += 1
        current_question += 1
        # 延迟后问下一题
        await get_tree().create_timer(2.0).timeout
        ask_question()
    else:
        wrong_count += 1
        if wrong_count >= 2:
            game_over()
        else:
            # 重试当前题目
            await get_tree().create_timer(2.0).timeout
            ask_question()

func show_feedback(result):
    current_state = State.FEEDBACK
    npc.show_reaction(result.passed)
    ui.show_feedback(result.message, result.passed)

func game_complete():
    current_state = State.COMPLETE
    ui.show_success_screen()
    npc.show_success()

func game_over():
    current_state = State.COMPLETE
    ui.show_failure_screen()
    npc.show_failure()
```

#### 2. 语音录制器 (VoiceRecorder.gd)
```gdscript
class_name VoiceRecorder
extends Node

signal answer_received(text: String)

# 语音识别组件 (使用Whisper插件)
var whisper_node: Node
var is_recording: bool = false
var fallback_input: LineEdit

func _ready():
    # 初始化Whisper插件
    setup_whisper()
    setup_fallback_input()

func setup_whisper():
    # 加载Whisper插件
    if has_method("load_whisper_addon"):
        whisper_node = load_whisper_addon()
        whisper_node.transcription_completed.connect(_on_transcription_completed)
    else:
        print("Whisper插件未找到，使用文本输入备用方案")

func setup_fallback_input():
    # 创建文本输入备用方案
    fallback_input = LineEdit.new()
    fallback_input.placeholder_text = "请输入您的回答 (备用方案)"
    fallback_input.text_submitted.connect(_on_text_submitted)
    add_child(fallback_input)
    fallback_input.hide()

func start_recording():
    if whisper_node and whisper_node.is_available():
        # 使用语音识别
        is_recording = true
        whisper_node.start_recording()
        # 10秒超时
        get_tree().create_timer(10.0).timeout.connect(_on_recording_timeout)
    else:
        # 使用文本输入备用方案
        show_text_input()

func stop_recording():
    if is_recording and whisper_node:
        is_recording = false
        whisper_node.stop_recording()

func show_text_input():
    fallback_input.show()
    fallback_input.grab_focus()

func _on_transcription_completed(text: String):
    is_recording = false
    if text.length() > 0:
        answer_received.emit(text)
    else:
        # 识别失败，显示文本输入
        show_text_input()

func _on_text_submitted(text: String):
    fallback_input.hide()
    fallback_input.clear()
    answer_received.emit(text)

func _on_recording_timeout():
    if is_recording:
        stop_recording()
        show_text_input()
```

#### 3. 答案评估器 (AnswerEvaluator.gd)
```gdscript
class_name AnswerEvaluator
extends Node

struct EvaluationResult:
    var passed: bool
    var score: int
    var message: String
    var feedback: String

func evaluate_answer(answer: String, question: Dictionary) -> EvaluationResult:
    var result = EvaluationResult.new()
    var answer_lower = answer.to_lower()
    
    # 检查禁用词
    for forbidden_word in question.forbidden:
        if forbidden_word in answer_lower:
            result.passed = false
            result.score = 0
            result.message = "❌ 错误回答"
            result.feedback = "避免使用: " + forbidden_word
            return result
    
    # 检查关键词
    var keyword_found = false
    for keyword in question.keywords:
        if keyword in answer_lower:
            keyword_found = true
            break
    
    if keyword_found:
        result.passed = true
        result.score = 100
        result.message = "✅ 回答正确"
        result.feedback = "很好！继续保持"
    else:
        result.passed = false
        result.score = 0
        result.message = "⚠️ 需要改进"
        result.feedback = "尝试使用: " + ", ".join(question.keywords[:3])
    
    return result
```

#### 4. NPC控制器 (NPCController.gd)
```gdscript
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

func _ready():
    # 加载表情纹理
    load_expressions()
    set_expression("neutral")

func load_expressions():
    expression_neutral = load("res://assets/images/海关表情【平静】.png")
    expression_smile = load("res://assets/images/海关表情【微笑】.png")
    expression_angry = load("res://assets/images/海关表情【警告】.png")
    # 怀疑表情可以复用警告表情
    expression_doubt = expression_angry

func ask_question(question_text: String):
    set_expression("neutral")
    # 播放问题音频 (如果有)
    # audio_player.play()
    
func show_reaction(passed: bool):
    if passed:
        set_expression("smile")
        glasses_effect.modulate.a = 0.0  # 眼镜不反光
    else:
        set_expression("angry")
        glasses_effect.modulate.a = 0.8  # 眼镜强烈反光

func set_expression(expression: String):
    match expression:
        "neutral":
            npc_sprite.texture = expression_neutral
        "smile":
            npc_sprite.texture = expression_smile
        "angry":
            npc_sprite.texture = expression_angry
        "doubt":
            npc_sprite.texture = expression_doubt

func show_success():
    set_expression("smile")
    # 播放盖章动画
    var tween = create_tween()
    tween.tween_property(npc_sprite, "scale", Vector2(1.1, 1.1), 0.2)
    tween.tween_property(npc_sprite, "scale", Vector2(1.0, 1.0), 0.2)

func show_failure():
    set_expression("angry")
    glasses_effect.modulate.a = 1.0
```

## 📊 48小时开发计划

### Day 1 (24小时)

#### 上午 (0-6小时)
- **技术搭建** (3小时)
  - Godot项目创建和配置
  - Whisper插件集成测试
  - 基础场景结构搭建
- **核心逻辑** (3小时)
  - GameManager基础框架
  - 题库数据结构设计
  - 状态机实现

#### 下午 (6-12小时)
- **语音系统** (4小时)
  - VoiceRecorder实现
  - 文本输入备用方案
  - 答案评估算法
- **UI界面** (2小时)
  - 基础UI布局
  - 问答界面实现

#### 晚上 (12-18小时)
- **NPC系统** (3小时)
  - 表情切换逻辑
  - 反馈动画实现
- **美术集成** (3小时)
  - 图片资源导入
  - UI美化调整

#### 深夜 (18-24小时)
- **核心功能联调** (4小时)
  - 游戏流程打通
  - Bug修复
- **基础测试** (2小时)
  - 功能测试
  - 体验优化

### Day 2 (24小时)

#### 上午 (24-30小时)
- **功能完善** (4小时)
  - 评分系统优化
  - 反馈机制完善
- **体验优化** (2小时)
  - 动画效果添加
  - 音效集成

#### 下午 (30-36小时)
- **稳定性测试** (3小时)
  - 边界情况测试
  - 性能优化
- **演示准备** (3小时)
  - 演示脚本准备
  - 演示视频录制

#### 晚上 (36-42小时)
- **最终调试** (4小时)
  - 最后Bug修复
  - 用户体验微调
- **打包发布** (2小时)
  - 多平台打包
  - 发布准备

#### 深夜 (42-48小时)
- **演示彩排** (3小时)
  - 演示流程练习
  - 应急预案准备
- **文档整理** (3小时)
  - 技术文档更新
  - 演示材料准备

## ⚠️ 风险控制策略

### 技术风险应对

#### 1. 语音识别失败
- **风险**: Whisper插件不兼容或性能差
- **应对**: 文本输入备用方案 (已实现)
- **触发条件**: 语音识别准确率<60%

#### 2. 性能问题
- **风险**: 游戏卡顿或崩溃
- **应对**: 简化特效，优化资源加载
- **触发条件**: 帧率<30FPS

#### 3. 时间不足
- **风险**: 48小时内无法完成
- **应对**: 砍掉非核心功能，确保最小闭环
- **优先级**: 核心游戏流程 > UI美化 > 特效动画

### 质量保证措施

#### 1. 每日里程碑检查
- Day 1结束: 核心功能可运行
- Day 2中午: 完整流程可演示
- Day 2结束: 稳定版本可发布

#### 2. 最小可演示版本
- **核心场景**: 1个问答循环
- **基础评分**: 关键词匹配
- **简单反馈**: 表情+文字

#### 3. 应急演示方案
- **预录视频**: 避免现场技术故障
- **手动模式**: 关键时刻手动触发反馈
- **简化版本**: 最简单的可运行版本

## 📈 成功验收标准

### 功能验收 (必须100%完成)
- [ ] 完整的3题问答流程
- [ ] 语音识别或文本输入正常工作
- [ ] NPC表情反馈正确
- [ ] 通关/失败判定准确
- [ ] 基础UI界面完整

### 体验验收 (80%完成即可)
- [ ] 游戏流程直观易懂
- [ ] 反馈信息清晰有用
- [ ] 视觉效果基本满意
- [ ] 无严重Bug和崩溃

### 演示验收 (关键成功因素)
- [ ] 1分钟完整演示流程
- [ ] 核心价值清晰展示
- [ ] 技术实现可信度高
- [ ] 商业潜力明显

## 🎯 MVP成功指标

### 技术指标
- 语音识别准确率 > 70%
- 游戏响应时间 < 2秒
- 系统稳定性 > 95%
- 跨平台兼容性良好

### 用户体验指标
- 学习效果明显 (用户反馈)
- 游戏化体验有趣 (观察反应)
- 操作流程简单 (无需说明书)
- 错误提示有用 (帮助改进)

### 商业验证指标
- 演示观众兴趣度高
- 潜在用户询问购买
- 投资人认可商业模式
- 媒体报道正面评价

## 🚀 后续迭代规划

### V1.1 (1周内)
- 根据演示反馈优化体验
- 修复发现的技术问题
- 增加基础数据统计

### V1.5 (1个月内)
- 扩展题库到10个问题
- 实现用户进度保存
- 开发简单的订阅系统

### V2.0 (3个月内)
- 多场景支持 (机场、酒店等)
- AI智能评分系统
- 完整的学习报告
- 社区功能开发

---

**闪电式开发核心原则**: 快速验证 > 完美实现，用户价值 > 技术炫技，可用产品 > 完美代码

**项目座右铭**: "Done is better than perfect" - 完成比完美更重要！

---

**文档版本**: v1.0  
**创建日期**: 2024年  
**适用引擎**: Godot 4.4.1  
**开发周期**: 48小时极限冲刺