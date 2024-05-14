local mod = PonyMenu

if not mod.Config.Enabled then return end

RoomSetData.PonyMenu = {
	PonyMenuRoom =
	{
		InheritFrom = { "BaseF" },

		HasFishingPoint = false,

		ResetBinksOnEnter = true,
		ResetBinksOnExit = true,
		LegalEncounters = { "HealthRestore" },
		ForcedReward = "",

		EntranceFunctionName = "",
		EntranceFunctionArgs = {},
		BlockCameraReattach = false,
		ZoomFraction = 0.8,
		FlipHorizontalChance = 0.0,
	}
}

AddTableKeysCheckDupes(RoomData, RoomSetData.PonyMenu)
