
printTimer1 = false;
numTM1sPrinted = 0;
startFrame = 0;
endFrame = 0;

function onStartTimer1()
	printTimer1 = true;
	startFrame = emu.framecount();
	numTM1sPrinted = 0;
end

function onSeedRng()
	endFrame = emu.framecount();
	print("seed: " .. emu.getregister("R0") .. "\nframe diff: " .. (endFrame - startFrame));
end

event.onmemoryexecute(onStartTimer1, 0x8000558);
event.onmemoryexecute(onSeedRng, 0x8044eea);

print("print_tm1_cnt.lua running!");

while true do
	emu.frameadvance();
	if printTimer1 then
		print("TM1: " .. memory.read_u16_le(0x4000104));
		numTM1sPrinted = numTM1sPrinted + 1;
		if numTM1sPrinted > 2 then
			printTimer1 = false;
			print("");
		end
	end
end
