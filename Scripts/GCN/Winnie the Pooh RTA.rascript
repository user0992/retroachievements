// Winnie The Pooh's Rumbly Tumbly Adventure
// #ID = 25488

// --- HELPERS -------------------------------------------------------------------

NULL = 0
function if_else(p, t, f) { if (p) { return t } else return f }
idfunc = (x) => x
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

// function ptr(x) => dword_be(x) & 0x1FFFFFF
function ptr(x) => dword_be(x) + 0x80000000
// function ptr(x) => tbyte_be(x+1) // NOT IDEAL

// --- MEMORY -------------------------------------------------------------------

// $000000: Game ID [6 bytes]
function game_id() => byte(0x000000)

// $2CF678: Language [32 bit BE]
//          0 = English
//          1 = French
//          2 = Spanish
function language() => dword_be(0x2CF678)

// $2E1DD4: Pointer to Minigame Info [32 bit BE]
//          +0x46C | FTC Cookies [32 bit BE]
function ftc_cookies() => dword_be(ptr(0x2E1DD4) + 0x46C)

// $2E1E88: Pointer to Minigame Info [32 bit BE]
//          +0x2CC | FTC Round [32 bit BE] (0-3)
function ftc_round() => dword_be(ptr(0x2E1E88) + 0x2CC)

// $325730: Game State [32 bit BE]
//          includes some loading information
function game_state() => dword_be(0x325730)

// Chapter data is in 1300 byte chunks
CHAPTER_SIZE = 1300

// $32596C: Chapter 1 - Pooh Stamp [32 bit BE]
//          0 = incomplete
//          1 = complete
// $325980: Chapter 1 Map Flags [60 bytes]
//          bit0 = visited
//          bit1 = maybe starting location?
//          bit2 = collected all honey pots
//          
//          array of locations, each 32 bit BE
//          corresponding to the offsets at 0x0032aa80
// $325E1C: Chapter 1 - Total Honey Possible [32 bit BE]
// $325E20: Chapter 1 - Honey Remaining [32 bit BE]
// $325E24: Chapter 1 - Honey Collected [32 bit BE]
// $325E48: Chapter 1 - Number of Music Notes Collected [8 bit]
function chapter_pooh_stamp(i) => dword_be(0x32596C + CHAPTER_SIZE * (i - 1))
function room_completed(i, map) => bit2(0x325980 + CHAPTER_SIZE * (i - 1) + 4 * map)
function chapter_total_honey_possible(i) => dword_be(0x325E1C + CHAPTER_SIZE * (i - 1))
function chapter_honey_on_hand(i) => dword_be(0x325E20 + CHAPTER_SIZE * (i - 1))
function chapter_total_honey_collected(i) => dword_be(0x325E24 + CHAPTER_SIZE * (i - 1))
function chapter_music_notes(i) => byte(0x325E48 + CHAPTER_SIZE * (i - 1))

// $32AA7C: Current Chapter [32 bit BE]
//          1 = Piglet's Birthday
//          2 = Roo's Birthday
//          3 = Tigger's Birthday
//          4 = Eeyore's Birthday
//          5 = Pooh's Birthday
//          
//          0 = Title Screen
//          6 = Minigames
//          7 = Junior Mode
//          8 = Game Menus
function current_chapter() => dword_be(0x32AA7C)

