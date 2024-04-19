// Adventures in the Magic Kingdom
// #ID = 1527

// HELPERS
function if_else(p, t, f) { if (p) { return t } else return f }
idfunc = (x) => x

// $001C: Y Position [16 bit]
function y_position() => word(0x00001C)

// $001E: X Position [16 bit]
function x_position() => word(0x00001E)

// $0030: Player Health [8 bit]
//        Max 3, Dead at 0
function health() => byte(0x000030)

// $0037: Overworld State [8 bit]
//        0x96 = Normal
//        0xbb = Transition to...
//        0x1b = Gate Opening
//        0xb3 = Parade
function overworld_state() => byte(0x000037)

OVERWORLD_NORMAL = 0x96
OVERWORLD_GATE_OPENING = 0x1b
OVERWORLD_PARADE = 0xb3

// $0050: Train - Meters Remaining [3 bytes]
//        hundreds, tens, ones - expanded BCD
function train_meters_remaining() => byte(0x000050) * 100 + byte(0x000051) * 10 + byte(0x000052)

// $0061: Room ID [8 bit]
//        Mansion: 01, 05, 04, 03, 02
function room_id() => byte(0x000061)

// $0092: Cursor Position in Name Entry [8 bit]
function name_entry_cursor() => byte(0x000092)

// $00BA: Stars [8 bit]
function stars() => byte(0x0000BA)

PRICE_HEALTH = 6
PRICE_FREEZE = 8
PRICE_INVINC = 10
PRICE_1UP = 12

// $00BB: Invincibility Timer [8 bit]
//        subtracts 1 every 4 frames
//        0x3c = 60 = 4 seconds
function invinc_timer() => byte(0x0000BB)

// $00BC: Freeze Frames [8 bit]
//        0xb4 = 180 = 3 seconds
function freeze_timer() => byte(0x0000BC)

// $00B8: Talking Portrait [8 bit]
//        0x01 = Old Man (Pirates)
//        0x02 = Cowboy Goofy
//        0x03 = Panhandle Pete
//        0x04 = Normal Goofy
//        0x07 = Space Mickey
//        0x0c = Normal Mickey
//        0x0e = Ghoul
//        0x0f = Cowboy Mickey
function talking_portrait() => byte(0x00B8)

TALK_OLDMAN = 0x01
TALK_COWBOY_GOOFY = 0x02
TALK_PETE = 0x03
TALK_GOOFY = 0x04
TALK_SPACE_MICKEY = 0x07
TALK_MICKEY = 0x0c
TALK_GHOUL = 0x0e
TALK_COWBOY_MICKEY = 0x0f

// $00D0: Sound Effect Metadata [32 bit]
//        byte0 = tone value
//        byte3 = timer (frames)
//        star collect: 0x04feae3d
function sound_effect() => dword(0x00D0)

STAR_SOUND = 0x04feae3d
function collect_star() => prev(sound_effect()) != STAR_SOUND && sound_effect() == STAR_SOUND

// $00EA: Map ID [8 bit]
//        0x00 = Overworld
//        0x02 = Pirates
//        0x04 = Haunted Mansion
//        0x07 = Autopia
//        0x08 = Intro Cutscene
//        0x09 = The End
//        0x0a = Title Screen
//        0x0b = Big Thunder Mountain
//        0x0c = Space Mountain
function map_id() => byte(0x0000EA)

MAP_OVERWORLD = 0x00
MAP_PIRATE = 0x02
MAP_GHOST = 0x04
MAP_CARS = 0x07
MAP_INTRO = 0x08
MAP_THEEND = 0x09
MAP_TITLE = 0x0a
MAP_TRAIN = 0x0b
MAP_SPACE = 0x0c

// $0603: Current Star [8 bit] - Space Mountain
//        0 -> 4 for A-E, does not change to 5
function space_star() => byte(0x000603)

// $06D8: Lives Remaining [8 bit]
function lives() => byte(0x0006D8)

