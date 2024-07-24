include("/pfm/pfm.lua")

tests.launch_pfm(function(pm)

local models = { "headcrabclassic" }
local tEnts = {}
local min = Vector(math.huge, math.huge, math.huge)
local max = Vector(-math.huge, -math.huge, -math.huge)
for _, mdlName in ipairs(models) do
	local mdl = game.load_model(mdlName)
	if mdl == nil then
		util.remove(tEnts)
		return false, "Failed to load model '" .. mdlName .. "'!"
	else
		local ent = ents.create_prop(mdlName)
		if util.is_valid(ent) == false then
			return false, "Failed to create prop with model '" .. mdlName .. "'!"
		end
		ent:Spawn()

		local renderC = ent:GetComponent(ents.COMPONENT_RENDER)
		if renderC ~= nil then
			local entMin, entMax = renderC:GetAbsoluteRenderBounds()
			for i = 0, 2 do
				min:Set(i, math.min(min:Get(i), entMin:Get(i)))
				max:Set(i, math.max(max:Get(i), entMax:Get(i)))
			end
		end
	end
end

console.run("render_clear_scene", "1")
console.run("render_clear_scene_color", "180 180 180 255")

local border = 20
min = min - Vector(border, border, border)
max = max + Vector(border, border, border)

min = -Vector(100,100,100)
max = Vector(100,100,100)

print("Bounds: ",min,max)

--local entRefl = ents.create("env_reflection_probe")
--entRefl:Spawn()

local cam = game.get_primary_camera()
local entCam = cam:GetEntity()
local obsC = entCam:GetComponent(ents.COMPONENT_OBSERVER)
obsC:SetActive(false)

local viewerC = entCam:AddComponent("viewer_camera")
viewerC:FitViewToScene(min, max)
viewerC:SetRotation(math.rad(-15), math.rad(20))
viewerC:UpdatePose()

pm:GoToWindow("render")
local render = pm:GetWindow("render")
if util.is_valid(render) then
    render:SetRenderer("cycles")
    render:AddCallback("OnRenderComplete", function()
        game.wait_for_frames(30, function()
            tests.complete(true, { screenshot = true })
        end, true)
    end)
    render:Refresh(true)
end



end)