// $32AA80: Map ID [32 bit BE]
//          
//          In Adventure Mode:
//          0x01 = Pooh's House
//          0x02 = Kanga's House
//          0x03 = Tigger's House
//          0x04 = Piglet's House
//          0x05 = the Clearing
//          0x06 = the waterfall
//          0x07 = behind Tigger's House
//          0x08 = Owl's House
//          0x09 = on the mountaintop
//          0x0a = behind Rabbit's House
//          0x0b = Rabbit's House
//          0x0c = by the scary cave
//          0x0d = inside the scary cave
//          0x0e = the forest grove
//          0x0f = inside the mountain cave
//          
//          In Menu:
//          0x01 = New Game / Load File
//          0x02 = Options Menu
//          0x03 = Game Menu
//          
//          In Junior Mode:
//          0x01 = Eeyore
//          0x02 = Piglet
//          0x03 = Pooh
//          0x04 = Tigger
//          
//          In Minigames:
//          0x01 = Cookie Maze #1
//          0x02 = Cookie Maze #2
//          0x03 = Catch the Honey Pot #1
//          0x04 = Catch the Honey Pot #2
//          0x05 = Follow the Line #1
//          0x06 = Follow the Line #2
//          0x07 = Find the Cookies #1
//          0x08 = Find the Cookies #2
//          0x09 = The Scare-Off
function map_id() => dword_be(0x32AA80)

// $32AA8C: 1P Character (Minigames) [32-bit BE]
//          1 = Pooh
//          2 = Piglet
//          3 = Tigger
//          4 = Roo
//          5 = Honey Pot
function minigame_p1_char() => dword_be(0x32AA8C)

// $540400: Filename [ASCII Text]
FILENAME = 0x540400

// $1526510: Pointer to Junior Mode Cutscene Info [32 bit BE]
//           +0x038 | Cutscene Filename [ASCII Text] (8 chars)
function junior_cutscene_name() => ptr(0x1526510) + 0x038

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function cutscene_ended(x) => (
	ascii_string_equals(junior_cutscene_name(), x, length=8, transform=(x)=>prev(x)) &&
	!ascii_string_equals(junior_cutscene_name(), x, length=8)
)

// --- MAIN DATA -------------------------------------------------------------------

TITLE_SCREEN = 0
CHAPTER_PIGLET = 1
CHAPTER_ROO = 2
CHAPTER_TIGGER = 3
CHAPTER_EEYORE = 4
CHAPTER_POOH = 5
MODE_MINIGAMES = 6
MODE_JUNIOR = 7
GAME_MENU = 8

MAP_POOH_HOUSE = 0x01
MAP_KANGA_HOUSE = 0x02
MAP_TIGGER_HOUSE = 0x03
MAP_PIGLET_HOUSE = 0x04
MAP_CLEARING = 0x05
MAP_WATERFALL = 0x06
MAP_BEHIND_TIGGER = 0x07
MAP_OWL_HOUSE = 0x08
MAP_MOUNTAINTOP = 0x09
MAP_BEHIND_RABBIT = 0x0a
MAP_RABBIT_HOUSE = 0x0b
MAP_OUTSIDE_SKULL_CAVE = 0x0c
MAP_INSIDE_SKULL_CAVE = 0x0d
MAP_FOREST_GROVE = 0x0e
MAP_MOUNTAIN_CAVE = 0x0f

MENU_NEWGAME_LOADFILE = 0x01
MENU_OPTIONS = 0x02
MENU_MODE_SELECT = 0x03

JUNIOR_EEYORE = 0x01
JUNIOR_PIGLET = 0x02
JUNIOR_POOH = 0x03
JUNIOR_TIGGER = 0x04

MINIGAME_COOKIE_MAZE_1 = 0x01
MINIGAME_COOKIE_MAZE_2 = 0x02
MINIGAME_CATCH_HONEYPOT_1 = 0x03
MINIGAME_CATCH_HONEYPOT_2 = 0x04
MINIGAME_FOLLOW_LINE_1 = 0x05
MINIGAME_FOLLOW_LINE_2 = 0x06
MINIGAME_FIND_THE_COOKIES_1 = 0x07
MINIGAME_FIND_THE_COOKIES_2 = 0x08
MINIGAME_SCARE_OFF = 0x09

MINIGAME_CHAR_POOH = 1
MINIGAME_CHAR_PIGLET = 2
MINIGAME_CHAR_TIGGER = 3
MINIGAME_CHAR_ROO = 4
MINIGAME_CHAR_HONEYPOT = 5

