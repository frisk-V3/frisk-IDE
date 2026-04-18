extends Control

# -------------------------
# ノード参照（型注釈）
# -------------------------
var editor: CodeEdit
var minimap: CodeEdit
var lang_input: LineEdit
var command_input: LineEdit
var file_open_dialog: FileDialog
var file_save_dialog: FileDialog
var explorer_popup: Window

# -------------------------
# 状態
# -------------------------
var current_lang_key: String = "js"
var current_file_path: String = ""
var current_theme: String = "dark"
var is_mobile: bool = false

# 言語設定（JSONファイル名）
var languages := {
	"cs": {"json": "C#.json"},
	"csUnity": {"json": "C#Unity.json"},
	"py": {"json": "Python.json"},
	"js": {"json": "javascript.json"}
}

# デバウンス用
var _defer_timer: Timer = null
var _pending_highlighter_obj: CodeHighlighter = null
var _pending_highlighter_path: String = ""

# -------------------------
# 初期化
# -------------------------
func _ready() -> void:
	is_mobile = _detect_mobile()
	setup_vscode_layout()
	_apply_theme(current_theme)
	_reload_highlighter_for_lang(current_lang_key)
	if editor:
		editor.text = "console.log('Hello IDE');\n\nfunction test(){\n\treturn 42;\n}"

# ============================================================
# デバイス判定
# ============================================================
func _detect_mobile() -> bool:
	if OS.has_feature("mobile"):
		return true
	var size: Vector2i = DisplayServer.screen_get_size()
	return size.x < 900

# ============================================================
# レイアウト構築
# ============================================================
func setup_vscode_layout() -> void:
	RenderingServer.set_default_clear_color(Color("1e1e1e"))
	self.set_anchors_preset(Control.PRESET_FULL_RECT)
	if is_mobile:
		_setup_mobile_layout()
	else:
		_setup_desktop_layout()

func _setup_desktop_layout() -> void:
	var h_split: HSplitContainer = HSplitContainer.new()
	h_split.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(h_split)

	var sidebar: VBoxContainer = VBoxContainer.new()
	sidebar.custom_minimum_size.x = 220
	h_split.add_child(sidebar)

	var side_label: Label = Label.new()
	side_label.text = "  EXPLORER"
	side_label.add_theme_font_size_override("font_size", 13)
	sidebar.add_child(side_label)

	var tree: Tree = _create_explorer_tree()
	sidebar.add_child(tree)

	var main_vbox: VBoxContainer = _create_main_editor_area()
	h_split.add_child(main_vbox)

func _setup_mobile_layout() -> void:
	var root_vbox: VBoxContainer = VBoxContainer.new()
	root_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root_vbox)

	var menu_hbox: HBoxContainer = HBoxContainer.new()
	root_vbox.add_child(menu_hbox)

	var btn_explorer: Button = Button.new()
	btn_explorer.text = "EXPLORER"
	btn_explorer.custom_minimum_size.x = 120
	btn_explorer.pressed.connect(_on_explorer_button_pressed)
	menu_hbox.add_child(btn_explorer)

	var btn_open: Button = Button.new()
	btn_open.text = "Open"
	btn_open.custom_minimum_size.x = 80
	btn_open.pressed.connect(_on_open_pressed)
	menu_hbox.add_child(btn_open)

	var btn_save: Button = Button.new()
	btn_save.text = "Save"
	btn_save.custom_minimum_size.x = 80
	btn_save.pressed.connect(_on_save_pressed)
	menu_hbox.add_child(btn_save)

	var btn_run: Button = Button.new()
	btn_run.text = "Run"
	btn_run.custom_minimum_size.x = 80
	btn_run.pressed.connect(_on_debug_run)
	menu_hbox.add_child(btn_run)

	lang_input = LineEdit.new()
	lang_input.placeholder_text = "gengo (js) / (py) / (cs) ..."
	lang_input.text = "(js)"
	lang_input.text_submitted.connect(_on_lang_submitted)
	root_vbox.add_child(lang_input)

	command_input = LineEdit.new()
	command_input.placeholder_text = "command: te-ma(dark) / te-ma(light)"
	command_input.text_submitted.connect(_on_command_submitted)
	root_vbox.add_child(command_input)

	editor = CodeEdit.new()
	editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	editor.gutters_draw_line_numbers = true
	editor.gutters_draw_fold_gutter = true
	editor.indent_automatic = true
	editor.code_completion_enabled = true
	editor.highlight_current_line = true
	editor.draw_tabs = true
	editor.draw_spaces = true
	editor.add_theme_font_size_override("font_size", 18)
	editor.text_changed.connect(_on_editor_text_changed)
	editor.gui_input.connect(_on_editor_gui_input)
	root_vbox.add_child(editor)

	explorer_popup = Window.new()
	explorer_popup.title = "EXPLORER"
	explorer_popup.size = Vector2i(300, 400)
	var popup_vbox: VBoxContainer = VBoxContainer.new()
	explorer_popup.add_child(popup_vbox)
	var pop_label: Label = Label.new()
	pop_label.text = "  EXPLORER"
	pop_label.add_theme_font_size_override("font_size", 13)
	popup_vbox.add_child(pop_label)
	var tree: Tree = _create_explorer_tree()
	popup_vbox.add_child(tree)
	add_child(explorer_popup)

	_create_file_dialogs()

