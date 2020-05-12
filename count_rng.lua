
extraRngCount = 0;
startFrame = 0;
endFrame = 0;

startFrame_AToSeedRNG = 0;
endFrame_AToSeedRNG = 0;

startFrame_SeedRNGToGetMon = 0;
endFrame_SeedRNGToGetMon = 0;

checkNonVBlankRandom = false;
starterBeingCreated = false;

sScriptContext1_scriptPtr = 0x3000eb8;
gRngValue = 0x3005000;

function resetExtraRngCountAndStartFrame()
	extraRngCount = 0;
	startFrame = 0;
end

function onRandom()
	local r14Value = emu.getregister("R14");
	if r14Value ~= 0x800078d then
		extraRngCount = extraRngCount + 1;
		--print(string.format("extraRngCount: %d, lr: 0x%07x", extraRngCount, r14Value));
		local rngAtStr;

		if r14Value == 0x803db05 then
			starterBeingCreated = true;
			rngAtStr = "PID1";
		elseif r14Value == 0x803db0b then
			rngAtStr = "PID2";
		elseif r14Value == 0x803dcd5 then
			rngAtStr = "IV1";
		elseif r14Value == 0x803dd1f then
			rngAtStr = "IV2";
		end

		if rngAtStr ~= nil then
			local rngValue = memory.read_u32_le(gRngValue);
			print(string.format("rng seed at %s: %08x", rngAtStr, rngValue));
		end
	else
		if starterBeingCreated then
			print("lag frame during starter generation!");
		end
	end
end

function afterScriptGiveMonRandomCalls()
	starterBeingCreated = false;
end

function printFrameDiff()
	print("frame diff: " .. (endFrame - startFrame));
end

function onSeedRngAndSetTrainerId()
	endFrame_AToSeedRNG = emu.framecount();
	print("AToSeedRNG frame diff: " .. endFrame_AToSeedRNG - startFrame_AToSeedRNG);
	client.pause();
end

function onSeedRngAndSetTrainerId_SeedRNGToGetMon()
	startFrame_SeedRNGToGetMon = emu.framecount();
end

function checkPressA()
	local aButton = joypad.get()["A"];
	if startFrame == 0 and aButton then
		startFrame = emu.framecount();
		startFrame_AToSeedRNG = startFrame;
		print("RNG seeded!");
	end
end

function onScriptGiveMon()
	--client.pause();
end

-- function onAorBPressedForMsgbox()
	-- startFrame = emu.framecount();
	-- checkNonVBlankRandom = true;
-- end

function onAorBPressedForMsgbox()
	local scriptContext1ScriptPtr = memory.read_u32_le(sScriptContext1_scriptPtr);
	-- for grasshole
	if scriptContext1ScriptPtr == 0x81a73d9 then
		endFrame = emu.framecount();
		printFrameDiff();
	end
end

event.onmemoryexecute(onRandom, 0x8044ec8);
--event.onmemoryexecute(onSeedRngAndSetTrainerId, 0x8000564);
--event.onmemoryexecute(onAorBPressedForMsgbox, 0x806b922);
event.onmemoryexecute(afterScriptGiveMonRandomCalls, 0x8FE5870);


--event.onmemoryexecute(onScriptGiveMon, 0x8FE5824);

event.onloadstate(resetExtraRngCountAndStartFrame);

local firstRun = true;

print("Running!");

while true do
	checkPressA();
	emu.frameadvance();
end
