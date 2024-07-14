
local DEFAULT_BEZIER_SAMPLING = 10;

local function mix(x0,y0,z0,x1,y1,z1,a)
    return Vector3.new(x0,y0,z0):Lerp(Vector3.new(x1,y1,z1), a);
end

local function BezierIterator(t, points): Vector3
    local len = #points;

    local ans = {};
    while len > 1 do
        len -= 1;
        for i = 1,len do
            ans[i] = points[i]:Lerp(points[i+1], t);
        end
        points = ans
    end
    return ans[1]
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
    for i = 0, times do
        local j = (i-1)*5 + 1;
        local a = i/times;
        local v = BezierIterator(a, points);

        data[j], data[j+1], data[j+2], data[j+3] = v.X, v.Y, v.Z, a;
    end
    self.data = data;
    return setmetatable(self, Vector3Sequence);
end

function Vector3Sequence:GetPoint(index:number)
    local data = self.data;
    local i = (index-1)*5 + 1;
    return data[i], data[i+1], data[i+2], data[i+3], data[i+4];
end

function Vector3Sequence:GetValue(alpha:number, seed:number?)
    local p, q = 1, self.length;

    while p <= q do
        local m = math.floor( (p+q)/2 );
        local _,_,_,mt = self:GetPoint(m)
        if alpha >= mt then
            p = m+1;
        else
            q = m-1;
        end
    end

    local x0,y0,z0,t0,e0 = self:GetPoint(p-1);
    local x1,y1,z1,t1,e1 = self:GetPoint(p);
    local a = (alpha-t0)/(t1-t0);

    return mix(x0,y0,z0,x1,y1,z1,a);
end
Vector3Sequence.Value = Vector3Sequence.GetValue

return  Vector3Sequence;