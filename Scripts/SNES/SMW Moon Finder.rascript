// ~Hack~ Moon Finder
// #ID = 30879

// --- HELPERS -------------------------------------------------------------------

NULL = 0
function if_else(p, t, f) { if (p) { return t } else return f }
idfunc = (x) => x
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

function zfill(num, c)
{
	result = format("{0}", num)
	for i in range(0, 10)
	{
		if (length(result) >= c) return result
		result = format("0{0}", result)
	}
	return result
}

// --- MEMORY -------------------------------------------------------------------

// $00CE: Pointer to Sprite Data [24 bit]
function sublevel() => tbyte(0x0000CE)

// $00D1: Player X Position [16 bit]
// $00D3: Player Y Position [16 bit]
function player_x_position() => word(0x0000D1)
function player_y_position() => word(0x0000D3)

// $0100: Game State [8 bit]
//        --- 00 | Loading Nintendo Presents
//        --- 01 | Nintendo Presents
//        --- 02 | Fade to Title Screen
//        --- 03 | Load Title Screen
//        --- 04 | Prepare Title Screen
//        --- 05 | Fade in Title Screen
//        --- 06 | Circle Effect in Title Screen
//        --- 07 | Title Screen
//        --- 08 | File Select
//        --- 09 | File Deletion
//        --- 0A | Player Select
//        --- 0B | Fade to Overworld
//        --- 0C | Load Overworld
//        --- 0D | Fade in Overworld
//        --- 0E | Overworld
//        --- 0F | Fade to Level
//        --- 10 | Fade to Level 2
//        --- 11 | Load Level
//        --- 12 | Prepare Level
//        --- 13 | Fade in Level
//        --- 14 | In Level
//        --- 15 | Fade to Game Over / Time Up
//        --- 16 | Load Game Over / Time Up
//        --- 17 | Game Over / Time Up
//        --- 18 | Load Credits / Cutscene
//        --- 19 | Load Credits / Cutscene 2
//        --- 1A | Load Credits / Cutscene 3
//        --- 1B | Credits / Cutscene
//        --- 1C | Fade to Yoshi's House in Credits
//        --- 1D | Load Yoshi's House in Credits
//        --- 1E | Fade in Yoshi's House in Credits
//        --- 1F | Yoshi's House in Credits
//        --- 20 | Fade to Enemies in Credits
//        --- 21 | Fade to Enemies 2 in Credits
//        --- 22 | Fade to Enemies 3 in Credits
//        --- 23 | Fade to Enemies 4 in Credits
//        --- 24 | Fade in Enemies in Credits
//        --- 25 | Enemies in Credits
//        --- 26 | Fade to End Screen
//        --- 27 | Load End Screen
//        --- 28 | Fade in End Screen
//        --- 29 | End Screen
function game_state() => byte(0x000100)

STATE_IN_LEVEL = 0x14

// $0DB4: Mario Lives [8 bit]
function mario_lives() => byte(0x000DB4)

