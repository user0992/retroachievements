// ~Hack~ Super Mario Bros. 2 Squared: Return to Subcon
// #ID = 13455

// --- HELPERS -------------------------------------------------------------------

NULL = 0
function if_else(p, t, f) { if (p) { return t } else return f }
idfunc = (x) => x
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

function ptr(addr) => word(addr)

// --- MEMORY -------------------------------------------------------------------

// $0003: Paused [8 bit]
//        0 when unpaused, cycles through a few other values at other times
function is_paused() => byte(0x000003)
UNPAUSED = 0

// $008F: Current Character [8 bit]
//        0 = Mario
//        1 = Princess
//        2 = Toad
//        3 = Luigi
function current_character() => byte(0x00008F)

CHAR_MARIO = 0
CHAR_PEACH = 1
CHAR_TOAD = 2
CHAR_LUIGI = 3

// $04AE: Player Control [8 bit]
//        1 when player has control, 0 otherwise
function has_control() => byte(0x0004AE)

// $04C2: Health [8 bit]
//        upper4 is hits remaining (0 = small)
//        lower4 is 0xF until death, when 0x0
function hits() => high4(0x0004C2)
function alive() => bit0(0x0004C2)

// $04E7: Respawn - Area [8 bit]
// $04E8: Respawn - Sub-Area [8 bit]
// $04E9: Respawn - Page [8 bit]
function respawn_area() => byte(0x0004E7)
function respawn_sub_area() => byte(0x0004E8)
function respawn_page() => byte(0x0004E9)
function respawn_location() => tbyte_be(0x0004E7)

// $04ED: Life Count [8 bit]
//        displays value -1
function life_count() => byte(0x0004ED)

// $0531: Current Area [8 bit]
//        0x00 = 1-1
//        0x01 = 1-2
//        0x02 = 1-3
//        0x03 = 2-1
//        0x04 = 2-2
//        0x05 = 2-3
//        0x06 = 3-1
//        0x07 = 3-2
//        0x08 = 3-3
//        0x09 = 4-1
//        0x0A = 4-2
//        0x0B = 4-3
//        0x12 = 7-1
//        0x13 = 7-2
// $0532: Current Sub-Area [8 bit]
//        (01, 00->05) = 1-2 secret GC7 room
//        (03, 00->04) = 2-1 secret d4 room with 1-up
//        (04, 01->02) = 2-2 vine clip in room 2
// $0533: Current Page [8 bit]
function current_area() => byte(0x000531)
function current_sub_area() => byte(0x000532)
function current_page() => byte(0x000533)
function location() => tbyte_be(0x000531)

WARTS_ROOM = 0x130500

// $05EE: Music [8 bit]
//        0x07 = char select
//        0x10 = overworld
//        0x17 = boss music
//        0x19 = wart
//        0x1a = title
//        0x1e = subcon
//        0x23 = end game victory
//        0x29 = underworld
function music() => byte(0x0005EE)

MUSIC_TITLE = 0x1A
MUSIC_SUBCON = 0x1E
MUSIC_BOSS = 0x17
MUSIC_WART = 0x19
MUSIC_CHARSELECT = 0x07
MUSIC_END = 0x23

// $0600: Play Music  [8 bit]
//        bit0 = overworld
//        bit1 = char select
//        bit2 = underground
//        bit3 = boss
//        bit4 = star
//        bit5 = subcon
//        bit6 = wart
//        bit7 = title music
// $0601: Play Sound Effect A [8 bit]
//        bit0 = door opening
//        bit2 = take damage
//        bit3 = grab object
//        bit6 = enemy hurt
//        bit7 = death
// $0602: Play Sound Effect B [8 bit]
//        bit2 = grab heart
//        bit3 = throw object
//        bit4 = collect 1up
//        bit7 = hawkmouth open
PLAY_MUSIC_ADDR = 0x000600
SOUND_EFFECTS_A_ADDR = 0x000601
SOUND_EFFECTS_B_ADDR = 0x000602

function open_door() => bit0(SOUND_EFFECTS_A_ADDR)
function take_damage() => bit2(SOUND_EFFECTS_A_ADDR)
function death_sound() => bit7(SOUND_EFFECTS_A_ADDR)
function throw_object() => bit3(SOUND_EFFECTS_B_ADDR)

// $062A: Cherries [8 bit]
function cherries() => byte(0x00062A)

