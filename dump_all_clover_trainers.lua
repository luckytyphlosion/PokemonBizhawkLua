DATA_FOLDER = "clover";

dofile (DATA_FOLDER .. "/Data.lua");
dofile (DATA_FOLDER .. "/Memory.lua");
dofile (DATA_FOLDER .. "/Program.lua");
dofile (DATA_FOLDER .. "/Utils.lua");

curTrainer = 0;
finalTrainer = false;
continueDump = true;
loadSavestate = false;

function onCreateNPCTrainerParty()
	memory.write_u16_le(gTrainerBattleOpponent_A, curTrainer);
	if curTrainer % 20 == 1 then
		print("curTrainer: " .. curTrainer);
	end
	curTrainer = curTrainer + 1;
	if curTrainer == 734 then
		curTrainer = 736;
	elseif curTrainer == 738 then
		curTrainer = 740;
	elseif curTrainer >= 742 then
		finalTrainer = true;
	end
end

function onIsInBattle()
	local status, output = pcall(Program.makeTrainerData);
	if status == false then
		print(output);
		client.pause();
	elseif output ~= "" then
		logFile:write(output);
	end
	loadSavestate = true;
	if finalTrainer then
		continueDump = false;
	end
end

logFile = io.open("all_trainer_sets.txt", "w");

onCreateNPCTrainerPartyGUID = event.onmemoryexecute(onCreateNPCTrainerParty, 0x800ff8a);
onIsInBattleGUID = event.onmemoryexecute(onIsInBattle, 0x800ff98);

print("Running!");

while continueDump do
	emu.frameadvance();
	if loadSavestate then
		loadSavestate = false;
		savestate.loadslot(3);
	end
end

print("Done!");
logFile:close();

event.unregisterbyid(onCreateNPCTrainerPartyGUID);
event.unregisterbyid(onIsInBattleGUID);