// $06D9: Number of Keys [8 bit]
function key_count() => byte(0x0006D9)

// $06E4: Train Target Station [8 bit]
//        0 = 4th
//        1 = 3rd
//        2 = 2nd
//        3 = 1st
function train_target_station() => byte(0x0006E4)

// $06E6: Key - Pirates of the Caribbean [8 bit]
// $06E7: Key - Big Thunder Mountain [8 bit]
// $06E8: Key - Autopia [8 bit]
// $06E9: Key - The Haunted Mansion [8 bit]
// $06EC: Key - Space Mountain [8 bit]
//        0x00 = No Key
//        0xC0 = Have Key
function key_pirate() => byte(0x0006E6)
function key_train() => byte(0x0006E7)
function key_cars() => byte(0x0006E8)
function key_ghost() => byte(0x0006E9)
function key_space() => byte(0x0006EC)

HAVE_KEY = 0xC0

// $06EE: Key - Disney Trivia [8 bit]
//        Number of questions answered (0-7)
//        0x07 = Have Key
function key_trivia() => byte(0x0006EE)

// $06ED: Pirates Collectables
//        b0 = Maiden in front of cannon
//        b1 = Maiden above 2nd cave exit
//        b2 = Last Maiden
//        b3 = Underground Maiden
//        b4 = First Maiden (orange building)
//        b5 = Second Maiden (tricky firey platforming)
//        b6 = <Unused>
//        b7 = Candle
PIRATES_COLLECTABLES = 0x0006ED

// $06F2: Candles Remaining [8 bit]
function candles() => byte(0x0006F2)

// $06F3: Timer - Frames [8 bit]
function timer_frames() => byte(0x0006F3)

// $06F4: Timer - Seconds [8 bit]
//        hundreds, tens, ones - expanded BCD
function timer() => byte(0x0006F4) * 100 + byte(0x0006F5) * 10 + byte(0x0006F6)

// $06F7: Name [8 bytes]
NAME_START = 0x0006F7

// $06FF: Name Length [8 bit]
function name_length() => byte(0x0006FF)

LevelNameLookup = {
    MAP_OVERWORLD: "looking for silver keys in the Magic Kingdom",
    MAP_PIRATE: "rescuing maidens in Pirates of the Caribbean",
    MAP_GHOST: "being spooked in the Haunted Mansion",
    MAP_CARS: "racing Panhandle Pete at Autopia",
    MAP_THEEND: "enjoying the parade at the Magic Kingdom",
    MAP_TRAIN: "barrelling down the tracks of Big Thunder Mountain Railroad",
    MAP_SPACE: "zooming through the stars on Space Mountain",
}

LifeText = {
    1: "life"
}

rich_presence_conditional_display(map_id() == MAP_TITLE || map_id() == MAP_INTRO,
    "Adventuring in the Magic Kingdom"
)

rich_presence_display("Currently {0} [🗝️{1}, ⭐{2}, ❤️{3}, {4} {5}]",
    rich_presence_lookup("LevelName", map_id(), LevelNameLookup, fallback=LevelNameLookup[MAP_OVERWORLD]),
    rich_presence_value("Number", key_count()),
    rich_presence_value("Number", stars()),
    rich_presence_value("Number", health()),
    rich_presence_value("Number", lives()),
    rich_presence_lookup("LifeText", lives(), {1: "Life"}, fallback="Lives")
)

CHARMAP = {
    "A": 0x0a, "B": 0x0b, "C": 0x0c, "D": 0x0d, "E": 0x0e, "F": 0x0f, "G": 0x10, "H": 0x11, "I": 0x12, "J": 0x13,
    "K": 0x14, "L": 0x15, "M": 0x16, "N": 0x17, "O": 0x18, "P": 0x19, "Q": 0x1a, "R": 0x1b, "S": 0x1c, "T": 0x1d,
    "U": 0x1e, "V": 0x1f, "W": 0x20, "X": 0x21, "Y": 0x22, "Z": 0x23, " ": 0x24, ".": 0x2a, "'": 0x27, "-": 0x28,
    "1": 0x01, "2": 0x02, "3": 0x03, "4": 0x04, "5": 0x05, "6": 0x06, "7": 0x07, "8": 0x08, "9": 0x09, "0": 0x18,
}

