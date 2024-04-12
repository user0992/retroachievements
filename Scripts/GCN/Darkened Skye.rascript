// Darkened Skye
// #ID = 25437

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
function item_count() => dword_be(0x16F10C)

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
function item_table() => 0x37C640 // tbyte_be(PTR_TO_ITEM_TABLE + 1)

function item_struct(i) => i * 36 + item_table()
function item_id(i) => dword_be(tbyte_be(item_struct(i) + 9))
function item_count(i) => dword_be(item_struct(i) + 24)

function holding_item(x) => has_selected_item() && item_id(selected_item_index()) == x
function current_item_used() => has_selected_item() && item_count(selected_item_index()) < prev(item_count(selected_item_index()))

// list of item lookups
ITEM_GEMSTONES = 0x8038CBB1
ITEM_LIFE_POT = 0
ITEM_MANA_POT = 0

// $17F128: Number of Available Spells [32 bit BE]
function spell_count() => dword_be(0x17F128)

// $17F13C: Total Number of Skittles® [32 bit BE]
function skittles_count() => dword_be(0x17F13C)

// $17F150: Unallocated Skittles® [32 bit BE]
function skittles_unallocated() => dword_be(0x17F150)

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
function level_number() => dword_be(0x19ADBC)

// $19ADBC: Level Number - Main [16 bit BE]
function level_number_main() => word_be(0x19ADBC)

// $19ADBE: Level Number - Part [16 bit BE]
//          00,00 = Intro Cutscene
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
function level_number_part() => word_be(0x19ADBE)

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
    0x000e0001: [26, 25, 24, 23, 22],
    0x000e0002: [13, 12, 11, 10,  9],
    0x000e0003: [ 9, 10, 11, 12, 13],
    0x000e0005: [11, 10,  9,  8,  7],
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
function skye_pointer() => word_be(0x1D5530) & 0xFFFFFF

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

MapLookup = {
    0x00010001: "Lynlora",
    0x00010002: "Lynlora",
    0x00010003: "Lynlora",
    0x00020001: "Ogmire Archipelago",
    0x00030001: "Tikniki Swamp",
    0x00040001: "Ogmire City",
    0x00040002: "Ogmire Dungeons",
    0x00040003: "Ogmire Prison Tower",
    0x00050001: "Lynlora",
    0x00050002: "Lynlora",
    0x00050003: "Lynlora",
    0x00050004: "the Pirates' Sky Camp",
    0x00050005: "Lynlora",
    0x00050006: "Lynlora",
    0x00060001: "Zen'jai Hills",
    0x00060002: "Zen'jai Hills",
    0x00070001: "the Dragon Village",
    0x00070002: "the Dragon Village",
    0x00070003: "the Dragon Village",
    0x00070004: "the Dragon Village",
    0x00080001: "the Warlord's Palace",
    0x00080002: "the Warlord's Palace",
    0x00080003: "the Warlord's Palace",
    0x00090001: "Lynlora",
    0x00090002: "Lynlora",
    0x00090003: "Lynlora ",
    0x00090004: "the Zogle Gem Mines",
    0x00090005: "Lynlora",
    0x000a0001: "the Stoneheath Circles",
    0x000a0002: "the Stoneheath Circles",
    0x000b0001: "the Goblin Prison",
    0x000b0002: "the Goblin Laboratory",
    0x000b0003: "the Goblin Lair",
    0x000b0004: "the Goblin Workshop",
    0x000b0005: "the Goblin Workshop",
    0x000c0001: "the Bone Lands",
    0x000d0001: "Lynlora",
    0x000d0002: "Lynlora",
    0x000d0003: "Lynlora",
    0x000d0004: "Twell Country",
    0x000d0005: "Twell Country",
    0x000d0006: "Lynlora",
    0x000e0001: "the Gargoyle Cemetery",
    0x000e0002: "the Gargoyle Catacombs",
    0x000e0003: "the Gargoyle Catacombs",
    0x000e0004: "the Gargoyle Cemetery",
    0x000e0005: "the Gargoyle Catacombs",
    0x000e0006: "the Gargoyle Catacombs",
    0x000f0001: "the Cathedral Library",
    0x000f0002: "the Cathedral",
    0x000f0003: "the Bell Tower",
    0x00100001: "Necroth's Realm",
    0x00100002: "the Dark Prism",
    0x00100003: "Necroth's Lair",
}

