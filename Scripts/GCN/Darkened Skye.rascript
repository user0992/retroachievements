// Darkened Skye
// #ID = 25437

// --- HELPERS -------------------------------------------------------------------

NULL = 0
function if_else(p, t, f) { if (p) { return t } else return f }
idfunc = (x) => x
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

function ptr(addr) => dword_be(addr) & 0x1FFFFFFF

// --- MEMORY -------------------------------------------------------------------

// $16D97C: Menu Popup Visible [32 bit BE]
//          0 = No, 1 = Yes
function menu_popup_visible() => dword_be(0x16D97C)

// $16D984: Pointer to Popup Text [32 bit BE]
//          0x8013d248 = Loading confirmation
LOADING_CONFIRMATION = 0x8013d248
function menu_popup_text() => dword_be(0x16D984)

// $1D5630: Loading screen active [32 bit BE]
//          0 = not loading, 1 = loading
function loading_screen() => dword_be(0x1D5630)

// $16F010: Selected Item Index [32 bit BE]
//          0xffffffff = <None>
//          Index into item table
function selected_item_index() => dword_be(0x16F010)
function has_selected_item() => selected_item_index() != 0xFFFFFFFF

// $16F034: Prepared Spell [32 bit BE]
//          0xffffffff = <None>
//          Index into spell list
function prepared_spell_index() => dword_be(0x16F034)
function has_prepared_spell() => prepared_spell_index() != 0xFFFFFFFF

// $16F038: Spell Menu Cursor Position [32 bit BE]
//          Same index as 0x16f034
function spell_menu_cursor_position() => dword_be(0x16F038)

// $16F08C: Boss Health Bar Shown [32 bit BE]
//          0 = No, 1 = Yes
function boss_health_bar_shown() => dword_be(0x16F08C) == 1
function showing_boss_health() => prev(dword_be(0x16F08C)) == 0 && boss_health_bar_shown()

// $16F090: Boss Health Value [Float BE]
//          ranges from 0 to 1
function boss_health() => float_be(0x16F090)
function boss_fight_starting() => prev(dword_be(0x16F08C)) == 0 && dword_be(0x16F08C) == 1 && boss_health() == 1.0

// $16F098: Started Game? [32 bit BE]
//          0 = Intro, Title Screen, Main Menu
//          1 = after New Game or Load
function started_game() => dword_be(0x16F098) == 1

// $16F0BC: Pause Menu Tab [32 bit BE]
//          0 = <Unpaused>
//          1 = Spell List
//          2 = Item Collection
//          3 = Quests, Notes, Quotes
//          4 = Continue, New Game, etc
//          5 = File Save/Load Screen
//          6 = Options
function pause_menu_tab() => dword_be(0x16F0BC)
function unpaused() => pause_menu_tab() == 0

// jumping from File Load to Unpaused is a sign of loading a save game
function loading_file() => prev(pause_menu_tab()) == 5 && pause_menu_tab() == 0

// $16F10C: Number of Held Items [32 bit BE]
function num_items() => dword_be(0x16F10C)

// $16F11C: Pointer to Held Item Table [32 bit BE]
//          .. Held Item Table (36 bytes x # of items)
//          .. Struct for each item, indexed based on the item menu:
//          .. +8 = Pointer to table of metadata [32 bit BE] (20 byte entries)
//          .... +0 = Internal Identifier pointer [32 bit BE] -> ASCII Text
//          .... +4 = Display Name pointer [32 bit BE] -> ASCII Text
//          .... +8 = Item Description pointer [32 bit BE] -> ASCII Text
//          .... +12 = Flags?
//          .... +16 = Icon Index [32 bit BE], 0xffffffff if not loaded
//          .. +12 = Flags?
//          .. +24 = Current Item Count [32 bit BE]
//          .. +28 = Max Item Count [32 bit BE], 0 if unlimited
PTR_TO_ITEM_TABLE = 0x16F11C
function item_table() => ptr(PTR_TO_ITEM_TABLE)
function item_table() => 0x37C640 // tbyte_be(PTR_TO_ITEM_TABLE + 1)

function item_struct(i) => i * 36 + item_table()
function item_id(i) => dword_be(tbyte_be(item_struct(i) + 9))
function item_count(i) => dword_be(item_struct(i) + 24)

function holding_item(x) => has_selected_item() && item_id(selected_item_index()) == x

// largest number of item slots to check
MAX_ITEM_COUNT = 24

// list of item lookups
ITEM_GEMSTONES = 0x8038cbb1
ITEM_LIFE_POT = 0x8038d931
ITEM_MANA_POT = 0x8038e087
ITEM_FISH = 0x8038c8bb

ITEM_WOOD_TOYS = [
    0x8038daeb, // toy boat
    0x8038dbba, // wooden doll
    0x8038db72, // toy wagon
    0x8038db34, // toy monster
]

// $17DDA8: Diminish Timer (seconds) [Float BE]
//          - stays at ~6, when cast Diminish, resets to 0 and counts up
//          - once timer reaches 5, starts regrowing up to ~6 again
//          - if cannot grow (low ceiling), timer stays under 5
function diminish_timer() => float_be(0x17DDA8)

// $17F128: Number of Available Spells [32 bit BE]
function num_spells() => dword_be(0x17F128)