// a function representing earning the correct key on the correct map
function earn_key(map, key) => map_id() == map && prev(key) == 0 && key == HAVE_KEY

// game start is when we transition from the intro to the overworld
function start_game() => prev(map_id()) == MAP_INTRO && map_id() == MAP_OVERWORLD

// game end is when we see the parade
function win_the_game() =>
(
    // collect 6 keys, be on the overworld
    key_count() == 6 && map_id() == MAP_OVERWORLD && 
    
    // transition from the cutscene of watching the gate open to the parade starting
    prev(overworld_state()) == OVERWORLD_GATE_OPENING && overworld_state() == OVERWORLD_PARADE
)

function name_is(chars)
{
    i = 0
    trigger = name_length() == length(chars)
    for ch in chars
    {
        trigger = trigger && (byte(NAME_START + i) == CHARMAP[ch])
        i = i + 1
    }
    return trigger
}

achievement(id=47911, // badge=48437,
    title="Ya Dun Goofed!",
    description="Give us your name, not his!",
    points=1,
    trigger=(
        // transitioning from name entry to intro
        prev(map_id()) == MAP_TITLE && map_id() == MAP_INTRO &&

        // name is input as "GOOFY"
        name_is(["G", "O", "O", "F", "Y"])
    )
)

achievement(id=47924, // badge=48455,
    title="Checking My ID",
    description="How did Goofy know my *real* name?",
    points=1,
    trigger=(
        // transitioning from name entry to intro
        prev(map_id()) == MAP_TITLE && map_id() == MAP_INTRO &&

        // player didn't enter a name
        name_entry_cursor() == 0 && 

        // so Goofy just assigns the name "BAMBOO.7"
        name_is(["B", "A", "M", "B", "O", "O", ".", "7"])
    )
)

achievement(id=47912, // badge=48438,
    title="Silver Mic-keys: Pirates of the Caribbean",
    description="Rescue six maidens and light the signal fire for a silver key",
    points=10,
    type="progression",
    trigger=earn_key(MAP_PIRATE, key_pirate())
)

achievement(
    title="Silver Mic-keys: The Haunted Mansion",
    description="Carry a light to the end of the mansion where the Master Spectre is guarding a silver key",
    points=10,
    type="progression",
    trigger=earn_key(MAP_GHOST, key_ghost())
)

achievement(
    title="Silver Mic-keys: Big Thunder Mountain Railroad",
    description="Guide your train to the correct station where Goofy is waiting to hand over a silver key",
    points=10,
    type="progression",
    trigger=earn_key(MAP_TRAIN, key_train())
)

achievement(
    title="Silver Mic-keys: Space Mountain",
    description="Safely navigate the wormhole to reach Star F and collect a silver key",
    points=10,
    type="progression",
    trigger=earn_key(MAP_SPACE, key_space())
)

achievement(
    title="Silver Mic-keys: Autopia",
    description="Beat Panhandle Pete in the big race to earn one of Mickey's silver keys",
    points=10,
    type="progression",
    trigger=earn_key(MAP_CARS, key_cars())
)

achievement(id=47919, // badge=48445,
    title="Silver Mic-keys: Trivia Master",
    description="Earn a silver key by answering Disney trivia questions around the park",
    points=10,
    type="progression",

    trigger=(
        // measured trivia
        measured(key_trivia() == 7,

            // when on the overworld and ONLY when we see 
            when=map_id() == MAP_OVERWORLD && prev(key_trivia()) + 1 == key_trivia())
    )
)

