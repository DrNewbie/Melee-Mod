_G.Melee2WEP = _G.Melee2WEP or {}

local InstantConcussionBulletMelee_do_melee_damage = PlayerStandard._do_melee_damage

function PlayerStandard:_do_melee_damage(t, bayonet_melee, melee_hit_ray, melee_entry, ...)
	local col_ray = InstantConcussionBulletMelee_do_melee_damage(self, t, bayonet_melee, melee_hit_ray, melee_entry, ...)
	melee_entry = melee_entry or managers.blackmarket:equipped_melee_weapon()
	if Melee2WEP and Melee2WEP:IsMeleeApplyInGame(melee_entry) and table.contains(Melee2WEP.Mods[melee_entry].blueprint, "wpn_fps_concussionbullet_melee") then
		local range = ConcussionGrenade._PLAYER_FLASH_RANGE
		for _, data in pairs(managers.enemy:all_enemies()) do
			local hit_unit = data.unit
			if hit_unit and mvector3.distance(hit_unit:position(), self._unit:position()) <= range and hit_unit:character_damage() and hit_unit:character_damage().stun_hit then
				hit_unit:character_damage():stun_hit({
					variant = "stun",
					damage = 0,
					attacker_unit = self._unit,
					weapon_unit = self._equipped_unit,
					col_ray = col_ray or {
						position = hit_unit:position(),
						ray = Vector3(0, 0, 1)
					}
				})
				if hit_unit:character_damage().damage_simple then
					hit_unit:character_damage():damage_simple({
						variant = "graze",
						damage = 1,
						attacker_unit = self._unit,
						pos = hit_unit:position(),
						attack_dir = Vector3(0, 0, 1)
					})
				end
			end
		end
		local detonate_pos = self._unit:position() + math.UP * 100
		local affected, line_of_sight, travel_dis, linear_dis = QuickFlashGrenade._chk_dazzle_local_player(self, detonate_pos, range)
		managers.explosion:play_sound_and_effects(detonate_pos, math.UP, range, {
			camera_shake_max_mul = 4,
			effect = "effects/particles/explosions/explosion_flash_grenade",
			sound_event = "concussion_explosion",
			feedback_range = range
		})
		if affected then
			managers.environment_controller:set_concussion_grenade(detonate_pos, line_of_sight, travel_dis, linear_dis, tweak_data.character.concussion_multiplier)
			local sound_eff_mul = math.clamp(1 - (travel_dis or linear_dis) / range, 0.3, 1)
			managers.player:player_unit():character_damage():on_concussion(sound_eff_mul)
		end
	end
	return col_ray
end