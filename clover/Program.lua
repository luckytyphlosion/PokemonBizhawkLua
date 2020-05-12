Program = {};

gEnemyParty = 0x202402c;
gTrainers = 0x823eac8;
gTrainerBattleOpponent_A = 0x20386ae;
Trainer_partySize = 0x20;
Trainer_SIZE = 0x28;
gBaseStats = 0x8254784;
gBaseStats_SIZE = 0x1c;
gBaseStats_abilities = 0x16;
gBaseStats_type1 = 0x6;
gBaseStats_type2 = 0x7;
BATTLE_TYPE_TRAINER = 0x8;
gBattleTypeFlags = 0x2022b4c;

foundTrainers = {};

function Program.concatEVsOrIVs(t, allowZero)
	local output = "";
	local firstValue = true;

	for i, value in ipairs(t) do
		if allowZero or value ~= 0 then
			if not firstValue then
				output = output .. "/";
			end
			output = output .. value .. " " .. PokemonData.stats[i];
			firstValue = false;
		end
	end

	return output;
end

function Program.makeTrainerData()
	local trainerData = {}
	local battleTypeFlags = Memory.readdword(gBattleTypeFlags);
	local partySize;
	local trainerBattleOpponent;

	if bit.band(battleTypeFlags, BATTLE_TYPE_TRAINER) ~= 0 then
		trainerBattleOpponent = Memory.readword(gTrainerBattleOpponent_A);
		if foundTrainers[trainerBattleOpponent] == nil then
			-- gTrainers[trainerNum].partySize
			partySize = Memory.readbyte(gTrainers + Trainer_SIZE * trainerBattleOpponent + Trainer_partySize)
		else
			return "";
		end

		table.insert(trainerData, string.format("Trainer 0x%x:\n", trainerBattleOpponent))
	else
		table.insert(trainerData, "Wild encounter or totem\n");
		partySize = 1;
	end

	for i = 1, partySize, 1 do
		local monData = Program.getPokemonData(i, gEnemyParty);
		local monString = PokemonData.name[monData.pokemonID + 1];

		if monData.gender == 0 then
			monString = monString .. " (M) @ "
		else
			monString = monString .. " (F) @ "
		end
		
		if monData.heldItem ~= 0 then
			monString = monString .. PokemonData.item[monData.heldItem + 1]
		else
			monString = monString .. "None"
		end
		
		monString = monString .. "\nAbility: "
		local abilityID;

		if monData.hiddenAbility == 0 then
			local abilityAddr = gBaseStats + gBaseStats_SIZE * monData.pokemonID + gBaseStats_abilities + monData.ability
			abilityID = Memory.readbyte(abilityAddr)
		else
			abilityID = monData.hiddenAbility
		end
		
		monString = monString .. PokemonData.ability[abilityID + 1];
		monString = monString .. "\nLevel: " .. monData.level;
		local evOutput = Program.concatEVsOrIVs(monData.EVs, false);
		if evOutput ~= "" then
			monString = monString .. "\nEVs: " .. evOutput;
		end
		monString = monString .. "\nIVs: " .. Program.concatEVsOrIVs(monData.IVs, true);
		monString = monString .. "\nStats: ";
		
		local firstStat = true;

		for j, stat in ipairs(monData.stats) do
			if not firstStat then
				monString = monString .. "/";
			end
			monString = monString .. stat;
			firstStat = false;
		end

		local type1 = Memory.readbyte(gBaseStats + gBaseStats_SIZE * monData.pokemonID + gBaseStats_type1)
		local type2 = Memory.readbyte(gBaseStats + gBaseStats_SIZE * monData.pokemonID + gBaseStats_type2)
		monString = monString .. "\nType: "

		if type1 == type2 then
			monString = monString .. PokemonData.type[type1 + 1];
		else
			monString = monString .. PokemonData.type[type1 + 1] .. "/" .. PokemonData.type[type2 + 1];
		end

		monString = monString .. "\n" .. PokemonData.nature[monData.nature + 1] .. " Nature";

		for j, move in ipairs(monData.moves) do
			if move == 0 then
				break;
			end
			monString = monString .. "\n- " .. PokemonData.move[move + 1];
		end
		
		monString = monString .. "\n\n";
		table.insert(trainerData, monString);
	end

	table.insert(trainerData, "===================================\n\n");

	if trainerBattleOpponent ~= nil then
		foundTrainers[trainerBattleOpponent] = true;
	end

	return table.concat(trainerData, "");
end

