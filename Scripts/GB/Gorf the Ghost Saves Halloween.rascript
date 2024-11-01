// ~Homebrew~ Gorf the Ghost Saves Halloween
// #ID = 31198

// --- HELPERS -------------------------------------------------------------------

NULL = 0
function if_else(p, t, f) { if (p) { return t } else return f }
id = (x) => x
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
function bitx(i, addr) => bit(i % 8, addr + i / 8)

SECONDS = 60
MINUTES = 60 * SECONDS

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

// $C6AE: Current Area [8 bit]
//        0x00 = (Dashrando presents)
//        0x01 = (Title screen)
//        0x02 = Your Street
//        0x03 = North Street
//        0x04 = Mart
//        0x05 = Forgotten Forest
//        0x06 = West Street
//        0x07 = Sewer (Mat's hiding place)
//        0x08 = Joy's House
//        0x09 = Sewer (Miranda's hiding place)
//        0x0a = Pumpkin House
//        0x0b = Tote's House
//        0x0c = Gorf's House & Tweak (cat)
//        0x0d = Sam's House
//        0x0e = Underworld (graveyard key)
//        0x0f = Lash's House
//        0x10 = Zukes' House & Reilly (dog)
//        0x11 = Winston's House
//        0x12 = (Credits 1)
//        0x13 = Graveyard & skeleton fight
//        0x14 = Victory scene
//        0x15 = (Credits 2)
//        0x16 = (The End)
function loc() => byte(0x00C6AE)

// $C95A: Script Info [16 bit]
//        seems to relate to actors doing dialogue or emotes
//        
//        0x5252 = Street - Neighbor 1
//        0x55a1 = N Street - Car at Mart
//        0x5692 = N Street - Mart Dumpster
//        0x5c4f = W Street - Rob's window -> 0x5c57
//        0x5efd = Joy - "Loretta" painting -> 0x5f05
//        0x63b4 = Atlas & Totes playing Fortnite
//        0x64f2 = Home - Cat Meow
//        0x64fa = Home - Cat Love
//        0x662e = Sam - TV "Booty Bananza Vol 3" -> 0x6636
//        0x67bb = Lash - Sketchbook -> 0x67c3
//        0x67b0 = Lash - TV
//        0x68fb = Zukes - Dog Woof
//        0x6903 = Zukes - Dog Love
//        0x6a59 = Winston - Life is Strange
function script_info() => word(0x00C95A)

function start_talk(loc, x) => loc() == loc && prev(script_info()) != x && script_info() == x
function end_talk(loc, x) => loc() == loc && prev(script_info()) == x && script_info() != x

// $CC15: Title Screen Menu Selection [8 bit]
//        0 = New Game
//        1 = Continue
function title_screen_menu_selection() => byte(0x00CC15)

// $CCE0: (Item) Candy Bucket [8 bit]
//        0 = not found, 1 = found
function item_bucket() => byte(0x00CCE0)

// $CCE1: (Item) Candy Corn [8 bit]
//        0 = not found, 1 = found
function item_candy() => byte(0x00CCE1)

// $CCE2: (Item) Cash [8 bit]
//        0 = not found, 1 = found
function item_cash() => byte(0x00CCE2)

// $CCE3: (Item) Beer [8 bit]
//        0 = not found, 1 = found
function item_beer() => byte(0x00CCE3)

// $CCE4: (Item) Human Skull [8 bit]
//        0 = not found, 1 = found
function item_skull() => byte(0x00CCE4)

// $CCE5: (Item) Goat Blood [8 bit]
//        0 = not found, 1 = found
function item_gblood() => byte(0x00CCE5)

// $CCE6: (Item) Graveyard Key [8 bit]
//        0 = not found, 1 = found
function item_gravekey() => byte(0x00CCE6)

// $CCE7: (Item) Spooky Sword [8 bit]
//        0 = not found, 1 = found
function item_sword() => byte(0x00CCE7)

// $CCEB: Gorf Health (Graveyard) [8 bit]
//        max 4, dead when 0
function gorf_hp() => byte(0x00CCEB)

// $CCEC: Skeleton Health (Graveyard) [8 bit]
//        max 10, dead when 0
function skele_hp() => byte(0x00CCEC)

// --- MAIN DATA -------------------------------------------------------------------

LOC_TITLE_DEV = 0x00
LOC_TITLE_SCREEN = 0x01
LOC_YOUR_STREET = 0x02
LOC_NORTH_STREET = 0x03
LOC_MART = 0x04
LOC_FOREST = 0x05
LOC_WEST_STREET = 0x06
LOC_SEWER_1 = 0x07
LOC_HOUSE_JOY = 0x08
LOC_SEWER_2 = 0x09
LOC_HOUSE_PUMPKIN = 0x0a
LOC_HOUSE_TOTES = 0x0b
LOC_HOUSE_GORF = 0x0c
LOC_HOUSE_SAM = 0x0d
LOC_UNDERWORLD = 0x0e
LOC_HOUSE_LASH = 0x0f
LOC_HOUSE_ZUKES = 0x10
LOC_HOUSE_WINSTON = 0x11
LOC_CREDITS_1 = 0x12
LOC_GRAVEYARD = 0x13
LOC_VICTORY = 0x14
LOC_CREDITS_2 = 0x15
LOC_THE_END = 0x16
LOC_MAP = 0x17

