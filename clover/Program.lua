Program = {};

gEnemyParty = 0x202402c;
Pokemon_SIZE = 0x64;
gTrainers = 0x823eac8;
gTrainerBattleOpponent_A = 0x20386ae;
Trainer_partySize = 0x20;
Trainer_SIZE = 0x28;
gBaseStats = 0x9970fe8;
gBaseStats_stats = 0x0;
gBaseStats_SIZE = 0x1c;
gBaseStats_abilities = 0x16;
gBaseStats_type1 = 0x6;
gBaseStats_type2 = 0x7;
gBaseStats_hiddenAbility = 0x1a;
BATTLE_TYPE_TRAINER = 0x8;
gBattleTypeFlags = 0x2022b4c;

foundTrainers = {};

MON_DATA_HELD_ITEM = 12;
MON_DATA_MOVE1 = 13;
MON_DATA_MOVE2 = 14;
MON_DATA_MOVE3 = 15;
MON_DATA_MOVE4 = 16;

MON_DATA_IV_BASE = 39;
MON_DATA_HP_IV = 39;
MON_DATA_ATK_IV = 40;
MON_DATA_DEF_IV = 41;
MON_DATA_SPEED_IV = 42;
MON_DATA_SPATK_IV = 43;
MON_DATA_SPDEF_IV = 44;
MON_DATA_NATURE = 91;

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
		if trainerBattleOpponent == 0x29 then
			print(string.format("partySize: %d, monData.pokemonID: %d", partySize, monData.pokemonID));
		end

		--print(monData.pokemonID);
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
		local baseStatsAddr = gBaseStats + gBaseStats_SIZE * monData.pokemonID;

		local monAbilityType = monsWithRandomAbilities[i];

		if monAbilityType == 0 then
			if monData.isHiddenAbility == 0 then
				abilityID = Memory.readbyte(baseStatsAddr + gBaseStats_abilities + monData.ability);
				if abilityID == 0 then
					abilityID = Memory.readbyte(baseStatsAddr + gBaseStats_abilities)
				end
			else
				abilityID = Memory.readbyte(baseStatsAddr + gBaseStats_hiddenAbility);
			end
	
			monString = monString .. PokemonData.ability[abilityID + 1];
		-- random standard ability
		elseif monAbilityType == 1 then
			--print(string.format("monAbilityType = 1, trainerBattleOpponent = 0x%x", trainerBattleOpponent));
			ability1 = Memory.readbyte(baseStatsAddr + gBaseStats_abilities + 0);
			ability2 = Memory.readbyte(baseStatsAddr + gBaseStats_abilities + 1);

			if ability2 == 0 or ability1 == ability2 then
				monString = monString .. PokemonData.ability[ability1 + 1];
			else
				monString = monString .. PokemonData.ability[ability1 + 1] .. " or " .. PokemonData.ability[ability2 + 1];
			end
		elseif monAbilityType == 2 then
			--print(string.format("monAbilityType = 2, trainerBattleOpponent = 0x%x", trainerBattleOpponent));
			ability1 = Memory.readbyte(baseStatsAddr + gBaseStats_abilities + 0);
			ability2 = Memory.readbyte(baseStatsAddr + gBaseStats_abilities + 1);
			hiddenAbility = Memory.readbyte(baseStatsAddr + gBaseStats_hiddenAbility);

			local abilityStrPt1;

			if ability2 == 0 or ability1 == ability2 then
				abilityStrPt1 = PokemonData.ability[ability1 + 1];
			else
				abilityStrPt1 = PokemonData.ability[ability1 + 1] .. " or " .. PokemonData.ability[ability2 + 1];
			end

			if hiddenAbility ~= 0 then
				monString = monString .. abilityStrPt1 .. " or " .. PokemonData.ability[hiddenAbility + 1];
			else
				monString = monString .. abilityStrPt1;
			end
		else
			error(string.format("Invalid monAbilityType of %d!", monAbilityType));
		end

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
		--print(string.format("type1: %d, type2: %d, addr: %07x", type1, type2, gBaseStats + gBaseStats_SIZE * monData.pokemonID + gBaseStats_type1));
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

	table.insert(trainerData, "====================\n\n");

	if trainerBattleOpponent ~= nil then
		foundTrainers[trainerBattleOpponent] = true;
	end

	return table.concat(trainerData, "");