SPELL_SLOTS = [2, 3, 3, 2, 4, 6, 2, 3, 6, 2, 4, 5, 5, 3, 6, 6, 2, 4, 4, 4, 5, 3, 4]
SpellLookup = {
    0x0: "True Sight", // 2
    0x1: "Awaken Stone", // 3
    0x2: "Diminish", // 3
    0x3: "Prismatic Pulse", // 2
    0x4: "Firewalk", // 4
    0x5: "Lightning", // 6
    0x6: "Strength Sap", // 2
    0x7: "Pyro Pulse", // 3
    0x8: "Wind Glide", // 6
    0x9: "Shadow Vision", // 2
    0xa: "Polar Pulse", // 4
    0xb: "Cleanse Evil", // 5
    0xc: "Affliction", // 5
    0xd: "Madness", // 3
    0xe: "Create Wizard", // 6
    0xf: "Heart of the Rainbow", // 6
    0x10: "Impede", // 2
    0x11: "Magnify Magic", // 4
    0x12: "Psychic Blast", // 4
    0x13: "Spell Shield", // 4
    0x14: "Ring of Rime", // 5
    0x15: "Universal Smite", // 3
    0x16: "Veil", // 4
}

function cast_spell(spell)
{
    // should only need to check the charge of the first slotted Skittles®
    charge = skittle_charge(dword_be(prepared_spell_index() * 128 + SPELL_TABLE + 88))
    return is_current_spell(spell) && charge < prev(charge)
}

function cast_any_spell()
{
    // should only need to check the charge of the first slotted Skittles®
    charge = skittle_charge(dword_be(prepared_spell_index() * 128 + SPELL_TABLE + 88))
    return has_prepared_spell() && charge < prev(charge)
}

rich_presence_conditional_display(level_number() == 0x00090004 && holding_item(ITEM_GEMSTONES),
    "Skye is collecting rare gemstones in the Zogle Gem Mines | ❤️{0}% | 💎{1}%",
    rich_presence_value("Number", current_health()),
    rich_presence_value("Number", item_count(selected_item_index()) * 2)
)

rich_presence_conditional_display(prepared_spell_index() != 0xFFFFFFFF,
    "Skye is collecting Skittles® in {0} | ❤️{1}% | 🪄{2}",
    rich_presence_lookup("Map", level_number(), MapLookup, fallback="the Five Lands"),
    rich_presence_value("Number", current_health()),
    rich_presence_lookup("Spell", current_spell(), SpellLookup, fallback="<Unknown>")
)

rich_presence_display(
    "Skye is collecting Skittles® in {0} | ❤️{1}%",
    rich_presence_lookup("Map", level_number(), MapLookup, fallback="the Five Lands"),
    rich_presence_value("Number", current_health())
)

