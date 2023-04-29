_G.Melee2WEP = _G.Melee2WEP or {}

local clonefakewep_BlackMarketGui_equip_weapon_callback = BlackMarketGui.equip_weapon_callback

function BlackMarketGui:equip_weapon_callback(data, ...)
	if Global.blackmarket_manager.crafted_items[data.category] then
		if Global.blackmarket_manager.crafted_items[data.category][data.slot] then
			local d = Global.blackmarket_manager.crafted_items[data.category][data.slot]
			if tostring(d.weapon_id):find("clonefakewep_") then
				local melee_id = tostring(d.weapon_id):gsub("clonefakewep_", "")
				if Melee2WEP.Mods[melee_id] and Melee2WEP.Mods[melee_id].slot == data.slot then
					Melee2WEP.Mods[melee_id] = nil
					managers.system_menu:show({
						title = "[Melee Mod]",
						text = "Remove this Mod from this melee.",
						button_list = {{text = "END", is_cancel_button = true}},
						id = tostring(math.random(0,0xFFFFFFFF))
					})
				else
					Melee2WEP.Mods[melee_id] = {
						slot = data.slot,
						blueprint = d.blueprint
					}
					managers.system_menu:show({
						title = "[Melee Mod]",
						text = "Apply this Mod to this melee.",
						button_list = {{text = "END", is_cancel_button = true}},
						id = tostring(math.random(0,0xFFFFFFFF))
					})
				end
				Melee2WEP:Save()
				return
			end
		end
	end
	clonefakewep_BlackMarketGui_equip_weapon_callback(self, data, ...)
end

Hooks:PostHook(BlackMarketGui, "show_stats", "clonefakewep_BlackMarketGui_show_stats", function(self)
	if not self._stats_panel or not self._rweapon_stats_panel or not self._armor_stats_panel or not self._mweapon_stats_panel then
		return
	end	
	if type(self._slot_data) ~= "table" then
		return
	end	
	local weapon = managers.blackmarket:get_crafted_category_slot(self._slot_data.category, self._slot_data.slot)
	if weapon then
		if tostring(weapon.weapon_id):find("clonefakewep_") then
			local melee_id = tostring(weapon.weapon_id):gsub("clonefakewep_", "")
			if Melee2WEP.Mods[melee_id] then
				self._slot_data.equipped = Melee2WEP.Mods[melee_id].slot == self._slot_data.slot
				self._slot_data.name_localized = ""..self._slot_data.name_localized..""
				self:update_info_text()
			end
		end
	end
end)