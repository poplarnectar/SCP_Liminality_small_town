extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var load_button = $VBoxContainer/LoadButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var save_panel = $CanvasLayer/SavePanel
@onready var left_sidebar = $CanvasLayer/LeftSidebar

@onready var quick_save_btn = $CanvasLayer/LeftSidebar/SaveButtonsContainer/QuickSaveBtn
@onready var open_save_panel_btn = $CanvasLayer/LeftSidebar/SaveButtonsContainer/OpenSavePanelBtn

# 获取关闭按钮的引用（注意：根据你左侧的树，它可能挂在 SavePanel 下）
@onready var close_btn = $CanvasLayer/SavePanel/CloseBtn

func _ready():
	print("======== 游戏开始加载 ========")
	
	# 1. 主菜单按钮信号连接
	start_button.pressed.connect(_on_start_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	
	# 2. 侧边栏按钮信号连接
	quick_save_btn.pressed.connect(_on_quick_save_pressed)
	open_save_panel_btn.pressed.connect(_on_open_save_panel_pressed)
	
	# 3. 关闭按钮连接
	if close_btn:
		close_btn.pressed.connect(_on_close_btn_pressed)
	else:
		print("警告：没有找到 CloseBtn 节点！")
	
	# 4. 背景监听
	if not Dialogic.Backgrounds.background_changed.is_connected(_on_bg_changed):
		Dialogic.Backgrounds.background_changed.connect(_on_bg_changed)
		
	# 隐藏初始不需要的 UI
	left_sidebar.hide()
	save_panel.hide()
	

# --- 主菜单按钮逻辑 ---
func _on_start_button_pressed():
	print("点击了开始游戏")
	# 1. 彻底隐藏主菜单的按钮和背景图
	$VBoxContainer.hide()
	$TextureRect.hide() 
	
	# 2. 显示侧边栏，并且强制显示底部的按钮！
	left_sidebar.show()
	$CanvasLayer/LeftSidebar/SaveButtonsContainer.show() 
	
	Dialogic.start("res://Tineline/badroom1.dtl")

func _on_load_button_pressed():
	print("点击了读取存档，打开面板")
	# 隐藏底部的按钮容器
	$CanvasLayer/LeftSidebar/SaveButtonsContainer.hide()
	save_panel.open_panel(false)

func _on_quit_button_pressed():
	print("退出游戏")
	get_tree().quit()

# --- 侧边栏按钮逻辑 ---
# 侧边栏点“快存” (打开面板并自动切到快速存档)
func _on_quick_save_pressed():
	print("👉 [Start Menu] 点击了快存按钮")
	
	# 这里隐藏底部的按钮
	$CanvasLayer/LeftSidebar/SaveButtonsContainer.hide()
	
	# 打开面板，强制让它到最前面
	save_panel.open_panel(true, true)

# 侧边栏点“存档” (打开面板并切到普通存档)
func _on_open_save_panel_pressed():
	print("打开普通存档面板")
	$CanvasLayer/LeftSidebar/SaveButtonsContainer.hide()
	save_panel.z_index = 100
	# 打开面板：传 true 代表保存模式，第二个 false 代表普通存档页
	save_panel.open_panel(true, false)

# --- 新增：关闭存档面板逻辑 ---
func _on_close_btn_pressed():
	print("关闭存档面板")
	save_panel.hide()
	
	# 如果你在游戏里，恢复侧边栏和所有按钮
	if not $VBoxContainer.visible: 
		left_sidebar.show()
		$CanvasLayer/LeftSidebar/SaveButtonsContainer.show()

# --- 背景控制 ---
func _on_bg_changed(_info: Dictionary):
	await get_tree().process_frame
	var bg = Dialogic.Backgrounds.get_background_node()
	if bg:
		bg.size = Vector2(1680, 1080)
		bg.position = Vector2(240, 0)
		if bg is TextureRect:
			bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