// $17F13C: Total Number of Skittles® [32 bit BE]
function num_skittles() => dword_be(0x17F13C)

// $17F150: Unallocated Skittles® [32 bit BE]
function num_skittles_unallocated() => dword_be(0x17F150)

// $19A810: Actual Current Health [Float BE]
//          Max = 100.0
//          Dying sets this to -10.0
function current_health() => float_be(0x19A810)
function is_dead() => current_health() <= 0.0
function lose_health() => current_health() < prev(current_health())

// $19A888: Pointer to Object Under Feet [32 bit BE]
//          0 = Not Grounded
function ground_object() => dword_be(0x19A888)

// $19ACD0: Camera Lock [32 bit BE]
//          0 = Free Cam, 1 = Camera follows Skye
function camera_lock() => dword_be(0x19ACD0)

// $19ADBC: Level Number [32 bit BE], separated into main and part
// $19ADBC: Level Number - Main [16 bit BE]
// $19ADBE: Level Number - Part [16 bit BE]
function level_number() => dword_be(0x19ADBC)
function level_number_main() => word_be(0x19ADBC)
function level_number_part() => word_be(0x19ADBE)


function STAGE(main, part) => main * 0x10000 + part

//          01,01 = Lynlora 1
//          01,02 = Lynlora 1 Hut Cutscene
//          01,03 = Lynlora 1 Post-Hut
//          02,01 = Ogmire Archipelago
//          03,01 = Tikniki Swamp
//          04,01 = Ogmire City
//          04,02 = Ogmire Dungeons
//          04,03 = Prison Tower
//          05,01 = Lynlora 2
//          05,02 = Lynlora 2 Hut Cutscene
//          05,03 = Lynlora 2 Post-Hut
//          05,04 = Pirates' Sky Camp
//          05,05 = Lynlora 2 back from camp
//          05,06 = Lynlora 2 Hut Cutscene again
//          06,01 = Zen'jai Hills 1
//          06,02 = Zen'jai Hills 2
//          07,01 = Dragon Village, Ice Heart
//          07,02 = Dragon Village, between
//          07,03 = Dragon Village, Fire Heart
//          07,04 = Dragon Village, Black Heart
//          08,01 = Warlord's Palace Intro Cutscene
//          08,02 = Warlord's Palace 1, Assembling Swordsman
//          08,03 = Warlord's Palace 2
//          08,04 = Warlord's Palace Exit Cutscene
//          09,01 = Lynlora 3
//          09,02 = Lynlora 3 Hut Cutscene
//          09,03 = Lynlora 3 Trade Quest
//          09,04 = Zogle Gem Mines - x/50 rare gemstones
//          09,05 = Lynlora 3 Hut Cutscene again
//          0a,01 = Stoneheath Circles
//          0a,02 = Post-Stoneheath Cutscene
//          0b,01 = Goblin Prison
//          0b,02 = Goblin Laboratory
//          0b,03 = Goblin Lair
//          0b,04 = Goblin Workshop
//          0b,05 = Post-Goblin Cutscene
//          0c,01 = The Bone Lands
//          0d,01 = Lynlora 4
//          0d,02 = Lynlora 4 Hut Cutscene
//          0d,03 = Lynlora 4 Post-Hut
//          0d,04 = Riding da Boat Cutscene
//          0d,05 = Twell Country
//          0d,06 = Lynlora 4 Hut Cutscene again
//          0e,01 = Gargoyle Cemetery (PANTS)
//          0e,02 = Gargoyle Catacombs 1 (BREAD)
//          0e,03 = Gargoyle Catacombs 2 (LAGER)
//          0e,04 = Return to Cemetery
//          0e,05 = Gargoyle Catacombs 3 (BLIND)
//          0e,06 = Gargoyle Catacombs 4 vs Dracula
//          0f,01 = Cathedral Library
//          0f,02 = Cathedral
//          0f,03 = The Bell Tower
//          10,01 = Necroth's Realm
//          10,02 = The Dark Prism
//          10,03 = Necroth's Lair

// $19B6D4: Cutscene Active? [32 bit BE]
//          0 = no, 1 = yes
function _cutscene_active() => dword_be(0x19B6D4)
function cutscene_active() => _cutscene_active() == 1

// $19B6F8: Cutscene Timer [Float BE]
//          counts up from 0
function cutscene_timer() => float_be(0x19B6F8)

// $19B6A8: Cutscene ID Major [32 bit BE]
// $19B6AC: Cutscene ID Minor [32 bit BE]
// $19B6B0: Cutscene ID Sub [32 bit BE], usually 0xffffffff (-1)
function cutscene_id_major() => dword_be(0x19B6A8)
function cutscene_id_minor() => dword_be(0x19B6AC)
function cutscene_id_sub() => dword_be(0x19B6B0)

// 07, 05 -> ice heart defeat
// 07, 1B, 00 -> fire heart defeat
// 08, 04 -> assembled swordsman defeat
// 09, 16 -> E to E flat
function cutscene_playing(a, b, c=0xFFFFFFFF) =>
(
    cutscene_active() && 
    cutscene_id_major() == a && 
    cutscene_id_minor() == b && 
    cutscene_id_sub() == c
)

function cutscene_playing_from_params(x) => cutscene_playing(x[0], x[1], x[2])

