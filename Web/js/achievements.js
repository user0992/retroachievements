const Console = Object.freeze({
	// Nintendo
	GB: { id: 4, name: "Game Boy", icon: "gb", },
	GBC: { id: 6, name: "Game Boy Color", icon: "gbc", },
	GBA: { id: 5, name: "Game Boy Advance", icon: "gba", },
	NES: { id: 7, name: "NES/Famicom", icon: "nes", },
	SNES: { id: 3, name: "SNES/Super Famicom", icon: "snes", },
	N64: { id: 2, name: "Nintendo 64", icon: "n64", },
	GCN: { id: 16, name: "GameCube", icon: "gc", },
	DS: { id: 18, name: "Nintendo DS", icon: "ds", },
	DSI: { id: 78, name: "Nintendo DSi", icon: "dsi", },
	PKMN: { id: 24, name: "Pokemon Mini", icon: "mini", },
	VB: { id: 28, name: "Virtual Boy", icon: "vb", },

	// Sony
	PSX: { id: 12, name: "PlayStation", icon: "ps1", },
	PS2: { id: 21, name: "PlayStation 2", icon: "ps2", },
	PSP: { id: 41, name: "PlayStation Portable", icon: "psp", },
});

function console_icon(tag) { return `https://static.retroachievements.org/assets/images/system/${tag}.png`; }
const ConsoleMap = Object.fromEntries(
	Object.entries(Console).map(([k, v]) => [v.id, v])
);

const AssetState = Object.freeze({
	CORE: { rank: 0, name: 'core', marker: '', },
	UNOFFICIAL: { rank: 1, name: 'unofficial', marker: '🚧 '},
	LOCAL: { rank: 2, name: 'local', marker: '✏️ '},
});

class Achievement
{
	id = -1;
	title;
	desc;
	points = 5;
	author;
	achtype = "";
	badge;
	state;
	logic;

	constructor() {  }
	static fromJSON(json)
	{
		let ach = new Achievement();
		ach.id = json.ID;
		ach.title = json.Title;
		ach.desc = json.Description;
		ach.points = json.Points;
		ach.author = json.Author;
		ach.achtype = json.Type;
		ach.badge = json.BadgeURL;

		ach.state = AssetState.CORE;
		if (json.Flags == 5) ach.state = AssetState.UNOFFICIAL;

		ach.logic = Logic.fromString(json.MemAddr);
		return ach;
	}
	
	static fromLocal(row)
	{
		let ach = new Achievement();
		ach.id = +row[0];
		ach.title = row[2];
		ach.desc = row[3];
		ach.points = +row[8];
		ach.author = row[7];
		ach.achtype = row[6];
		ach.badge = `https://media.retroachievements.org/Badge/${row[13]}.png`
		
		ach.state = AssetState.LOCAL;
		ach.logic = Logic.fromString(row[1]);
		return ach;
	}
}

class Leaderboard
{
	id = -1;
	title;
	desc;
	format;
	lower_is_better = true;
	state = null;
	components = {};

	constructor() {  }
	static fromJSON(json)
	{
		let lb = new Leaderboard();
		lb.id = json.ID;
		lb.title = json.Title;
		lb.desc = json.Description;
		lb.format = json.Format;
		lb.lower_is_better = json.LowerIsBetter;

		lb.components = {};
		for (let part of json.Mem.split("::"))
		{
			let tag = part.substring(0, 3);
			let mem = part.substring(4);
			lb.components[tag] = Logic.fromString(mem);
		}
		lb.state = AssetState.CORE;
		return lb;
	}
	
	static fromLocal(row)
	{
		let lb = new Leaderboard();
		lb.id = +row[0].substring(1);
		lb.title = row[6];
		lb.desc = row[7];
		lb.format = row[5];
		lb.lower_is_better = row[8] == '1';

		lb.components = {
			'STA': Logic.fromString(row[1]),
			'CAN': Logic.fromString(row[2]),
			'SUB': Logic.fromString(row[3]),
			'VAL': Logic.fromString(row[4]),
		}
		lb.state = AssetState.LOCAL;
		return lb;
	}
}

class AchievementSet
{
	id;
	title = null;
	icon = null;
	console = null;
	achievements = [];
	leaderboards = [];

