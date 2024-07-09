ADDR_CAM_X = 0x0702
ADDR_CAM_Y = 0x070a
ADDR_PLAYER_X = 0x41c1
ADDR_PLAYER_Y = 0x41c4
ADDR_VISIBILITY = 0x41e3
ADDR_STAGE = 0x0750
ADDR_HEALTH = 0x0754
ADDR_CHAR_STATE = 0x4185

X_OFFSET = 0x60
Y_OFFSET = 0xa1

INVISIBLE = 0x58

stage = mainmemory.read_u8(ADDR_STAGE)
STAGE_W = {0x1700, 0x1500, 0x1600, 0x0F00, 0x0D00}

w = STAGE_W[stage+1]
h = STAGE_H[stage+1]

target_x = 0
target_y = 0

--snes.setlayer_bg_2(false)
snes.setlayer_bg_3(false)

last_cam_x = mainmemory.read_u16_le(ADDR_CAM_X)
last_cam_y = mainmemory.read_u16_le(ADDR_CAM_Y)
no_move = 0

more = true
last_row = false
while more do
	mainmemory.write_u8(ADDR_CHAR_STATE, 0x03)
	mainmemory.write_u8(ADDR_HEALTH, 20)
	mainmemory.write_u8(ADDR_VISIBILITY, INVISIBLE)

	char_x = 0x3FFF
	if target_x == 0 then char_x = 0 end

	char_y = target_y + Y_OFFSET
	if target_y == 0 then char_y = 0 end

	mainmemory.write_u16_le(ADDR_PLAYER_X, char_x)
	mainmemory.write_u16_le(ADDR_PLAYER_Y, char_y)

	curr_cam_x = mainmemory.read_u16_le(ADDR_CAM_X)
	curr_cam_y = mainmemory.read_u16_le(ADDR_CAM_Y)

	no_move = no_move + 1
	if curr_cam_x ~= last_cam_x or curr_cam_y ~= last_cam_y then no_move = 0 end

	if (curr_cam_x == target_x and curr_cam_y == target_y) then
		filename = string.format("maps/stage%d/%04d-%04d.png", stage, curr_cam_x, curr_cam_y)
		print("screenshotting " .. filename)
		client.screenshot(filename)

		-- shift right one screen
		target_x = target_x + 0x100

		if no_move > 60 then
			if last_row then
				more = false
			end
			last_row = true
			target_y = curr_cam_y
		end

		-- if the camera cannot go down further
		if target_x > w then
			-- reset to the top
			target_x = 0
		
			-- shift down one screen
			target_y = target_y + 0xD0
		end

		no_move = 0
	end

	last_cam_x = curr_cam_x
	last_cam_y = curr_cam_y

	emu.frameadvance()
end

mainmemory.write_u16_le(ADDR_PLAYER_X, 0)
mainmemory.write_u16_le(ADDR_PLAYER_Y, 0)

snes.setlayer_bg_3(true)
snes.setlayer_bg_3(true)