// $062B: Coins [8 bit]
function coins() => byte(0x00062B)

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function died() => prev(alive()) == 1 && alive() == 0 // prev(death_sound()) == 0 && death_sound() == 1

function took_damage() => hits() < prev(hits())

function unpaused() => has_control() == 1 && is_paused() == UNPAUSED

function death_count(n) => (
	// count the number of times the player died
	measured(repeated(n, died())) &&

	// reset (or otherwise don't increment) on the title screen
	never(prev(music()) == MUSIC_TITLE)
)

function damageless() => (
	// checkpoint hit at the start of the stage
	once(prev(music()) == MUSIC_CHARSELECT && music() != MUSIC_CHARSELECT) &&

	// reset if respawn position is updated while you've taken hits
	never(respawn_location() != prev(respawn_location()) && hits() < 1)
)

function damageless_since_last_respawn() => (
	tally(1,
		// +1 by default
		once(always_true()),

		// -1 if player takes damage, remove -1 when respawn
		deduct(once(hits() < 1 && never(alive() > prev(alive()))))
	)
)

function new_game() => once(prev(music()) == MUSIC_CHARSELECT && music() != MUSIC_CHARSELECT && current_area() == 0x00)

function win_the_game() => prev(music()) != MUSIC_END && music() == MUSIC_END

// --- MAIN DATA -------------------------------------------------------------------

STAGES = [
	{
		"stage": "1-1",
		"area": 0x00,
		"name": "Shy Guy Summit",
		"last": 0x000500,
	},
	{
		"stage": "1-2",
		"area": 0x01,
		"name": "Featherlight Falls",
		"last": 0x010200,
	},
	{
		"stage": "1-3",
		"area": 0x02,
		"name": "Heave & Hover", // mouser
		"last": 0x020400,
	},
	{
		"stage": "2-1",
		"area": 0x03,
		"name": "Star Cherry Grotto", 
		"last": 0x030200,
	},
	{
		"stage": "2-2",
		"area": 0x04,
		"name": "Tarzan in Green",
		"last": 0x040500,
	},
	{
		"stage": "2-3",
		"area": 0x05,
		"name": "Colorblock Cavern", // triclyde
		"last": 0x050600,
	},
	{
		"stage": "3-1",
		"area": 0x06,
		"name": "Beezos Brookfalls",
		"last": 0x060400,
	},
	{
		"stage": "3-2",
		"area": 0x07,
		"name": "Arrhythmia",
		"last": 0x070100,
	},
	{
		"stage": "3-3",
		"area": 0x08,
		"name": "Spring Block Sprint", // birdo
		"last": 0x080600,
	},
	{
		"stage": "4-1",
		"area": 0x09,
		"name": "Blowhole Blizzard",
		"last": 0x090200,
	},
	{
		"stage": "4-2",
		"area": 0x0A,
		"name": "Eggshell Surfer",
		"last": 0x0A0400,
	},
	{
		"stage": "4-3",
		"area": 0x0B,
		"name": "Five Room Cavern", // fryguy
		"last": 0x0B0200,
	},
	{
		"stage": "7-1",
		"area": 0x12,
		"name": "Castle Conveyors", // hawkmouth
		"last": 0x120101,
	},
	{
		"stage": "7-2",
		"area": 0x13,
		"name": "Wart's Palace", // wart
		"last": WARTS_ROOM,
	},
]

WORLDS = [
	{"w": 1, "name": "Mouser Mountain", "boss": "Mouser"},
	{"w": 2, "name": "Triclyde Tundra", "boss": "Triclyde"},
	{"w": 3, "name": "Birdo Basin", "boss": "Birdo"},
	{"w": 4, "name": "Fryguy Fortress", "boss": "Fryguy"},
]

// --- RICH PRESENCE -------------------------------------------------------------------

CHAR_LOOKUP = {
	CHAR_MARIO: "🔴 Mario",
	CHAR_LUIGI: "🟢 Luigi",
	CHAR_PEACH: "👑 Princess",
	CHAR_TOAD: "🍄 Toad",
}

STAGE_LOOKUP = {}
TITLE_LOOKUP = {}

for stage in STAGES
{
	STAGE_LOOKUP[stage["area"]] = stage["stage"]
	TITLE_LOOKUP[stage["area"]] = stage["name"]
}

