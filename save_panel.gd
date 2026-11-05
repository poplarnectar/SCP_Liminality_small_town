extends Control

@onready var grid = $Grid
@onready var close_btn = $CloseBtn
# 获取两个标签按钮
@onready var tab_normal = $TabContainer/TabNormal
@onready var tab_quick = $TabContainer/TabQuick

var is_saving_mode = false 
var is_quick_mode = false # 记录当前是在哪个标签页

func _ready():
	hide()
	
	# 绑定返回按钮
	if close_btn:
		close_btn.pressed.connect(_on_close_btn_pressed)
		
	# 绑定标签页切换
	tab_normal.pressed.connect(func(): _switch_tab(false))
	tab_quick.pressed.connect(func(): _switch_tab(true))
		
	# 绑定格子的点击事件，这里传的是格子索引 (0-5)
	for i in range(grid.get_child_count()):
		var slot_button = grid.get_child(i)
		slot_button.pressed.connect(_on_slot_pressed.bind(i)) 

# 打开面板时调用
func open_panel(saving_mode: bool, quick_mode: bool = false):
	print("👉 [SavePanel] 准备打开面板！模式: ", quick_mode)
	
	is_saving_mode = saving_mode
	is_quick_mode = quick_mode
	
	show() # 强制显示
	z_index = 100 # 强制层级最高，防止被侧边栏挡住
	refresh_slots()

# 切换标签页
func _switch_tab(quick: bool):
	is_quick_mode = quick
	refresh_slots() # 切换后立刻刷新界面

# 刷新界面显示
func refresh_slots():
	for i in range(grid.get_child_count()):
		var slot_btn = grid.get_child(i)
		
		# 核心逻辑：根据当前模式决定前缀
		var prefix = "quick_" if is_quick_mode else "slot_"
		var slot_name = prefix + str(i + 1)
		
		var thumb_rect = slot_btn.get_node_or_null("Thumbnail2")
		var info_label = slot_btn.get_node_or_null("InfoLabel")
		var delete_btn = slot_btn.get_node_or_null("DeleteBtn")
		
		if Dialogic.Save.has_slot(slot_name):
			# 有存档：显示截图和时间
			if thumb_rect:
				var tex = Dialogic.Save.get_slot_thumbnail(slot_name)
				if tex:
					thumb_rect.texture = tex
					thumb_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
					thumb_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			
			if info_label:
				var info = Dialogic.Save.get_slot_info(slot_name)
				if info is Dictionary and info.has("date"):
					info_label.text = str(info["date"])
				else:
					info_label.text = "已保存"
			
			# 显示删除按钮
			if delete_btn:
				delete_btn.show()
				if delete_btn.pressed.is_connected(_on_delete_btn_pressed):
					delete_btn.pressed.disconnect(_on_delete_btn_pressed)
				delete_btn.pressed.connect(_on_delete_btn_pressed.bind(slot_name))
		else:
			# 空槽位
			if thumb_rect: thumb_rect.texture = null
			if info_label: info_label.text = "空槽位"
			if delete_btn: delete_btn.hide()

# 点击格子（存或读）
func _on_slot_pressed(idx: int):
	var prefix = "quick_" if is_quick_mode else "slot_"
	var slot_name = prefix + str(idx + 1)
	
	if is_saving_mode:
		print("【执行存档】保存到: ", slot_name)
		hide() # 隐藏面板，为了截图干净
		await RenderingServer.frame_post_draw # 等待一帧渲染
		Dialogic.Save.take_thumbnail() # 截图
		
		var extra_info = { "date": Time.get_datetime_string_from_system(false, true) }
		Dialogic.Save.save(slot_name, false, Dialogic.Save.ThumbnailMode.STORE_ONLY, extra_info)
		
		show() # 重新显示面板
		refresh_slots() # 刷新UI
	else:
		print("【执行读档】读取: ", slot_name)
		if Dialogic.Save.has_slot(slot_name):
			Dialogic.Save.load(slot_name)
			hide()
			
			# --- 核心修复：使用 current_scene 和 get_node_or_null 保证安全 ---
			var main_scene = get_tree().current_scene
			if main_scene:
				# 强制隐藏 XP 背景和主菜单
				var tex = main_scene.get_node_or_null("TextureRect")
				if tex: tex.hide()
				
				var vbox = main_scene.get_node_or_null("VBoxContainer")
				if vbox: vbox.hide()
				
				# 显示侧边栏和按钮
				var sidebar = main_scene.get_node_or_null("CanvasLayer/LeftSidebar")
				if sidebar: sidebar.show()
				
				var save_btns = main_scene.get_node_or_null("CanvasLayer/LeftSidebar/SaveButtonsContainer")
				if save_btns: save_btns.show()
			# -----------------------------------------------------------
		else:
			print("空槽位，无法读取")

# 点击删除按钮
func _on_delete_btn_pressed(slot_name: String):
	print("【执行删除】删除存档: ", slot_name)
	Dialogic.Save.delete_slot(slot_name)
	refresh_slots() # 删除后瞬间刷新

# 点击关闭按钮
func _on_close_btn_pressed():
	print("关闭存档面板")
	hide()
	# 恢复侧边栏底部的按钮
	get_parent().get_node("LeftSidebar/SaveButtonsContainer").show()