// $13BF: Level ID [8 bit]
//        --- 0x01 | Vanilla Secret 2
//        --- 0x02 | Vanilla Secret 3
//        --- 0x03 | Top Secret Area
//        --- 0x04 | Donut Ghost House
//        --- 0x05 | Donut Plains 3
//        --- 0x06 | Donut Plains 4
//        --- 0x07 | #2 Morton
//        --- 0x08 | Green Switch Palace
//        --- 0x09 | Donut Plains 2
//        --- 0x0A | Donut Secret 1
//        --- 0x0B | Vanilla Fort
//        --- 0x0C | Butter Bridge 1
//        --- 0x0D | Butter Bridge 2
//        --- 0x0E | #4 Ludwig
//        --- 0x0F | Cheese Bridge Area
//        --- 0x10 | Cookie Mountain
//        --- 0x11 | Soda Lake
//        --- 0x14 | Yellow Switch Palace
//        --- 0x15 | Donut Plains 1
//        --- 0x18 | Sunken Ghost Ship
//        --- 0x1A | #6 Wendy
//        --- 0x1B | Chocolate Fort
//        --- 0x1C | Chocolate Island 5
//        --- 0x1D | Chocolate Island 4
//        --- 0x1F | Forest Fort
//        --- 0x20 | #5 Roy
//        --- 0x21 | Choco-Ghost House
//        --- 0x22 | Chocolate Island 1
//        --- 0x23 | Chocolate Island 3
//        --- 0x24 | Chocolate Island 2
//        --- 0x25 | #1 Iggy
//        --- 0x26 | Yoshi's Island 4
//        --- 0x27 | Yoshi's Island 3
//        --- 0x28 | Yoshi's House
//        --- 0x29 | Yoshi's Island 1
//        --- 0x2A | Yoshi's Island 2
//        --- 0x2B | Vanilla Ghost House
//        --- 0x2D | Vanilla Secret 1
//        --- 0x2E | Vanilla Dome 3
//        --- 0x2F | Donut Secret 2
//        --- 0x31 | Bowser Front Door
//        --- 0x32 | Bowser Back Door
//        --- 0x33 | Valley of Bowser 4
//        --- 0x34 | #7 Larry
//        --- 0x35 | Valley Fort
//        --- 0x37 | Valley of Bowser 3
//        --- 0x38 | Valley Ghost House
//        --- 0x39 | Valley of Bowser 2
//        --- 0x3A | Valley of Bowser 1
//        --- 0x3B | Chocolate Secret
//        --- 0x3C | Vanilla Dome 2
//        --- 0x3D | Vanilla Dome 4
//        --- 0x3E | Vanilla Dome 1
//        --- 0x3F | Red Switch Palace
//        --- 0x40 | #3 Lemmy
//        --- 0x41 | Forest Ghost House
//        --- 0x42 | Forest of Illusion 1
//        --- 0x43 | Forest of Illusion 4
//        --- 0x44 | Forest of Illusion 2
//        --- 0x45 | Blue Switch Palace
//        --- 0x46 | Forest Secret Area
//        --- 0x47 | Forest of Illusion 3
//        --- 0x49 | Funky
//        --- 0x4A | Outrageous
//        --- 0x4B | Mondo
//        --- 0x4C | Groovy
//        --- 0x4E | Gnarly
//        --- 0x4F | Tubular
//        --- 0x50 | Way Cool
//        --- 0x51 | Awesome
//        --- 0x54 | Star World 2
//        --- 0x56 | Star World 3
//        --- 0x58 | Star World 1
//        --- 0x59 | Star World 4
//        --- 0x5A | Star World 5
function level_id() => byte(0x0013BF)

// $13C5: Moon Count [8 bit]
function moon_count() => byte(0x0013C5)

// $1426: Message Box Trigger [8 bit]
//        --- 0x00 | no message
//        --- 0x01 | message 1
//        --- 0x02 | message 2
//        --- 0x03 | Yoshi's thanks
function message_box_state() => byte(0x001426)

// $14AD: Blue P-Switch Timer [8 bit]
//        0xb0 when pressed
function blue_p_switch_timer() => byte(0x0014AD)

// $1891: P-Balloon Timer [8 bit]
function p_balloon_timer() => byte(0x001891)

// $18C5: Ground Pound Action [8 bit]
//        0 = not ground pounding
//        1 = starting ground pound [16f]
//        2 = falling
function ground_pound_action() => byte(0x0018C5)

// $18C6: Ground Pound Active Frames [8 bit]
//        starting ground pound lasts 16f
//        screen shake for 16f when ground pound hits
function ground_pound_active_frames() => byte(0x0018C6)

// $18C7: Ground Pound Hit [8 bit]
//        1 when ground pound hits ground, 0 otherwise
function ground_pound_hit() => byte(0x0018C7)

// $1F11: Mario Submap [8 bit]
//        --- 00 | Main
//        --- 01 | Yoshi's Island
//        --- 02 | Vanilla Dome
//        --- 03 | Forest of Illusion
//        --- 04 | Valley of Bowser
//        --- 05 | Special World
//        --- 06 | Star World
function mario_submap() => byte(0x001F11)