PRE_GAME = [LOC_TITLE_DEV, LOC_TITLE_SCREEN]
POST_GAME = [LOC_VICTORY, LOC_CREDITS_1, LOC_CREDITS_2, LOC_THE_END]

OBJECTIVES = [
	item_bucket(),
	item_candy(),
	item_cash(),
	item_beer(),
	item_skull(),
	item_gblood(),
	item_gravekey(),
	item_sword(),
]

PETS = [
	start_talk(LOC_HOUSE_GORF, 0x64fa),  // Tweak
	start_talk(LOC_HOUSE_ZUKES, 0x6903), // Reilly
]

GAMES = [
	end_talk(LOC_HOUSE_TOTES, 0x63b4), // Fortnite
	end_talk(LOC_HOUSE_WINSTON, 0x6a59), // Life is Strange
]

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function on_title_screen() => any_of(PRE_GAME, x => loc() == x)

function win_the_game() => prev(loc()) == LOC_GRAVEYARD && loc() == LOC_VICTORY

function new_game() => (
	prev(loc()) == LOC_TITLE_SCREEN && loc() > LOC_TITLE_SCREEN && 
	title_screen_menu_selection() == 0 &&
	all_of(OBJECTIVES, x => x == 0)
)

function is_new_game() => once(new_game() && never(on_title_screen()))

function game_time(x) => tally(x, is_new_game() && loc() > LOC_TITLE_SCREEN && loc() != LOC_MAP && script_info() == 0)

// --- RICH PRESENCE -------------------------------------------------------------------

Location = {
	LOC_YOUR_STREET: "South Street",
	LOC_NORTH_STREET: "North Street",
	LOC_WEST_STREET: "West Street",

	LOC_FOREST: "Forgotten Forest",
	LOC_MART: "Food Mart",
	LOC_UNDERWORLD: "uNdErWorLD",
	LOC_GRAVEYARD: "Graveyard",

	LOC_SEWER_1: "Sewer",
	LOC_SEWER_2: "Sewer",

	LOC_HOUSE_PUMPKIN: "Pumpkin House",
	LOC_HOUSE_JOY: "Joy's House",
	LOC_HOUSE_TOTES: "Totes & Atlas's House",
	LOC_HOUSE_GORF: "Gorf's House",
	LOC_HOUSE_SAM: "Sam's House",
	LOC_HOUSE_LASH: "Lash's House",
	LOC_HOUSE_ZUKES: "Zukes' House",
	LOC_HOUSE_WINSTON: "Winston's House",

	LOC_MAP: "Checking the map 🔎",
}

// 💀👻🍬📝⏱️📍

rp_location = rich_presence_lookup("Location", loc(), Location, fallback="Town")
rp_objective_count = rich_presence_value("_Number", sum_of(OBJECTIVES, x => x / x), "VALUE")
rp_game_time = rich_presence_value("_Frames", measured(game_time(0)), "FRAMES")

rp_gorf_hp = rich_presence_value("_Number", 100 * gorf_hp() / 4, "VALUE")
rp_skel_hp = rich_presence_value("_Number", 100 * skele_hp() / 10, "VALUE")

rich_presence_conditional_display(any_of(PRE_GAME, x => loc() == x),
	"👻 Gorf the Ghost is ready to save Halloween"
)

rich_presence_conditional_display(any_of(POST_GAME, x => loc() == x),
	"👻 Gorf the Ghost has saved Halloween! 🍬🍬🍬"
)

rich_presence_conditional_display(loc() == LOC_GRAVEYARD && is_new_game(),
	"🗺️ " + Location[LOC_GRAVEYARD] + " | 👻 {0}% vs 💀 {1}% | ⏱️ {2}",
	rp_gorf_hp, rp_skel_hp, rp_game_time
)

rich_presence_conditional_display(loc() == LOC_GRAVEYARD,
	"🗺️ " + Location[LOC_GRAVEYARD] + " | 👻 {0}% vs 💀 {1}%",
	rp_gorf_hp, rp_skel_hp
)

rich_presence_conditional_display(is_new_game(),
	"🗺️ {0} | 📝 {1}/" + length(OBJECTIVES) + " objectives completed | ⏱️ {2}",
	rp_location, rp_objective_count, rp_game_time
)

