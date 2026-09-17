extends Control

const SAVE_PATH := "user://valhala_save.json"
const SINGLE_COST := 100
const TEN_COST := 900
const START_GOLD := 1000
const RARITIES := 10
const CLASSES := ["Guerrier", "Mage", "Archer", "Paladin", "Assassin", "Druide"]

var gold: int = START_GOLD
var heroes: Array = []
var history: Array = []
var rng := RandomNumberGenerator.new()
var gold_label: Label
var inventory_grid: GridContainer
var results_label: Label
var probability_label: Label
var summon_one_button: Button
var summon_ten_button: Button
var toast_label: Label

func _ready() -> void:
    rng.randomize()
    _load_game()
    _build_interface()
    _refresh_inventory()

func _build_interface() -> void:
    var background := ColorRect.new()
    background.color = Color("10152b")
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left", 28)
    margin.add_theme_constant_override("margin_right", 28)
    margin.add_theme_constant_override("margin_top", 24)
    margin.add_theme_constant_override("margin_bottom", 24)
    add_child(margin)

    var root := VBoxContainer.new()
    root.add_theme_constant_override("separation", 16)
    margin.add_child(root)

    var title := Label.new()
    title.text = "✦ VALHALA PROJECTC ✦"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 30)
    title.add_theme_color_override("font_color", Color("f4d58d"))
    root.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "Chroniques fantastiques • Prototype hors ligne"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_color_override("font_color", Color("aeb8d6"))
    root.add_child(subtitle)

    var resource_bar := HBoxContainer.new()
    resource_bar.alignment = BoxContainer.ALIGNMENT_CENTER
    root.add_child(resource_bar)
    gold_label = Label.new()
    gold_label.add_theme_font_size_override("font_size", 22)
    gold_label.add_theme_color_override("font_color", Color("f4d58d"))
    resource_bar.add_child(gold_label)

    var separator := HSeparator.new()
    root.add_child(separator)

    var summon_title := Label.new()
    summon_title.text = "AUTEL DES INVOCATIONS"
    summon_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    summon_title.add_theme_font_size_override("font_size", 22)
    summon_title.add_theme_color_override("font_color", Color("d9b6ff"))
    root.add_child(summon_title)

    probability_label = Label.new()
    probability_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    probability_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    probability_label.add_theme_color_override("font_color", Color("bbc5e4"))
    root.add_child(probability_label)
    probability_label.text = _probability_text()

    var buttons := HBoxContainer.new()
    buttons.alignment = BoxContainer.ALIGNMENT_CENTER
    buttons.add_theme_constant_override("separation", 18)
    root.add_child(buttons)
    summon_one_button = _make_button("INVOCATION x1\n100 ✦", Color("405aa1"))
    summon_one_button.pressed.connect(func(): _summon(1))
    buttons.add_child(summon_one_button)
    summon_ten_button = _make_button("INVOCATION x10\n900 ✦", Color("74448f"))
    summon_ten_button.pressed.connect(func(): _summon(10))
    buttons.add_child(summon_ten_button)

    results_label = Label.new()
    results_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    results_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    results_label.add_theme_color_override("font_color", Color("f4d58d"))
    root.add_child(results_label)

    var inv_title := Label.new()
    inv_title.text = "HÉROS INVOQUÉS"
    inv_title.add_theme_font_size_override("font_size", 22)
    inv_title.add_theme_color_override("font_color", Color("d9b6ff"))
    root.add_child(inv_title)

    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    root.add_child(scroll)
    inventory_grid = GridContainer.new()
    inventory_grid.columns = 2
    inventory_grid.add_theme_constant_override("h_separation", 12)
    inventory_grid.add_theme_constant_override("v_separation", 12)
    scroll.add_child(inventory_grid)

    toast_label = Label.new()
    toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    toast_label.add_theme_color_override("font_color", Color("8ff0bd"))
    root.add_child(toast_label)
    _update_resources()

func _make_button(text_value: String, color: Color) -> Button:
    var button := Button.new()
    button.text = text_value
    button.custom_minimum_size = Vector2(220, 76)
    button.add_theme_font_size_override("font_size", 18)
    button.add_theme_color_override("font_color", Color.WHITE)
    var normal := StyleBoxFlat.new()
    normal.bg_color = color
    normal.corner_radius_top_left = 12
    normal.corner_radius_top_right = 12
    normal.corner_radius_bottom_left = 12
    normal.corner_radius_bottom_right = 12
    button.add_theme_stylebox_override("normal", normal)
    return button

