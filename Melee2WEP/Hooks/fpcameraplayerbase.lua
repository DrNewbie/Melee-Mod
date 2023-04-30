_G.Melee2WEP = _G.Melee2WEP or {}

Hooks:PostHook(FPCameraPlayerBase, "spawn_melee_item", "Event_ApplyAttachments2Melee", function(self)
	if type(self._melee_item_units) == "table" then
		local melee_entry = managers.blackmarket:equipped_melee_weapon()
		local unit_name = tweak_data.blackmarket.melee_weapons[melee_entry].unit
		for _, melee in pairs(self._melee_item_units) do
			if melee and alive(melee) and melee:name() == Idstring(unit_name) and Melee2WEP:IsMeleeApplyInGame(melee_entry) then
				Melee2WEP:ApplyLinkToWeapon({
					melee_unit = melee,
					melee_id = melee_entry
				})
			end
		end
	end
end)

Hooks:PreHook(FPCameraPlayerBase, "unspawn_melee_item", "Event_RemoveMeleeAttachments", function(self)
	Melee2WEP:RemoveAllSpawned()
end)