achievement(id=47922, // badge=48452,
    title="Time to Party",
    description="Collect all six silver keys and start the big parade!",
    points=25,
    type="win_condition",
    trigger=win_the_game()
)

achievement(id=47913, // badge=48439,
    title="Meet Jack Sparrow",
    description="Collect the candle in Pirates of the Caribbean",
    points=1, // rescore: 10
    trigger=(
        // correct stage
        map_id() == MAP_PIRATE &&

        // collect the candle weapon
        bit7(PIRATES_COLLECTABLES) == 1
    )
)

achievement(id=47927, // badge=48460,
    title="Sailing With the Wind", // rename: "Speedy Rescue"
    description="Complete Pirates of the Caribbean with 85 or more seconds left on the clock",
    points=10, // rescore: 25
    trigger=(
        // correct stage
        map_id() == MAP_PIRATE &&

        // disable the achievement if we go over time
        timer() > 85 &&

        // trigger when talking to the grateful old man after collecting all of the items
        trigger_when(talking_portrait() == TALK_OLDMAN)
    )
)

achievement(id=47914, // badge=48440,
    title="In a Rush", 
    description="Become number 1000 within 1 second",
    points=2, // rescore: 10
    trigger=(
        // correct level
        map_id() == MAP_GHOST && 
        
        // ghoul is talking to you if you die to the first ghost
        timer() <= 158 && talking_portrait() == TALK_GHOUL
    )
)

achievement(id=47916, // badge=48449,
    title="Happy Birthday", // rename: "Conservative"
    description="Reach the second floor of the Haunted Mansion with 60 or more candles",
    points=10, // rescore: 25
    trigger=(
        // correct level
        map_id() == MAP_GHOST && 
        
        // transitioning from 1st floor to 2nd floor
        prev(room_id()) == 5 && room_id() == 4 &&

        // enough candles
        candles() >= 60
    )
)

achievement(id=47917, // badge=48443,
    title="An Actual Fire Hazard", // rename: "A b-press is a b-press"
    description="Reach the boss of the Haunted Mansion with 79 or more candles",
    points=25, // rescore: 50
    trigger=(
        // correct level
        map_id() == MAP_GHOST && 
        
        // transitioning from 3rd floor to boss room
        prev(room_id()) == 3 && room_id() == 2 &&

        // enough candles
        candles() >= 79
    )
)

achievement(id=47918, // badge=48444,
    title="Gold Cup on the Disney 500", // rename: "World Record"
    description="Complete the race with 15 or more seconds left",
    points=10, // rescore: 25

    // cross the finish line on Autopia with 15 or more seconds left on the timer
    trigger=(map_id() == MAP_CARS && talking_portrait() == TALK_PETE && timer() >= 15)
)

AUTOPIA_STARS = 35
achievement(
    title="Autopia Superstar",
    description=format("Collect {0} or more stars in one race on Autopia", AUTOPIA_STARS),
    points=10,
    trigger=(
        // count the correct number of stars
        measured(tally(AUTOPIA_STARS, collect_star())) &&
        
        // as long as we are on Autopia
        never(map_id() != MAP_CARS)
    )
)

achievement(id=47920, // badge=48447,
    title="To Boldly Go Where No Mouse Has Gone Before", // rename: "Star Wars"
    description="Reach Star F without getting hit", // on the most difficult route (D<><>, E<>)",
    points=10,
    trigger=(
        // if we are on Space Mountain
        map_id() == MAP_SPACE &&

        // check that we are at the end of Space Mountain
        trigger_when(talking_portrait() == TALK_SPACE_MICKEY) &&

        // pause lock if we take damage
        disable_when(health() < prev(health()),
            until=map_id() != MAP_SPACE)
    )
)

