/*

	Behavior:

	Knifing Combat Behavior.

	Weighting Parameters:
	1. Target must be able to be meleed(in the map or behind a barrier).
	2. Target is not grouped with other threats.
	3. Health is less than or equal to our knife damage.
	4. Target is within sprint distance(movespeed * 1.5 * sprinttimeleft).
	5. We want more money.

	Scripted Parameters:
	1. Denizen is attached.
	2. Hooked by panzer and claw is in range to be meleed.
	3. We have galvaknuckles on Die Rise during a jumping jack round.
	4. Melee avogadro if we are fighting him and do not have ray gun or emps.


	Shooting Combat Behavior.

	Explosives:

	Weighting Parameters:
	1. There are a lot of zombies grouped up.
	2. We don't need money.
	3. We wouldn't die to the explosion.
	4. Save a teammate.
	5. Kill special zombies.
	6. Insta kill for lots of kills/points.

	Scripted Parameters:
	1. Prefer target ground near target or target's feet.

	Full Auto Bullet:

	Weighting Parameters:
	1. There are a lot of zombies grouped up.
	2. We want money.
	3. Save a teammate.
	4. Kill special zombies.
	5. Insta Kill.
	6. Close to medium distance preferred.
	7. Hipfire close range; ADS medium to long range.

	Scripted Parameters:
	1. Prefer headshots.
	2. Prefer collaterals.

	Semi Auto/Bolt Action Bullet:

	Weighting Parameters:
	1. There are a lot of zombies grouped up.
	2. Save a teammate.
	3. Kill special zombies.
	4. Insta Kill(if semi auto).
	5. Medium to long distance preferred.

	Scripted Parameters:
	1. Prefer headshots.
	2. Prefer collaterals.
	3. Prefer ADS.

	Spread Bullet:

	Weighting Parameters:
	1. There are a lot of zombies grouped up.
	2. Save a teammate.
	3. Kill special zombies.
	4. Insta Kill.
	5. Close to medium distance preferred.

	Scripted Parameters:
	1. Prefer torso.
	2. Prefer hip fire.


	Reloading Combat Behavior:

	Weighting Parameters:
	1. We have time to complete the reload or reload cancel.
	2. Our alternate weapons suck.
	3. Tac reload if we aren't needing to shoot or sprint(any reload interrupting animation).

	Scripted Parameters:
	1. Try to reload all guns if a max ammo drops.


	Perk Priorities:

	Juggernog:
	1. We do not have it.
	2. It is accessible or we can afford it if we pay to access it.
	3. We have enough slots.
	4. We have enough points to afford it.
	5. We don't have a shield.
	6. We are playing solo.

	Speed Cola:
	1. We do not have it.
	2. We have enough slots.
	3. We have enough points to afford it.
	4. We have enough defense to preserve the investment.
	5. We have high reload time weapons that are high quality.
	6. We are rich as fuck.

	Double Tap:
	1. We do not have it.
	2. We have enough slots.
	3. We have enough points to afford it.
	4. We have enough defense to preserve the investment.
	5. We have weapons that benefit from the fire rate bonus.
	6. We have weapons that benefit from the bullet doubling effect.
	7. We have weapons that benefit from both.

	Quick Revive Solo:
	1. We do not have it.
	2. We have enough slots.
	3. We have enough points to afford it.

	Quick Revive Coop:
	1. We do not have it.
	2. We have enough slots.
	3. We have enough points to afford it.
	4. We have enough defense to preserve the investment.
	5. Our teammates are useful.
	6. We have Perma Quick Revive.
	7. We have a remote revive weapon(ballistic knife, staff, maxis drone).
	8. We have Juggernog.
	9. We have Electric Cherry.
	10. We have tacticals that affect the difficulty of reviving.
	11. We have a wonder weapon.
	12. We have teammates with high revives.
	13. We down more often than the team average.

	Staminup:
	1. We do not have it.
	2. We have enough slots.
	3. We have enough points to afford it.
	4. We have enough defense to preserve the investment.
	5. We have slow weapons.
	6. Map is big.
	7. We need to sprint longer for escapes and training.

	PHD Flopper:
	1. We do not have it.
	2. We have enough slots.
	3. We have enough points to afford it.
	4. We have enough defense to preserve the investment.
	5. We have explosive weapons.
	6. We like to flop.
	7. Fall damage is common on the map.

	Deadshot Daquiri:
	1. We have enough slots.
	2. We have enough points to afford it.
	3. We have enough defense to preserve the investment.
	4. It's the last perk on Earth.

	Mule Kick:
	1. We do not have it.
	2. We have enough slots.
	3. We have enough points to afford it.
	4. We have enough defense to preserve the investment.
	5. We are rich as fuck.
	6. We don't have a wonder weapon and it's not available.

	Tombstone:
	1. We have enough slots.
	2. We have enough points to afford it.
	3. We have enough defense to preserve the investment.
	4. It's the last perk on Earth.

	Who's Who:
	1. We do not have it.
	2. We have enough slots.
	3. We have enough points to afford it.
	4. We are playing Coop.
	5. We have other perks already
	
	Electric Cherry:
	1. We do not have it.
	2. We have enough slots.
	3. We have enough points to afford it.
	4. We have the Blundergat.
	5. We have Speed Cola.
	6. We have weapons that have a quick reload.
	7. We have weapons with a high empty rate.

	Vulture Aid:
	1. We do not have it.
	2. We have enough slots.
	3. We have enough points to afford it.
	4. We have enough defense to preserve the investment.
	5. We are rich as fuck.
	
*/