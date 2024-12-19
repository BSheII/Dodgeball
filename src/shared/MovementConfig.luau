return {
	MinRunSpeed = 8, -- Min run speed for the player (Walk speed)
	MaxRunSpeed = 32, -- Max run speed for the player

	VaultCooldown = 0.5, -- Vault cooldown for the player
	MaxVaultReachDistance = 4, -- Vault raycast direction's magnitude
	MaxPartSizeToPosDifference = 0.8, -- Max difference between the position of the top of the part and the raycast's hit position
	VaultBoostBase = 1.1, -- Base boost of a vault
	PerfectVault = 2.75, -- Boost number which is considered "perfect"
	PerfectVaultForgiveness = 0.1, -- Forgiveness for a perfect vault
}
