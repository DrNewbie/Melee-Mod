Hooks:PostHook(WeaponFactoryTweakData, "init", "InstantConcussionBulletMelee_TweakData", function(self)
	for fac_id, fac_data in pairs(self) do
		if tostring(fac_id):find("wpn_fps_clonefakewep_") then
			table.insert(self[fac_id].uses_parts, "wpn_fps_concussionbullet_melee")
		end
	end
end)