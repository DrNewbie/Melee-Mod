_G.Melee2WEP = _G.Melee2WEP or {}
Melee2WEP.ModPath = ModPath
Melee2WEP.Mods = Melee2WEP.Mods or {true}
Melee2WEP.ObjectList = Melee2WEP.ObjectList or {true}
Melee2WEP.Version = 6.1

local function __Save()
	local save_files = io.open(Melee2WEP.ModPath.."/Mods.json", "w+")
	if save_files then
		save_files:write(json.encode(Melee2WEP.Mods))
		save_files:close()
	end
	return
end

local function __Load()
	local save_files = io.open(Melee2WEP.ModPath.."/Mods.json", "r")
	if save_files then
		Melee2WEP.Mods = json.decode(save_files:read("*all"))
		save_files:close()
		if type(Melee2WEP.Mods) ~= "table" or table.empty(Melee2WEP.Mods) then
			Melee2WEP.Mods = {true}
		end
	else
		Melee2WEP.Mods = {true}
	end
	save_files = io.open(Melee2WEP.ModPath.."/unit2object.json", "r")
	if save_files then
		Melee2WEP.ObjectList = json.decode(save_files:read("*all"))
		save_files:close()
		if type(Melee2WEP.ObjectList) ~= "table" or table.empty(Melee2WEP.ObjectList) then
			Melee2WEP.ObjectList = {true}
		end
	else
		Melee2WEP.ObjectList = {true}
	end
	pcall(__Save)
	return
end

function Melee2WEP:IsMeleeApplyInGame(melee_entry)
	if not self.Mods[melee_entry] then
		return false
	end
	if not Global.blackmarket_manager or not Global.blackmarket_manager.crafted_items or not Global.blackmarket_manager.crafted_items.primaries then
		return false
	end
	if not Global.blackmarket_manager.crafted_items.primaries[self.Mods[melee_entry].slot] then
		return false
	end
	local d = Global.blackmarket_manager.crafted_items.primaries[self.Mods[melee_entry].slot]
	if not type(d) == "table" then
		return false
	end
	local wep_id = tostring(d.weapon_id)
	if not wep_id:find("clonefakewep_") then
		return false
	end
	if wep_id:gsub("clonefakewep_", "") ~= melee_entry then
		return false
	end
	return true
end

Melee2WEP.p_units = Melee2WEP.p_units or {}

function Melee2WEP:RemoveAllSpawned()
	for __k, __attach in pairs(self.p_units) do
		if alive(__attach) then
			__attach:unlink()
			__attach:set_slot(0)
		end
		if alive(__attach) then
			World:delete_unit(__attach)
		end
		self.p_units[__k] = nil
	end
	return
end

function Melee2WEP:ApplyLinkToWeapon(data)
	if type(data) ~= "table" then
		return
	end
	if not data.melee_unit or not alive(data.melee_unit) or not data.melee_id then
		return
	end
	local melee_unit = data.melee_unit
	local melee_id = data.melee_id
	if not self.Mods or not self.Mods[melee_id] or not Melee2WEP.Mods[melee_id].blueprint then
		return
	end
	--[[
		Clean old spanwed
	]]
	self:RemoveAllSpawned()
	--[[
		OK
	]]
	local __blueprint = Melee2WEP.Mods[melee_id].blueprint
	local align_obj = nil
	if self.ObjectList[melee_id] then
		local align_obj_name = Idstring(self.ObjectList[melee_id])
		align_obj = data.melee:get_object(align_obj_name)
	end
	if not align_obj then
		align_obj = melee_unit:orientation_object()
	end
	if align_obj then
		for _, d in pairs(__blueprint) do
			if d ~= "wpn_fps_empty_melee_sight" and d ~= "wpn_fps_empty_melee_body_standard" then
				if tweak_data.weapon.factory.parts[d] and tweak_data.weapon.factory.parts[d].unit ~= "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy" then
					local fac_unit_name = tweak_data.weapon.factory.parts[d] and tweak_data.weapon.factory.parts[d].unit
					if fac_unit_name and DB:has(Idstring("unit"), Idstring(fac_unit_name)) then
						managers.dyn_resource:load(Idstring("unit"), Idstring(fac_unit_name), managers.dyn_resource.DYN_RESOURCES_PACKAGE, function()
							local p_unit = World:spawn_unit(Idstring(fac_unit_name), align_obj:position(), align_obj:rotation())
							if p_unit and alive(p_unit) then
								self.p_units[p_unit:key()] = p_unit
								melee_unit:link(align_obj:name(), p_unit, p_unit:orientation_object():name())
							end
						end)
					end
				end
			end
		end
	end
	return
