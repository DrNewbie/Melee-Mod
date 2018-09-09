_G.Melee2WEP = _G.Melee2WEP or {}

function FPCameraPlayerBase:Run_ApplyAttachments2Melee(data)
	if type(data) ~= "table" then
		return
	end
	if not data.unit_name or not data.melee or not data.melee_entry then
		return
	end
	local aligns = tweak_data.blackmarket.melee_weapons[data.melee_entry].align_objects or {"a_weapon_left"}
	for _, align in ipairs(aligns) do
		local graphic_objects = tweak_data.blackmarket.melee_weapons[data.melee_entry].graphic_objects or {}
		local align_obj_name = Idstring(align)
		local align_obj = self._unit:get_object(align_obj_name)			
		local unit = World:spawn_unit(Idstring(data.unit_name), align_obj:position(), align_obj:rotation())
		self._unit:link(align_obj:name(), unit, unit:orientation_object():name())
	end
end

Hooks:PostHook(FPCameraPlayerBase, "spawn_melee_item", "Event_ApplyAttachments2Melee", function(self)
	if type(self._melee_item_units) == "table" then
		local melee_entry = managers.blackmarket:equipped_melee_weapon()
		local unit_name = tweak_data.blackmarket.melee_weapons[melee_entry].unit
		for _, melee in pairs(self._melee_item_units) do
			if melee and alive(melee) and melee:name() == Idstring(unit_name) and Melee2WEP:IsMeleeApplyInGame(melee_entry) then
				for _, d in pairs(Melee2WEP.Mods[melee_entry].blueprint) do
					if d ~= "wpn_fps_empty_melee_sight" and d ~= "wpn_fps_empty_melee_body_standard" then
						if tweak_data.weapon.factory.parts[d] and tweak_data.weapon.factory.parts[d].unit ~= "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy" then
							local unit_name = tweak_data.weapon.factory.parts[d] and tweak_data.weapon.factory.parts[d].unit
							if unit_name and DB:has(Idstring("unit"), Idstring(unit_name)) then
								if not managers.dyn_resource:is_resource_ready(Idstring("unit"), Idstring(unit_name), managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
									managers.dyn_resource:load(Idstring("unit"), Idstring(unit_name), managers.dyn_resource.DYN_RESOURCES_PACKAGE, callback(self, self, "Run_ApplyAttachments2Melee", {melee = melee, unit_name = unit_name, melee_entry = melee_entry}))
								else
									self:Run_ApplyAttachments2Melee({melee = melee, unit_name = unit_name, melee_entry = melee_entry})
								end
							end
						end
					end
				end
			end
		end
	end
end)