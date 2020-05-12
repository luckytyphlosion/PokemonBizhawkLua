DATA_FOLDER = "clover"

dofile (DATA_FOLDER .. "/Utils.lua");
dofile (DATA_FOLDER .. "/xoshiro128pp.lua");

gRngValue = 0x3005000;
gRandomTurnNumber = 0x2023e80;
gOtherRandomTurnNumberBase = 0x203f624;
gMain_inBattle = 0x3003529;
NUM_OTHER_RANDOM_TURN_NUMBERS = 8;

function randomizeRNG()
	local value = Random.nextInt();
	print(string.format("value: 0x%08x", value));
	memory.write_u32_le(gRngValue, value);

	local inBattleByte = memory.read_u8(gMain_inBattle);
	local inBattle = Utils.getbits(inBattleByte, 1, 1);
	if inBattle == 1 then
		memory.write_u16_le(gRandomTurnNumber, Random.nextShort());
		
		for i = 1, NUM_OTHER_RANDOM_TURN_NUMBERS, 1 do
			memory.write_u16_le(gOtherRandomTurnNumberBase + (i - 1) * 2, Random.nextShort());
		end
	end
end

Random.seed(os.time());

if true then
	randomizeRNG();
end

event.onloadstate(randomizeRNG);

print("Running!");

while true do
	emu.frameadvance();
end