func _create_main_editor_area() -> VBoxContainer:
	var main_vbox: VBoxContainer = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var menu_hbox: HBoxContainer = HBoxContainer.new()
	main_vbox.add_child(menu_hbox)

	var btn_open: Button = Button.new()
	btn_open.text = "Open"
	btn_open.pressed.connect(_on_open_pressed)
	menu_hbox.add_child(btn_open)

	var btn_save: Button = Button.new()
	btn_save.text = "Save"
	btn_save.pressed.connect(_on_save_pressed)
	menu_hbox.add_child(btn_save)

	var btn_save_as: Button = Button.new()
	btn_save_as.text = "Save As..."
	btn_save_as.pressed.connect(_on_save_as_pressed)
	menu_hbox.add_child(btn_save_as)

	var btn_run: Button = Button.new()
	btn_run.text = "Run (F5)"
	btn_run.pressed.connect(_on_debug_run)
	menu_hbox.add_child(btn_run)

	var tabs: TabBar = TabBar.new()
	tabs.add_tab("  Main  ")
	main_vbox.add_child(tabs)

	lang_input = LineEdit.new()
	lang_input.placeholder_text = "gengo (js) / (py) / (cs) ..."
	lang_input.text = "(js)"
	lang_input.text_submitted.connect(_on_lang_submitted)
	main_vbox.add_child(lang_input)

	command_input = LineEdit.new()
	command_input.placeholder_text = "command: te-ma(dark) / te-ma(light)"
	command_input.text_submitted.connect(_on_command_submitted)
	main_vbox.add_child(command_input)

	var editor_hbox: HBoxContainer = HBoxContainer.new()
	editor_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(editor_hbox)

	editor = CodeEdit.new()
	editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	editor.gutters_draw_line_numbers = true
	editor.gutters_draw_fold_gutter = true
	editor.indent_automatic = true
	editor.code_completion_enabled = true
	editor.highlight_current_line = true
	editor.draw_tabs = true
	editor.draw_spaces = true
	editor.add_theme_font_size_override("font_size", 16)
	editor.text_changed.connect(_on_editor_text_changed)
	editor.gui_input.connect(_on_editor_gui_input)
	editor_hbox.add_child(editor)

	minimap = CodeEdit.new()
	minimap.editable = false
	minimap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	minimap.custom_minimum_size.x = 120
	minimap.gutters_draw_line_numbers = false
	minimap.gutters_draw_fold_gutter = false
	minimap.highlight_current_line = false
	minimap.add_theme_font_size_override("font_size", 8)
	# ミニマップのスクロールバーを非表示にする（安全に内部ノードへアクセス）
	if minimap.has_method("get_v_scroll_bar"):
		var mini_v_scroll := minimap.get_v_scroll_bar()
		if mini_v_scroll:
			mini_v_scroll.custom_minimum_size.x = 0
			mini_v_scroll.visible = false
	editor_hbox.add_child(minimap)

	_create_file_dialogs()
	return main_vbox

