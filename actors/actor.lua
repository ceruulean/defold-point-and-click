-- Actor class for moving objects
-- https://paulwatt526.github.io/wattageTileEngineDocs/luaOopPrimer.html
local Globals = require "main.globals"

local Actor = {}

local function clamp(mn, n, mx) return math.max(mn, math.min(mx, n)) end

local function quadratic_bezier(t, p0, p1, p2)
	local l1 = vmath.lerp(t, p0, p1)
	local l2 = vmath.lerp(t, p1, p2)
	return vmath.lerp(t, l1, l2)
end

-- mutates the `position` vector to stay within map coordinates
function Actor.clamp_to_map(position)
	position.x = clamp(0, position.x, Globals.map_width)
	position.y = clamp(0, position.y, Globals.map_height)
end

-- Instantiate a new Actor
Actor.new = function()
	local self = {}
	self.inventory = {}
	self.wants_to_move = false
	self.velocity = vmath.vector3(0)
	self.z = 0
	self.depth_scale = vmath.vector3(0)

	-- Takes a height (y) and adjusts the z value and scale factor
	function self.scale_depth_along_height(y)
		MIN_SCALE = 0.1
		MAX_SCALE = 2.0
		
		local ptg = clamp(0.1, (1 - y / Globals.map_height), 1,0)
		local scale_curved = quadratic_bezier(ptg, vmath.vector3(0), vmath.vector3(0.12, 1, 0), vmath.vector3(1, 1, 0))
		self.z = 100 * ptg
		if scale_curved.y > 99.9 then 
			self.depth_scale = 1.0
		else
			self.depth_scale = clamp(MIN_SCALE, scale_curved.y, MAX_SCALE)
		end
	end

	function self.move(from, velocity)
		if self.wants_to_move then
			-- check map bounds and block movement if going beyond
			local going_to = from + vmath.normalize(velocity)
			if going_to.x > Globals.map_width or going_to.x < 0 then
				velocity.x = 0
			end
			if going_to.y > Globals.map_height or going_to.y < 0 then
				velocity.y = 0
			end
			self.velocity = velocity
		else
			self.velocity = vmath.vector3(0)
		end
	end
	
	return self
end

return Actor