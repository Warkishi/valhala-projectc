extends Control

var hero: Dictionary
var phase := 0.0
var base_color := Color.WHITE

func set_character(value: Dictionary) -> void:
    hero = value
    base_color = Color.from_hsv(float(int(hero.get("seed", 1)) % 360) / 360.0, 0.55, 0.95)
    queue_redraw()

func _ready() -> void:
    var tween := create_tween().set_loops()
    tween.tween_property(self, "phase", TAU, 2.4).from(0.0).set_trans(Tween.TRANS_SINE)
    tween.tween_callback(queue_redraw)

func _process(delta: float) -> void:
    phase = fmod(phase + delta * 2.6, TAU)
    queue_redraw()

func _draw() -> void:
    if hero.is_empty():
        return
    var center := size / 2.0
    var bob := sin(phase) * 3.0
    var scale := 1.0 + sin(phase * 1.7) * 0.025
    var rarity := int(hero.get("rarity", 1))
    var glow := Color.from_hsv(float(rarity - 1) / 14.0 + 0.70, 0.45, 1.0, 0.22)
    draw_circle(center + Vector2(0, bob), 80.0 * scale, glow)
    draw_circle(center + Vector2(0, bob), 64.0 * scale, Color("1c2442"))
    draw_arc(center + Vector2(0, bob), 65.0 * scale, 0, TAU, 48, base_color.lightened(0.25), 3.0)
    var head := center + Vector2(0, -28 + bob)
    draw_circle(head, 25.0 * scale, Color("f1bd98"))
    var hair := PackedVector2Array([head + Vector2(-28, -7), head + Vector2(-18, -34), head + Vector2(2, -40), head + Vector2(28, -22), head + Vector2(22, -5), head + Vector2(8, -18), head + Vector2(-8, -12)])
    draw_colored_polygon(hair, base_color.darkened(0.25))
    draw_circle(head + Vector2(-9, 2), 3, Color("20233b"))
    draw_circle(head + Vector2(9, 2), 3, Color("20233b"))
    var body := center + Vector2(0, 43 + bob)
    var cloak := PackedVector2Array([body + Vector2(-43, 66), body + Vector2(-31, -8), body + Vector2(0, -27), body + Vector2(31, -8), body + Vector2(43, 66)])
    draw_colored_polygon(cloak, base_color.darkened(0.4))
    draw_line(body + Vector2(-18, 2), body + Vector2(18, 2), Color("f4d58d"), 4.0)
    var class_name: String = str(hero.get("class", "Héros"))
    if class_name == "Mage":
        draw_line(body + Vector2(35, 50), body + Vector2(53, -35), Color("c49aff"), 5.0)
        draw_circle(body + Vector2(53, -40), 8, Color("c49aff"))
    elif class_name == "Archer" or class_name == "Assassin":
        draw_arc(body + Vector2(35, 18), 25, -1.2, 1.2, 20, Color("d7a96d"), 3.0)
    else:
        draw_line(body + Vector2(-48, 40), body + Vector2(-48, -30), Color("c5d2e8"), 5.0)