func _probability_text() -> String:
    var weights: Array[float] = []
    var total := 0.0
    for rarity in range(1, RARITIES + 1):
        var weight := pow(2.0, float(RARITIES - rarity))
        weights.append(weight)
        total += weight
    var parts: Array[String] = []
    for rarity in range(1, RARITIES + 1):
        var chance := weights[rarity - 1] / total * 100.0
        parts.append("%d★ %.2f%%" % [rarity, chance])
    return "Probabilités exponentielles\n" + "  •  ".join(parts)

func _summon(amount: int) -> void:
    var cost := SINGLE_COST if amount == 1 else TEN_COST
    if gold < cost:
        _show_toast("Pas assez de fragments ✦")
        return
    gold -= cost
    var new_names: Array[String] = []
    for i in range(amount):
        var hero := _create_hero()
        heroes.push_front(hero)
        history.push_front(hero)
        new_names.append("%s %s★" % [hero.name, hero.rarity])
    _save_game()
    _update_resources()
    _refresh_inventory()
    results_label.text = "Dernière invocation : " + ", ".join(new_names)
    _show_toast("Les portes de Valhala s'ouvrent...")

func _create_hero() -> Dictionary:
    var rarity := _roll_rarity()
    var hero_index := rng.randi_range(1000, 99999999)
    var first_names := ["Ael", "Lyra", "Kael", "Mira", "Orin", "Nyx", "Eira", "Thane", "Sora", "Vey"]
    var hero_name: String = first_names[rng.randi_range(0, first_names.size() - 1)] + "-" + str(hero_index % 997)
    return {"id": hero_index, "name": hero_name, "class": CLASSES[rng.randi_range(0, CLASSES.size() - 1)], "rarity": rarity, "power": rng.randi_range(40, 80) + rarity * 35, "seed": rng.randi_range(1, 999999)}

func _roll_rarity() -> int:
    var total := pow(2.0, 10.0) - 1.0
    var pick := rng.randf() * total
    for rarity in range(1, RARITIES + 1):
        pick -= pow(2.0, float(RARITIES - rarity))
        if pick <= 0.0:
            return rarity
    return 1

func _refresh_inventory() -> void:
    if not inventory_grid:
        return
    for child in inventory_grid.get_children():
        child.queue_free()
    if heroes.is_empty():
        var empty := Label.new()
        empty.text = "Aucun héros. Lancez votre première invocation !"
        empty.add_theme_color_override("font_color", Color("aeb8d6"))
        inventory_grid.add_child(empty)
        return
    for hero in heroes:
        var card := _hero_card(hero)
        inventory_grid.add_child(card)

func _hero_card(hero: Dictionary) -> Control:
    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(245, 300)
    var box := VBoxContainer.new()
    box.alignment = BoxContainer.ALIGNMENT_CENTER
    box.add_theme_constant_override("separation", 5)
    panel.add_child(box)
    var portrait := preload("res://portrait.gd").new()
    portrait.custom_minimum_size = Vector2(220, 190)
    portrait.set_character(hero)
    box.add_child(portrait)
    var name_label := Label.new()
    name_label.text = "%s\n%s • %d★" % [hero.name, hero.class, hero.rarity]
    name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    name_label.add_theme_color_override("font_color", _rarity_color(hero.rarity))
    box.add_child(name_label)
    var power := Label.new()
    power.text = "Puissance %d" % hero.power
    power.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    power.add_theme_color_override("font_color", Color("aeb8d6"))
    box.add_child(power)
    return panel

func _rarity_color(rarity: int) -> Color:
    return Color.from_hsv(float(rarity - 1) / 14.0 + 0.70, 0.55, 1.0)

func _update_resources() -> void:
    if gold_label:
        gold_label.text = "✦ Fragments : %d" % gold
    if summon_one_button:
        summon_one_button.disabled = gold < SINGLE_COST
    if summon_ten_button:
        summon_ten_button.disabled = gold < TEN_COST

func _show_toast(message: String) -> void:
    if toast_label:
        toast_label.text = message
        var timer := get_tree().create_timer(2.5)
        timer.timeout.connect(func(): toast_label.text = "")

func _save_game() -> void:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify({"gold": gold, "heroes": heroes, "history": history}))

func _load_game() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    var parsed = JSON.parse_string(file.get_as_text())
    if parsed is Dictionary:
        gold = int(parsed.get("gold", START_GOLD))
        heroes = parsed.get("heroes", [])
        history = parsed.get("history", [])