// $1FEE: 3-Up Moons Collected [8 bit]
//        bit1 | 40 - Donut Plains 4
//        bit2 | 07 - Donut Plains 3
//        bit3 | 14 - Donut Ghost House
//        bit4 | 12 - Top Secret Area
//        bit5 | 26 - Vanilla Secret 3
//        bit6 | 32 - Vanilla Secret 2
//        bit7 | 00 - Intro
// $1FEF: 3-Up Moons Collected [8 bit]
//        bit1 | 11 - #4 Ludwig
//        bit2 | 34 - Butter Bridge 2
//        bit5 | 08 - Donut Secret 1
//        bit6 | 10 - Donut Plains 2
// $1FF0: 3-Up Moons Collected [8 bit]
//        bit3 | 36 - Yellow Switch Palace
//        bit7 | 21 - Cookie Mountain
// $1FF1: 3-Up Moons Collected [8 bit]
//        bit2 | 30 - Chocolate Island 4
//        bit3 | 17 - Chocolate Island 5
//        bit4 | 01 - Chocolate Fort
//        bit5 | 16 - #6 Wendy
// $1FF2: 3-Up Moons Collected [8 bit]
//        bit0 | 22 - Yoshi's Island 2
//        bit1 | 27 - Yoshi's Island 4
//        bit5 | 05 - Chocolate Island 1
// $1FF3: 3-Up Moons Collected [8 bit]
//        bit1 | 06 - Vanilla Dome 3
//        bit4 | 19 - Vanilla Ghost House
//        bit5 | 23 - Yoshi's Island 2
//        bit7 | 09 - Yoshi's House
// $1FF4: 3-Up Moons Collected [8 bit]
//        bit0 | 35 - Valley of Bowser 3
//        bit2 | 29 - Valley Fort
//        bit3 | 31 - #7 Larry
//        bit4 | 18 - Valley of Bowser 4
//        bit6 | 24 - Bowser's Castle
// $1FF5: 3-Up Moons Collected [8 bit]
//        bit1 | 38 - Vanilla Dome 1
//        bit2 | 04 - Vanilla Dome 4
//        bit3 | 13 - Vanilla Dome 2
//        bit5 | 33 - Valley of Bowser 1
//        bit6 | 15 - Valley of Bowser 2
// $1FF6: 3-Up Moons Collected [8 bit]
//        bit4 | 20 - Forest of Illusion 4
//        bit5 | 39 - Forest of Illusion 1
// $1FF7: 3-Up Moons Collected [8 bit]
//        bit0 | 37 - Tubular
//        bit1 | 28 - Gnarly
//        bit3 | 03 - Groovy
//        bit6 | 25 - Funky
// $1FF8: 3-Up Moons Collected [8 bit]
//        bit1 | 02 - Star World 3

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function is_ground_pounding() => game_state() == STATE_IN_LEVEL && ground_pound_hit() > prev(ground_pound_hit())

DELTA = 7
function ground_pound_location(level, sub, x, y)
{
	// check if we are ground pounding in the correct level/sublevel
	trigger = is_ground_pounding() && level_id() == level

	// check if a sublevel has been provided
	if (sub != NULL) trigger = trigger && sublevel() == sub

	// check if we are within the appropriate bounding box
	trigger = trigger && player_x_position() >= x - DELTA && player_x_position() <= x + DELTA
	trigger = trigger && player_y_position() >= y - DELTA && player_y_position() <= y + DELTA
	return trigger
}

// --- MAIN DATA -------------------------------------------------------------------

