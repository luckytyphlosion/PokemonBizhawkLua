DATA_FOLDER = "clover";

dofile (DATA_FOLDER .. "/Data.lua");
dofile (DATA_FOLDER .. "/Memory.lua");
dofile (DATA_FOLDER .. "/Program.lua");
dofile (DATA_FOLDER .. "/Utils.lua");

gPlayerParty = 0x2024284;

function onPokemonSummaryScreen()
	local cursorPos = emu.getregister("R1");
	local monData = Program.getPokemonData(cursorPos + 1, gPlayerParty);
	print("IVs: " .. Program.concatEVsOrIVs(monData.IVs, true) .. "\nEVs: " .. Program.concatEVsOrIVs(monData.EVs, true));
	
end

event.onmemoryexecute(onPokemonSummaryScreen, 0x81344F8);

print("Running!");

while true do
	emu.frameadvance();
end