function cutscene_ended(a, b, c=0xFFFFFFFF) =>
(
    prev(_cutscene_active()) == 1 &&
    prev(cutscene_id_major()) == a && 
    prev(cutscene_id_minor()) == b && 
    prev(cutscene_id_sub()) == c &&
    !cutscene_active() 
)

// $1B95DC: Pointer to Filename for Loaded Movie [32 bit BE]
//          0x80159824 - intro (6355 frames)
//          0x801597b8 - outro (3534 frames)
//          0x801597d0 - credits (4307 frames)
//          0x801598d8 - simon & schuster logo
//          0x801598f0 - boston animation logo
function loaded_movie() => dword_be(0x1B95DC)

// $1A1968: Movie Progress (in frames) [32 bit BE]
function movie_timer() => dword_be(0x1A1968)

// $1D4C88: [Cheat] God Mode? [32 bit BE]
function god_mode_enabled() => dword_be(0x1D4C88) == 1

// $1D5470: Current Mana Meter [Float BE] (Calculated)
//          Max = 100.0
function current_mana() => float_be(0x1D5470)

// $1D547C: Item Menu Cursor Position [32 bit BE]
function item_menu_cursor_position() => dword_be(0x1D547C)

// $19A8C8: Pointer to Actor/Object Table [32 bit BE]
//          .. array of 32 bit BE pointers to objects
//          .... +0 = Object Name [ASCII Text] (16 bytes)
//          .... +16 = X Position [Float BE]
//          .... +20 = Y Position [Float BE]
//          .... +24 = Z Position [Float BE]
//          .... +148 = Param* [32 bit BE]

//          *Skulls:
//          0x00-0x18 = letters 
//          1: indices 26->22
//          2: indices 13->9
//          3: indices 9->13
//          4: indices 11->7
OBJECT_TABLE_POINTER = 0x19A8C8
function get_object_ptr(i) => tbyte_be(i * 4 + 1 + tbyte_be(OBJECT_TABLE_POINTER + 1))
function get_object_param(i) => dword_be(get_object_ptr(i) + 148)

SKULL_INDICES = {
    STAGE(0x0e, 0x01): [26, 25, 24, 23, 22],
    STAGE(0x0e, 0x02): [13, 12, 11, 10,  9],
    STAGE(0x0e, 0x03): [ 9, 10, 11, 12, 13],
    STAGE(0x0e, 0x05): [11, 10,  9,  8,  7],
}
function get_skull(level, i) => get_object_param(SKULL_INDICES[level][i])

// $1D5530: Pointer to Main Actor (Skye) Object [32 bit BE]
//          .. +0 = Object Name [ASCII Text, 16 characters]
//          .. +16 = X Position [Float BE]
//          .. +20 = Y Position [Float BE]
//          .. +24 = Z Position [Float BE]
//          .. +30 = Feet Rotation? [16 bit BE]
//          .. +40 = X Delta [Float BE]
//          .. +44 = Y Delta [Float BE]
//          .. +48 = Z Delta [Float BE]
//          .. +84 = Model Name [ASCII Text] (outfit info)
function skye_ptr() => word_be(0x1D5530) & 0xFFFFFF

// $365160: Prepared Spell Table (128 bytes x # of spells)
//          Struct for each spell, indexed based on the spell menu:
//          +0 = Icon Index [32 bit BE]
//          +4 = Unknown pointer
//          +8 = Spell Name [ASCII Text] (64 characters)
//          +72 = Number of lines of text [8 bit]
//          followed by [8 bit x N] offsets into spell name
//          +84 = Number of Skittles® slots [8 bit]
//          +88 = Indices into Skittles® Lookup Table [32 bit x N]
//          for which Skittles® currently in slot
//          0xffffffff = Empty Slot
//          
//          Icons:
//          0x00 = True Sight
//          0x01 = Awaken Stone
//          0x02 = Diminish
//          0x03 = Prismatic Pulse
//          0x04 = Firewalk
//          0x05 = Lightning
//          0x06 = Strength Sap
//          0x07 = Pyro Pulse
//          0x08 = Wind Glide
//          0x09 = Shadow Vision
//          0x0a = Polar Pulse
//          0x0b = Cleanse Evil
//          0x0c = Affliction
//          0x0d = Madness
//          0x0e = Create Wizard
//          0x0f = Heart of the Rainbow
//          0x10 = Impede
//          0x11 = Magnify Magic
//          0x12 = Psychic Blast
//          0x13 = Spell Shield
//          0x14 = Ring of Rime
//          0x15 = Universal Smite
//          0x16 = Veil
SPELL_TABLE = 0x365160
function current_spell() => dword_be(prepared_spell_index() * 128 + SPELL_TABLE)
function is_current_spell(i) => has_prepared_spell() && current_spell() == i

