
startFrame = 0;
endFrame = 0;
printExtraRngCount = false;
extraRngCount = 0;

function onRandom()
	local r14Value = emu.getregister("R14");
	if printExtraRngCount and r14Value ~= 0x800078d then
		extraRngCount = extraRngCount + 1;
		print(string.format("extraRngCount: %d, lr: 0x%07x", extraRngCount, r14Value));
		if r14Value == 0x803db05 then
			endFrame = emu.framecount();
			print("frame diff: " .. (endFrame - startFrame));
		end
	end
end

function onSeedRngAndSetTrainerId()
	startFrame = emu.framecount();
	printExtraRngCount = true;
	extraRngCount = 0;
end

function onSoftReset()
	printExtraRngCount = false;
end

event.onmemoryexecute(onRandom, 0x8044ec8);
event.onmemoryexecute(onSeedRngAndSetTrainerId, 0x8000564);
event.onmemoryexecute(onSoftReset, 0x81E3B84);

print("check_troubait_frametime.lua running!");

while true do
	emu.frameadvance();
end