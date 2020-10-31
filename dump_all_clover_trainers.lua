DATA_FOLDER = "clover";

dofile (DATA_FOLDER .. "/Data.lua");
dofile (DATA_FOLDER .. "/Memory.lua");
dofile (DATA_FOLDER .. "/Program.lua");
dofile (DATA_FOLDER .. "/Utils.lua");

curTrainer = 0;
finalTrainer = false;
continueDump = true;
loadSavestate = false;
monsWithRandomAbilities = {0, 0, 0, 0, 0, 0};
badTrainers = {
	[0x29] = true,
};

function onBuildTrainerPartyHook()
	memory.write_u16_le(gTrainerBattleOpponent_A, curTrainer);
	if curTrainer % 20 == 0 then
		print("curTrainer: " .. curTrainer);
	end
end

function onError(x)
	return x .. "\n" .. debug.traceback() .. string.format("\ncurTrainer: 0x%x", curTrainer) .. "\n";
end

function onIsInBattle()
	local status, output = xpcall(Program.makeTrainerData, onError);
	loadSavestate = true;
	if status == false then
		print(output);
		loadSavestate = false;
		client.pause();
	elseif output ~= "" then
		logFile:write(output);
	end

	repeat
		curTrainer = curTrainer + 1;
	until not badTrainers[curTrainer];

	if curTrainer >= 742 then -- 742
		continueDump = false;
	end
	monsWithRandomAbilities = {0, 0, 0, 0, 0, 0};
end

function onRandom()
	local lr = emu.getregister("R14");
	if lr ~= 0x800078d and lr ~= 0x9499fcb then
		print(string.format("lr: %07x", lr));
	end
end

function onGetNatureFromPersonality()
	local lr = emu.getregister("R14");
	--if lr ~= 0x800078d and lr ~= 0x9499fcb then
		print(string.format("lr: %07x", lr));
	--end
end

function onGenerateRandomAbility()
	onGenerateRandomAbilityCommon(1);
end

function onGenerateRandomAbilityFull()
	onGenerateRandomAbilityCommon(2);
end

function onGenerateRandomAbilityCommon(val)
	local r7 = emu.getregister("R7");
	local monIndex = (r7 - gEnemyParty)/Pokemon_SIZE + 1;
	monsWithRandomAbilities[monIndex] = val;
	--print(string.format("Generating random ability for opponent 0x%x mon %d!", curTrainer, monIndex));
end

logFile = io.open("all_radical_red_trainer_sets.txt", "w");

onCreateNPCTrainerPartyGUID = event.onmemoryexecute(onBuildTrainerPartyHook, 0x800ff7e);
onIsInBattleGUID = event.onmemoryexecute(onIsInBattle, 0x800ff98);
-- onRandomGUID = event.onmemoryexecute(onRandom, 0x8044ec8);
--onGetNatureFromPersonalityGUID = event.onmemoryexecute(onGetNatureFromPersonality, 0x945bf10);

onGenerateRandomAbilityGUID = event.onmemoryexecute(onGenerateRandomAbility, 0x945f512);
onGenerateRandomAbilityFullGUID = event.onmemoryexecute(onGenerateRandomAbilityFull, 0x945f524);

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
--event.unregisterbyid(onRandomGUID);
event.unregisterbyid(onGenerateRandomAbilityGUID);
event.unregisterbyid(onGenerateRandomAbilityFullGUID);

