Hooks:PostHook(WeaponFactoryTweakData, "init", Idstring(ModPath):key(), function(self)
	if self.wpn_fps_clonefakewep_rambo then
		table.insert(self.wpn_fps_clonefakewep_rambo.uses_parts, "wpn_fps_upg_o_aimpoint")
		self.parts.wpn_fps_upg_o_aimpoint.__melee_mod_pos_rot_func = function(data)
			if type(data) ~= "table" then
				return
			end
			if not data.melee_unit or not alive(data.melee_unit) then
				return
			end
			if not data.melee_mod_unit or not alive(data.melee_mod_unit) then
				return
			end
			data.melee_mod_unit:set_local_position(
				data.melee_mod_unit:local_position() + Vector3(0, 20, 0)
			)
			return
		end
	end
end)