// Lifeline | Life Line
// #ID = 19057

// --- HELPERS -------------------------------------------------------------------

NULL = 0
function if_else(p, t, f) { if (p) { return t } else return f }
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
function bitx(i, addr) => bit(i % 8, addr + i / 8)
function ptr(x) => dword(x)

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

function commas(x)
{
	function comma_join(list)
	{
		res = ""
		for i in range(0, length(list)-1)
		{
			if (i == length(list) - 1)
				res = format("{0}", list[i]) + res
			else res = "," + zfill(list[i], 3) + res
		}
		return res
	}

	parts = []
	for i in range(1, 10)
	{
		if (x == 0) return comma_join(parts)
		array_push(parts, x % 1000)
		x = x / 1000
	}
}

// --- MEMORY -------------------------------------------------------------------

// $34F440: Message Identifier [32 bit]
function message_identifier() => dword(0x34F440)

// $38CF24: Pointer to Rio's Active/Recent Voice Data [32 bit]
//          
//          +0x090 | Rio's Active Voice Line Time Sequence [32 bit]
//          +0x1E0 | Pointer to Active/Recent Voice Stream Data [32 bit]
//          +0x3C4 | Is Actively Talking [32 bit] (1 when talking)
RIO_VOICE_STRUCT = 0x38CF24
function ptr_to_active_voice_stream() => ptr(ptr(0x38CF24) + 0x1E0)
function is_rio_talking() => dword(ptr(0x38CF24) + 0x3C4)

// $38D174: Pointer to Rio's Voice Database [32 bit]
//          
//          +0x0 | Pointer to Start of Voice Stream Data [32 bit]
//          +0x4 | Pointer to Table of Voice Offsets by ID [32 bit]
//          +0x8 | Size of Voice Data Table
RIO_VOICE_DATA = 0x38D174
function ptr_to_voice_stream_data() => ptr(ptr(RIO_VOICE_DATA) + 0x0)
function ptr_to_voice_table() => ptr(ptr(RIO_VOICE_DATA) + 0x4)
function voice_table_size() => dword(ptr(RIO_VOICE_DATA) + 0x8)

// $3E5130: Flags [8 bit]
function shutter1() => bit2(0x3E5130) // Shutter 7
function shutter2() => bit0(0x3E5131) // Shutter 3
function shutter3() => bit7(0x3E5133) // Shutter 2
function shutter4() => bit5(0x3E519B) // Shutter 5
function shutter5() => bit6(0x3E519B) // Shutter 6

function shutter_spider() => bit5(0x3E5130) // Shutter 4 closed
function spider_killed() => bit1(0x3E514A) // Shutter 4
function enter_sun_suite() => bit1(0x3E5132)

// $50E754: Can Talk [8 bit]
//          0 = Cannot Talk
//          1 = Talk Now
function can_talk() => byte(0x50E754)

// $50E78C: Voice Score [16 bit]
function voice_score() => word(0x50E78C)

// $50E7E4: Voice Command Given [ASCII]
VOICE_COMMAND_TEXT = 0x50E7E4

// $518540: Location ID [32 bit]
//          0x01 = Equipment Room
//          0x02 = Guest Room 1
//          0x03 = Guest Room 2
//          0x04 = Guest Room 3
//          0x05 = Guest Room 4
//          0x08 = Guest Room 5
//          0x09 = Sun Suite
//          0x0A = Moon Suite
//          0x0B = Restrooms (Dark)
//          0x0C = Medical Room
//          0x0E = Receiving Port
//          0x0F = Staff Room
//          0x11 = Service Staff Quarters
//          0x13 = Waiting Room
//          0x14 = Elevator Hall (by Observatory Restaurant)
//          0x16 = Warehouse
//          0x15 = Elevator Hall (top of elevator)
//          0x17 = Elevator Hall (by Receiving Port)
//          0x19 = Observatory Restaurant
//          0x1A = Observatory Elevator
//          0x20 = Break Room
//          0x21 = Manager's Office
//          0x22 = Exhibit Room
//          0x24 = Hideaway
//          0x25 = Laboratory
//          0x26 = Zero-Gravity Warehouse
//          0x28 = Shuttleport
//          0x3D = Hall - GUEST (1)
//          0x3E = Hall - GUEST (1)
//          0x44 = Hall - GUEST (1 return)
//          0x4D = Hall - STAFF
//          0x4E = Hall - STAFF
//          0x4F = Duct
//          0x50 = Hall - STAFF
//          0x58 = Hall - SENIOR STAFF
//          0x5E = Corridor
function location() => dword(0x518540)

