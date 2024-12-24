return {
	AccelerationRate = 16, -- Acceleration rate for running
	DecelerationRate = 24, -- Deceleration rate for walking
	MinRunSpeed = 16, -- Min run speed for the player (Walk speed)
	MaxRunSpeed = 32, -- Max run speed for the player

	MinJumpPower = 16, -- Min jump power for the player
	MaxJumpPower = 28, -- Max jump power for the player

	VaultCooldown = 0.15, -- Vault cooldown for the player
	MaxVaultStuds = 2.75, -- Max studs in a vault
	MaxVaultReachDistance = 4, -- Vault raycast direction's magnitude
	MaxPartSizeToPosDifference = 0.8, -- Max difference between the position of the top of the part and the raycast's hit position

	SwingVelocity = 100, -- Horizontal velocity when swinging
	SwingWalkSpeed = 55, -- Walk speed after swing
}
