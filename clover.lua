DATA_FOLDER = "clover";

dofile (DATA_FOLDER .. "/Data.lua");
dofile (DATA_FOLDER .. "/Memory.lua");
dofile (DATA_FOLDER .. "/Program.lua");
dofile (DATA_FOLDER .. "/Utils.lua");

function onIsInBattle()
	local status, output = pcall(Program.makeTrainerData);
	if status == false then
		print(output);
		client.pause();
	elseif output ~= "" then
		local logFile = io.open("trainer_sets_routing.txt", "a");
		logFile:write(output);
		logFile:close();
		print("Wrote trainer or encounter data!");
	end
end

event.onmemoryexecute(onIsInBattle, 0x800ff98);

print("Running!");

while true do
	emu.frameadvance();
end
