
Random = {};

s0 = 0;
s1 = 0;
s2 = 0;
s3 = 0;

function dwordMultiply(a, b)
	if a > 0xffffffff or b > 0xffffffff then
		print("Warning: a or b greater than 32 bits, truncating!");
		a = bit.band(a, 0xffffffff);
		b = bit.band(b, 0xffffffff);
	end
	local ah = bit.rshift(a, 16);
	local al = bit.band(a, 0xffff);
	local bh = bit.rshift(b, 16);
	local bl = bit.band(b, 0xffff);

	local high = bit.band((ah * bl) + (al * bh), 0xffff);

	return bit.band(bit.lshift(high, 16) + al * bl, 0xffffffff);
end

function splitMix32(x)
	x = bit.bxor(x, bit.rshift(x, 16));
	x = dwordMultiply(x, 0x85ebca6b)
	x = bit.bxor(x, bit.rshift(x, 13));
	x = dwordMultiply(x, 0xc2b2ae35);
	x = bit.bxor(x, bit.rshift(x, 16));
	return x;
end

function Random.seed(seed)
	s0 = splitMix32(seed);
	s1 = splitMix32(s0);
	s2 = splitMix32(s1);
	s3 = splitMix32(s2);
	-- print(string.format("s0: 0x%08x\ns1: 0x%08x\ns2: 0x%08x\ns3: 0x%08x\n", s0, s1, s2, s3));
end

function Random.nextInt()
	local result = bit.band(bit.rol(bit.band(s0 + s3, 0xffffffff), 7) + s0, 0xffffffff);

	t = bit.lshift(s1, 9);

	s2 = bit.bxor(s2, s0);
	s3 = bit.bxor(s3, s1);
	s1 = bit.bxor(s1, s2);
	s0 = bit.bxor(s0, s3);
	
	s2 = bit.bxor(s2, t);
	
	s3 = bit.rol(s3, 11);

	return result - 1;
end

function Random.nextShort()
	return bit.band(Random.nextInt(), 0xffff);
end

function testRandom()
	print("\nTesting xoshiro128++!");
	Random.seed(42069);
	for i = 1, 10, 1 do
		print(string.format("value: 0x%08x", Random.nextInt()));
	end
end

Random.seed(os.time());
