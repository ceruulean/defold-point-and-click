-- https://paulwatt526.github.io/wattageTileEngineDocs/luaOopPrimer.html

local map_height = 0
local map_width = 0

-- General class for moving objects
local Actor = {}


local function clamp(mn, n, mx) return math.max(mn, math.min(mx, n)) end

local function quadratic_bezier(t, p0, p1, p2)
	local l1 = vmath.lerp(t, p0, p1)
	local l2 = vmath.lerp(t, p1, p2)
	return vmath.lerp(t, l1, l2)
end

function Actor.update_map_size()
	map_height = go.get("main:/camera#script", "bounds_top")
	map_width = go.get("main:/camera#script", "bounds_right")
end

-- mutates the `position` vector to stay within map coordinates
function Actor.clamp_to_map(position)
	position.x = clamp(0, position.x, map_width)
	position.y = clamp(0, position.y, map_height)
end

-- Define the new() function
Actor.new = function()
	local self = {}
	self.wants_to_move = false
	self.velocity = vmath.vector3(0)
	self.z = 0
	self.depth_scale = vmath.vector3(0)

	-- Takes a height (y) and adjusts the z value and scale factor
	function self.scale_depth_along_height(y)
		MIN_SCALE = 0.1
		MAX_SCALE = 2.0

		local ptg = clamp(0.1, (1 - y / map_height), 1,0)
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
			self.stop_at_map_bounds(from)
		end
	end


	function self.stop_at_map_bounds(position)
		local going_to = position + vmath.normalize(self.velocity)
		if going_to.x > map_width or going_to.x < 0 then
			self.velocity.x = 0
		end
		if going_to.y > map_height or going_to.y < 0 then
			self.velocity.y = 0
		end
	end
	
	return self
end

return Actor