STAGE_LOOKUP = {
	0x00: "the tutorial",
	0x01: "Vanilla Secret 2",
	0x02: "Vanilla Secret 3",
	0x03: "Top Secret Area",
	0x04: "Donut Ghost House",
	0x05: "Donut Plains 3",
	0x06: "Donut Plains 4",
	0x07: "#2 Morton's Castle",
	0x08: "Green Switch Palace",
	0x09: "Donut Plains 2",
	0x0A: "Donut Secret 1",
	0x0B: "Vanilla Fortress",
	0x0C: "Butter Bridge 1",
	0x0D: "Butter Bridge 2",
	0x0E: "#4 Ludwig's Castle",
	0x0F: "Cheese Bridge Area",
	0x10: "Cookie Mountain",
	0x11: "Soda Lake",
	0x14: "Yellow Switch Palace",
	0x15: "Donut Plains 1",
	0x18: "Sunken Ghost Ship",
	0x1A: "#6 Wendy's Castle",
	0x1B: "Chocolate Fortress",
	0x1C: "Chocolate Island 5",
	0x1D: "Chocolate Island 4",
	0x1F: "Forest Fortress",
	0x20: "#5 Roy's Castle",
	0x21: "Choco-Ghost House",
	0x22: "Chocolate Island 1",
	0x23: "Chocolate Island 3",
	0x24: "Chocolate Island 2",
	0x25: "#1 Iggy's Castle",
	0x26: "Yoshi's Island 4",
	0x27: "Yoshi's Island 3",
	0x28: "Yoshi's House",
	0x29: "Yoshi's Island 1",
	0x2A: "Yoshi's Island 2",
	0x2B: "Vanilla Ghost House",
	0x2D: "Vanilla Secret 1",
	0x2E: "Vanilla Dome 3",
	0x2F: "Donut Secret 2",
	0x31: "Bowser Front Door",
	0x32: "Bowser Back Door",
	0x33: "Valley of Bowser 4",
	0x34: "#7 Larry's Castle",
	0x35: "Valley Fortress",
	0x37: "Valley of Bowser 3",
	0x38: "Valley Ghost House",
	0x39: "Valley of Bowser 2",
	0x3A: "Valley of Bowser 1",
	0x3B: "Chocolate Secret",
	0x3C: "Vanilla Dome 2",
	0x3D: "Vanilla Dome 4",
	0x3E: "Vanilla Dome 1",
	0x3F: "Red Switch Palace",
	0x40: "#3 Lemmy's Castle",
	0x41: "Forest Ghost House",
	0x42: "Forest of Illusion 1",
	0x43: "Forest of Illusion 4",
	0x44: "Forest of Illusion 2",
	0x45: "Blue Switch Palace",
	0x46: "Forest Secret Area",
	0x47: "Forest of Illusion 3",
	0x49: "Funky",
	0x4A: "Outrageous",
	0x4B: "Mondo",
	0x4C: "Groovy",
	0x4E: "Gnarly",
	0x4F: "Tubular",
	0x50: "Way Cool",
	0x51: "Awesome",
	0x54: "Star World 2",
	0x56: "Star World 3",
	0x58: "Star World 1",
	0x59: "Star World 4",
	0x5A: "Star World 5",
}