CS_EEYORE_HOUSE = "_043.anm"    // Eeyore house
CS_PIGLET_PLANT = "_081.anm"    // Piglet plant
CS_PIGLET_WATER = "_049_26."    // Piglet water
CS_PIGLET_FLOWR = "_049_1.d"    // Piglet flower
CS_TIGGER_PAINT = "_045.anm"    // Tigger paint

CHAPTERS = [
	{
		"c": CHAPTER_PIGLET,

		"progression_title": "A Perfect Birthday",
		"honey_title": "A Single Drop of Honey",
		"music_title": "If I Wasn't So Small",

		"max_honey": 60,
	},
	{
		"c": CHAPTER_ROO,

		"progression_title": "The Whoop-de-Dooper Bounce",
		"honey_title": "A Small Smackerel of Honey",
		"music_title": "Little Mr. Roo",

		"max_honey": 105,
	},
	{
		"c": CHAPTER_TIGGER,

		"progression_title": "Tiggerrific Friends",
		"honey_title": "A Few Smackerels More",
		"music_title": "The Wonderful Thing About Tiggers",

		"max_honey": 105,
	},
	{
		"c": CHAPTER_EEYORE,

		"progression_title": "Just What I Wanted",
		"honey_title": "Under the Honey Tree",
		"music_title": "Eeyore Needs His Tail",

		"max_honey": 120,
	},
	{
		"c": CHAPTER_POOH,

		"progression_title": "My Most Delicious Birthday",
		"honey_title": "Everything is Honey",
		"music_title": "A Bear of Very Little Brain",

		"max_honey": 135,
	},
]

// --- RICH PRESENCE -------------------------------------------------------------------

LocationLookup = {
	MAP_POOH_HOUSE: "in front of his house",
	MAP_KANGA_HOUSE: "in front of Kanga's house",
	MAP_TIGGER_HOUSE: "in front of Tigger's house",
	MAP_PIGLET_HOUSE: "in front of Piglet's house",
	MAP_CLEARING: "in the clearing",
	MAP_WATERFALL: "by the waterfall",
	MAP_BEHIND_TIGGER: "behind Tigger's house",
	MAP_OWL_HOUSE: "in front of Owl's house",
	MAP_MOUNTAINTOP: "atop the snowy mountain",
	MAP_BEHIND_RABBIT: "behind Rabbit's house",
	MAP_RABBIT_HOUSE: "in front of Rabbit's house",
	MAP_OUTSIDE_SKULL_CAVE: "outside a very scary cave",
	MAP_INSIDE_SKULL_CAVE: "inside a very scary cave",
	MAP_FOREST_GROVE: "in a secluded grove",
	MAP_MOUNTAIN_CAVE: "in a frozen mountain cave",
}

JuniorLookup = {
	JUNIOR_EEYORE: "Eeyore",
	JUNIOR_PIGLET: "Piglet",
	JUNIOR_POOH: "Pooh",
	JUNIOR_TIGGER: "Tigger",
}

MinigameLookup = {
	MINIGAME_COOKIE_MAZE_1: "Cookie Maze #1",
	MINIGAME_COOKIE_MAZE_2: "Cookie Maze #2",
	MINIGAME_CATCH_HONEYPOT_1: "Catch the Honey Pot #1",
	MINIGAME_CATCH_HONEYPOT_2: "Catch the Honey Pot #2",
	MINIGAME_FOLLOW_LINE_1: "Follow the Line #1",
	MINIGAME_FOLLOW_LINE_2: "Follow the Line #2",
	MINIGAME_FIND_THE_COOKIES_1: "Find the Cookies #1",
	MINIGAME_FIND_THE_COOKIES_2: "Find the Cookies #2",
	MINIGAME_SCARE_OFF: "Scare-Off",
}