// $518564: Game Time (in frames) [32 bit]
function game_time_f() => dword(0x518564)
function game_time_secs() => game_time_f() / 60

// $518584: Meta Location/State [32 bit]
//          check note @ 0x00518540 for base values
//          
//          0x63 (99) = Ending
//          0x64 (100) = Save Game
//          0x65 (101) = Load Game
//          
//          0x3E8 (1000) = Tutorial
//          0x3EC (1004) = Title Screen
//          0x3ED (1005) = Bonus Game (All)
//          0x3F7 (1015) = Game Over
function meta_state() => dword(0x518584)

// $59BE90: Rio's Voice Line Frame Counter [32 bit]
function rio_voice_f() => dword(0x59BE90)

// $59BEE0: Pointer to Rio's Voice Line [32 bit]
RIO_VOICE_PTR = 0x59BEE0

// $6E3918: Current Health [32 bit]
//          max = 1000
function current_health() => dword(0x6E3918)

// $6E3958: Heal Capsules [32 bit]
function heal_capsules() => dword(0x6E3958)

// $6E39B8: Chips Collected [32 bit]
function chips_collected() => dword(0x6E39B8)

// $6E3978: Launcher Grenades [32 bit]
function launcher_grenades() => dword(0x6E3978)

// $6E3CF8: Number of Voice Commands [16 bit]
function voice_command_count() => word(0x6E3CF8)

// $6E3D78: Word Jumble High Score [32 bit]
function word_jumble_high_score() => dword(0x6E3D78)

// $6E3D98: Complete the Phrases High Score [32 bit]
function complete_the_phrases_high_score() => dword(0x6E3D98)

// $6E3DB8: The Calc High Score [32 bit]
function the_calc_high_score() => dword(0x6E3DB8)

// $6E3DD8: Categories Game Wins [32 bit]
function categories_game_wins() => dword(0x6E3DD8)

// $6E3DF8: Categories Game Losses [32 bit]
function categories_game_losses() => dword(0x6E3DF8)


// --- MAIN DATA -------------------------------------------------------------------

VOICE_RIO_BARKS = 0x5070
VOICE_RIO_SEXY_POSE = 0x1133
VOICE_RIO_CAMERA_CHECK = 0x1134
VOICE_SHE_SELLS_WIN = 0x5059
VOICE_GIRL_NAME_KRISTEN = 0x2220
VOICE_GIRL_NAME_RIO = 0x2222
VOICE_MOON_PM_HOLD_UP = 0x2B5F
VOICE_MOON_RIO_STOP = 0x2B90
VOICE_BRAIN_LORE_DROP = 0x3020

LOC_TITLE_SCREEN = 0x3EC
LOC_TUTORIAL = 0x3E8
LOC_BONUS_GAME = 0x3ED
LOC_ENDING = 0x63
LOC_GAME_OVER = 0x3F7
LOC_SAVE_GAME = 0x64
LOC_LOAD_GAME = 0x65

MIRRORS = [
	bit2(0x3E516E), // [Mirror] Restrooms Ladies' Washstands left
	bit3(0x3E516E), // [Mirror] Restrooms Ladies' Washstands middle
	bit4(0x3E516E), // [Mirror] Restrooms Ladies' Washstands right
	bit5(0x3E516E), // [Mirror] Restrooms Men's Washstands left
	bit6(0x3E516E), // [Mirror] Restrooms Men's Washstands middle
	bit7(0x3E516E), // [Mirror] Restrooms Men's Washstands right
	bit2(0x3E51A1), // [Mirror] Guest Room 2 Dresser
	bit6(0x3E51A1), // [Mirror] Guest Room 2 Bathroom
	bit5(0x3E51A2), // [Mirror] Guest Room 3 Dresser
	bit6(0x3E51A3), // [Mirror] Guest Room 4 Dresser
	bit3(0x3E51A5), // [Mirror] Sun Suite 2nd Floor Washroom
	bit5(0x3E51A6), // [Mirror] Guest Room 1 Dresser
	bit2(0x3E51A7), // [Mirror] Guest Room 1 Bathroom
]