MOONS = [
	/*00*/ { "check": bit7(0x1FEE), "level": 0x00, "name": "My First Moon", },
	/*01*/ { "check": bit4(0x1FF1), "level": 0x1B, "name": "Hummer Cheng Sends His Regards", },
	/*02*/ { "check": bit1(0x1FF8), "level": 0x56, "name": "Is This Loss?", },
	/*03*/ { "check": bit3(0x1FF7), "level": 0x4C, "name": "Abbey Road", },
	/*04*/ { "check": bit2(0x1FF5), "level": 0x3D, "name": "A Moon for an All-Star", },
	/*05*/ { "check": bit5(0x1FF2), "level": 0x22, "name": "Maslow's Hierarchy of Moons", },
	/*06*/ { "check": bit1(0x1FF3), "level": 0x2E, "name": "The Cave of the Hot Lips", },
	/*07*/ { "check": bit2(0x1FEE), "level": 0x05, "name": "Timing is Key", },
	/*08*/ { "check": bit5(0x1FEF), "level": 0x0A, "name": "Top of the Grotto", },
	/*09*/ { "check": bit7(0x1FF3), "level": 0x28, "name": "Special Delivery", },
	/*10*/ { "check": bit6(0x1FEF), "level": 0x09, "name": "Watch Your Head", },
	/*11*/ { "check": bit1(0x1FEF), "level": 0x0E, "name": "Breaking Out", },
	/*12*/ { "check": bit4(0x1FEE), "level": 0x03, "name": "Storeroom Satellite", },
	/*13*/ { "check": bit3(0x1FF5), "level": 0x3C, "name": "An Inconvenient Place", },
	/*14*/ { "check": bit3(0x1FEE), "level": 0x04, "name": "A Fine Collection of Doors", },
	/*15*/ { "check": bit6(0x1FF5), "level": 0x39, "name": "The Moon and the Tides", },
	/*16*/ { "check": bit5(0x1FF1), "level": 0x1A, "name": "Dotted Destination", },
	/*17*/ { "check": bit3(0x1FF1), "level": 0x1C, "name": "Boxes, Boxes, and More Boxes", },
	/*18*/ { "check": bit4(0x1FF4), "level": 0x33, "name": "A Forgotten Frigid Lake", },
	/*19*/ { "check": bit4(0x1FF3), "level": 0x2B, "name": "Amongst the Checkpoint 1-Ups", },
	/*20*/ { "check": bit4(0x1FF6), "level": 0x43, "name": "Between Two Pyramids", },
	/*21*/ { "check": bit7(0x1FF0), "level": 0x10, "name": "Poochy's Prize", },
	/*22*/ { "check": bit0(0x1FF2), "level": 0x27, "name": "The Twentieth Letter", },
	/*23*/ { "check": bit5(0x1FF3), "level": 0x2A, "name": "Math Was Never My Strong Suit", },
	/*24*/ { "check": bit6(0x1FF4), "level": 0x31, "name": "Moon Solitaire", },
	/*25*/ { "check": bit6(0x1FF7), "level": 0x49, "name": "PLAYing for KEEPs", },
	/*26*/ { "check": bit5(0x1FEE), "level": 0x02, "name": "Perfect Parabolas", },
	/*27*/ { "check": bit1(0x1FF2), "level": 0x26, "name": "Point of Advice", },
	/*28*/ { "check": bit1(0x1FF7), "level": 0x4E, "name": "Poochy Ain't Stupid", },
	/*29*/ { "check": bit2(0x1FF4), "level": 0x35, "name": "X Marks the Spot", },
	/*30*/ { "check": bit2(0x1FF1), "level": 0x1D, "name": "Going Down", },
	/*31*/ { "check": bit3(0x1FF4), "level": 0x34, "name": "Seek the Discrepancy", },
	/*32*/ { "check": bit6(0x1FEE), "level": 0x01, "name": "Invited to the Spiny Party", },
	/*33*/ { "check": bit5(0x1FF5), "level": 0x3A, "name": "Smiles From Ear to Ear", },
	/*34*/ { "check": bit2(0x1FEF), "level": 0x0D, "name": "Goonies Never Say Fly", },
	/*35*/ { "check": bit0(0x1FF4), "level": 0x37, "name": "Rough Timing, Rough Sketch", },
	/*36*/ { "check": bit3(0x1FF0), "level": 0x14, "name": "Moonic", },
	/*37*/ { "check": bit0(0x1FF7), "level": 0x4F, "name": "The Sixteenth Letter", },
	/*38*/ { "check": bit1(0x1FF5), "level": 0x3E, "name": "The Seventh Letter", },
	/*39*/ { "check": bit5(0x1FF6), "level": 0x42, "name": "A Very Berry Expedition", },
	/*40*/ { "check": bit1(0x1FEE), "level": 0x06, "name": "Lunar Petroglyphs", },
]

SUBLEVEL_CI4_VERTICAL = 0x9CEA03

CUSTOM_MOONS = [
	// Yoshi's Island 1 main room, requires the flying powerup block at the start
	{ "check": ground_pound_location(0x29, 0x97E7DE, 0x0110, 0x0110), "name": "Timing is Key #2", },

	// Donut Plains 1 cape tutorial room, pictured as the in-game screenshot on the RetroAchievements game page
	{ "check": ground_pound_location(0x15, 0x97AB83, 0x09A0, 0x0160), "name": "https://retroachievements.org/game/30879", },

	// Forest of Illusion 4 main room, the coins pictured appear when the blue p-switch is pressed
	{ "check": ground_pound_location(0x43, 0x98A89F, 0x0BB0, 0x0100), "name": "Press Any Switch to Continue", },

	// Soda Lake exit
	{ "check": ground_pound_location(0x11, 0x97823A, 0x0040, 0x0140), "name": "I Can Hold My Breath for Ten Minutes", },

	// --- { "check": ground_pound_location(), "name": "", },
]