SPELL_TRUE_SIGHT = 0x00
SPELL_AWAKEN_STONE = 0x01
SPELL_DIMINISH = 0x02
SPELL_PRISMATIC_PULSE = 0x03
SPELL_FIREWALK = 0x04
SPELL_LIGHTNING = 0x05
SPELL_STRENGTH_SAP = 0x06
SPELL_PYRO_PULSE = 0x07
SPELL_WIND_GLIDE = 0x08
SPELL_SHADOW_VISION = 0x09
SPELL_POLAR_PULSE = 0x0a
SPELL_CLEANSE_EVIL = 0x0b
SPELL_AFFLICTION = 0x0c
SPELL_MADNESS = 0x0d
SPELL_CREATE_WIZARD = 0x0e
SPELL_HEART_OF_THE_RAINBOW = 0x0f
SPELL_IMPEDE = 0x10
SPELL_MAGNIFY_MAGIC = 0x11
SPELL_PSYCHIC_BLAST = 0x12
SPELL_SPELL_SHIELD = 0x13
SPELL_RING_OF_RIME = 0x14
SPELL_UNIVERSAL_SMITE = 0x15
SPELL_VEIL = 0x16

// $365D80: Skittles® Lookup Table - N x 12-byte structs
//          Size of table located at 0x0017f13c
//          
//          +0 = Color [32 bit BE]
//          +4 = Charge [Float BE] (Max = 1.0)
//          +8 = Slotted Spell [32 bit BE] (0xffffffff = Unallocated)
SKITTLES_TABLE = 0x365D80
function skittle_color(i) => dword_be(i * 12 + SKITTLES_TABLE + 0)
function skittle_charge(i) => float_be(i * 12 + SKITTLES_TABLE + 4)
function skittle_spell(i) => dword_be(i * 12 + SKITTLES_TABLE + 8)

// --- AUX FUNCTIONS  -------------------------------------------------------------------

function cast_spell(spell)
{
    // should only need to check the charge of the first slotted Skittles®
    charge = skittle_charge(dword_be(prepared_spell_index() * 128 + SPELL_TABLE + 88))
    return is_current_spell(spell) && prepared_spell_index() == prev(prepared_spell_index()) && charge < prev(charge)
}

function cast_any_spell()
{
    // should only need to check the charge of the first slotted Skittles®
    charge = skittle_charge(dword_be(prepared_spell_index() * 128 + SPELL_TABLE + 88))
    return has_prepared_spell() && prepared_spell_index() == prev(prepared_spell_index()) && charge < prev(charge)
}

// return true if the item id is held and the predicate is true
// @param pred: func(i) for additional check for that 
function check_inventory(id, pred=((x) => always_true()))
{
    trigger = always_false()
    for i in range(0, MAX_ITEM_COUNT-1)
    {
        trigger = trigger || (i < num_items() && item_id(i) == id && pred(i))
    }
    return trigger
}

// FIXME: does not work due to some of the timings of these values changing
function used_item(id) => (
    (
        // either the item count goes down
        (prev(has_selected_item()) && prev(item_id(selected_item_index())) == id &&
            prev(item_count(selected_item_index())) > 1 && 
            item_count(selected_item_index()) < prev(item_count(selected_item_index())) && 
            holding_item(id)) ||

        // or the item is no longer present in the inventory
        (prev(has_selected_item()) && prev(item_id(selected_item_index())) == id &&
            prev(item_count(selected_item_index())) == 1 && num_items() == prev(num_items()) - 1 && !holding_item(id))
    )
)

// --- MAIN DATA -------------------------------------------------------------------