TRAIN_LIMIT = 45
achievement(id=47921, // badge=48450,
    title="Full Steam Ahead", // rename: "Mine Craft"
    description=format("Reach the correct station within {0} seconds without getting hit", TRAIN_LIMIT),
    points=10, // rescore: 25
    trigger=(
        // correct stage
        map_id() == MAP_TRAIN &&
        
        // disable the achievement if we go over time
        timer() > (70 - TRAIN_LIMIT) &&

        // you picked the right route if Goofy is talking to us
        trigger_when(talking_portrait() == TALK_COWBOY_GOOFY) &&

        // pause lock if we ever take damage
        disable_when(health() < prev(health()),
            until=map_id() != MAP_TRAIN)
    )
)

SMALL_WORLD_DOOR = [
    {"x": 0x150d, "y": 0x0104},
    {"x": 0x150e, "y": 0x0104},
]
achievement(
    title="It's a Small World", 
    description="This ride is closed for maintenance. Sorry for the inconvenience!",
    points=1,
    trigger=(
        // correct level
        map_id() == MAP_OVERWORLD && 
        
        // stand in front of It's a Small World for 5 consecutive frames
        // (need frame count because x/y pos flicker for 3f on overworld)
        any_of(SMALL_WORLD_DOOR, c => repeated(5, x_position() == c["x"] && y_position() == c["y"]))
    )
)

achievement(id=47925, // badge=48458,
    title="When You Wish Upon a Star", // rename: "Super Star"
    description="Collect and hold 99 stars",
    points=5, // rescore: 10
    trigger=(
        // if we collected our 99th star
        measured(stars() >= 99, when=collect_star())
    )
)

achievement(id=47926, // badge=48459,
    title="You Know There Are Unlimited Continues, Right?",
    description="Waste your stars on something useless",
    points=5, // rescore: 10
    trigger=(
        // spend the correct number of stars
        prev(stars()) - stars() == PRICE_1UP &&

        // buy a life from the pause menu
        prev(lives()) == 8 && lives() == 9
    )
)

achievement(
    title="A Damsel in Distress",
    description="Rescue a maiden in Pirates of the Caribbean while under the effect of invincibility",
    points=1,
    trigger=(
        // correct stage
        map_id() == MAP_PIRATE &&

        trigger_when(
            // current invincible
            invinc_timer() > 0 && 
            
            // collectables changed
            bitcount(PIRATES_COLLECTABLES) > prev(bitcount(PIRATES_COLLECTABLES)) && 
            
            // but not picking up the candle
            prev(bit7(PIRATES_COLLECTABLES)) == bit7(PIRATES_COLLECTABLES)
        )
    )
)

achievement(
    title="Pressing Pause",
    description="Stop the dancers by freezing time three or more times on the second floor of the Haunted Mansion",
    points=5,
    trigger=(
        // count the number of times we buy freeze time
        measured(tally(3, prev(stars()) - stars() == PRICE_FREEZE && freeze_timer() == 0xb4)) &&

        // reset if we are not on the 2nd floor of the Haunted Mansion
        never(map_id() != MAP_GHOST || room_id() != 4)
    )
)

// star pickup worth 1 in every stage 
count_stars = [collect_star()]
// except Big Thunder Mountain Railroad, where they're worth 5
for i in range(2,5) array_push(count_stars, collect_star() && map_id() == MAP_TRAIN)

leaderboard(id=85700,
    title="Star of the Matterhorn",
    description="Collect as many stars as possible before completing the game or running out of lives",

    start=start_game(),
    cancel=map_id() == MAP_INTRO,
    submit=win_the_game() || lives() == 0,
    
    value=measured(tally(0, count_stars)),
    format="VALUE"
)

leaderboard(id=85701,
    title="Speedy Key Collector",
    description="Collect all six silver keys as fast as possible",

    start=start_game(),
    cancel=map_id() == MAP_INTRO,
    submit=prev(key_count()) == 5 && key_count() == 6,

    value=measured(tally(0, always_true())),
    format="FRAMES",
    lower_is_better=true
)
