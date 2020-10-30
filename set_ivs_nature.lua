
dofile ("clover_includes.lua");

gPlayerParty = 0x2024284;

function string:split(sSeparator, nMax, bRegexp)
   assert(sSeparator ~= '')
   assert(nMax == nil or nMax >= 1)

   local aRecord = {}

   if self:len() > 0 then
      local bPlain = not bRegexp
      nMax = nMax or -1

      local nField, nStart = 1, 1
      local nFirst,nLast = self:find(sSeparator, nStart, bPlain)
      while nFirst and nMax ~= 0 do
         aRecord[nField] = self:sub(nStart, nFirst-1)
         nField = nField+1
         nStart = nLast+1
         nFirst,nLast = self:find(sSeparator, nStart, bPlain)
         nMax = nMax-1
      end
      aRecord[nField] = self:sub(nStart)
   end

   return aRecord
end

function onChangeIVNature()
	local input = forms.gettext(texthandle);

	local splitInput = input:split(" ");
	local slot = tonumber(splitInput[2]);
	if bizstring.startswith(splitInput[1], "nature") then
		local natureStr = splitInput[3]:lower();
		local nature = PokemonData.natureLookup[natureStr];
		Program.setPokemonData(slot, gPlayerParty, MON_DATA_NATURE, nature);
		print(string.format("Set nature of slot %d to %s!", slot, natureStr:gsub("^%l", string.upper)));
	elseif bizstring.startswith(splitInput[1], "iv") then
		local statStr = splitInput[3]:lower();
		local monDataOffset = MON_DATA_IV_BASE + PokemonData.statsInternalLookup[statStr];
		local ivValue = tonumber(splitInput[4]);
		Program.setPokemonData(slot, gPlayerParty, monDataOffset, ivValue);
		print(string.format("Set %s IV of slot %d to %d!", statStr:gsub("^%l", string.upper), slot, ivValue));
	elseif bizstring.startswith(splitInput[1], "move") then
		local moveStr = splitInput[3]:lower();
		local move = PokemonData.moveLookup[moveStr];
		local moveSlot = tonumber(splitInput[4]) - 1;
		local monDataOffset = MON_DATA_MOVE1 + moveSlot;
		Program.setPokemonData(slot, gPlayerParty, monDataOffset, move);
		print("set move todo!");
	elseif bizstring.startswith(splitInput[1], "item") then
		local itemStr = splitInput[3]:lower();
		local item = PokemonData.itemLookup[itemStr];
		local monDataOffset = MON_DATA_HELD_ITEM;
		Program.setPokemonData(slot, gPlayerParty, monDataOffset, item);
		print(string.format("Set item of slot %d to %s!", slot, itemStr));
	else
		print("Unknown command \"" .. splitInput[1] .. "\"!");
	end
end

function onExit()
	forms.destroyall();
	print("Exited set_ivs_nature.lua!");
end

event.onexit(onExit);

print("Running set_ivs_nature.lua!");

formhandle = forms.newform(250, 130, "Change IV/Nature");
texthandle = forms.textbox(formhandle, "", 140, 30, nil, 45, 15);
forms.button(formhandle, "Accept", onChangeIVNature, 75, 50, 80, 30);

while true do
	emu.frameadvance();
end