STAGE_CLEARS = [
    {
        "id": 442877,
        "src": STAGE(0x01, 0x03),
        "dst": STAGE(0x02, 0x01),
        "title": "The Adventure Begins", 
        "desc": "Use True Sight to find the way to leave Lynlora with the orange prism",
        "pts": 5,
    },
    {
        "id": 442878,
        "src": STAGE(0x02, 0x01), 
        "dst": STAGE(0x03, 0x01), 
        "title": "The Keepers of the Rainbow", 
        "desc": "Find Merlin in Ogmire Archipelago and learn about the Keepers of the Rainbow",
        "pts": 5,
    },
    {
        "id": 442879,
        "src": STAGE(0x03, 0x01), 
        "dst": STAGE(0x04, 0x01), 
        "title": "Getting out of Tikniki Swamp", 
        "desc": "Once you get used to the smell, it's actually quite lovely",
        "pts": 10,
    },
    {
        "id": 442880,
        "src": STAGE(0x04, 0x01), 
        "dst": STAGE(0x04, 0x02), 
        "title": "The City Beyond the Sea", 
        "desc": "Search Ogmire City for clues to the whereabouts of the yellow prism",
        "pts": 5,
    },
    {
        "id": 442881,
        "src": STAGE(0x04, 0x02), 
        "dst": STAGE(0x04, 0x03), 
        "title": "The Ogmire Jailbreak", 
        "desc": "Escape from the Ogmire Dungeons",
        "pts": 5,
    },
    {
        "id": 442882,
        "src": STAGE(0x04, 0x02), 
        "dst": STAGE(0x04, 0x03), 
        "title": "Bloodsquall's Quick Escape", 
        "desc": "Help Bloodsquall escape the Prison Tower with the yellow prism in-hand",
        "pts": 10,
    },
    {
        "id": 442883,
        "src": STAGE(0x05, 0x03), 
        "dst": STAGE(0x05, 0x04), 
        "title": "One Toot on This Whistle...", 
        "desc": "Get whisked away to the Pirates' Sky Camp",
        "pts": 5,
    },
    {
        "id": 442884,
        "src": STAGE(0x05, 0x04), 
        "dst": STAGE(0x05, 0x05), 
        "title": "Crafting a MacGuffin", 
        "desc": "Reach Yancey's ship in the sky and ask about the green prism",
        "pts": 10,
    },
    {
        "id": 442885,
        "src": STAGE(0x06, 0x02), 
        "dst": STAGE(0x07, 0x01), 
        "title": "The Hills Have Zen'jais", 
        "desc": "Escape the Zen'jai Hills with Dorian",
        "pts": 5,
    },
    {
        "id": 442886,
        "src": STAGE(0x07, 0x04), 
        "dst": STAGE(0x08, 0x01), 
        "title": "How to Train Your Dragon", 
        "desc": "Hitch a ride on Black Heart's back-- destination: the dark warlord's palace",
        "pts": 10,
    },
    {
        "id": 442887,
        "src": STAGE(0x08, 0x02), 
        "dst": STAGE(0x08, 0x03), 
        "title": "Some Assembly Required", 
        "desc": "Assemble the pieces of General Quang's secret weapon",
        "pts": 10,
    },
    {
        "id": 442888,
        "src": STAGE(0x08, 0x04), 
        "dst": STAGE(0x09, 0x01), 
        "title": "Harmonious Living", 
        "desc": "Bring together the five birds of harmony and leave Zen'jai",
        "pts": 10,
    },
    {
        "id": 442889,
        "src": STAGE(0x09, 0x03), 
        "dst": STAGE(0x09, 0x04), 
        "title": "Fruitcake Millionaire", 
        "desc": "Trade your fruitcake for entry into the Zogle Gem Mines",
        "pts": 5,
    },
    {
        "id": 442890,
        "src": STAGE(0x09, 0x04), 
        "dst": STAGE(0x09, 0x05), 
        "title": "Delighted", 
        "desc": "Exchange a bag full of rare gemstones for the green prism",
        "pts": 5,
    },
    {
        "id": 442891,
        "src": STAGE(0x0a, 0x02), 
        "dst": STAGE(0x0b, 0x01), 
        "title": "Triple Cherries at the Stoneheath Slot Machine", 
        "desc": "Wake the Stoneheath golems and free Gwenella's horse in Stoneheath Circles",
        "pts": 10,
    },
    {
        "id": 442892,
        "src": STAGE(0x0b, 0x02), 
        "dst": STAGE(0x0b, 0x03), 
        "title": "Do You Think Love Can Bloom Even in a Goblin Lair?", 
        "desc": "Sneak through the goblin dungeons up into their secret lair",
        "pts": 5,
    },
    {
        "id": 442893,
        "src": STAGE(0x0b, 0x05), 
        "dst": STAGE(0x0c, 0x01), 
        "title": "Trust Me and We Will Escape From the City", 
        "desc": "Execute a flawless prison escape from the Goblin Lair",
        "pts": 10,
    },
    {
        "id": 442894,
        "src": STAGE(0x0c, 0x01), 
        "dst": STAGE(0x0d, 0x01), 
        "title": "Gwenella's Return", 
        "desc": "Play Frankenskye and revive Gwenella by assembling her possessions",
        "pts": 10,
    },
    {
        "id": 442900,
        "src": STAGE(0x0d, 0x04), 
        "dst": STAGE(0x0d, 0x05), 
        "title": "Come Sail Away", 
        "desc": "Enter Twell Country in search of the green prism",
        "pts": 5,
    },
    {
        "id": 442895,
        "src": STAGE(0x0d, 0x05), 
        "dst": STAGE(0x0d, 0x06), 
        "title": "Honey, I Shrunk the Protagonist", 
        "desc": "Slay the Manta-krynn and recover the five elixirs",
        "pts": 5,
    },
    {
        "id": 442896,
        "src": STAGE(0x0e, 0x01), 
        "dst": STAGE(0x0e, 0x02), 
        "title": "Stan's Kozy Krypts: Everybody's Just Dying to Get In!", 
        "desc": "Draak doesn't seem to be in the graveyard. Head down into the crypts",
        "pts": 5,
    },
    {
        "id": 442901,
        "src": STAGE(0x0e, 0x03), 
        "dst": STAGE(0x0e, 0x04), 
        "title": "Straight Outta Crypt-town", 
        "desc": "Oops, wrong crypt! Head back to the graveyard so you can find the right one",
        "pts": 10,
    },
    {
        "id": 442897,
        "src": STAGE(0x0e, 0x06), 
        "dst": STAGE(0x0f, 0x01), 
        "title": "It's Not That He Sucks Blood... He Just Sucks", 
        "desc": "Defeat the whiny vampyre (ugh) and make your way to the great cathedral",
        "pts": 10,
    },
    {
        "id": 442902,
        "src": STAGE(0x0f, 0x02), 
        "dst": STAGE(0x0f, 0x03), 
        "title": "Schism", 
        "desc": "Fight the mysterious villain in the cathedral, and win-- duh!",
        "pts": 10,
    },
    {
        "id": 442898,
        "src": STAGE(0x0f, 0x03), 
        "dst": STAGE(0x10, 0x01), 
        "title": "Carillon, My Wayward Son", 
        "desc": "Climb the Bell Tower. That's where gargoyles usually hang out, right?",
        "pts": 5,
    },
    {
        "id": 442903,
        "src": STAGE(0x10, 0x02), 
        "dst": STAGE(0x10, 0x03), 
        "title": "A Happy Family Reunion", 
        "desc": "Use the Heart of the Rainbow to gain access to Necroth's lair for the final showdown",
        "pts": 10,
    },
]