end

function Program.getPokemonData(index, partySrc)
	if index > 6 then
		return nil
	end

	local start = partySrc + (index - 1) * Pokemon_SIZE;

	local personality = Memory.readdword(start)

	local otid = Memory.readdword(start + 4)
	local magicword = 0-- bit.bxor(personality, otid)

	local aux = personality % 24
	local growthoffset = 0 --(TableData.growth[aux+1] - 1) * 12
	local attackoffset = 12 --(TableData.attack[aux+1] - 1) * 12
	local effortoffset = 24 --(TableData.effort[aux+1] - 1) * 12
	local miscoffset   = 36 --(TableData.misc[aux+1]   - 1) * 12
	
	local growth1 = bit.bxor(Memory.readdword(start+32+growthoffset),   magicword)
	--print(string.format("start: %07x, personality: %08x, growth1: %08x", start, personality, growth1));
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
		-- hiddenAbility = Utils.getbits(growth3, 16, 8);

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
		isHiddenAbility = Utils.getbits(misc2, 31, 1),

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
		personality = personality,
		ability = personality % 2
	};

	monData.EVs = {monData.hpEV, monData.atkEV, monData.defEV, monData.spatkEV, monData.spdefEV, monData.speedEV};
	monData.IVs = {monData.hpIV, monData.atkIV, monData.defIV, monData.spatkIV, monData.spdefIV, monData.speedIV};
	monData.stats = {monData.maxHP, monData.atk, monData.def, monData.spa, monData.spd, monData.spe};
	monData.moves = {monData.move1, monData.move2, monData.move3, monData.move4};

	return monData;
end