ChapterLookup = {
	CHAPTER_PIGLET: "Piglet",
	CHAPTER_ROO: "Roo",
	CHAPTER_TIGGER: "Tigger",
	CHAPTER_EEYORE: "Eeyore",
	CHAPTER_POOH: "Pooh",
}

ChapterPossessiveLookup = {
	CHAPTER_PIGLET: "Piglet's",
	CHAPTER_ROO: "Roo's",
	CHAPTER_TIGGER: "Tigger's",
	CHAPTER_EEYORE: "Eeyore's",
	CHAPTER_POOH: "his",
}

MinigameCharLookup = {
	MINIGAME_CHAR_POOH: "Pooh",
	MINIGAME_CHAR_PIGLET: "Piglet",
	MINIGAME_CHAR_TIGGER: "Tigger",
	MINIGAME_CHAR_ROO: "Roo",
	MINIGAME_CHAR_HONEYPOT: "the Honey Pot",
}

LanguageLookup = {
	0: "🇬🇧",
	1: "🇫🇷",
	2: "🇪🇸",
}

rp_chapter = rich_presence_lookup("Chapter", current_chapter(), ChapterLookup, fallback=ChapterLookup[CHAPTER_POOH])
rp_chapter_pos = rich_presence_lookup("ChapterPossessive", current_chapter(), ChapterPossessiveLookup, fallback="a")
rp_location = rich_presence_lookup("Location", map_id(), LocationLookup, fallback="in the Hundred Acre Wood")
rp_room_complete = rich_presence_lookup("Checked", 0 /*room_completed(current_chapter(), map_id())*/, {1: " ✅"}, fallback="")

function rp_chapter_complete(x) => rich_presence_lookup("Complete", chapter_pooh_stamp(x), {1: "🎂"}, fallback="")
function rp_honey_cur(x) => rich_presence_value("Number_", chapter_honey_on_hand(x), "VALUE")
function rp_honey_total(x) => rich_presence_value("Number_", chapter_total_honey_collected(x), "VALUE")
function rp_honey_max(x) => rich_presence_value("Number_", chapter_total_honey_possible(x), "VALUE")

function rp_music(x) => rich_presence_value("Number_", chapter_music_notes(x), "VALUE")
function rp_music_note(x) => rich_presence_lookup("MusicNotes", chapter_music_notes(x), {3: " 🎵"}, fallback="")

rp_junior = rich_presence_lookup("JuniorChar", map_id(), JuniorLookup, fallback=JuniorLookup[JUNIOR_POOH])

rp_minigame = rich_presence_lookup("Minigame", map_id(), MinigameLookup, fallback="a minigame")
rp_minigame_char = rich_presence_lookup("MinigameChar", minigame_p1_char(), MinigameCharLookup, fallback=MinigameCharLookup[MINIGAME_CHAR_POOH])

// file loaded, game menu
rich_presence_conditional_display(current_chapter() == GAME_MENU && map_id() != MENU_NEWGAME_LOADFILE,
	"📖 Pooh is remembering some wonderful birthdays [{0}{1} 🍯{2}/{3}{4}] [{5}{6} 🍯{7}/{8}{9}] [{10}{11} 🍯{12}/{13}{14}] [{15}{16} 🍯{17}/{18}{19}] [{20}{21} 🍯{22}/{23}{24}]",
	rp_chapter_complete(1), ChapterLookup[1], rp_honey_total(1), rp_honey_max(1), rp_music_note(1),
	rp_chapter_complete(2), ChapterLookup[2], rp_honey_total(2), rp_honey_max(2), rp_music_note(2),
	rp_chapter_complete(3), ChapterLookup[3], rp_honey_total(3), rp_honey_max(3), rp_music_note(3),
	rp_chapter_complete(4), ChapterLookup[4], rp_honey_total(4), rp_honey_max(4), rp_music_note(4),
	rp_chapter_complete(5), ChapterLookup[5], rp_honey_total(5), rp_honey_max(5), rp_music_note(5)
)