RIDDLES = [
    {
        "id": 442909,
        "level": STAGE(0x0e, 0x01),
        "title": "The Gargoyles' Riddle #1 - Skulls in the Graveyard", 
        "desc": "I am an odd number. Take away a letter and I become even.",
        "answer": ["S", "E", "V", "E", "N"],
    },
    {
        "id": 442910,
        "level": STAGE(0x0e, 0x02),
        "title": "The Gargoyles' Riddle #2 - Skulls in the Grey Tunnels", 
        "desc": "I have two hands, but cannot clap.",
        "answer": ["C", "L", "O", "C", "K"],
    },
    {
        "id": 442911,
        "level": STAGE(0x0e, 0x03),
        "title": "The Gargoyles' Riddle #3 - Skulls at the Top of the Stairs", 
        "desc": "What word becomes shorter by adding two letters?",
        "answer": ["S", "H", "O", "R", "T"],
    },
    {
        "id": 442912,
        "level": STAGE(0x0e, 0x05),
        "title": "The Gargoyles' Riddle #4 - Skulls in the Crystal Halls", 
        "desc": "I have a great many keys, but I open no locks.",
        "answer": ["P", "I", "A", "N", "O"],
    },
]

CUTSCENE_TRIGGERS = [
    {
        "id": 442904,
        "title": "RSVP (Ruthless Slayer Vanquished Permanently) in Lynlora",
        "desc": "Get invited to Stumpy's party (don't forget to bring a funny gift)",
        "params": [0x01, 0x09, -1],
        "pts": 3,
    },
    {
        "id": 442905,
        "title": "A Marketing Decision",
        "desc": "Even horrifying lake monsters can't get enough of that delicious Skittles® flavor",
        "params": [0x02, 0x0b, -1],
        "pts": 1,
    },
    {
        "id": 442906,
        "title": "So That's Where All the Unsold Copies Went",
        "desc": "If you can believe it, video games used to come out on these ancient circles called \"CDs\"",
        "params": [0x03, 0x20, -1],
        "pts": 2,
    },
    {
        "id": 442907,
        "title": "Build-a-Wizard Workshop",
        "desc": "Try bringing along a few friends to meet your estranged father",
        "params": [0x10, 0x12, -1],
        "pts": 3,
    },
]

GADGET_PITCHES = [
    [0x05, 0x0c, -1], 
    [0x05, 0x0d, -1], 
    [0x05, 0x0b, -1], 
    [0x09, 0x12, -1],
]

SPELL_ACHIEVEMENTS = [
    {
        "id": 442914,
        "spell": SPELL_MAGNIFY_MAGIC, 
        "title": "More Bang for Your Buck", 
        "why": "to power up your attacks", 
        "points": 2 
    },
    { 
        "id": 442915,
        "spell": SPELL_WIND_GLIDE, 
        "title": "I'm Walking on Sunshine", 
        "why": "and defy gravity", 
        "points": 2 
    },
    { 
        "id": 442916,
        "spell": SPELL_DIMINISH, 
        "title": "Short People Got Nobody", 
        "why": "to get a fresh perspective", 
        "points": 1 
    },
]

// --- RICH PRESENCE -------------------------------------------------------------------

