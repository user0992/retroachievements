// ~Hack~ Reverie
// #ID = 30906

// --- HELPERS -------------------------------------------------------------------

NULL = 0
function if_else(p, t, f) { if (p) { return t } else return f }
id = (x) => x
ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
function bitx(i, addr) => bit(i % 8, addr + i / 8)

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

// $00010A: Current File [8 bit]
//          00 = A
//          01 = B
//          02 = C
function current_file() => byte(0x00010A)

// $00010B: Current Map [16 bit]
//          0x0001 = Origin D1
//          0x0002 = Treetops D1
//          0x0003 = Subterrane D1
//          0x0004 = Tower inside D1
//          0x0005 = Caldera D1
//          0x0006 = Lake D1
//          0x0007 = Precipice D1
//          0x000a = Tower outside D1
//          0x000e = dance hall D1
//          0x000f = above Precipice D1
//          0x0011 = Origin D2
//          0x0013 = Treetops D2
//          0x0015 = Tower inside D2
//          0x0018 = Precipice D2
//          0x0019 = above Precipice D2
//          0x001a = Treetops treehouses D2
//          0x001b = Treetops inner grove D2
//          0x001c = Tower D2
//          0x001d = Tower clock rooms D2
//          0x001e = Tower left tower D2
//          0x001f = Tower right tower D2
//          0x0020 = dance hall D2
//          0x0021 = Moon below Subterrane D1
//          0x0028 = atlas room Precipice D2
//          0x0030 = Origin D4
//          0x0105 = vestibule
function current_map() => word(0x00010B)

// $000F3A: Loop 1 Hundredths Remaining [8 bit]
function loop_1_hundredths_remaining() => byte(0x000F3A)

// $000F3B: Loop 1 Seconds Remaining [8 bit]
function loop_1_seconds_remaining() => byte(0x000F3B)

// $000F3C: Loop 1 Minutes Remaining [8 bit]
function loop_1_minutes_remaining() => byte(0x000F3C)

// $0013BF: Level Number [8 bit]
//          for message purposes
//          
//          0x01,1 = Galoomba mathematician Treetops D1
//          0x01,2 = Galoomba number the gaps as you fall Treetops D2
//          0x02,1 = Swooper a dormant being Subterrane D1
//          0x02,2 = Swooper hanging four Subterrane D2
//          0x03,1 = Boo treetops vine puzzle Tower D1
//          0x03,2 = Boo overhead dancers Tower D2
//          0x04,1 = Blarggh shoulder work Caldera D1
//          0x04,2 = Blarggh open the closed door Caldera D2
//          0x05,1 = Rip van Fish six doors Lake D1
//          0x05,2 = Rip van Fish left thrice, right twice Lake D2
//          0x06,1 = Monty Mole performed a certain way Precipice D1
//          0x06,2 = Monty Mole
//          0x07,1 = Starman show me their meaning
//          0x12,1 = Boo!
//          0x26,2 = essence of a land is its center Treetops D2
//          0x28,1 = (scroll) scan the land as a clock would
//          0x30,1 through 0x32,2 = essence location scrolls
function level_number() => byte(0x0013BF)

// $001426: Message Box Trigger [8 bit]
//          00 = none
//          01 = message 1
//          02 = message 2
function message_box_trigger() => byte(0x001426)

// $01B900: Reverie File Seed [16 bit]
function reverie_file_seed() => word(0x01B900)

// $01B902: Glyphs of Origin [6 bytes]
//          earth, void, time, fire, sea, sky
function glyphs_of_origin() => byte(0x01B902)

// $01B908: Star Status [8 bit]
//          00 = asleep
//          01 = awake
function star_status() => byte(0x01B908)

// $01B909: Moon Status [8 bit]
//          00 = asleep
//          01 = awake
//          02 = post-game
function moon_status() => byte(0x01B909)

// $01B90A: Moon Essences Solved [8 bit]
//          bit0 | Earth essence
//          bit1 | Void essence
//          bit2 | Time essence
//          bit3 | Fire essence
//          bit4 | Sea essence
//          bit5 | Sky essence
function moon_essences_solved() => byte(0x01B90A)

// $01B90B: Moon Orbs Collected [8 bit]
//          bit0 | Earth orb
//          bit1 | Void orb
//          bit2 | Time orb
//          bit3 | Fire orb
//          bit4 | Sea orb
//          bit5 | Sky orb
function moon_orbs_collected() => byte(0x01B90B)

// $01B90C: Item Box Contents [8 bit]
//          0x00 = empty
//          0x80 = key
function item_box_contents() => byte(0x01B90C)