// in a chapter
rich_presence_conditional_display(current_chapter() >= 1 && current_chapter() <= 5,
	"🎂 Pooh is preparing for {0} very special birthday {1}{2} · 🍯{3} [{4}/{5}] 🎵{6}",
	rp_chapter_pos, rp_location, rp_room_complete,
	rp_honey_cur(current_chapter()), rp_honey_total(current_chapter()), rp_honey_max(current_chapter()),
	rp_music(current_chapter())
)

// junior mode
rich_presence_conditional_display(current_chapter() == MODE_JUNIOR,
	"👶 {0} and the little ones are learning in Junior Mode",
	rp_junior
)

// minigames
rich_presence_conditional_display(current_chapter() == MODE_MINIGAMES,
	"🎮 Playing {0} as {1}",
	rp_minigame, rp_minigame_char
)

// no file loaded
rich_presence_display(
	"{0} Pooh is getting ready for a rumbly tumbly adventure",
	rich_presence_lookup("Language", language(), LanguageLookup, fallback=LanguageLookup[0])
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

ach_id = 455960
for ch in CHAPTERS
{
	achievement(id=ach_id,
		title=ch["progression_title"],
		description=format("Complete the story of {0}'s birthday", ChapterLookup[ch["c"]]),
		points=if_else(ch["c"] == CHAPTER_POOH, 25, 10),
		type=if_else(ch["c"] == CHAPTER_POOH, "win_condition", "progression"),
		trigger=current_chapter() == ch["c"] && prev(chapter_pooh_stamp(ch["c"])) == 0 && chapter_pooh_stamp(ch["c"]) == 1
	)
	ach_id = ach_id + 1
}

for ch in CHAPTERS
{
	achievement(id=ach_id,
		title=ch["honey_title"],
		description=format("Find all of the honey in {0}'s birthday", ChapterLookup[ch["c"]]),
		points=if_else(ch["max_honey"] >= 120, 10, 5),
		trigger=(
			// previous frame is less than the needed amount
			prev(chapter_total_honey_collected(ch["c"])) < ch["max_honey"] &&

			// now the correct amount has been reached
			measured(chapter_total_honey_collected(ch["c"]) >= ch["max_honey"], 
				when=current_chapter() == ch["c"])
		)
	)
	ach_id = ach_id + 1
}

for ch in CHAPTERS
{
	achievement(id=ach_id,
		title=ch["music_title"],
		description=format("Find all three music notes in {0}'s birthday", ChapterLookup[ch["c"]]),
		points=3,
		trigger=(
			// previous frame is less than the needed amount
			prev(chapter_music_notes(ch["c"])) < 3 &&

			// now the correct amount has been reached
			measured(chapter_music_notes(ch["c"]) >= 3, 
				when=current_chapter() == ch["c"])
		)
	)
	ach_id = ach_id + 1
}

achievement(id=455975,
	title="I'm Planting a Haycorn",
	description="In Junior Mode, as Piglet, pick a haycorn flower",
	points=2,
	trigger=current_chapter() == MODE_JUNIOR && map_id() == JUNIOR_PIGLET && trigger_when(cutscene_ended(CS_PIGLET_FLOWR))
)

achievement(id=455976,
	title="The Worstest Kind of Tigger",
	description="In Junior Mode, as Tigger, get a new paint job",
	points=2,
	trigger=current_chapter() == MODE_JUNIOR && map_id() == JUNIOR_TIGGER && trigger_when(cutscene_ended(CS_TIGGER_PAINT))
)

achievement(id=455977,
	title="Not Much of a House, Just Right for Not Much of a Donkey",
	description="In Junior Mode, remodel Eeyore's house",
	points=1,
	trigger=current_chapter() == MODE_JUNIOR && map_id() == JUNIOR_EEYORE && trigger_when(cutscene_ended(CS_EEYORE_HOUSE))
)

// --- LEADERBOARDS -------------------------------------------------------------------