rich_presence_display(
	"🗺️ {0} | 📝 {1}/" + length(OBJECTIVES) + " objectives completed",
	rp_location, rp_objective_count
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(
	title="Mr. Bucket",
	description="You found Atlas' lost candy bucket. Now who's giving out the full size candy bars?",
	type="progression",
	points=3,
	trigger=loc() == LOC_WEST_STREET && item_bucket() > prev(item_bucket())
)

achievement(
	title="A Treatise in Defense of Candy Corn",
	description="It takes a refined palate to appreciate the complex and nuanced flavor of candy corn",
	type="progression",
	points=3,
	trigger=loc() == LOC_YOUR_STREET && item_candy() > prev(item_candy())
)

achievement(
	title="Money Can Be Exchanged for Goods and Services",
	description="Trade candy corn for cash, which Miranda could have done at the store",
	type="progression",
	points=3,
	trigger=loc() == LOC_SEWER_2 && item_cash() > prev(item_cash())
)

achievement(
	title="Shop Smart, Shop S-Mart",
	description="Buy some beer from the Mart",
	type="progression",
	points=3,
	trigger=loc() == LOC_MART && item_beer() > prev(item_beer())
)

achievement(
	title="Alas Poor Yorick! I Knew Him, Horatio",
	description="A fellow of infinite jest, of most excellent fancy",
	type="progression",
	points=3,
	trigger=loc() == LOC_WEST_STREET && item_skull() > prev(item_skull())
)

achievement(
	title="Was This Goat Blood Ethically-Sourced?",
	description="When the cops ask you where you got the goat blood, probably don't mention you traded it for a human skull",
	type="progression",
	points=3,
	trigger=loc() == LOC_FOREST && item_gblood() > prev(item_gblood())
)

achievement(
	title="What Kind of Key Do You Find in the uNdErWorLD? A Spoo-key!",
	description="bUt rEaLLy, wHy aRE wE tALkInG LikE tHIs?",
	type="progression",
	points=3,
	trigger=(loc() == LOC_UNDERWORLD || loc() == LOC_NORTH_STREET) && 
		item_gravekey() > prev(item_gravekey())
)

achievement(
	title="It's Dangerous to Go Alone! Take This",
	description="The old man in the pumpkin house actually had a purpose??",
	type="progression",
	points=3,
	trigger=loc() == LOC_HOUSE_PUMPKIN && item_sword() > prev(item_sword())
)

achievement(
	title="Gorf the Ghost Saves Halloween",
	description="Defeat the evil skeleton terrorizing the graveyard",
	type="win_condition",
	points=10,
	trigger=win_the_game() && item_gravekey() == 1 && item_sword() == 1
)

achievement(
	title="The Sword of Damocles Is Hanging over My Head",
	description="Defeat the evil skeleton in the graveyard damageless",
	points=5,
	trigger=loc() == LOC_GRAVEYARD && gorf_hp() == 4 && 
		trigger_when(prev(skele_hp()) == 1 && skele_hp() == 0)
)

SPEED_THRESHOLD = 4
achievement(
	title="Before the Streetlights Come On",
	description=format("Starting from a New Game, save Halloween in less than {0} minutes", SPEED_THRESHOLD),
	points=10,
	trigger=is_new_game() && never(game_time(SPEED_THRESHOLD * MINUTES)) && trigger_when(win_the_game())
)

achievement(
	title="A Ghost's Best Friend",
	description="Meet and greet all of the pets in town",
	points=2,
	trigger=measured(tally(length(PETS), array_map(PETS, x => once(x)))) &&
		never(loc() == LOC_TITLE_SCREEN)
)

achievement(
	title="Her Body is a Work of Art",
	description="Introduce yourself to Loretta",
	points=1,
	trigger=end_talk(LOC_HOUSE_JOY, 0x5f05)
)

achievement(
	title="Gumshoe Gorf, Private Eye",
	description="Discover Sam's salacious secret. That's what I get for snooping around!",
	points=1,
	trigger=end_talk(LOC_HOUSE_SAM, 0x6636)
)

achievement(
	title="Sponsored by Raid Shadow Legends #ad",
	description="Check out what other video games the townspeople have been playing",
	points=2,
	trigger=measured(tally(length(GAMES), array_map(GAMES, x => once(x)))) &&
		never(loc() == LOC_TITLE_SCREEN)
)

achievement(
	title="Peeping Tom",
	description="Peek in the window of a neighbor's house. Where was *my* invitation?",
	points=2,
	trigger=end_talk(LOC_WEST_STREET, 0x5c57)
)

achievement(
	title="Dumpster Diving",
	description="Go trick-or-treating in a rather unlikely place",
	points=1,
	trigger=end_talk(LOC_NORTH_STREET, 0x5692)
)

// --- LEADERBOARDS -------------------------------------------------------------------

leaderboard(
	title="Saving Halloween in a Hurry",
	description="Starting from a New Game, save Halloween as quickly as possible",

	start=new_game(),
	cancel=loc() == LOC_TITLE_SCREEN,
	submit=win_the_game(),
	
	value=measured(game_time(0)),
	format="FRAMES",
	lower_is_better=true
)