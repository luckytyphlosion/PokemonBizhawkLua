
dofile ("clover_includes.lua");

gPlayerParty = 0x2024284;

function onPokemonSummaryScreen()
	local cursorPos = emu.getregister("R1");
	local monData = Program.getPokemonData(cursorPos + 1, gPlayerParty);
	if monData ~= nill then
		print("IVs: " .. Program.concatEVsOrIVs(monData.IVs, true) .. "\nEVs: " .. Program.concatEVsOrIVs(monData.EVs, true));
	end
end

function onExit()
	event.unregisterbyid(onPokemonSummaryScreenId)
	print("Exited check_ivs.lua!");
end

onPokemonSummaryScreenId = event.onmemoryexecute(onPokemonSummaryScreen, 0x81344F8);
event.onexit(onExit);

print("Running check_ivs.lua!");

while true do
	emu.frameadvance();
end
