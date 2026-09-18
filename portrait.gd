extends Control

var hero: Dictionary = {}
var phase: float = 0.0
var base_color: Color = Color.WHITE

func set_character(value: Dictionary) -> void:
    hero = value
    var hero_seed: int = int(hero.get("seed", 1))
    base_color = Color.from_hsv(float(hero_seed % 360) / 360.0, 0.55, 0.95)
    queue_redraw()

func _ready() -> void:
    set_process(true)

func _process(delta: float) -> void:
    phase = fmod(phase + delta * 2.6, TAU)
    queue_redraw()

func _draw() -> void:
    if hero.is_empty():
        return

    var center: Vector2 = size / 2.0
    var bob: float = sin(phase) * 3.0
    var animation_scale: float = 1.0 + sin(phase * 1.7) * 0.025
    var rarity: int = int(hero.get("rarity", 1))
    var glow_color: Color = Color.from_hsv(float(rarity - 1) / 14.0 + 0.70, 0.45, 1.0, 0.22)

    draw_circle(center + Vector2(0.0, bob), 80.0 * animation_scale, glow_color)
    draw_circle(center + Vector2(0.0, bob), 64.0 * animation_scale, Color("1c2442"))
    draw_arc(center + Vector2(0.0, bob), 65.0 * animation_scale, 0.0, TAU, 48, base_color.lightened(0.25), 3.0)

    var head: Vector2 = center + Vector2(0.0, -28.0 + bob)
    draw_circle(head, 25.0 * animation_scale, Color("f1bd98"))
    var hair := PackedVector2Array([
        head + Vector2(-28.0, -7.0),
        head + Vector2(-18.0, -34.0),
        head + Vector2(2.0, -40.0),
        head + Vector2(28.0, -22.0),
        head + Vector2(22.0, -5.0),
        head + Vector2(8.0, -18.0),
        head + Vector2(-8.0, -12.0)
    ])
    draw_colored_polygon(hair, base_color.darkened(0.25))
    draw_circle(head + Vector2(-9.0, 2.0), 3.0, Color("20233b"))
    draw_circle(head + Vector2(9.0, 2.0), 3.0, Color("20233b"))

    var body: Vector2 = center + Vector2(0.0, 43.0 + bob)
    var cloak := PackedVector2Array([
        body + Vector2(-43.0, 66.0),
        body + Vector2(-31.0, -8.0),
        body + Vector2(0.0, -27.0),
        body + Vector2(31.0, -8.0),
        body + Vector2(43.0, 66.0)
    ])
    draw_colored_polygon(cloak, base_color.darkened(0.4))
    draw_line(body + Vector2(-18.0, 2.0), body + Vector2(18.0, 2.0), Color("f4d58d"), 4.0)

    var class_name: String = str(hero.get("class", "Héros"))
    if class_name == "Mage":
        draw_line(body + Vector2(35.0, 50.0), body + Vector2(53.0, -35.0), Color("c49aff"), 5.0)
        draw_circle(body + Vector2(53.0, -40.0), 8.0, Color("c49aff"))
    elif class_name == "Archer" or class_name == "Assassin":
        draw_arc(body + Vector2(35.0, 18.0), 25.0, -1.2, 1.2, 20, Color("d7a96d"), 3.0)
    else:
        draw_line(body + Vector2(-48.0, 40.0), body + Vector2(-48.0, -30.0), Color("c5d2e8"), 5.0)