STAGE_CLEARS = [
    {
        "src": 0x00010003,
        "dst": 0x00020001,
        "title": "The Adventure Begins", 
        "desc": "Use True Sight to find the way to leave Lynlora with the orange prism",
    },
    {
        "src": 0x00020001, 
        "dst": 0x00030001, 
        "title": "The Keepers of the Rainbow", 
        "desc": "Find Merlin in Ogmire Archipelago and learn about the Keepers of the Rainbow",
    },
    {
        "src": 0x00030001, 
        "dst": 0x00040001, 
        "title": "Getting out of Tikniki Swamp", 
        "desc": "Once you get used to the smell, it's actually quite lovely",
    },
    {
        "src": 0x00040001, 
        "dst": 0x00040002, 
        "title": "The City Beyond the Sea", 
        "desc": "Search Ogmire City for clues to the whereabouts of the yellow prism",
    },
    {
        "src": 0x00040002, 
        "dst": 0x00040003, 
        "title": "The Ogmire Jailbreak", 
        "desc": "Escape from the Ogmire Dungeons",
    },
    {
        "src": 0x00040002, 
        "dst": 0x00040003, 
        "title": "Bloodsquall's Quick Escape", 
        "desc": "Help Bloodsquall escape the Prison Tower with the yellow prism in-hand",
    },
    {
        "src": 0x00050003, 
        "dst": 0x00050004, 
        "title": "One Toot on This Whistle...", 
        "desc": "Get whisked away to the Pirates' Sky Camp",
    },
    {
        "src": 0x00050004, 
        "dst": 0x00050005, 
        "title": "Crafting a MacGuffin", 
        "desc": "Reach Yancey's ship in the sky and ask about the green prism",
    },
    {
        "src": 0x00060002, 
        "dst": 0x00070001, 
        "title": "The Hills Have Zen'jais", 
        "desc": "Escape the Zen'jai Hills with Dorian",
    },
    {
        "src": 0x00070004, 
        "dst": 0x00080001, 
        "title": "How to Train Your Dragon", 
        "desc": "Hitch a ride on Black Heart's back-- destination: the dark warlord's palace",
    },
    {
        "src": 0x00080002, 
        "dst": 0x00080003, 
        "title": "Some Assembly Required", 
        "desc": "Assemble the pieces of General Quang's secret weapon",
    },
    {
        "src": 0x00080003, 
        "dst": 0x00090001, 
        "title": "<Completing Warlord's Palace>", 
        "desc": "Bring together the five birds of harmony and leave Zen'jai",
    },
    {
        "src": 0x00090003, 
        "dst": 0x00090004, 
        "title": "Fruitcake Millionaire", 
        "desc": "Trade your fruitcake for entry into the Zogle Gem Mines",
    },
    {
        "src": 0x00090005, 
        "dst": 0x000A0001, 
        "title": "<Lynlora -> Stoneheath>", 
        "desc": "",
    },
    {
        "src": 0x000A0002, 
        "dst": 0x000B0001, 
        "title": "<Stoneheath -> Goblin Prison>", 
        "desc": "",
    },
    { // TODO: is this one needed?
        "src": 0x000B0002, 
        "dst": 0x000B0003, 
        "title": "<Goblin Lab -> Goblin Lair>", 
        "desc": "",
    },
    {
        "src": 0x000B0004, 
        "dst": 0x000C0001, 
        "title": "<Goblin Lair -> Bone Lands>", 
        "desc": "",
    },
    {
        "src": 0x000C0001, 
        "dst": 0x000D0001, 
        "title": "<Bone Lands -> Lynlora>", 
        "desc": "",
    },
    {
        "src": 0x000D0004, 
        "dst": 0x000D0005, 
        "title": "<Lynlora -> Twell Country>", 
        "desc": "",
    },
    {
        "src": 0x000D0005, 
        "dst": 0x000D0006, 
        "title": "<Complete Twell Country>", 
        "desc": "",
    },
    {
        "src": 0x000E0001, 
        "dst": 0x000E0002, 
        "title": "<Gargoyle Cemetery -> Catacombs 1>", 
        "desc": "",
    },
    {
        "src": 0x000E0003, 
        "dst": 0x000E0004, 
        "title": "<Gargoyle Catacombs 2 -> Cemetery>", 
        "desc": "",
    },
    {
        "src": 0x000E0006, 
        "dst": 0x000F0001, 
        "title": "<Gargoyle Catacombs 4 (Vampire) -> Cathedral Library>", 
        "desc": "",
    },
]