function Program.setPokemonData(index, partySrc, field, newValue)
	if index > 6 then
		return nil
	end

	local start = partySrc + (index - 1) * Pokemon_SIZE;

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

	local recalculateStats = false;

	if field == MON_DATA_HP_IV then
		misc2 = Utils.setbits(misc2, newValue, 0, 5);
		recalculateStats = true;
	elseif field == MON_DATA_ATK_IV then
		misc2 = Utils.setbits(misc2, newValue, 5, 5);
		recalculateStats = true;
	elseif field == MON_DATA_DEF_IV then
		misc2 = Utils.setbits(misc2, newValue, 10, 5);
		recalculateStats = true;
	elseif field == MON_DATA_SPEED_IV then
		misc2 = Utils.setbits(misc2, newValue, 15, 5);
		recalculateStats = true;
	elseif field == MON_DATA_SPATK_IV then
		misc2 = Utils.setbits(misc2, newValue, 20, 5);
		recalculateStats = true;
	elseif field == MON_DATA_SPDEF_IV then
		misc2 = Utils.setbits(misc2, newValue, 25, 5);
		recalculateStats = true;
	elseif field == MON_DATA_NATURE then
		local randomValue = Random.nextInt();
		local offset = (newValue - randomValue) % 25;
		personality = offset + randomValue;
		if personality > 0xffffffff then
			offset = (randomValue - newValue) % 25;
			personality = randomValue - offset;
		end

		memory.write_u32_le(start, personality);
		aux = personality % 24;
		print("aux: " .. aux);
		growthoffset = (TableData.growth[aux+1] - 1) * 12
		attackoffset = (TableData.attack[aux+1] - 1) * 12
		effortoffset = (TableData.effort[aux+1] - 1) * 12
		miscoffset   = (TableData.misc[aux+1]   - 1) * 12
		recalculateStats = true;
	elseif field == MON_DATA_MOVE1 then
		attack1 = Utils.setbits(attack1, newValue, 0, 16);
	elseif field == MON_DATA_MOVE2 then
		attack1 = Utils.setbits(attack1, newValue, 16, 16);
	elseif field == MON_DATA_MOVE3 then
		attack2 = Utils.setbits(attack2, newValue, 0, 16);
	elseif field == MON_DATA_MOVE4 then
		attack2 = Utils.setbits(attack2, newValue, 16, 16);
	elseif field == MON_DATA_HELD_ITEM  then
		growth1 = Utils.setbits(growth1, newValue, 16, 16);
	else
		print("Warning: unknown field " .. field .. "!");
	end

	if recalculateStats then
		local stats = {};
		local baseStats = {};
		local hpIV = Utils.getbits(misc2, 0, 5);
		local atkIV = Utils.getbits(misc2, 5, 5);
		local defIV = Utils.getbits(misc2, 10, 5);
		local speedIV = Utils.getbits(misc2, 15, 5);
		local spatkIV = Utils.getbits(misc2, 20, 5);
		local spdefIV = Utils.getbits(misc2, 25, 5);
		
		local hpEV = Utils.getbits(effort1, 0, 8);
		local atkEV = Utils.getbits(effort1, 8, 8);
		local defEV = Utils.getbits(effort1, 16, 8);
		local speedEV = Utils.getbits(effort1, 24, 8);
		local spatkEV = Utils.getbits(effort2, 0, 8);
		local spdefEV = Utils.getbits(effort2, 8, 8);

		local EVs = {hpEV, atkEV, defEV, speedEV, spatkEV, spdefEV};
		local IVs = {hpIV, atkIV, defIV, speedIV, spatkIV, spdefIV};

		local level = Memory.readbyte(start + 84);

		local curHP = Memory.readword(start + 86);
		local oldMaxHP = Memory.readword(start + 88);
		
		local nature = personality % 25 + 1;

		local pokemonID = Utils.getbits(growth1, 0, 16);

		for i = 1, 6, 1 do
			baseStats[i] = Memory.readbyte(gBaseStats + gBaseStats_stats + pokemonID * gBaseStats_SIZE + (i - 1));
			-- print(PokemonData.statsInternal[i] .. ": " .. baseStats[i]);
		end

		stats[1] = math.floor(((2 * baseStats[1] + hpIV + math.floor(hpEV / 4)) * level) / 100) + level + 10;
		
		for i = 2, 6, 1 do
			stats[i] = math.floor(((2 * baseStats[i] + IVs[i] + math.floor(EVs[i] / 4)) * level) / 100) + 5;
		end

		local natureModifier = PokemonData.natureModifier[nature];
		local natureModifier1 = natureModifier[1];
		local natureModifier2 = natureModifier[2];

		if natureModifier1 ~= natureModifier2 then
			stats[natureModifier1] = math.floor((stats[natureModifier1] * 11) / 10);
			stats[natureModifier2] = math.floor((stats[natureModifier2] * 9) / 10);
		end

		for i = 1, 6, 1 do
			memory.write_u16_le(start + 88 + (i - 1) * 2, stats[i]);
		end

		if curHP ~= 0 then
			curHP = curHP + stats[1] - oldMaxHP;
		end

		memory.write_u16_le(start + 86, curHP);
	end

	local cs = Utils.addhalves(growth1) + Utils.addhalves(growth2) + Utils.addhalves(growth3)
	         + Utils.addhalves(attack1) + Utils.addhalves(attack2) + Utils.addhalves(attack3)
			 + Utils.addhalves(effort1) + Utils.addhalves(effort2) + Utils.addhalves(effort3)
			 + Utils.addhalves(misc1)   + Utils.addhalves(misc2)   + Utils.addhalves(misc3)
	cs = cs % 65536;
	memory.write_u16_le(start+0x1c, cs);

	magicword = bit.bxor(personality, otid);

	memory.write_u32_le(start+32+growthoffset,   bit.bxor(growth1, magicword));
	memory.write_u32_le(start+32+growthoffset+4, bit.bxor(growth2, magicword));
	memory.write_u32_le(start+32+growthoffset+8, bit.bxor(growth3, magicword));
	memory.write_u32_le(start+32+attackoffset,   bit.bxor(attack1, magicword));
	memory.write_u32_le(start+32+attackoffset+4, bit.bxor(attack2, magicword));
	memory.write_u32_le(start+32+attackoffset+8, bit.bxor(attack3, magicword));
	memory.write_u32_le(start+32+effortoffset,   bit.bxor(effort1, magicword));
	memory.write_u32_le(start+32+effortoffset+4, bit.bxor(effort2, magicword));
	memory.write_u32_le(start+32+effortoffset+8, bit.bxor(effort3, magicword));
	memory.write_u32_le(start+32+miscoffset,     bit.bxor(misc1, magicword));
	memory.write_u32_le(start+32+miscoffset+4,   bit.bxor(misc2, magicword));
	memory.write_u32_le(start+32+miscoffset+8,   bit.bxor(misc3, magicword));
end
