-- * WORKSPACE

local v3Seq = require(script:WaitForChild 'Vector3Sequence');


local seqs = v3Seq.Bezier {
	Vector3.new(0,0,0);
	Vector3.new(4,4,4);
	Vector3.new(0,0,0);
}

local seq = v3Seq.Bezier {
	Vector3.new(0,4,4);
	Vector3.new(20,4,4);
	Vector3.new(12,4,-4);
	Vector3.new(32,4,-4);
}

local sequence = v3Seq.simple {
	0,   0,   0,   0;
	0.1, 0.1, 0.1, 0.4;
	0.9, 0.9, 0.9, 0.6;
	0,   0,   0,   0;
}

local parts = {}
local len = 10
for i = 1, len do
	local part = Instance.new 'Part'
	part.Anchored = true;
	part.Size = Vector3.one;
	part.Parent = workspace
	parts[i] = part;
end


local timer = 0
while true do
	timer += task.wait();
	
	for i, part in parts do
		local alpha = (timer/2 + (i-1)/len)%1
		part.Size = seqs:Value(alpha)
		part.CFrame = CFrame.new(seq:Value(alpha))
	end
end