COMMANDS = [
	bit3(0x3E514A), // [Command] Sexy pose
	bit4(0x3E514A), // [Command] Camera check
	bit5(0x3E514A), // [Command] Jumpback
	bit6(0x3E514A), // [Command] Jump
	bit0(0x3E514B), // [Command] Microphone check
	bit1(0x3E514B), // [Command] Category Game
	bit2(0x3E514B), // [Command] Break time
	bit3(0x3E514B), // [Command] Strafe
	bit4(0x3E514B), // [Command] Spin the Gun
	bit5(0x3E514B), // [Command] Taunt
	bit6(0x3E514B), // [Command] Auto-fire
	bit7(0x3E514B), // [Command] Zoom in
	bit0(0x3E514C), // [Command] I'll leave it to you
	bit1(0x3E514C), // [Command] She sells
	bit2(0x3E514C), // [Command] Low kick
]

CHIPS = [
	bit7(0x3E5136), // [Chip] Sun Suite Fruits @ Lounge
	bit5(0x3E513C), // [Chip] Security Room Locker
	bit4(0x3E5145), // [Chip] Equipment Room center Utility Unit shelf
	bit1(0x3E5148), // [Chip] Break Room Table Mug
	bit5(0x3E514F), // [Chip] Guest Room 1 Trunk
	bit1(0x3E5153), // [Chip] Guest Room 2 Nightstand
	bit4(0x3E5156), // [Chip] Guest Room 3 - Cigar Case
	bit7(0x3E5159), // [Chip] Guest Room 4 Bed
	bit2(0x3E515D), // [Chip] Guest Room 5 - Bathrobe on Bed
	bit7(0x3E5168), // [Chip] Infirmary Case 5
	bit1(0x3E516C), // [Chip] Restrooms - Men's Stalls #2
	bit5(0x3E5174), // [Chip] Waiting Room Under Video Camera
	bit6(0x3E5175), // [Chip] Staff Room Gustav's locker
	bit3(0x3E5179), // [Chip] Manager's Office Bed under pillow
	bit0(0x3E517B), // [Chip] Warehouse Area B-2
	bit6(0x3E5184), // [Chip] Observatory Restaurant VIP Seat 2
]

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function in_game() => meta_state() <= 0x5E

// I owe Souzooka big time for helping me work this logic out :)
// usable ids can be found by putting an execution breakpoint at 00162E80 and checking the contents of register a1
TABLE_MAX = 300
function rio_says(id) => is_rio_talking() < prev(is_rio_talking()) && any_of(range(0, TABLE_MAX), (i) => (
	// the index is within the bounds of the table
	i < voice_table_size() &&

	// the id of the voice line in the table matches the id we are looking for
	dword(ptr_to_voice_table() + (i * 0x10) + 0x0) == id &&

	// the pointer to the current spoken voice line matches this entry with a 0x10 offset
	ptr_to_voice_stream_data() + dword(ptr_to_voice_table() + (i * 0x10) + 0x8) + 0x10 == ptr_to_active_voice_stream()
))

// --- RICH PRESENCE -------------------------------------------------------------------

Locations = {
	0x01: "Equipment Room",
	0x02: "Guest Room 1",
	0x03: "Guest Room 2",
	0x04: "Guest Room 3",
	0x05: "Guest Room 4",
	0x08: "Guest Room 5",
	0x09: "Sun Suite",
	0x0A: "Moon Suite",
	0x0B: "Toilet",
	0x0C: "Medical Room",
	0x0E: "Receiving Port",
	0x0F: "Staff Room",
	0x11: "Service Staff Quarters",
	0x13: "Waiting Room",
	0x14: "Elevator Hall",
	0x16: "Warehouse",
	0x15: "Elevator Hall",
	0x17: "Elevator Hall",
	0x19: "Observatory Restaurant",
	0x1A: "Observatory Elevator",
	0x20: "Break Room",
	0x21: "Manager's Office",
	0x22: "Exhibit Room",
	0x24: "Hideaway",
	0x25: "Laboratory",
	0x26: "Zero-Gravity Warehouse",
	0x28: "Shuttleport",
	0x3D: "Guest Floor Hall",
	0x3E: "Guest Floor Hall",
	0x44: "Guest Floor Hall",
	0x4D: "Staff Floor Hall",
	0x4E: "Staff Floor Hall",
	0x4F: "Duct",
	0x50: "Staff Floor Hall",
	0x58: "Senior Staff Floor Hall",
	0x5E: "Zero-Gravity Corridor",
}