	constructor() {  }
	static fromJSON(json)
	{
		let achset = new AchievementSet();
		achset.id = json.ID;
		achset.title = json.Title;
		achset.icon = json.ImageIconURL;
		achset.console = json.ConsoleID; // TODO: make enum

		achset.achievements = json.Achievements
			.filter((x) => !x.Title.toUpperCase().includes('[VOID]'))
			.map((x) => Achievement.fromJSON(x));
		achset.leaderboards = json.Leaderboards
			.filter((x) => !x.Hidden)
			.map((x) => Leaderboard.fromJSON(x));
		
		return achset;
	}

	static fromLocal(txt)
	{
		function parseColons(line)
		{
			let res = [];
			let start = 0, inquotes = false;

			let chars = Array.from(line + ':');
			for (let [ci, ch] of chars.entries())
			{
				if (start > ci) continue;
				else if (start == ci && !inquotes && ch == '"')
				{
					inquotes = true;
					continue;
				}
				else if ((inquotes && ch == '"' && line[ci-1] != '\\') || (!inquotes && ch == ':'))
				{
					if (inquotes) ci += 1;
					let x = chars.slice(start, ci).join('');
					if (inquotes) x = JSON.parse(x);

					res.push(x);
					start = ci + 1;
					inquotes = false;
				}
			}
			return res;
		}

		const lines = txt.match(/[^\r\n]+/g);
		let achset = new AchievementSet();
		achset.title = lines[1];
		for (let i = 2; i < lines.length; i++)
		{
			const row = parseColons(lines[i]);
			switch (row[0][0])
			{
				case 'N': // TODO: this is a local code note
					break;
				case 'L': // leaderboard
					achset.leaderboards.push(Leaderboard.fromLocal(row));
					break;
				default: // achievement
					achset.achievements.push(Achievement.fromLocal(row));
					break;
			}
		}
		return achset;
	}
}

const LABEL_RE = RegExp(
	"([\\(\\[\\{])" + 
	".*" +
	"(\\d+ ?[x\\*\u00D7] ?)*" +
	"(upper4|lower4|\\d+[\\- ]?(?:bit|byte)s?|float|double32|mbf32|bitflags?|bitfield|bitcount)(?: BE| LE)?" + 
	"([x\\*\u00D7] ?\\d+ ?)*" + 
	".*" +
	"([\\)\\]\\}])", 
"gi");

class CodeNote
{
	addr;
	size = 1;
	type = null; // null means unknown, otherwise MemSize object
	note = "";
	author = "";
	constructor(addr, note, author)
	{
		this.addr = +addr;
		this.note = note;
		this.author = author;

		[this.type, this.size] = CodeNote.getSize(note);
	}

	contains(addr)
	{
		return addr >= this.addr && addr < this.addr + this.size;
	}

	isArray()
	{
		if (this.type == null) return false;
		return this.size != this.type.bytes;
	}