end

Hooks:Add("MenuManagerSetupCustomMenus", "Melee2WEPOptions", function()
	MenuHelper:NewMenu("Melee2WEP_menu")
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "Melee2WEPOptions", function( menu_manager, nodes )
	MenuCallbackHandler.Melee2WEP_menu_forced_update_callback = function(self, item)
		local _file = io.open(Melee2WEP.ModPath..'/main.xml', "w")
		if _file then
			_file:write('<table name=\"Melee2WEP\">\n')
			_file:write('	<AssetUpdates id="Melee Mod" version="'..Melee2WEP.Version..'">\n')
 			_file:write('		<custom_provider \n')
			_file:write('			version_api_url="https://drnewbie.github.io/Melee-Mod/UpdateProvider/Melee2WEP.txt" \n')
			_file:write('			download_url="https://drnewbie.github.io/Melee-Mod/UpdateProvider/Melee2WEP.zip"\n')
			_file:write('	/>\n')
			_file:write('	</AssetUpdates>\n')
			_file:write('	<Localization directory="Loc" default="english.txt"/>\n')
			_file:write('	<Hooks directory="Hooks">\n')
			_file:write('		<hook file="Menu_Function.lua" source_file="lib/managers/menumanager"/>\n')
			_file:write('		<hook file="blackmarketmanager.lua" source_file="lib/managers/blackmarketmanager"/>\n')
			_file:write('		<hook file="menuscenemanager.lua" source_file="lib/managers/menu/menuscenemanager"/>\n')
			_file:write('		<hook file="menucomponentmanager.lua" source_file="lib/managers/menu/menucomponentmanager"/>\n')
			_file:write('		<hook file="tweakdata.lua" source_file="lib/tweak_data/tweakdata"/>\n')
			_file:write('		<hook file="blackmarketgui.lua" source_file="lib/managers/menu/blackmarketgui"/>\n')
			_file:write('		<hook file="fpcameraplayerbase.lua" source_file="lib/units/cameras/fpcameraplayerbase"/>\n')
			_file:write('	</Hooks>\n')
			local _, _, _, _, melee_list, _, _, _, _, _ = tweak_data.statistics:statistics_table()
			local new_named_loc = {
				["Melee2WEP_menu_title"] = "Melee Mod",
				["Melee2WEP_menu_desc"] = " ",
				["Melee2WEP_menu_forced_update_all_title"] = "Update , All",
				["Melee2WEP_menu_forced_update_all_desc"] = " ",
				["menu_clonefakewep"] = "Melee Mod",
				["bm_wpn_fps_empty_melee_sight"] = " ",
				["bm_wpn_fps_empty_melee_body_standard"] = " ",
			}			
			_file:write('	<WeaponMod id="wpn_fps_empty_melee_sight" name_id="bm_wpn_fps_empty_melee_sight" based_on="wpn_fps_pis_p226_body_standard" "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy" type="sight" drop="false" is_a_unlockable="false">\n')
			_file:write('		<pcs/>\n')
			_file:write('	</WeaponMod>\n')
			_file:write('	<WeaponMod id="wpn_fps_empty_melee_body_standard" name_id="bm_wpn_fps_empty_melee_body_standard" based_on="wpn_fps_pis_p226_body_standard" unit="units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy" type="nothing" drop="false" is_a_unlockable="false">\n')
			_file:write('		<pcs/>\n')
			_file:write('	</WeaponMod>\n')
			for _, melee_id in pairs(melee_list) do
				local melee_data = tweak_data.blackmarket.melee_weapons[melee_id]
				if melee_data and melee_data.unit then
					local fac_id = "wpn_fps_clonefakewep_"..melee_id
					local wep_id = "clonefakewep_"..melee_id
					local name_id = melee_data.name_id
					_file:write('	<Weapon>\n')
					_file:write('		<weapon id="'..wep_id..'" based_on="new_m4" name_id="'..name_id..'" DAMAGE="0" CLIP_AMMO_MAX="0" NR_CLIPS_MAX="0" AMMO_MAX="0"ammo_pickup="0" texture_bundle_folder="'..(melee_data.texture_bundle_folder or "")..'">\n')
					_file:write('			<stats zoom="0" total_ammo_mod="0" damage="0" alert_size="0" spread="0" spread_moving="0" recoil="0" value="0" extra_ammo="0" reload="0" suppression="0" oncealment="0"/>\n')
					_file:write('			<sounds fire="ak12_fire_single" fire_single="ak12_fire_single" use_fix="true"/>\n')
					_file:write('			<animations reload_name_id="flint"/>\n')
					_file:write('			<categories>\n')
					_file:write('				<value_node value="clonefakewep"/>\n')
					_file:write('				<value_node value="pistol"/>\n')
					_file:write('			</categories>\n')
					_file:write('		</weapon>\n')
					_file:write('		<factory id="'..fac_id..'" unit="'..melee_data.unit..'">\n')
					_file:write('			<animations fire="recoil" reload="reload" reload_not_empty="reload_not_empty" fire_steelsight="recoil"/>\n')
					_file:write('			<optional_types>\n')
					_file:write('				<value_node value="sight"/>\n')
					_file:write('				<value_node value="gadget"/>\n')
					_file:write('			</optional_types>\n')
					_file:write('			<adds/>\n')
					_file:write('			<override/>\n')
					_file:write('			<default_blueprint>\n')
					_file:write('				<value_node value="wpn_fps_empty_melee_sight"/>\n')
					_file:write('				<value_node value="wpn_fps_empty_melee_body_standard"/>\n')
					_file:write('			</default_blueprint>\n')
					_file:write('			<uses_parts>\n')
					_file:write('				<value_node value="wpn_fps_empty_melee_sight"/>\n')
					_file:write('				<value_node value="wpn_fps_empty_melee_body_standard"/>\n')
					_file:write('			</uses_parts>\n')
					_file:write('		</factory>\n')
					_file:write('		<stance/>\n')
					_file:write('	</Weapon>\n')
				end
			end
			_file:write('</table>')
			_file:close()			
			_file = io.open(Melee2WEP.ModPath..'/Loc/english.txt', "w+")
			_file:write(json.encode(new_named_loc))
			_file:close()
			local _dialog_data = {
				title = "[Weapon Clone]",
				text = "Please reboot the game.",
				button_list = {{ text = "[OK]", is_cancel_button = true }},
				id = tostring(math.random(0,0xFFFFFFFF))
			}
			local _unit2object = io.open(Melee2WEP.ModPath..'/unit2object.json', "w")
			if _unit2object and tweak_data.blackmarket.melee_weapons then
				local dates_insert = {true}
				local melee_tweak = tweak_data.blackmarket.melee_weapons
				local ids_unit = Idstring("unit")
				local ids_object = Idstring("object")
				for melee_id, melee_data in pairs(melee_tweak) do
					if melee_data.unit then
						local ids_melee_unit = Idstring(tostring(melee_data.unit))
						if melee_data.unit and DB:has(ids_unit, ids_melee_unit) then
							local db_unit_node = DB:load_node(ids_unit, ids_melee_unit)
							if db_unit_node then
								for child in db_unit_node:children() do
									if child:name() == "object" then
										local ids_melee_object = Idstring(tostring(child:parameter("file")))
										if DB:has(ids_object, ids_melee_object) then
											local db_oject_node = DB:load_node(ids_object, ids_melee_object)
											if db_oject_node then
												for child_o in db_oject_node:children() do
													if child_o:name() == "graphics" then
														for child_o_o in child_o:children() do
															if child_o_o:name() == "object" then
																dates_insert[melee_id] = tostring(child_o_o:parameter("name"))
															end
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end				
				_unit2object:write(json.encode(dates_insert))
				_unit2object:close()
			end
			managers.system_menu:show(_dialog_data)
		end
	end
	MenuHelper:AddButton({
		id = "Melee2WEP_menu_forced_update_callback",
		title = "Melee2WEP_menu_forced_update_all_title",
		desc = "Melee2WEP_menu_forced_update_all_desc",
		callback = "Melee2WEP_menu_forced_update_callback",
		menu_id = "Melee2WEP_menu",
	})
end)

Hooks:Add("MenuManagerBuildCustomMenus", "Melee2WEPOptions", function(menu_manager, nodes)
	nodes["Melee2WEP_menu"] = MenuHelper:BuildMenu( "Melee2WEP_menu" )
	MenuHelper:AddMenuItem(nodes["blt_options"], "Melee2WEP_menu", "Melee2WEP_menu_title", "Melee2WEP_menu_desc")
end)

pcall(__Load)