MapLookup = {
    STAGE(0x01, 0x01): "Lynlora",
    STAGE(0x01, 0x02): "Lynlora",
    STAGE(0x01, 0x03): "Lynlora",
    STAGE(0x02, 0x01): "Ogmire Archipelago",
    STAGE(0x03, 0x01): "Tikniki Swamp",
    STAGE(0x04, 0x01): "Ogmire City",
    STAGE(0x04, 0x02): "Ogmire Dungeons",
    STAGE(0x04, 0x03): "Ogmire Prison Tower",
    STAGE(0x05, 0x01): "Lynlora",
    STAGE(0x05, 0x02): "Lynlora",
    STAGE(0x05, 0x03): "Lynlora",
    STAGE(0x05, 0x04): "the Pirates' Sky Camp",
    STAGE(0x05, 0x05): "Lynlora",
    STAGE(0x05, 0x06): "Lynlora",
    STAGE(0x06, 0x01): "Zen'jai Hills",
    STAGE(0x06, 0x02): "Zen'jai Hills",
    STAGE(0x07, 0x01): "the Dragon Village",
    STAGE(0x07, 0x02): "the Dragon Village",
    STAGE(0x07, 0x03): "the Dragon Village",
    STAGE(0x07, 0x04): "the Dragon Village",
    STAGE(0x08, 0x01): "the Warlord's Palace",
    STAGE(0x08, 0x02): "the Warlord's Palace",
    STAGE(0x08, 0x03): "the Warlord's Palace",
    STAGE(0x08, 0x04): "the Warlord's Palace",
    STAGE(0x09, 0x01): "Lynlora",
    STAGE(0x09, 0x02): "Lynlora",
    STAGE(0x09, 0x03): "Lynlora",
    STAGE(0x09, 0x04): "the Zogle Gem Mines",
    STAGE(0x09, 0x05): "Lynlora",
    STAGE(0x0a, 0x01): "the Stoneheath Circles",
    STAGE(0x0a, 0x02): "the Stoneheath Circles",
    STAGE(0x0b, 0x01): "the Goblin Prison",
    STAGE(0x0b, 0x02): "the Goblin Laboratory",
    STAGE(0x0b, 0x03): "the Goblin Lair",
    STAGE(0x0b, 0x04): "the Goblin Workshop",
    STAGE(0x0b, 0x05): "the Goblin Workshop",
    STAGE(0x0c, 0x01): "the Bone Lands",
    STAGE(0x0d, 0x01): "Lynlora",
    STAGE(0x0d, 0x02): "Lynlora",
    STAGE(0x0d, 0x03): "Lynlora",
    STAGE(0x0d, 0x04): "Twell Country",
    STAGE(0x0d, 0x05): "Twell Country",
    STAGE(0x0d, 0x06): "Lynlora",
    STAGE(0x0e, 0x01): "the Gargoyle Cemetery",
    STAGE(0x0e, 0x02): "the Gargoyle Catacombs",
    STAGE(0x0e, 0x03): "the Gargoyle Catacombs",
    STAGE(0x0e, 0x04): "the Gargoyle Cemetery",
    STAGE(0x0e, 0x05): "the Gargoyle Catacombs",
    STAGE(0x0e, 0x06): "the Gargoyle Catacombs",
    STAGE(0x0f, 0x01): "the Cathedral Library",
    STAGE(0x0f, 0x02): "the Cathedral",
    STAGE(0x0f, 0x03): "the Bell Tower",
    STAGE(0x10, 0x01): "Necroth's Realm",
    STAGE(0x10, 0x02): "the Dark Prism",
    STAGE(0x10, 0x03): "Necroth's Lair",
}

SPELL_SLOTS = [2, 3, 3, 2, 4, 6, 2, 3, 6, 2, 4, 5, 5, 3, 6, 6, 2, 4, 4, 4, 5, 3, 4]
SpellLookup = {
    SPELL_TRUE_SIGHT: "True Sight", // 2
    SPELL_AWAKEN_STONE: "Awaken Stone", // 3
    SPELL_DIMINISH: "Diminish", // 3
    SPELL_PRISMATIC_PULSE: "Prismatic Pulse", // 2
    SPELL_FIREWALK: "Firewalk", // 4
    SPELL_LIGHTNING: "Lightning", // 6
    SPELL_STRENGTH_SAP: "Strength Sap", // 2
    SPELL_PYRO_PULSE: "Pyro Pulse", // 3
    SPELL_WIND_GLIDE: "Wind Glide", // 6
    SPELL_SHADOW_VISION: "Shadow Vision", // 2
    SPELL_POLAR_PULSE: "Polar Pulse", // 4
    SPELL_CLEANSE_EVIL: "Cleanse Evil", // 5
    SPELL_AFFLICTION: "Affliction", // 5
    SPELL_MADNESS: "Madness", // 3
    SPELL_CREATE_WIZARD: "Create Wizard", // 6
    SPELL_HEART_OF_THE_RAINBOW: "Heart of the Rainbow", // 6
    SPELL_IMPEDE: "Impede", // 2
    SPELL_MAGNIFY_MAGIC: "Magnify Magic", // 4
    SPELL_PSYCHIC_BLAST: "Psychic Blast", // 4
    SPELL_SPELL_SHIELD: "Spell Shield", // 4
    SPELL_RING_OF_RIME: "Ring of Rime", // 5
    SPELL_UNIVERSAL_SMITE: "Universal Smite", // 3
    SPELL_VEIL: "Veil", // 4
}

rp_hp = rich_presence_value("Number", current_health())
rp_map = rich_presence_lookup("Map", level_number(), MapLookup, fallback="the Five Lands")

rich_presence_conditional_display(level_number() == STAGE(0x09, 0x04) && holding_item(ITEM_GEMSTONES),
    "Skye is collecting rare gemstones in the Zogle Gem Mines | ❤️{0}% | 💎{1}%",
    rp_hp,
    rich_presence_value("Number", item_count(selected_item_index()) * 2)
)

rich_presence_conditional_display(prepared_spell_index() != 0xFFFFFFFF,
    "Skye is collecting Skittles® in {0} | ❤️{1}% | 🪄{2}",
    rp_map, rp_hp,
    rich_presence_lookup("Spell", current_spell(), SpellLookup, fallback="<Unknown>")
)

rich_presence_display(
    "Skye is collecting Skittles® in {0} | ❤️{1}%",
    rp_map, rp_hp
)

// --- ACHIEVEMENTS -------------------------------------------------------------------

achievement(id=442876,
    title="I Thought This Game Was About Skittles®",
    description="Watch the intro cutscene to learn the lore",
    points=0,
    trigger=(
        // watching the intro cutscene
        level_number() == 0 && loaded_movie() == 0x80159824 &&

        // reached the title card
        movie_timer() >= 6100
    )
)

for data in STAGE_CLEARS
{
    achievement(id=data["id"],
        title=data["title"],
        description=data["desc"],
        points=data["pts"],
        type="progression",
        trigger=(
            // prevents firing from loading a saved game
            unpaused() &&

            // check the transition from one level to another
            prev(level_number()) == data["src"] && level_number() == data["dst"]
        )
    )
}

