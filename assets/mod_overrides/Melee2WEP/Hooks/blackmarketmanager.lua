local clonefakewep_BlackMarketManager_get_weapon_icon_path = BlackMarketManager.get_weapon_icon_path

function BlackMarketManager:get_weapon_icon_path(weapon_id, ...)
	if weapon_id:find("clonefakewep_") then
		local melee_weapon_texture = "guis/textures/pd2/endscreen/what_is_this"
		local melee_weapon = weapon_id:gsub("clonefakewep_", "")
		local guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket.melee_weapons[melee_weapon] and tweak_data.blackmarket.melee_weapons[melee_weapon].texture_bundle_folder
		if bundle_folder then
			guis_catalog = guis_catalog.."dlcs/"..tostring(bundle_folder).."/"
		end
		melee_weapon_texture = guis_catalog.."textures/pd2/blackmarket/icons/melee_weapons/"..tostring(melee_weapon)
		return melee_weapon_texture
	end
	return clonefakewep_BlackMarketManager_get_weapon_icon_path(self, weapon_id, ...)
end

local clonefakewep_BlackMarketManager_spawn_item_weapon = MenuSceneManager.spawn_item_weapon

function MenuSceneManager:spawn_item_weapon(factory_id, ...)
	if tostring(factory_id):find("wpn_fps_clonefakewep_") then
		local melee_weapon = factory_id:gsub("wpn_fps_clonefakewep_", "")
		return self:spawn_melee_weapon_clbk(melee_weapon)
	end
	return clonefakewep_BlackMarketManager_spawn_item_weapon(self, factory_id, ...)
end