func _create_explorer_tree() -> Tree:
	var tree: Tree = Tree.new()
	tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var root = tree.create_item()
	tree.hide_root = true
	var folder = tree.create_item(root)
	folder.set_text(0, "📁 tokens")
	var files: Array = ["C#.json", "C#Unity.json", "Python.json", "javascript.json"]
	for f_name in files:
		var item = tree.create_item(folder)
		item.set_text(0, "  📄 " + f_name)
	return tree

func _create_file_dialogs() -> void:
	if file_open_dialog == null:
		file_open_dialog = FileDialog.new()
		file_open_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		file_open_dialog.access = FileDialog.ACCESS_FILESYSTEM
		file_open_dialog.file_selected.connect(_on_file_open_selected)
		add_child(file_open_dialog)
	if file_save_dialog == null:
		file_save_dialog = FileDialog.new()
		file_save_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		file_save_dialog.access = FileDialog.ACCESS_FILESYSTEM
		file_save_dialog.file_selected.connect(_on_file_save_selected)
		add_child(file_save_dialog)

# ============================================================
# テーマ
# ============================================================
func _apply_theme(theme_name: String) -> void:
	if theme_name == "dark":
		RenderingServer.set_default_clear_color(Color("1e1e1e"))
		if editor:
			editor.add_theme_color_override("font_color", Color("d4d4d4"))
			editor.add_theme_color_override("background_color", Color("1e1e1e"))
		if minimap:
			minimap.add_theme_color_override("font_color", Color("808080"))
			minimap.add_theme_color_override("background_color", Color("1a1a1a"))
	elif theme_name == "light":
		RenderingServer.set_default_clear_color(Color("ffffff"))
		if editor:
			editor.add_theme_color_override("font_color", Color("000000"))
			editor.add_theme_color_override("background_color", Color("ffffff"))
		if minimap:
			minimap.add_theme_color_override("font_color", Color("808080"))
			minimap.add_theme_color_override("background_color", Color("f0f0f0"))
	current_theme = theme_name

# ============================================================
# 言語切り替え
# ============================================================
func _on_lang_submitted(text: String) -> void:
	var key: String = text.strip_edges()
	if key.begins_with("(") and key.ends_with(")"):
		key = key.substr(1, key.length() - 2)
	if not languages.has(key):
		push_warning("未知の言語キー: " + key)
		return
	current_lang_key = key
	_reload_highlighter_for_lang(key)

func _reload_highlighter_for_lang(key: String) -> void:
	var lang_conf: Dictionary = languages.get(key, null)
	if lang_conf == null:
		return
	var json_file: String = str(lang_conf.get("json", ""))
	if json_file == "":
		return
	var highlighter: CodeHighlighter = CodeHighlighter.new()
	_setup_base_highlighter_colors(highlighter)
	_apply_json_to_highlighter("res://tokens/" + json_file, highlighter)
	# デバウンス適用（_apply_json_to_highlighter がセットする）

func _setup_base_highlighter_colors(highlighter: CodeHighlighter) -> void:
	highlighter.symbol_color = Color("abb2bf")
	highlighter.function_color = Color("61afef")
	highlighter.add_color_region('"', '"', Color("98c379"))
	highlighter.add_color_region("'", "'", Color("98c379"))

# ============================================================
# 正規表現エスケープと色変換
# ============================================================
func _escape_for_regex(text: String) -> String:
	var specials: Array = ["\\", ".", "+", "*", "?", "^", "$", "(", ")", "[", "]", "{", "}", "|"]
	var out := text
	for s in specials:
		out = out.replace(s, "\\" + s)
	return out

func _safe_color_from_string(code: String) -> Color:
	code = code.strip_edges()
	if code == "":
		return Color("white")
	if Color.html_is_valid(code):
		return Color(code)
	var lower := code.to_lower()
	var known := {
		"white":"ffffff","black":"000000","red":"ff0000","green":"98c379","blue":"61afef",
		"purple":"c678dd","yellow":"e5c07b","cyan":"56b6c2","orange":"d19a66","lightyellow":"fff5b1","lightblue":"9ad0ff","gray":"808080","grey":"808080"
	}
	if known.has(lower):
		return Color("#" + known[lower])
	push_warning("不明な色コード: " + code + " → white にフォールバック")
	return Color("white")

