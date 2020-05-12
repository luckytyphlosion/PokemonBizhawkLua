
gObjectEvents = 0x2036e38;
gPlayerAvatar_objectEventId = 0x2037078 + 0x5;
ObjectEvent_SIZE = 0x24;

function printCoords()
	local playerObjectEventId = memory.read_u8(gPlayerAvatar_objectEventId);

	playerObjectCoordsPtr = gObjectEvents + ObjectEvent_SIZE * playerObjectEventId + 0x10;

	local playerX = memory.read_s16_le(playerObjectCoordsPtr) - 7;
	local playerY = memory.read_s16_le(playerObjectCoordsPtr + 2) - 7;
	
	gui.cleartext();
	gui.text(10, 10, "x: " .. playerX .. ", y: " .. playerY);
end

print("print_coords.lua running!");

--keyPressed = false;
--keyDown = false;

while true do
	--local keyDownCur = input.get()["O"] == true;
	--keyPressed = (not keyDownCur ~= not keyDown) and keyDownCur;
	--keyDown = keyDownCur;

	--if keyPressed then
	--	printCoords();
	--end

	emu.frameadvance();
	printCoords();
end