RIDDLES = [
    {
        "level": 0x000e0001,
        "title": "The Gargoyles' Riddle #1 - Skulls in the Graveyard", 
        "desc": "I am an odd number. Take away a letter and I become even.",
        "answer": ["S", "E", "V", "E", "N"],
    },
    {
        "level": 0x000e0002,
        "title": "The Gargoyles' Riddle #2 - Skulls in the Grey Tunnels", 
        "desc": "I have two hands, but cannot clap.",
        "answer": ["C", "L", "O", "C", "K"],
    },
    {
        "level": 0x000e0003,
        "title": "The Gargoyles' Riddle #3 - Skulls at the Top of the Stairs", 
        "desc": "What word becomes shorter by adding two letters?",
        "answer": ["S", "H", "O", "R", "T"],
    },
    {
        "level": 0x000e0005,
        "title": "The Gargoyles' Riddle #4 - Skulls in the Alien Halls", 
        "desc": "I have a great many keys, but I open no locks.",
        "answer": ["P", "I", "A", "N", "O"],
    },
]

achievement(
    title="I Thought This Game Was About Skittles®",
    description="Watch the intro cutscene to learn the lore",
    points=0,
    trigger=(
        // watching the intro cutscene
        level_number() == 0 && loaded_movie() == 0x80159824 &&

        // reached the last frame of the movie
        movie_timer() >= 6355
    )
)

for data in STAGE_CLEARS
{
    achievement(
        title=data["title"],
        description=data["desc"],
        points=5,
        trigger=(
            // prevents firing from loading a saved game
            unpaused() &&

            // check the transition from one level to another
            prev(level_number()) == data["src"] && level_number() == data["dst"]
        )
    )
}

achievement(
    title="Heart of the Rainbow",
    description="Defeat Necroth in his lair and restore the power of the rainbow",
    points=25,
    trigger=(
        // was in Necroth's lair
        prior(level_number()) == 0x00100003 &&

        // now watching the outro cutscene
        level_number() == 0 && loaded_movie() == 0x801597b8
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

    achievement(
        title=riddle["title"],
        description=("\"" + riddle["desc"] + "\""),
        points=5,
        trigger=(level_number() == riddle["level"] && trigger_when(solution))
    )
}

achievement(
    title="Never Pay for Squelk Insurance",
    description="Collect and turn in a full bag of gems in the Zogle Gem Mines without your squelk's health dropping below 50%",
    points=10,
    trigger=(
        // in the correct level
        level_number() == 0x00090004 &&

        // trigger on watching the cutscene at the start of stage
        // (cutscene replays on death/failure)
        once(cutscene_ended(0x09, 0x29)) &&

        // trigger when the success cutscene plays
        trigger_when(cutscene_playing(0x09, 0x2c)) &&

        // reset if health ever drops below 50%
        never(current_health() < 50.0) &&

        // reset if the player loads a save game
        never(loading_file()) &&

        // reset if leave the stage somehow
        never(level_number() != 0x00090004)
    )
)

achievement(
    title="[TODO] A Slow Thaw",
    description="Defeat Ice Heart without using the Pyro Pulse spell",
    points=10,
    trigger=(
        // in the correct level
        level_number() == 0x00070001 &&

        // checkpoint hit for starting the boss fight
        once(boss_fight_starting()) &&

        // trigger when boss dies
        trigger_when(cutscene_playing(0x07, 0x05)) &&

        // never cast Pyro Pulse
        never(cast_spell(0x07)) &&

        // reset if the health bar goes away
        never(!boss_health_bar_shown())
    )
)

achievement(
    title="A Slow Burn",
    description="Defeat Fire Heart without taking damage",
    points=10,
    trigger=(
        // in the correct level
        level_number() == 0x00070003 &&

        // checkpoint hit for starting the boss fight
        once(boss_fight_starting()) &&

        // trigger when boss dies
        trigger_when(cutscene_playing(0x07, 0x1B, 0x00)) &&

        // reset if we lose health
        never(lose_health()) &&

        // reset if the health bar goes away
        never(!boss_health_bar_shown())
    )
)