# ============================================================
# トークンを正規表現パターンに変換
# JSON 拡張: item.pattern (bool or string), item.case_sensitive (bool), item.priority (int)
# ============================================================
func _token_to_pattern(item: Dictionary) -> Dictionary:
	var raw := str(item.get("token", "")).strip_edges()
	if raw == "":
		return {"pattern":"", "case_sensitive":false}
	if item.has("pattern") and typeof(item["pattern"]) == TYPE_STRING and str(item["pattern"]).strip_edges() != "":
		var pat := str(item["pattern"])
		var cs := bool(item.get("case_sensitive", false))
		return {"pattern":pat, "case_sensitive":cs}
	if item.has("pattern") and item["pattern"] == true:
		var cs2 := bool(item.get("case_sensitive", false))
		return {"pattern":raw, "case_sensitive":cs2}
	var needs_word_boundary := true
	if raw.find(".") != -1 or raw.find("/") != -1 or raw.find("-") != -1 or raw.find(":") != -1 or raw.find("(") != -1 or raw.find(")") != -1:
		needs_word_boundary = false
	var escaped := _escape_for_regex(raw)
	if needs_word_boundary:
		return {"pattern":"\\b" + escaped + "\\b", "case_sensitive": bool(item.get("case_sensitive", false))}
	else:
		return {"pattern":"(?<![A-Za-z0-9_])" + escaped + "(?![A-Za-z0-9_])", "case_sensitive": bool(item.get("case_sensitive", false))}

# ============================================================
# デバウンスタイマー確保
# ============================================================
func _ensure_debounce_timer() -> void:
	if _defer_timer == null:
		_defer_timer = Timer.new()
		_defer_timer.one_shot = true
		_defer_timer.wait_time = 0.12
		_defer_timer.timeout.connect(_on_debounce_timeout)
		add_child(_defer_timer)

func _on_debounce_timeout() -> void:
	if _pending_highlighter_obj != null:
		if editor:
			editor.syntax_highlighter = _pending_highlighter_obj
		if minimap:
			minimap.syntax_highlighter = _pending_highlighter_obj
	_pending_highlighter_obj = null
	_pending_highlighter_path = ""

# ============================================================
# JSON を読み込み、堅牢にハイライタへ反映する
# ============================================================
func _apply_json_to_highlighter(file_path: String, highlighter: CodeHighlighter) -> void:
	if not FileAccess.file_exists(file_path):
		push_warning("JSON ファイルが見つかりません: " + file_path)
		return
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_warning("JSON ファイルを開けません: " + file_path)
		return
	var json_text: String = file.get_as_text()
	var parse_result = JSON.parse_string(json_text)
	if typeof(parse_result) == TYPE_DICTIONARY and parse_result.has("error"):
		push_warning("JSON パースエラー: " + file_path + " : " + str(parse_result))
		return
	var json_data: Variant = parse_result
	if json_data == null:
		push_warning("JSON パース失敗（null）: " + file_path)
		return
	if not (json_data is Array):
		push_warning("JSON 形式が配列ではありません: " + file_path)
		return

	var entries: Array = []
	for item in json_data:
		if not (item is Dictionary):
			continue
		var token_raw: String = str(item.get("token", "")).strip_edges()
		if token_raw == "":
			continue
		var color_code: String = str(item.get("color", "white")).strip_edges()
		var pat_info := _token_to_pattern(item)
		var pat: String = str(pat_info["pattern"])
		if pat == "":
			continue
		var color: Color = _safe_color_from_string(color_code)
		var priority: int = int(item.get("priority", 0))
		entries.append({"token":token_raw, "pattern":pat, "color":color, "priority":priority, "case_sensitive": bool(pat_info["case_sensitive"])})

	# ソート: priority 高 → token 長い順 → 安定
	# 修正: Godot4 の sort_custom は Callable を受け取るので Callable を渡す
	entries.sort_custom(Callable(self, "_sort_entries_priority_then_length"))

	# 登録（CodeHighlighter が正規表現を受け取る前提）
	for e in entries:
		var pat_str: String = e["pattern"]
		var col: Color = e["color"]
		var cs: bool = e["case_sensitive"]
		if not cs:
			pat_str = "(?i)" + pat_str
		highlighter.add_keyword_color(pat_str, col)

	_pending_highlighter_obj = highlighter
	_pending_highlighter_path = file_path
	_ensure_debounce_timer()
	_defer_timer.start()