achievement(id=442899,
    title="Heart of the Rainbow",
    description="Defeat Necroth in his lair and restore the power of the rainbow",
    points=25,
    type="win_condition",
    trigger=(
        // was in Necroth's lair
        prior(level_number()) == STAGE(0x10, 0x03) &&

        // now watching the outro cutscene
        level_number() == 0 && loaded_movie() == 0x801597b8
    )
)

for a in CUTSCENE_TRIGGERS
{
    achievement(id=a["id"],
        title=a["title"],
        description=a["desc"],
        points=a["pts"],
        trigger=cutscene_playing_from_params(a["params"])
    )
}

achievement(id=442908,
    title="But Wait, There's More!",
    description="Listen to all of the gadget salesman's sales pitches. It seems like every time you visit, he has something new!",
    type="missable",
    points=3,
    trigger=(
        // check that we've heard all of the gadget pitches in one visit
        measured(tally(length(GADGET_PITCHES), array_map(GADGET_PITCHES, (x) => once(cutscene_playing_from_params(x))))) &&

        // reset any time the level number changes
        never(prev(level_number()) != level_number())
    )
)

LETTER_TO_NUM = {
    "A":  0, "B":  1, "C":  2, "D":  3, "E":  4,
    "F":  5, "G":  6, "H":  7, "I":  8, "K":  9,
    "L": 10, "M": 11, "N": 12, "O": 13, "P": 14,
    "Q": 15, "R": 16, "S": 17, "T": 18, "U": 19,
    "V": 20, "W": 21, "X": 22, "Y": 23, "Z": 24,
}
for riddle in RIDDLES
{
    solution = always_true()
    for i in range(0, 4)
        solution = solution && get_skull(riddle["level"], i) == LETTER_TO_NUM[riddle["answer"][i]]

    achievement(id=riddle["id"],
        title=riddle["title"],
        description=("\"" + riddle["desc"] + "\""),
        type="missable",
        points=5,
        trigger=(level_number() == riddle["level"] && trigger_when(solution))
    )
}

SQUELK_HEALTH_MIN = 50
achievement(id=442913,
    title="Never Pay for Squelk Insurance",
    description=format("Collect and turn in a full bag of gems in the Zogle Gem Mines without your squelk's health dropping below {0}%", SQUELK_HEALTH_MIN),
    type="missable",
    points=10,
    trigger=(
        // in the correct level
        level_number() == STAGE(0x09, 0x04) &&

        // trigger on watching the cutscene at the start of stage
        // (cutscene replays on death/failure)
        once(cutscene_ended(0x09, 0x29)) &&

        // trigger when the success cutscene plays
        trigger_when(cutscene_playing(0x09, 0x2c)) &&

        // reset if health ever drops below 50%
        never(current_health() < SQUELK_HEALTH_MIN) &&

        // reset if the player loads a save game
        never(loading_file()) &&

        // reset if leave the stage somehow
        never(level_number() != STAGE(0x09, 0x04))
    )
)

achievement(id=442920,
    title="While Supplies Last",
    description="Collect the toy seller's whole line of Wood Wizard products",
    type="missable",
    points=1,
    trigger=(
        measured(tally_of(
            // for all item slots
            range(0, MAX_ITEM_COUNT-1), length(ITEM_WOOD_TOYS),

            // add a hit if this slot is occupied by this item
            (i) => once(num_items() > i && any_of(ITEM_WOOD_TOYS, (x) => item_id(i) == x))
        )) &&

        // reset if the number if items in the inventory changes
        never(num_items() != prev(num_items())) &&

        // reset any time the level number changes
        never(prev(level_number()) != level_number())
    )
)

for a in SPELL_ACHIEVEMENTS
{
    achievement(id=a["id"],
        title=a["title"],
        description=format("Cast the {0} spell {1}", SpellLookup[a["spell"]], a["why"]),
        points=a["points"],
        trigger=cast_spell(a["spell"])
    )
}

DIMINISH_SECONDS = 15
achievement(id=442917,
    title="I Don't Wanna Grow Up",
    description=format("Stubbornly refuse to let the {0} spell wear off for {1} seconds", SpellLookup[SPELL_DIMINISH], DIMINISH_SECONDS),
    points=3,
    // count the number of frames that the diminish timer holds in place waiting for Skye to be able to grow
    trigger=repeated(DIMINISH_SECONDS * 60, diminish_timer() > 4.75 && diminish_timer() <= 5 && unpaused() && never(diminish_timer() > 5))
)

achievement(id=442918,
    title="Lvl 99 Fishing",
    description="Every good JRPG has a fishing minigame. Collect 3 fish",
    type="missable",
    points=10,
    trigger=check_inventory(ITEM_FISH, (i) => measured(item_count(i) == 3, when=item_id(i) == ITEM_FISH))
)

achievement(id=442919,
    title="Full of Skittles® Juice",
    description="Collect and hold 10 life potions at the same time",
    points=10,
    trigger=check_inventory(ITEM_LIFE_POT, (i) => measured(item_count(i) == 10, when=item_id(i) == ITEM_LIFE_POT))
)