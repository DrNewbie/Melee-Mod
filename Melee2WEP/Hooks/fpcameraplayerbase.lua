_G.Melee2WEP = _G.Melee2WEP or {}

Hooks:PostHook(FPCameraPlayerBase, "init", "Event_MeleeAttachmentsInit", function(self)
	self._MeleeAttachmentsHook = {}
end)

function FPCameraPlayerBase:SetMeleeAttachmentsHook(melee, attach)
	if melee and alive(melee) and attach and alive(attach) then
		self._MeleeAttachmentsHook[melee:key()] = self._MeleeAttachmentsHook[melee:key()] or {}
		table.insert(self._MeleeAttachmentsHook[melee:key()], attach)
	end
end

function FPCameraPlayerBase:Run_ApplyAttachments2Melee(data)
	if type(data) ~= "table" then
		return
	end
	if not data.unit_name or not data.melee or not data.melee_entry then
		return
	end
	if Melee2WEP.ObjectList[data.melee_entry] then
		local align_obj_name = Idstring(Melee2WEP.ObjectList[data.melee_entry])
		local align_obj = data.melee:get_object(align_obj_name)
		if align_obj then
			local unit = World:spawn_unit(Idstring(data.unit_name), align_obj:position(), align_obj:rotation())
			data.melee:link(align_obj:name(), unit, unit:orientation_object():name())
			self:SetMeleeAttachmentsHook(data.melee, unit)
			return
		end
	end
	local aligns = tweak_data.blackmarket.melee_weapons[data.melee_entry].align_objects or {"a_weapon_left"}
	for _, align in ipairs(aligns) do
		local graphic_objects = tweak_data.blackmarket.melee_weapons[data.melee_entry].graphic_objects or {}
		local align_obj_name = Idstring(align)
		local align_obj = self._unit:get_object(align_obj_name)
		local unit = World:spawn_unit(Idstring(data.unit_name), align_obj:position(), align_obj:rotation())
		self._unit:link(align_obj:name(), unit, unit:orientation_object():name())
		self:SetMeleeAttachmentsHook(data.melee, unit)
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
							local fac_unit_name = tweak_data.weapon.factory.parts[d] and tweak_data.weapon.factory.parts[d].unit
							if fac_unit_name and DB:has(Idstring("unit"), Idstring(fac_unit_name)) then
								if not managers.dyn_resource:is_resource_ready(Idstring("unit"), Idstring(fac_unit_name), managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
									managers.dyn_resource:load(Idstring("unit"), Idstring(fac_unit_name), managers.dyn_resource.DYN_RESOURCES_PACKAGE, callback(self, self, "Run_ApplyAttachments2Melee", {melee = melee, unit_name = fac_unit_name, melee_entry = melee_entry}))
								else
									self:Run_ApplyAttachments2Melee({melee = melee, unit_name = fac_unit_name, melee_entry = melee_entry})
								end	
							end
						end
					end
				end
			end
		end
	end
end)

Hooks:PreHook(FPCameraPlayerBase, "unspawn_melee_item", "Event_RemoveMeleeAttachments", function(self)
	if not self._melee_item_units then
		return
	end
	for _, melee in ipairs(self._melee_item_units) do
		if alive(melee) then
			self._MeleeAttachmentsHook[melee:key()] = self._MeleeAttachmentsHook[melee:key()] or {}
			for _, attach in pairs(self._MeleeAttachmentsHook[melee:key()]) do
				if alive(attach) then
					attach:unlink()
					World:delete_unit(attach)
				end
			end
			self._MeleeAttachmentsHook[melee:key()] = nil
		end
	end
end)