func _sort_entries_priority_then_length(a, b) -> int:
	var pa := int(a["priority"])
	var pb := int(b["priority"])
	if pa > pb:
		return -1
	elif pa < pb:
		return 1
	var la := str(a["token"]).length()
	var lb := str(b["token"]).length()
	if la > lb:
		return -1
	elif la < lb:
		return 1
	return 0

# ============================================================
# ファイル操作
# ============================================================
func _on_open_pressed() -> void:
	if file_open_dialog:
		file_open_dialog.popup_centered()

func _on_save_pressed() -> void:
	if current_file_path == "":
		if file_save_dialog:
			file_save_dialog.popup_centered()
		return
	_save_to_path(current_file_path)

func _on_save_as_pressed() -> void:
	if file_save_dialog:
		file_save_dialog.popup_centered()

func _on_file_open_selected(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("ファイルを開けません: " + path)
		return
	if editor:
		editor.text = file.get_as_text()
	current_file_path = path
	_update_minimap()

func _on_file_save_selected(path: String) -> void:
	_save_to_path(path)
	current_file_path = path

func _save_to_path(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("保存に失敗: " + path)
		return
	if editor:
		file.store_string(editor.text)

# ============================================================
# デバッグ（Python 実行）
# ============================================================
func _on_debug_run() -> void:
	if current_file_path == "":
		push_warning("まずファイルを保存してください")
		return
	var args: Array[String] = [current_file_path]
	var output: Array[String] = []
	var exit_code: int = OS.execute("python", args, output, true)
	var out_text: String = ""
	for line in output:
		out_text += line + "\n"
	if exit_code != 0:
		push_error("Python 実行エラー: " + str(exit_code) + "\n" + out_text)
	else:
		print("Python 実行成功:\n" + out_text)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F5:
			_on_debug_run()

# ============================================================
# コマンドバー
# ============================================================
func _on_command_submitted(text: String) -> void:
	var cmd: String = text.strip_edges()
	if cmd.begins_with("te-ma(") and cmd.ends_with(")"):
		var name: String = cmd.substr(6, cmd.length() - 7)
		_apply_theme(name)
	else:
		push_warning("未知のコマンド: " + cmd)

# ============================================================
# スクロール検知とミニマップ同期（Godot4対応）
# ============================================================
func _on_editor_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_on_editor_scroll_changed()
	if event is InputEventMouseMotion:
		_on_editor_scroll_changed()
	if event is InputEventPanGesture:
		_on_editor_scroll_changed()

func _on_editor_text_changed() -> void:
	_update_minimap()

func _on_editor_scroll_changed() -> void:
	if minimap == null or editor == null:
		return
	if not editor.has_method("get_v_scroll_bar"):
		return
	var editor_v_scroll := editor.get_v_scroll_bar()
	if editor_v_scroll == null:
		return
	var editor_value: float = float(editor_v_scroll.value)
	var editor_max: float = float(editor_v_scroll.max_value)
	if editor_max <= 0.0:
		return
	var ratio: float = editor_value / editor_max
	if minimap.has_method("get_v_scroll_bar"):
		var mini_v_scroll := minimap.get_v_scroll_bar()
		if mini_v_scroll:
			var mini_max: float = float(mini_v_scroll.max_value)
			mini_v_scroll.value = ratio * mini_max

func _update_minimap() -> void:
	if minimap == null or editor == null:
		return
	minimap.text = editor.text
	_on_editor_scroll_changed()

# ============================================================
# モバイル用 EXPLORER ボタン
# ============================================================
func _on_explorer_button_pressed() -> void:
	if explorer_popup:
		explorer_popup.popup_centered()