// $01B90D: Item Box Occupied [8 bit]
//          0 = Empty
//          1 = Has Item
function item_box_occupied() => byte(0x01B90D)

// $01B910: Chest Opened [8 bit]
//          bit0 | Earth chest
//          bit1 | Void chest
//          bit2 | Time chest
//          bit3 | Fire chest
//          bit4 | Sea chest
//          bit5 | Sky chest
function chest_opened() => byte(0x01B910)

// $01B912: Chest Unlocked [8 bit]
//          bit0 | Earth chest
//          bit1 | Void chest
//          bit2 | Time chest
//          bit3 | Fire chest
//          bit4 | Sea chest
//          bit5 | Sky chest
function chest_unlocked() => byte(0x01B912)

// $01B914: Subterrane Pipe Switch States [4 bytes]
//          +0 | room=0x10, correct=3
//          +1 | room=0x01, correct=3
//          +2 | room=0x06, correct=2
//          +3 | room=0x04, correct=1
//          
//          0 = ╩
//          1 = ╣
//          2 = ╦
//          3 = ╠
function subterrane_pipe_switch_states() => dword(0x01B914)

// $01B918: Current Screen [8 bit]
//          counts from 0 in row-major order
//          intro room = 0xFF
function current_screen() => byte(0x01B918)

// $01B919: Music Box Seed [8 bit]
function music_box_seed() => byte(0x01B919)

// $01B91A: Music Box Sequence [8 bit]
function music_box_sequence() => byte(0x01B91A)

// $01B91B: Music Box Index [8 bit]
function music_box_index() => byte(0x01B91B)

// $01B91C: Music Box Buffer [4 bytes]
function music_box_buffer() => dword(0x01B91C)

// $01B921: Puzzle Status [8 bit]
//          bit0 | Music Box Puzzle in Treetops (for key)
//          bit1 | Pipe Puzzle in Subterrane (flood Caldera)
//          bit2 | Clock Puzzle in Tower
//          bit3 | Animal Blocks in Lake (unlock dance hall)
//          bit4 | Vine dance in Treetops
//          bit5 | Glyphs of Origin dance puzzle to wake star
function puzzle_status() => byte(0x01B921)

// $01B922: Clock Switches [4 bytes]
//          from left to right
function clock_switches() => dword(0x01B922)

// $01B926: Animal Blocks [4 bytes]
//          +0 | Sea block
//          +1 | Void block
//          +2 | Fire block
//          +3 | Sky block
function animal_blocks() => dword(0x01B926)

// $01B92A: Tower Door Status [8 bit]
//          0 = Locked
//          1 = Unlocked
function tower_door_status() => byte(0x01B92A)

// $01B92B: Riddle Status - Second Dream [8 bit]
//          bit0 | Earth riddle
//          bit1 | Void riddle
//          bit2 | Time riddle
//          bit3 | Fire riddle
//          bit4 | Sea riddle
//          bit5 | Sky riddle - hanging four
function riddle_status_second_dream() => byte(0x01B92B)

// $01B92E: World Status [8 bit]
//          00 = First Dream
//          01 = Second Dream
//          02 = Third Dream
//          03 = Collapsed Dream
function world_status() => byte(0x01B92E)

// $01B92F: Dark Star Status [8 bit]
//          0 = asleep
//          1 = awake
function dark_star_status() => byte(0x01B92F)

// $01B930: Truth Status [8 bit]
//          bit0 | Genesis climb
//          bit1 | Swamp song
//          bit2 | Swamp door
//          bit3 | Grotto rope
//          bit4 | Ruins block
//          bit5 | Cenote fish puzzle
//          bit6 | Welkin ancient names
//          bit7 | Dark Star's name
function truth_status() => byte(0x01B930)

// $01B931: Fissure Door Sequence [8 bit]
function fissure_door_sequence() => byte(0x01B931)

// $01B932: Ancestor Times [6 bytes]
//          +0 | Earth ancestor
//          +1 | Void ancestor
//          +2 | Time ancestor
//          +3 | Fire ancestor
//          +4 | Sea ancestor
//          +5 | Sky ancestor
function ancestor_times() => byte(0x01B932)

// $01B938: Ruins Clock State [8 bit]
function ruins_clock_state() => byte(0x01B938)

// --- MAIN DATA -------------------------------------------------------------------

// --- AUX FUNCTIONS  -------------------------------------------------------------------

// --- RICH PRESENCE -------------------------------------------------------------------

// --- ACHIEVEMENTS -------------------------------------------------------------------

// --- LEADERBOARDS -------------------------------------------------------------------