VANILLA_MOONS = [
	ground_pound_location(0x29, 0x97E7DE, 0x0C60, 0x0030), // YI1
	ground_pound_location(0x06, 0x93B5AA, 0x0EF0, 0x0020), // DP4
	ground_pound_location(0x2E, 0x97F34F, 0x05E0, 0x0040), // VD3
	ground_pound_location(0x0F, 0x93C9C5, 0x1470, 0x0110), // CBA
	ground_pound_location(0x41, 0x9BD449, 0x0090, 0x0160), // FGH
	ground_pound_location(0x22, NULL,     0x0C60, 0x0030), // CI1 (any of room copies)
	ground_pound_location(0x3A, 0x98910E, 0x0B60, 0x0030), // VOB1
]

function collected_moon(moon) => game_state() == STATE_IN_LEVEL && level_id() == moon["level"] && moon["check"] > prev(moon["check"])

// --- RICH PRESENCE -------------------------------------------------------------------

rp_moon_count = rich_presence_value("_Number", moon_count(), "VALUE")
rp_level_name = rich_presence_lookup("Stage Name", level_id(), STAGE_LOOKUP, fallback="Dinosaur Land")

rich_presence_conditional_display(game_state() >= 0x0B && game_state() <= 0x0F && moon_count() < length(MOONS)-1,
	"[🌙{0}] Mario is looking for moons on the overworld",
	rp_moon_count
)

rich_presence_conditional_display(game_state() >= 0x0B && game_state() <= 0x0F && moon_count() == length(MOONS)-1,
	"[🌙{0}] Mario is a master Moon Finder!",
	rp_moon_count
)

rich_presence_conditional_display(game_state() >= 0x10 && game_state() <= 0x17,
	"[🌙{0}] Mario is looking for moons in {1}",
	rp_moon_count, rp_level_name
)

rich_presence_display(
	"Mario is finding some moooooooons! 🌙"
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

CHALLENGE_INFO = "Moon must not have already been collected, so attempt from a new file"

moon_num = 0
for moon in MOONS
{
	achievement(id=461030 + moon_num,
		title=moon["name"],
		description=format("Collect the moon indicated by hint art #{0}", zfill(moon_num, 2)),
		points=if_else(moon_num == 0, 1, 3),
		type=if_else(moon_num == 0, "", "progression"),
		trigger=collected_moon(moon)
	)
	moon_num = moon_num + 1
}

achievement(id=461071,
	title="Journey to the Center of Dinosaur Land",
	description="Collect moon #30 without ground pounding below the first row of brown blocks. " + CHALLENGE_INFO,
	points=5,
	trigger=collected_moon(MOONS[30]) && disable_when(
		sublevel() == SUBLEVEL_CI4_VERTICAL && ground_pound_action() == 1 && player_y_position() > 0x00E0, 
		until=sublevel() != SUBLEVEL_CI4_VERTICAL || game_state() != STATE_IN_LEVEL
	)
)

achievement(id=461072,
	title="Missing Some Key Information",
	description="Maybe you misunderstood the hint for moon #36?",
	points=2,
	trigger=ground_pound_location(0x15, 0x93D883, 0x1230, 0x0050) // Donut Plains 1 main level
)

achievement(id=461073,
	title="Ignoring the Prompt",
	description="Collect moon #37 without using the P-balloon. " + CHALLENGE_INFO,
	points=5,
	trigger=collected_moon(MOONS[37]) && disable_when(p_balloon_timer() > 0, until=game_state() != STATE_IN_LEVEL)
)

achievement(id=461074,
	title="Ceci N'est Pas Une Pipe",
	description="Investigate the mystery of Chocolate Island 2's missing pipe, but be careful...",
	points=1,
	trigger=game_state() == STATE_IN_LEVEL && level_id() == 0x24 && message_box_state() == 1
)

achievement(id=461075,
	title="404: Moon Not Found",
	description="Attempt to reveal any of the 7 original Super Mario World moons. They're not here, didn't you hear?",
	points=2,
	trigger=any_of(VANILLA_MOONS, idfunc)
)

// custom moons
moon_num = 1
for moon in CUSTOM_MOONS
{
	achievement(id=461075 + moon_num,
		title=moon["name"],
		description=format("Ground pound at the location indicated by custom hint art #{0}", zfill(moon_num, 2)),
		points=3,
		trigger=moon["check"]
	)
	moon_num = moon_num + 1
}

// --- LEADERBOARDS -------------------------------------------------------------------