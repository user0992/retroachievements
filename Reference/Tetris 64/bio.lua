-- this is the path to the file containing just a single integer BPM
-- if the file is local here, a relative path name (like the example below) should be fine
-- if the file has some fixed location elsewhere, copy the whole absolute path name starting with "C:/"
filename = "output.txt"
FREQUENCY = 15

-- ACTUAL SCRIPT STARTS HERE
bpm = 0
frame = 0
while true do
	-- at the specified frequency, get a new BPM
	if frame % FREQUENCY == 0 then
		fp = io.open(filename, 'r')
		bpm = tonumber(fp:read("*all"))
		fp:close()
	end
	frame = frame + 1

	memory.write_u8(0x04E497, 1, "RDRAM")
	memory.write_u16_be(0x04E494, bpm, "RDRAM")
	emu.frameadvance()
end