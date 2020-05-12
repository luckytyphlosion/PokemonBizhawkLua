
extraRngCount = 0;

function onRandom()
	local r14Value = memory.getregister("r14");
	if r14Value ~= 0x800078d then
		extraRngCount = extraRngCount + 1;
		print("extraRngCount: " .. extraRngCount);
	end
end

function randomizeRNG()
	local gRngValue = 0x3005000;
	local newRNG = math.random(0, 0x7fffffff);
	memory.writedword(gRngValue, newRNG);
	print(string.format("new RNG: 0x%08x", newRNG));
end

memory.registerexec(0x8044ec8, onRandom);

print("Running!");
randomizeRNG();

math.randomseed(os.time());

enableRngSavestateRandomization = true;

while true do
	local f11DownTemp = input.get()["F11"];
	f11Pressed = (not f11DownTemp ~= not f11Down) and f11DownTemp;
	f11Down = f11DownTemp;
	
	if f11Pressed then
		enableRngSavestateRandomization = not enableRngSavestateRandomization;
		print("RNG Randomization Enabled: ", enableRngSavestateRandomization);
	end
	
	local tempRngRandomize = (input.get()["F1"] or input.get()["F2"] or input.get()["F3"] or input.get()["F4"] or input.get()["F5"] or input.get()["F6"] or input.get()["F7"] or input.get()["F8"] or input.get()["F9"] or input.get()["F10"]) and not input.get()["shift"];
	
	rngRandomizePressed = (not tempRngRandomize ~= not rngRandomizeDown) and tempRngRandomize;
	rngRandomizeDown = tempRngRandomize;
	
	if enableRngSavestateRandomization and rngRandomizePressed then
		randomizeRNG()
	end
	vba.frameadvance();
end
