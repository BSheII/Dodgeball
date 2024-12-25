return {
	AccelerationRate = 16, -- Acceleration rate for running
	DecelerationRate = 24, -- Deceleration rate for walking
	MinRunSpeed = 16, -- Min run speed (Walk speed)
	MaxRunSpeed = 32, -- Max run speed (Walk speed)

	MinJumpPower = 16, -- Min jump power for the player
	MaxJumpPower = 28, -- Max jump power for the player

	VaultCooldown = 0.05, -- Vault cooldown for the player
	MaxVaultStuds = 2.75, -- Max studs in a vault

	SwingVelocity = 100, -- Horizontal velocity when swinging
	SwingWalkSpeed = 55, -- Walk speed after swing

	SlideMaxSpeed = 60, -- Max sliding speed
	SlideMinSpeed = 6, -- Minimum slide speed to keep sliding
	SlideAccelerationRate = 36, -- Acceleration rate for sliding
	SlideDecelerationRate = 75, -- Deceleration rate for sliding

	RollMaxSecondsTime = 1, -- Max seconds before rolling isn't valid
	MinimumVelocityToRoll = -40, -- Minimum velocity to be able to roll
}