	// transliterated closely from CodeNoteModel::ExtractSize for maximum compatability
	// https://github.com/RetroAchievements/RAIntegration/blob/8a26afb6adb27e22c737a6006344abce8f24c21f/src/data/models/CodeNoteModel.cpp#L242
	static getSize(note)
	{
		let bytes = 1;
		let memSize = null;

		const sNote = note.split('\n', 1)[0].toLowerCase();
		if (sNote.length < 4) return [null, 1];

		let bytesFromBits = false;
		let foundSize = false;
		let prevWordIsSize = false;
		let prevWordIsNumber = false;

		let prevWord = "";
		for (const m of sNote.matchAll(/((\d+)|([a-z]+)|.)/gi))
		{
			let word = m[1];
			let wordIsNumber = m[1] == m[2]
			let wordIsSize = false;
			
			if (wordIsNumber)
			{
				let num = +word;
				if (prevWord == 'mbf')
				{
					if (num == 32 || num == 40)
					{
						bytes = num / 8;
						memSize = MemSize.MBF32;
						wordIsSize = true;
						foundSize = true;
					}
				}
				else if (prevWord == 'double' && num == 32)
				{
					bytes = num / 8;
					memSize = MemSize.DBL32;
					wordIsSize = true;
					foundSize = true;
				}
			}
			else if (prevWordIsSize)
			{
				if (word == 'float')
				{
					if (memSize == MemSize.DWORD)
					{
						memSize = MemSize.FLOAT;
						wordIsSize = true;
					}
				}
				else if (word == 'double')
				{
					if (memSize == MemSize.DWORD || bytes == 8)
					{
						memSize = MemSize.DBL32;
						wordIsSize = true;
					}
				}
				else if (word == 'be' || word == 'bigendian')
				{
					switch (memSize)
					{
						case MemSize.WORD:  memSize = MemSize.WORD_BE;  break;
						case MemSize.TBYTE: memSize = MemSize.TBYTE_BE; break;
						case MemSize.DWORD: memSize = MemSize.DWORD_BE; break;
						case MemSize.FLOAT: memSize = MemSize.FLOAT_BE; break;
						case MemSize.DBL32: memSize = MemSize.DBL32_BE; break;
						default: break;
					}
				}
				else if (word == 'le')
				{
					if (memSize == MemSize.MBF32)
						memSize = MemSize.MBF32_LE;
				}
				else if (word == 'mbf')
				{
					if (bytes == 4 || bytes == 5)
						memSize = MemSize.MBF32;
				}
			}
			else if (prevWordIsNumber)
			{
				let num = +prevWord;
				if (word == 'bit' || word == 'bits')
				{
					if (!foundSize)
					{
						bytes = Math.floor((num + 7) / 8);
						memSize = null;
						bytesFromBits = true;
						wordIsSize = true;
						foundSize = true;
					}
				}
				else if (word == 'byte' || word == 'bytes')
				{
					if (!foundSize || bytesFromBits)
					{
						bytes = num;
						memSize = null;
						bytesFromBits = false;
						wordIsSize = true;
						foundSize = true;
					}
				}

				if (wordIsSize)
				{
					switch (bytes)
					{
						case 0: bytes = 1; break;
						case 1: memSize = MemSize.BYTE; break;
						case 2: memSize = MemSize.WORD; break;
						case 3: memSize = MemSize.TBYTE; break;
						case 4: memSize = MemSize.DWORD; break;
						default: memSize = null; break;
					}
				}
			}
			else if (word == 'float')
			{
				if (!foundSize)
				{
					bytes = 4;
					memSize = MemSize.FLOAT;
					wordIsSize = true;

					if (prevWord == 'be' || prevWord == 'bigendian')
						memSize = MemSize.FLOAT_BE;
				}
			}
			else if (word == 'double')
			{
				if (!foundSize)
				{
					bytes = 8;
					memSize = MemSize.DBL32;
					wordIsSize = true;

					if (prevWord == 'be' || prevWord == 'bigendian')
						memSize = MemSize.DBL32_BE;
				}
			}

			if (word != ' ' && word != '-')
			{
				prevWordIsSize = wordIsSize;
				prevWordIsNumber = wordIsNumber;
				prevWord = word;
			}
		}

		return [memSize, bytes];
	}
}

