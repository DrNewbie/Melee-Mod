_G.Melee2WEP = _G.Melee2WEP or {}

local old_spawn_melee_weapon_clbk = MenuSceneManager.spawn_melee_weapon_clbk

function MenuSceneManager:spawn_melee_weapon_clbk(melee_id, ...)
	local melee_unit = old_spawn_melee_weapon_clbk(self, melee_id, ...)
	Melee2WEP:ApplyLinkToWeapon({
		melee_unit = melee_unit,
		melee_id = melee_id
	})
	return melee_unit
end