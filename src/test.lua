-- * WORKSPACE

local v3Seq = require(script:WaitForChild 'Vector3Sequence');

-- Size Sequence
local seqs = v3Seq.Bezier {
	Vector3.new(0,0,1);
	Vector3.new(4,4,4);
	Vector3.new(0,0,0);
}

-- Position Sequence
local seq = v3Seq.Bezier {
	Vector3.new(0,4,4);
	Vector3.new(20,4,4);
	Vector3.new(12,4,-4);
	Vector3.new(32,4,-4);
}
seq:ApplyEnvlopeFromBezier {0, 5, 0}

-- Or try this
--seq:ApplyEnvlope {0, 1, 2, 3, 4, 4, 3, 2, 1, 0}

-- Tangent Sequence
local seqt = v3Seq.BezierTan {
	Vector3.new(0,4,4);
	Vector3.new(20,4,4);
	Vector3.new(12,4,-4);
	Vector3.new(32,4,-4);
}

-- Test
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
	local seed = math.ceil(timer/2);
	seed = nil; -- try to delete this line and see what would happen
	
	local x,y,z = math.noise(timer),math.noise(timer,5),math.noise(timer,10)
	local unit = Vector3.new(x,y,z)
	--unit = nil -- try to delete this

	for i, part in parts do
		local alpha = (timer/2 + (i-1)/len)%1
		
		local vl = seqt:Value(alpha)
		local vy = Vector3.new(0,1,0)
		local vx = vl:Cross(vy);
		
		part.Size = seqs:Value(alpha)
		part.CFrame = CFrame.fromMatrix(seq:Value(alpha, seed, unit), vx,vy,-vl)
	end
end