// https://github.com/RetroAchievements/RAIntegration/blob/8a26afb6adb27e22c737a6006344abce8f24c21f/tests/data/models/CodeNoteModel_Tests.cpp#L53
function testCodeNotes()
{
	let count = 0, fails = 0;
	function _testNote(note, size, type)
	{
		let cn = new CodeNote(0x0, note);
		let res = cn.size == size && cn.type == type ? "PASS" : "FAIL";
		
		console.log(note, '-->', size, type);
		console.log(res, cn);

		count += 1;
		if (!(cn.size == size && cn.type == type)) fails += 1;
	}

	_testNote("", 1, null);
	_testNote("Test", 1, null);
	_testNote("16-bit Test", 2, MemSize.WORD);
	_testNote("Test 16-bit", 2, MemSize.WORD);
	_testNote("Test 16-bi", 1, null);
	_testNote("[16-bit] Test", 2, MemSize.WORD);
	_testNote("[16 bit] Test", 2, MemSize.WORD);
	_testNote("[16 Bit] Test", 2, MemSize.WORD);
	_testNote("[24-bit] Test", 3, MemSize.TBYTE);
	_testNote("[32-bit] Test", 4, MemSize.DWORD);
	_testNote("[32 bit] Test", 4, MemSize.DWORD);
	_testNote("[32bit] Test", 4, MemSize.DWORD);
	_testNote("Test [16-bit]", 2, MemSize.WORD);
	_testNote("Test (16-bit)", 2, MemSize.WORD);
	_testNote("Test (16 bits)", 2, MemSize.WORD);
	_testNote("[64-bit] Test", 8, null);
	_testNote("[128-bit] Test", 16, null);
	_testNote("[17-bit] Test", 3, MemSize.TBYTE);
	_testNote("[100-bit] Test", 13, null);
	_testNote("[0-bit] Test", 1, null);
	_testNote("[1-bit] Test", 1, MemSize.BYTE);
	_testNote("[4-bit] Test", 1, MemSize.BYTE);
	_testNote("[8-bit] Test", 1, MemSize.BYTE);
	_testNote("[9-bit] Test", 2, MemSize.WORD);
	_testNote("bit", 1, null);
	_testNote("9bit", 2, MemSize.WORD);
	_testNote("-bit", 1, null);

	_testNote("[16-bit BE] Test", 2, MemSize.WORD_BE);
	_testNote("[24-bit BE] Test", 3, MemSize.TBYTE_BE);
	_testNote("[32-bit BE] Test", 4, MemSize.DWORD_BE);
	_testNote("Test [32-bit BE]", 4, MemSize.DWORD_BE);
	_testNote("Test (32-bit BE)", 4, MemSize.DWORD_BE);
	_testNote("Test 32-bit BE", 4, MemSize.DWORD_BE);
	_testNote("[16-bit BigEndian] Test", 2, MemSize.WORD_BE);
	_testNote("[16-bit-BE] Test", 2, MemSize.WORD_BE);
	_testNote("[4-bit BE] Test", 1, MemSize.BYTE);

	_testNote("8 BYTE Test", 8, null);
	_testNote("Test 8 BYTE", 8, null);
	_testNote("Test 8 BYT", 1, null);
	_testNote("[2 Byte] Test", 2, MemSize.WORD);
	_testNote("[4 Byte] Test", 4, MemSize.DWORD);
	_testNote("[4 Byte - Float] Test", 4, MemSize.FLOAT);
	_testNote("[8 Byte] Test", 8, null);
	_testNote("[100 Bytes] Test", 100, null);
	_testNote("[2 byte] Test", 2, MemSize.WORD);
	_testNote("[2-byte] Test", 2, MemSize.WORD);
	_testNote("Test (6 bytes)", 6, null);
	_testNote("[2byte] Test", 2, MemSize.WORD);

	_testNote("[float] Test", 4, MemSize.FLOAT);
	_testNote("[float32] Test", 4, MemSize.FLOAT);
	_testNote("Test float", 4, MemSize.FLOAT);
	_testNote("Test floa", 1, null);
	_testNote("is floating", 1, null);
	_testNote("has floated", 1, null);
	_testNote("16-afloat", 1, null);
	_testNote("[float be] Test", 4, MemSize.FLOAT_BE);
	_testNote("[float bigendian] Test", 4, MemSize.FLOAT_BE);
	_testNote("[be float] Test", 4, MemSize.FLOAT_BE);
	_testNote("[bigendian float] Test", 4, MemSize.FLOAT_BE);
	_testNote("[32-bit] pointer to float", 4, MemSize.DWORD);

	_testNote("[64-bit double] Test", 8, MemSize.DBL32);
	_testNote("[64-bit double BE] Test", 8, MemSize.DBL32_BE);
	_testNote("[double] Test", 8, MemSize.DBL32);
	_testNote("[double BE] Test", 8, MemSize.DBL32_BE);
	_testNote("[double32] Test", 4, MemSize.DBL32);
	_testNote("[double32 BE] Test", 4, MemSize.DBL32_BE);
	_testNote("[double64] Test", 8, MemSize.DBL32);

	_testNote("[MBF32] Test", 4, MemSize.MBF32);
	_testNote("[MBF40] Test", 5, MemSize.MBF32);
	_testNote("[MBF32 float] Test", 4, MemSize.MBF32);
	_testNote("[MBF80] Test", 1, null);
	_testNote("[MBF320] Test", 1, null);
	_testNote("[MBF-32] Test", 4, MemSize.MBF32);
	_testNote("[32-bit MBF] Test", 4, MemSize.MBF32);
	_testNote("[40-bit MBF] Test", 5, MemSize.MBF32);
	_testNote("[MBF] Test", 1, null);
	_testNote("Test MBF32", 4, MemSize.MBF32);
	_testNote("[MBF32 LE] Test", 4, MemSize.MBF32_LE);
	_testNote("[MBF40-LE] Test", 5, MemSize.MBF32_LE);

	_testNote("42=bitten", 1, null);
	_testNote("42-bitten", 1, null);
	_testNote("bit by bit", 1, null);
	_testNote("bit1=chest", 1, null);

	_testNote("Bite count (16-bit)", 2, MemSize.WORD);
	_testNote("Number of bits collected (32 bits)", 4, MemSize.DWORD);

	_testNote("100 32-bit pointers [400 bytes]", 400, null);
	_testNote("[400 bytes] 100 32-bit pointers", 400, null);

	console.log(fails + "/" + count + " failed")
}