--[[
MIT License

Copyright (c) 2024 Xorice

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local DEFAULT_BEZIER_SAMPLING = 16;

local function mix(x0,y0,z0,x1,y1,z1,a)
	return Vector3.new(
		x0 + (x1-x0)*a,
		y0 + (y1-y0)*a,
		z0 + (z1-z0)*a
	)
end

local function _random_array(seed)
	math.randomseed(seed);
	local x = math.random();
	math.randomseed(seed+x*10)
	local y = math.random();
	math.randomseed(seed+y*10)
	local z = math.random();

	return Vector3.new(x,y,z)
end

local function BezierIterator(t, points): Vector3
	local len = #points;

	local ans = {};
	while len > 1 do
		len -= 1;
		for i = 1,len do
			local a,b = points[i],points[i+1]
			ans[i] = a + (b-a)*t;
		end
		points = ans
	end
	return ans[1]
end

local function BezierTanIterator(t, points): Vector3
	local len = #points;

	local ans = {};
	for _ = 1, len-2 do
		len -= 1;
		for i = 1,len do
			ans[i] = points[i]:Lerp(points[i+1], t);
		end
		points = ans
	end
	return (ans[2] - ans[1]).Unit;
end

local function BezierIteratorFull(t, buffer:{number}):Vector3
	local len = math.ceil(#buffer / 4);

	local ans = {};
	while len > 1 do
		len -= 1;
		for i = 1, len do
			local j = (i-1)*4+1;
			local k = (i)*4+1;
			local x0,y0,z0,w0 = buffer[j],buffer[j+1],buffer[j+2],buffer[j+3];
			local x1,y1,z1,w1 = buffer[k],buffer[k+1],buffer[k+2],buffer[k+3];
			ans[j],ans[j+1],ans[j+2],ans[j+3] =
				x0 + (x1-x0) * t,
				y0 + (y1-y0) * t,
				z0 + (z1-z0) * t,
				w0 + (w1-w0) * t
		end
		buffer = ans;
	end
	return ans[1],ans[2],ans[3],ans[4];
end

local Vector3Sequence = {};
Vector3Sequence.__index = Vector3Sequence;

---Builder
---@param numberBuffer table numbers
function Vector3Sequence.new(numberBuffer:{number})
	local self = {};
	self.data = numberBuffer
	self.length = math.floor(#numberBuffer / 5);

	return setmetatable(self, Vector3Sequence);
end

---Build Sequence without envelope
function Vector3Sequence.simple(numberBuffer:{number})
	local self = {};
	local length = math.floor(#numberBuffer / 4);
	local data = table.create(length*5, 0);

	for i = 1, length do
		local j = (i-1)*5+1;
		local k = (i-1)*4+1;
		data[j], data[j+1], data[j+2] = numberBuffer[k], numberBuffer[k+1], numberBuffer[k+2];
		data[j+3] = numberBuffer[k+3];
	end

	self.data = data;
	self.length = length;
	return setmetatable(self, Vector3Sequence);
end

function Vector3Sequence.Bezier(points, times)
	times = times or DEFAULT_BEZIER_SAMPLING;
	local self = {}
	self.length = times;

	local data = table.create(times*5, 0)
	for i = 1, times do
		local j = (i-1)*5 + 1;
		local a = (i-1)/(times-1);
		local v = BezierIterator(a, points);

		data[j], data[j+1], data[j+2], data[j+3] = v.X, v.Y, v.Z, a;
	end
	self.data = data;
	return setmetatable(self, Vector3Sequence);
end

function Vector3Sequence.BezierTan(points, times)
	times = times or DEFAULT_BEZIER_SAMPLING;
	local self = {}
	self.length = times;

	local data = table.create(times*5, 0)
	for i = 1, times do
		local j = (i-1)*5 + 1;
		local a = (i-1)/(times-1);
		local v = BezierTanIterator(a, points);

		data[j], data[j+1], data[j+2], data[j+3] = v.X, v.Y, v.Z, a;
	end
	self.data = data;
	return setmetatable(self, Vector3Sequence);
end

function Vector3Sequence.BezierFull(buffer, times)
	times = times or DEFAULT_BEZIER_SAMPLING;
	local self = {};
	self.length = times;

	local data = table.create(times*5, 0);
	for i = 1, times do
		local j = (i-1)*5 + 1;
		local a = (i-1)/(times-1);
		local x,y,z,w = BezierIteratorFull(a, buffer);

		data[j],data[j+1],data[j+2],data[j+3] = x,y,z,w;
	end
	self.data = data;
	return setmetatable(self, Vector3Sequence);
end

function Vector3Sequence.split(numberBuffer:{number})
	local self = {};
	local length = math.floor(#numberBuffer / 3);
	local data = table.create(length*5, 0)

	for i = 1, length do
		local j = (i-1)*5+1;
		local k = (i-1)*3+1;
		data[j], data[j+1], data[j+2] = numberBuffer[k], numberBuffer[k+1], numberBuffer[k+2];
		data[j+3] = (i - 1)/(length - 1);
	end

	self.data = data;
	self.length = length;
	return setmetatable(self, Vector3Sequence);
end

function Vector3Sequence:GetPoint(index:number)
	local data = self.data;
	local i = (index-1)*5 + 1;
	return data[i], data[i+1], data[i+2], data[i+3], data[i+4];
end

function Vector3Sequence:GetValue(alpha:number, seed:number?, envlope:Vector3?)
	local p, q = 1, self.length;
	local data = self.data;

	while p <= q do
		local m = math.floor( (p+q)/2 );
		local mt = data[(m-1)*5 + 4];
		if alpha >= mt then
			p = m+1;
		else
			q = m-1;
		end
	end

	local x0,y0,z0,t0,e0 = self:GetPoint(p-1);
	local x1,y1,z1,t1,e1 = self:GetPoint(p);
	local a = (alpha-t0)/(t1-t0);
	local em = (e0+(e1-e0)*a); -- * Envlope mix

	envlope = envlope and (envlope*em) or Vector3.zero;
	if seed then
		envlope = _random_array(seed)*2 - Vector3.one;
		envlope = envlope * em;
	end

	return mix(x0,y0,z0,x1,y1,z1,a) + envlope;
end
Vector3Sequence.Value = Vector3Sequence.GetValue

function Vector3Sequence:ApplyEnvlope(points)
	local data = self.data
	for i,v in points do
		local j = (i-1)*5 + 1;
		data[j+4] = points[i];
	end
end
function Vector3Sequence:ApplyEnvlopeFromBezier(points)
	local times = self.length;

	local data = self.data
	for i = 1, times do
		local j = (i-1)*5 + 1;
		local a = (i-1)/(times-1);
		local v = BezierIterator(a, points);
		data[j+4] = v;
	end
end

return  Vector3Sequence;