function Program.getPokemonData(index, partySrc)
	local start = partySrc + (index - 1) * 0x64;
	
	local personality = Memory.readdword(start)
	local otid = Memory.readdword(start + 4)
	local magicword = bit.bxor(personality, otid)

	local aux = personality % 24
	local growthoffset = (TableData.growth[aux+1] - 1) * 12
	local attackoffset = (TableData.attack[aux+1] - 1) * 12
	local effortoffset = (TableData.effort[aux+1] - 1) * 12
	local miscoffset   = (TableData.misc[aux+1]   - 1) * 12
	
	local growth1 = bit.bxor(Memory.readdword(start+32+growthoffset),   magicword)
	local growth2 = bit.bxor(Memory.readdword(start+32+growthoffset+4), magicword)
	local growth3 = bit.bxor(Memory.readdword(start+32+growthoffset+8), magicword)
	local attack1 = bit.bxor(Memory.readdword(start+32+attackoffset),   magicword)
	local attack2 = bit.bxor(Memory.readdword(start+32+attackoffset+4), magicword)
	local attack3 = bit.bxor(Memory.readdword(start+32+attackoffset+8), magicword)
	local effort1 = bit.bxor(Memory.readdword(start+32+effortoffset),   magicword)
	local effort2 = bit.bxor(Memory.readdword(start+32+effortoffset+4), magicword)
	local effort3 = bit.bxor(Memory.readdword(start+32+effortoffset+8), magicword)
	local misc1   = bit.bxor(Memory.readdword(start+32+miscoffset),     magicword)
	local misc2   = bit.bxor(Memory.readdword(start+32+miscoffset+4),   magicword)
	local misc3   = bit.bxor(Memory.readdword(start+32+miscoffset+8),   magicword)
	
	local cs = Utils.addhalves(growth1) + Utils.addhalves(growth2) + Utils.addhalves(growth3)
	         + Utils.addhalves(attack1) + Utils.addhalves(attack2) + Utils.addhalves(attack3)
			 + Utils.addhalves(effort1) + Utils.addhalves(effort2) + Utils.addhalves(effort3)
			 + Utils.addhalves(misc1)   + Utils.addhalves(misc2)   + Utils.addhalves(misc3)
	cs = cs % 65536
	
	local status_aux = Memory.readdword(start+80)
	local sleep_turns_result = 0
	local status_result = 0
	if status_aux == 0 then
		status_result = 0
	elseif status_aux < 8 then
		sleep_turns_result = status_aux
		status_result = 1
	elseif status_aux == 8 then
		status_result = 2	
	elseif status_aux == 16 then
		status_result = 3	
	elseif status_aux == 32 then
		status_result = 4	
	elseif status_aux == 64 then
		status_result = 5	
	elseif status_aux == 128 then
		status_result = 6	
	end

	monData = {
		pokemonID = Utils.getbits(growth1, 0, 16),
		heldItem = Utils.getbits(growth1, 16, 16),
		friendship = Utils.getbits(growth3, 8, 8),
		hiddenAbility = Utils.getbits(growth3, 16, 8);

		move1 = Utils.getbits(attack1, 0, 16),
		move2 = Utils.getbits(attack1, 16, 16),
		move3 = Utils.getbits(attack2, 0, 16),
		move4 = Utils.getbits(attack2, 16, 16),
		pp = attack3,

		hpEV = Utils.getbits(effort1, 0, 8);
		atkEV = Utils.getbits(effort1, 8, 8);
		defEV = Utils.getbits(effort1, 16, 8);
		speedEV = Utils.getbits(effort1, 24, 8);
		spatkEV = Utils.getbits(effort2, 0, 8);
		spdefEV = Utils.getbits(effort2, 8, 8);

		pokerus = Utils.getbits(misc1, 0, 8),
		gender = Utils.getbits(misc1, 31, 1),
		
		hpIV = Utils.getbits(misc2, 0, 5),
		atkIV = Utils.getbits(misc2, 5, 5),
		defIV = Utils.getbits(misc2, 10, 5),
		speedIV = Utils.getbits(misc2, 15, 5),
		spatkIV = Utils.getbits(misc2, 20, 5),
		spdefIV = Utils.getbits(misc2, 25, 5),
		ability = Utils.getbits(misc2, 31, 1),

		level = Memory.readbyte(start + 84),
		nature = personality % 25,
		curHP = Memory.readword(start + 86),
		maxHP = Memory.readword(start + 88),
		atk = Memory.readword(start + 90),
		def = Memory.readword(start + 92),  
		spe = Memory.readword(start + 94),
		spa = Memory.readword(start + 96),
		spd = Memory.readword(start + 98),

		tid = Utils.getbits(otid, 0, 16),
		sid = Utils.getbits(otid, 16, 16),

		status = status_result,
		sleep_turns = sleep_turns_result,
		personality = personality
	};

	monData.EVs = {monData.hpEV, monData.atkEV, monData.defEV, monData.spatkEV, monData.spdefEV, monData.speedEV};
	monData.IVs = {monData.hpIV, monData.atkIV, monData.defIV, monData.spatkIV, monData.spdefIV, monData.speedIV};
	monData.stats = {monData.maxHP, monData.atk, monData.def, monData.spa, monData.spd, monData.spe};
	monData.moves = {monData.move1, monData.move2, monData.move3, monData.move4};

	return monData;
end