rp_stage = rich_presence_lookup("Stage", current_area(), STAGE_LOOKUP, fallback=STAGE_LOOKUP[0])
rp_character = rich_presence_lookup("Character", current_character(), CHAR_LOOKUP, fallback=CHAR_LOOKUP[CHAR_MARIO])
rp_title = rich_presence_lookup("Title", current_area(), TITLE_LOOKUP, fallback="Subcon")

rp_damageless = rich_presence_lookup("Damageless", 
	damageless() && never(current_area() != prev(current_area())), 
	{1: " 💜"}, fallback="")
rp_deaths = rich_presence_value("_Number", death_count(10000), "VALUE")
rp_paused = rich_presence_lookup("Paused", is_paused(), {UNPAUSED: ""}, fallback="⏸️ ")

rich_presence_conditional_display(music() == MUSIC_TITLE || music() == MUSIC_SUBCON,
	"Returning to Subcon"
)

rich_presence_conditional_display(music() == MUSIC_END,
	"Getting some much-deserved rest after returning to Subcon"
)

rich_presence_conditional_display(music() == MUSIC_CHARSELECT,
	"Selecting a character for {0}: {1} | 💀 {2}",
	rp_stage, rp_title, rp_deaths
)

rich_presence_display(
	"{5}{3} is in {0}: {1}{4} | 💀 {2}",
	rp_stage, rp_title, rp_deaths,
	rp_character, rp_damageless,
	rp_paused
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

ach_id = 448929
for stage in STAGES
if (stage["area"] % 3 == 2)
{
	w = WORLDS[stage["area"] / 3]
	achievement(id=ach_id,
		title=w["name"],
		description=format("Defeat {1} and complete World {0}", w["w"], w["boss"]),
		type="progression",
		points=10,
		// this isn't exactly a OCA, because the location() check is actually just 3 contiguous addresses
		trigger=prev(location()) == stage["last"] && current_area() > prev(current_area())
	)
	ach_id = ach_id + 1
}

achievement(id=448933,
	title="Dream Factory",
	description="Defeat Wart and complete World 7",
	type="win_condition",
	points=25,
	trigger=win_the_game()
)

ach_id = 448934
for stage in STAGES
if (stage["area"] != 0x07) // this stage has a gimmick that makes it incompatible with the damageless challenge
{
	// how we determine the level is completed doesn't work for the last level
	complete_level = current_area() > prev(current_area())
	if (stage["last"] == WARTS_ROOM) complete_level = win_the_game()

	achievement(id=ach_id,
		title=stage["name"],
		description=format("Complete {0} without taking damage between individual checkpoints. Retries at every checkpoint are allowed.", stage["stage"]),
		points=5,
		trigger=(
			// if the correct stage is completed damageless, show challenge indicator
			prev(current_area()) == stage["area"] && damageless() &&

			// challenge ends when the stage is completed
			trigger_when(prev(location()) == stage["last"] && complete_level && damageless_since_last_respawn())
		)
	)
	ach_id = ach_id + 1
}

DEATHS_ALLOWED = 50
achievement(id=448947,
	title="Kaizo Konqueror",
	description=format("In one session, starting from New Game, complete the game with fewer than {0} deaths", DEATHS_ALLOWED),
	points=50,
	trigger=new_game() && never(repeated(DEATHS_ALLOWED, died())) && never(music() == MUSIC_TITLE) && trigger_when(win_the_game())
)

achievement(id=448948,
	title="Thanks to GlitchCat7",
	description="Find the hidden GlitchCat7 developer room in World 1",
	points=5,
	trigger=current_area() == 0x01 && trigger_when(prev(current_sub_area()) == 0x00 && current_sub_area() == 0x05)
)

achievement(id=448949,
	title="Thanks to dtothefourth",
	description="Find the hidden dtothefourth developer room in World 2",
	points=5,
	trigger=current_area() == 0x03 && trigger_when(prev(current_sub_area()) == 0x00 && current_sub_area() == 0x04)
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(id=108755,
	title="Subcon Speedrun",
	description="Starting from New Game, complete the game as quickly as possible",

	start=new_game(),
	cancel=music() == MUSIC_TITLE,
	submit=win_the_game(),

	value=measured(tally(0, unpaused())),
	format="FRAMES",
	lower_is_better=false
)

leaderboard(id=108756,
	title="Kaizo Perfection",
	description="Starting from New Game, complete the game with as few deaths as possible",

	start=new_game(),
	cancel=music() == MUSIC_TITLE,
	submit=win_the_game(),

	value=measured(tally(0, died())),
	format="VALUE",
	lower_is_better=true
)