ASCII = {
	0x20: " ",
	0x2C: ",",
	0x2E: ".",
	0x30: "0",
	0x31: "1",
	0x32: "2",
	0x33: "3",
	0x34: "4",
	0x35: "5",
	0x36: "6",
	0x37: "7",
	0x38: "8",
	0x39: "9",
	0x41: "A",
	0x42: "B",
	0x43: "C",
	0x44: "D",
	0x45: "E",
	0x46: "F",
	0x47: "G",
	0x48: "H",
	0x49: "I",
	0x4A: "J",
	0x4B: "K",
	0x4C: "L",
	0x4D: "M",
	0x4E: "N",
	0x4F: "O",
	0x50: "P",
	0x51: "Q",
	0x52: "R",
	0x53: "S",
	0x54: "T",
	0x55: "U",
	0x56: "V",
	0x57: "W",
	0x58: "X",
	0x59: "Y",
	0x5A: "Z",
	0x61: "A",
	0x62: "B",
	0x63: "C",
	0x64: "D",
	0x65: "E",
	0x66: "F",
	0x67: "G",
	0x68: "H",
	0x69: "I",
	0x6A: "J",
	0x6B: "K",
	0x6C: "L",
	0x6D: "M",
	0x6E: "N",
	0x6F: "O",
	0x70: "P",
	0x71: "Q",
	0x72: "R",
	0x73: "S",
	0x74: "T",
	0x75: "U",
	0x76: "V",
	0x77: "W",
	0x78: "X",
	0x79: "Y",
	0x7A: "Z",
}

rp_location = rich_presence_lookup("Location", location(), Locations, fallback="JSL Station")
rp_health = rich_presence_value("_Fixed1", current_health(), "FIXED1")
rp_chips = rich_presence_value("_Number", chips_collected(), "VALUE")
rp_heal_capsules = rich_presence_value("_Number", heal_capsules(), "VALUE")
rp_time = rich_presence_value("_Minutes", game_time_secs() / 60, "MINUTES")
rp_voice_commands = rich_presence_value("_Number", voice_command_count(), "VALUE")

rich_presence_conditional_display(meta_state() == LOC_TUTORIAL,
	"🔰 Tutorial"
)

rich_presence_conditional_display(meta_state() == LOC_BONUS_GAME,
	"Playing a Minigame"
)

rich_presence_conditional_display(meta_state() == LOC_ENDING,
	"🚀 Escaping the JSL Station ⌛ {0}m 🎤 {1}",
	rp_time,
	rp_voice_commands
)

rich_presence_conditional_display(meta_state() == LOC_TITLE_SCREEN || location() == 0,
	"Getting ready for a Voice Action Adventure"
)

rich_presence_display(
	"📍 {0} ❤️ {1}% 🎟️ {2} 💊 {3} ⌛ {4}m 🎤 {5}",
	rp_location,
	rp_health,
	rp_chips,
	rp_heal_capsules,
	rp_time,
	rp_voice_commands
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

// progression
// - shut spider shutter
// - enter sun suite
// - defeat spider monster

achievement(
	title="Good Girl! Sit, Stay",
	description="Rio, bark like a dog",
	points=1,
	trigger=rio_says(VOICE_RIO_BARKS)
)

achievement(
	title="It's Like Where's Waldo",
	description="Rio, I can't seem to find you! Camera check",
	points=3,
	trigger=rio_says(VOICE_RIO_CAMERA_CHECK)
)

achievement(
	title="Seven Years of Bad Luck",
	description="Rio, you can't just break every mirror on the JSL station",
	points=5,
	trigger=(
		// previously one less than the total number of mirrors
		sum_of(MIRRORS, x => prev(x)) == length(MIRRORS)-1 &&
	
		// found all of the mirrors
		measured(sum_of(MIRRORS, x => x) >= length(MIRRORS))
	)
)

// --- LEADERBOARDS -------------------------------------------------------------------
