---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- here is where your mod sets up all the things it will do.
-- this file will not be reloaded if it changes during gameplay
-- 	so you will most likely want to have it reference
--	values and functions later defined in `reload.lua`.

mod = modutil.mod.Mod.Register(_PLUGIN.guid)

mod.Locales = mod.Locales or {}

data = {}

local package = rom.path.combine(_PLUGIN.plugins_data_mod_folder_path, _PLUGIN.guid)
modutil.mod.Path.Wrap("SetupMap", function(base) LoadPackages({ Name = package, })base()end)

ModUtil.LoadOnce(function()
	if not rom.game.GameState.PonyMenu then
		rom.game.GameState.PonyMenu = { Data = {} }
	end
	data = rom.game.GameState.PonyMenu.Data
end)

function mod.GetLanguageString(path)
	local locale = mod.Locales[GetLanguage()] or mod.Locales.en
	return ModUtil.Path.Get(path, locale) or ModUtil.Path.Get(path, mod.Locales.en)
end

function public.AddLocale(lang, data)
	mod.Locales[lang] = data
end

local function setupMainData()
	mod.CurrentLocale = GetLanguage()
	mod.Locale = setmetatable({}, {
		__index = function(_, k)
			return mod.GetLanguageString(k)
		end
	})

	mod.BoonData = {
		ZeusUpgrade = {},
		PoseidonUpgrade = {},
		AphroditeUpgrade = {},
		AresUpgrade = {},
		ApolloUpgrade = {},
		DemeterUpgrade = {},
		HephaestusUpgrade = {},
		HestiaUpgrade = {},
		ArtemisUpgrade = {},
		HermesUpgrade = {},
		HeraUpgrade = {},
		TrialUpgrade = {},
		SpellDrop = {},
		WeaponUpgrade = {},
		NPC_Arachne_01 = {},
		NPC_Narcissus_01 = {},
		NPC_Echo_01 = {},
		NPC_LordHades_01 = {},
		NPC_Medea_01 = {},
		NPC_Icarus_01 = {},
		NPC_Circe_01 = {},
		NPC_Athena_01 = {},
		NPC_Dionysus_01 = {}
	}

	mod.HammerRarityUpgradeOrder = { "Common", "Legendary" }


	mod.ConsumableData = {
		-- "HealDrop",
		-- "RoomMoneyDrop",
		-- "MaxHealthDrop",
		-- "MaxManaDrop",
		-- "TalentDrop",
		-- "RerollDrop",
		-- "LastStandDrop",
		-- "MinorDodgeDrop",
		-- "MinorDamageBoost",
		-- "HitShieldDrop",
		-- "ArmorBoost",
		-- "FireBoost",
		-- "AirBoost",
		-- "EarthBoost",
		-- "WaterBoost",
		-- "ElementalBoost",
		-- "MinorExDamageBoost",
	}
end

function mod.UpdateScreenData()
	if mod.CurrentLocale ~= GetLanguage() then
		mod.CurrentLocale = GetLanguage()
		mod.setupScreenData()
		mod.setupCommandData()
	end
end

-- Is it possible this could be done with ModUtil.Path.Context.Wrap?
ModUtil.Path.Override("InventoryScreenDisplayCategory", function(screen, categoryIndex, args)
	args = args or {}
	local components = screen.Components

	-- Cleanup prev category
	local prevCategory = screen.ItemCategories[screen.ActiveCategoryIndex]
	--Mod start
	if prevCategory == nil then
		prevCategory = screen.ItemCategories[1]
	end
	-- Mod end
	if prevCategory.CloseFunctionName ~= nil then
		CallFunctionName( prevCategory.CloseFunctionName, screen )
	else
		for i, resourceName in ipairs( prevCategory ) do
			local resourceComponent = components[resourceName]
			if resourceComponent ~= nil then
				if resourceComponent.NewIcon ~= nil then
					Destroy({ Id = resourceComponent.NewIcon.Id })
				end
				-- Mod start
				if resourceComponent.Highlight ~= nil then
					Destroy({ Id = resourceComponent.Highlight.Id })
				end
				-- Mod end
				Destroy({ Id = resourceComponent.Id })
			end
		end
	end

	ModifyTextBox({ Id = components.InfoBoxName.Id, FadeTarget = 0.0, })
	ModifyTextBox({ Id = components.InfoBoxDescription.Id, FadeTarget = 0.0, })
	ModifyTextBox({ Id = components.InfoBoxDetails.Id, FadeTarget = 0.0, })
	ModifyTextBox({ Id = components.InfoBoxFlavor.Id, FadeTarget = 0.0, })
	if screen.Components["Category"..prevCategory.Name] ~= nil then
		StopAnimation({ DestinationId = screen.Components["Category"..prevCategory.Name].Id, Name = "InventoryTabHighlightActiveCategory" })
	end

	local category = screen.ItemCategories[categoryIndex]
	if category.Locked then
		return
	end
	local slotName = category.Name

	-- Highlight new category
	CreateAnimation({ DestinationId = screen.Components["Category"..slotName].Id, Name = "InventoryTabHighlightActiveCategory", Group = "Combat_Menu_TraitTray" })
	ModifyTextBox({ Id = screen.Components.CategoryTitleText.Id, Text = category.Name })

	local newButtonKey = "NewIcon"..slotName
	if components[newButtonKey] ~= nil then
		Destroy({ Id = components[newButtonKey].Id })
	end

	--Mod Start
	if category.Name == "PONYMENU" or category.Name == "Pony Menu" then
		ModifyTextBox({ Id = screen.Components.CategoryTitleText.Id, Text = mod.Locale.PonyMenuCategoryTitle })
	else
		ModifyTextBox({ Id = screen.Components.CategoryTitleText.Id, Text = category.Name })
	end
	--Mod end

	screen.ActiveCategoryIndex = categoryIndex

	screen.CloseAnimation = category.CloseAnimation
	if args.FirstOpen then
		SetAnimation({ DestinationId = components.Background.Id, Name = category.OpenAnimation })
	else
		local fromMap = screen.TransitionAnimationMap[prevCategory.CloseAnimation]
		-- Mod start
		local transitionAnimationName
		if fromMap ~= nil then
			transitionAnimationName = fromMap[category.CloseAnimation]
		end
		-- Mod end
		if transitionAnimationName ~= nil then
			SetAnimation({ DestinationId = components.Background.Id, Name = transitionAnimationName })
		end
	end

	if category.GamepadNavigation ~= nil then
		SetGamepadNavigation( category )
	else
		SetGamepadNavigation( screen )
	end

	if category.OpenFunctionName ~= nil then
		CallFunctionName( category.OpenFunctionName, screen )
		return
	end

	if screen.Args.PlantTarget ~= nil and GameState.WorldUpgrades.WorldUpgradeGardenMultiPlant then
		components.PinButton.OnPressedFunctionName = "GardenMultiPlantSeed"
	end

	local resourceLocation = { X = screen.GridStartX, Y = screen.GridStartY }
	local columnNum = 1
	-- Mod start
	if category.Name ~= "PONYMENU" and category.Name ~= "Pony Menu" then
		for i, resourceName in ipairs( category ) do

			local resourceData = ResourceData[resourceName]
			if CanShowResourceInInventory( resourceData ) then

				local textLines = nil
				local canBeGifted = false
				local canBePlanted = false
				if screen.Args.PlantTarget ~= nil then
					if GardenData.Seeds[resourceName] then
						canBePlanted = true
					end
				elseif screen.Args.GiftTarget ~= nil then
					if screen.Args.GiftTarget.UnlimitedGifts ~= nil and screen.Args.GiftTarget.UnlimitedGifts[resourceName] then
						canBeGifted = true
					else
						local spending = {}
						spending[resourceName] = 1
						textLines = GetRandomEligibleTextLines( screen.Args.GiftTarget, screen.Args.GiftTarget.GiftTextLineSets, GetNarrativeDataValue( screen.Args.GiftTarget, "GiftTextLinePriorities" ), { Spending = spending } )
						if textLines ~= nil then
							canBeGifted = true
						end
					end
				end

				local alpha = nil
				local alphaTarget = nil
				local alphaTargetDuration = nil
				if args.FirstOpen then
					alpha = 0.0
					alphaTarget = 1.0
					alphaTargetDuration	= 0.6
				end
				local button = CreateScreenComponent({ Name = "ButtonInventoryItem",
					Scale = resourceData.IconScale or 1.0,
					Sound = "/SFX/Menu Sounds/IrisMenuBack",
					Group = "Combat_Menu_Overlay",
					X = resourceLocation.X,
					Y = resourceLocation.Y,
					Alpha = 0.0,
					AlphaTarget = 1.0,
					AlphaTargetDuration	= 0.6,
				})
				
				button.Screen = screen
				button.ResourceData = resourceData
				components[resourceName] = button
				SetAnimation({ DestinationId = button.Id, Name = resourceData.IconPath or resourceData.Icon })

				local buttonHighlight = CreateScreenComponent({ Name = "BlankObstacle",
					Group = "Combat_Menu_Overlay_Additive",
					X = resourceLocation.X,
					Y = resourceLocation.Y,
					Alpha = 0.0,
					AlphaTarget = 1.0,
					AlphaTargetDuration	= 0.6,
				})
				components[resourceName.."Highlight"] = buttonHighlight
				button.Highlight = buttonHighlight
			
				if canBePlanted then
					if HasResource( resourceName, 1 ) then
						button.ContextualAction = "Menu_Plant"
						button.OnPressedFunctionName = "GardenPlantSeed"

						if GameState.WorldUpgrades.WorldUpgradeGardenMultiPlant then
							local numEmptyPlots = 0
							for id, plot in pairs( GameState.GardenPlots ) do
								if plot.SeedName == nil then
									numEmptyPlots = numEmptyPlots + 1
								end
							end
							if numEmptyPlots > 1 and HasResource( resourceName, 2 ) then
								button.PinContextualAction = "Menu_MultiPlant"
								button.PlantAmount = math.min( numEmptyPlots, GameState.Resources[resourceName] )
							end
						end

						if #GardenData.Seeds[resourceName].RandomOutcomes == 1 then
							local growsIntoName = GetFirstKey( GardenData.Seeds[resourceName].RandomOutcomes[1].AddResources )
							local amountNeededByPins = GetResourceAmountNeededByPins( growsIntoName )
							if amountNeededByPins > 0 then
								local pinAnimation = "StoreItemPin"
								if HasResource( growsIntoName, amountNeededByPins ) then
									pinAnimation = "StoreItemPin_Complete"
								end
								button.PinIcon = CreateScreenComponent({
									Name = "BlankObstacle",
									Group = "Combat_Menu_Overlay",
									Scale = screen.SeedPinIconScale,
									X = resourceLocation.X + screen.SeedPinIconOffsetX,
									Y = resourceLocation.Y + screen.SeedPinIconOffsetY,
									Animation = pinAnimation,
								})
								components[resourceName.."PinIcon"] = button.PinIcon
							end
						end
					else
						SetColor({ Id = button.Id, Color = Color.Black })
						button.MouseOverText = "InventoryScreen_SeedNotAvailable"
					end
				elseif canBeGifted then
					if HasResource( resourceName, 1 ) then
						button.ContextualAction = "Menu_Gift"
						button.OnPressedFunctionName = "GiveSelectedGift"
						button.TextLines = textLines
					else
						SetColor({ Id = button.Id, Color = Color.Black })
						button.MouseOverText = "InventoryScreen_GiftNotAvailable"
					end				
				elseif screen.Args.PlantTarget ~= nil then
					SetColor({ Id = button.Id, Color = Color.Black })
					button.MouseOverText = "InventoryScreen_SeedNotWanted"
				elseif screen.Args.GiftTarget ~= nil then
					SetColor({ Id = button.Id, Color = Color.Black })
					button.MouseOverText = "InventoryScreen_GiftNotWanted"
				end

				CreateTextBoxWithScreenFormat( screen, button, "ResourceCountFormat", { Text = GameState.Resources[resourceName] or 0 } )

				button.MouseOverSound = "/SFX/Menu Sounds/DialoguePanelOutMenu"
				button.OnMouseOverFunctionName = "MouseOverResourceItem"
				button.OnMouseOffFunctionName = "MouseOffResourceItem"

				button.Viewable = not screen.Args.CategoryLocked or button.OnPressedFunctionName ~= nil
				if button.Viewable then
					-- highlight the initial selection, or the last resource you collected
					if resourceName == args.InitialSelection then
						screen.CursorStartX = resourceLocation.X
						screen.CursorStartY = resourceLocation.Y
					elseif resourceName == GameState.UnviewedLastResourceGained then
						UnviewedLastResourceGainedPresentation( screen, button )
						GameState.UnviewedLastResourceGained = nil
						screen.CursorStartX = resourceLocation.X
						screen.CursorStartY = resourceLocation.Y
					end

					-- mark unviewed resources as "new"
					if not GameState.ResourcesViewed[resourceName] then
						local newIcon = CreateScreenComponent({ Name = "BlankObstacle", Animation = "MusicPlayerNewTrack", Group = screen.ComponentData.DefaultGroup, Scale = screen.NewItemStarScale, })
						if args.FirstOpen then
							SetAlpha({ Id = newIcon.Id, Fraction = 0.0 })
							SetAlpha({ Id = newIcon.Id, Fraction = 1.0, Duration = 0.6 })
						end
						Attach({ Id = newIcon.Id, DestinationId = button.Id, OffsetX = screen.NewItemStarOffsetX, OffsetY = screen.NewItemStarOffsetY })
						button.NewIcon = newIcon
						components["NewIcon"..resourceName] = newIcon
					end
				end

				if columnNum < screen.GridWidth then
					columnNum = columnNum + 1
					resourceLocation.X = resourceLocation.X + screen.GridSpacingX
				else
					resourceLocation.Y = resourceLocation.Y + screen.GridSpacingY
					resourceLocation.X = screen.GridStartX
					columnNum = 1
				end
			end
			
		end
	else
		-- Pony Menu
		for index, k in ipairs(mod.CommandData) do
			-- for the clean up to work
			table.insert(category, index)

			local itemData = mod.CommandData[index]
			local button = CreateScreenComponent({
				Name = "ButtonInventoryItem",
				Scale = itemData.IconScale or 1.0,
				Sound = "/SFX/Menu Sounds/GodBoonMenuClose",
				Group = "Combat_Menu_Overlay",
				X = resourceLocation.X,
				Y = resourceLocation.Y + 10,
			})
			AttachLua({ Id = button.Id, Table = button })
			button.Screen = screen
			button.ItemData = itemData
			components[index] = button
			SetAnimation({ DestinationId = button.Id, Name = itemData.IconPath or itemData.Icon })

			-- CreateTextBoxWithScreenFormat( screen, button, "ResourceCountFormat", { Text = itemData.Name or "WIP" } )

			button.MouseOverSound = "/SFX/Menu Sounds/DialoguePanelOutMenu"
			button.OnMouseOverFunctionName = mod.mouseOverCommandItem
			button.OnMouseOffFunctionName = mod.mouseOffCommandItem
			button.OnPressedFunctionName = mod.Command

			if columnNum < screen.GridWidth then
				columnNum = columnNum + 1
				resourceLocation.X = resourceLocation.X + screen.GridSpacingX
			else
				resourceLocation.Y = resourceLocation.Y + screen.GridSpacingY
				resourceLocation.X = screen.GridStartX
				columnNum = 1
			end
		end
	end
	-- Mod end
end, mod)

function mod.mouseOverCommandItem(button)
	local screen = button.Screen
	if screen.Closing then
		return
	end

	GenericMouseOverPresentation(button)

	local components = screen.Components
	local buttonHighlight = CreateScreenComponent({
		Name = "InventorySlotHighlight",
		Scale = 1.0,
		Group =
		"Combat_Menu_Overlay",
		DestinationId = button.Id
	})
	components.InventorySlotHighlight = buttonHighlight
	button.HighlightId = buttonHighlight.Id
	Attach({ Id = buttonHighlight.Id, DestinationId = button.Id })
	ModifyTextBox({
		Id = components.InfoBoxName.Id,
		Text = button.ItemData.Name,
		UseDescription = false,
		FadeTarget = 1.0,
		ScaleTarget = 0.8
	})
	ModifyTextBox({
		Id = components.InfoBoxDescription.Id,
		Text = button.ItemData.Description or " ",
		UseDescription = false,
		FadeTarget = 1.0,
	})

	SetScale({ Id = button.Id, Fraction = (button.ItemData.IconScale or 1.0) * screen.IconMouseOverScale, Duration = 0.1, EaseIn = 0.9, EaseOut = 1.0, SkipGeometryUpdate = true })
	--StopFlashing({ Id = button.Id })
	UpdateResourceInteractionText(screen, button)
end

function mod.mouseOffCommandItem(button)
	Destroy({ Id = button.HighlightId })
	local components = button.Screen.Components
	components.InventorySlotHighlight = nil
	ModifyTextBox({ Id = components.InfoBoxName.Id, FadeTarget = 0.0, })
	ModifyTextBox({ Id = components.InfoBoxDescription.Id, FadeTarget = 0.0, })
	ModifyTextBox({ Id = components.InfoBoxDetails.Id, FadeTarget = 0.0, })
	ModifyTextBox({ Id = components.InfoBoxFlavor.Id, FadeTarget = 0.0, })
	SetScale({ Id = button.Id, Fraction = button.ItemData.IconScale or 1.0, Duration = 0.1, SkipGeometryUpdate = true })
	StopFlashing({ Id = button.Id })
	UpdateResourceInteractionText(button.Screen)
end

function mod.Command(screen, button)
	local command = button.ItemData
	local triggerArgs = {}
	if command.Type == "Boon" then
		mod.OpenBoonSelector(screen, button)
	elseif command.Type == "Command" then
		CloseInventoryScreen(screen, screen.ComponentData.ActionBar.Children.CloseButton)
		_G[command.Function]()
	end
end

function mod.PopulateBoonData(upgradeName)
	local godName = string.gsub(upgradeName, 'Upgrade', '')
	local index = 0

	if LootSetData[godName] ~= nil and LootSetData[godName][upgradeName].WeaponUpgrades ~= nil then
		for k, v in pairs(LootSetData[godName][upgradeName].WeaponUpgrades) do
			index = index + 1
			mod.BoonData[upgradeName][index] = v
		end
	end

	if LootSetData[godName] ~= nil and LootSetData[godName][upgradeName].Traits ~= nil then
		for k, v in pairs(LootSetData[godName][upgradeName].Traits) do
			index = index + 1
			mod.BoonData[upgradeName][index] = v
		end
	end

	if mod.BoonData[upgradeName] == nil or IsEmpty(mod.BoonData[upgradeName]) then
		if upgradeName == "SpellDrop" then
			for k, v in pairs(QuestData.QuestDarkSorceries.CompleteGameStateRequirements[1].HasAll) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		elseif upgradeName == "WeaponUpgrade" then
			local wp = GetEquippedWeapon()
			for k, v in pairs(LootSetData.Loot[upgradeName].Traits) do
				local boon = TraitData[v]
				if boon.CodexWeapon == GetEquippedWeapon() then
					index = index + 1
					mod.BoonData.WeaponUpgrade[index] = v
				end
			end
		elseif upgradeName == "TrialUpgrade" then
			for k, v in pairs(LootSetData.Chaos.TrialUpgrade.PermanentTraits) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		elseif upgradeName == "NPC_Arachne_01" then
			for k, v in pairs(PresetEventArgs.ArachneCostumeChoices.UpgradeOptions) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v.ItemName
			end
		elseif upgradeName == "ArtemisUpgrade" then
			for k, v in pairs(UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.Traits) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		elseif upgradeName == "NPC_Narcissus_01" then
			for k, v in pairs(UnitSetData.NPC_Narcissus.NPC_Narcissus_01.Traits) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		elseif upgradeName == "NPC_Echo_01" then
			for k, v in pairs(UnitSetData.NPC_Echo.NPC_Echo_01.Traits) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		elseif upgradeName == "NPC_LordHades_01" then
			for k, v in pairs(UnitSetData.NPC_Hades.NPC_Hades_Field_01.Traits) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		elseif upgradeName == "NPC_Medea_01" then
			for k, v in pairs(UnitSetData.NPC_Medea.NPC_Medea_01.Traits) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		elseif upgradeName == "NPC_Icarus_01" then
			for k, v in pairs(UnitSetData.NPC_Icarus.NPC_Icarus_01.Traits) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		elseif upgradeName == "NPC_Circe_01" then
			for k, v in pairs(UnitSetData.NPC_Circe.NPC_Circe_01.Traits) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		elseif upgradeName == "NPC_Athena_01" then
			for k, v in pairs(UnitSetData.NPC_Athena.NPC_Athena_01.Traits) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		elseif upgradeName == "NPC_Dionysus_01" then
			for k, v in pairs(UnitSetData.NPC_Dionysus.NPC_Dionysus_01.Traits) do
				index = index + 1
				mod.BoonData[upgradeName][index] = v
			end
		end
	end
end

function mod.GetLootColor(upgradeName)
	local godName = string.gsub(upgradeName, 'Upgrade', '')
	local color = Color.Black
	if config.ColorblindMode == true then
		return color
	end
	if LootSetData[godName] ~= nil then
		color = LootSetData[godName][upgradeName].LootColor
	elseif upgradeName == "SpellDrop" then
		color = LootSetData.Selene[upgradeName].LootColor
	elseif upgradeName == "WeaponUpgrade" then
		color = LootSetData.Loot[upgradeName].LootColor
	elseif upgradeName == "NPC_Arachne_01" then
		color = Color.ArachneVoice
	elseif upgradeName == "ArtemisUpgrade" then
		color = UnitSetData.NPC_Artemis.NPC_Artemis_Field_01.LootColor
	elseif upgradeName == "NPC_Echo_01" then
		color = Color.EchoVoice
	elseif upgradeName == "NPC_Narcissus_01" then
		color = Color.NarcissusVoice
	elseif upgradeName == "NPC_LordHades_01" then
		color = UnitSetData.NPC_Hades.NPC_Hades_Field_01.LootColor
	elseif upgradeName == "NPC_Medea_01" then
		color = Color.MedeaVoice
	elseif upgradeName == "NPC_Icarus_01" then
		color = Color.IcarusVoice
	elseif upgradeName == "NPC_Circe_01" then
		color = Color.CirceVoice
	elseif upgradeName == "NPC_Athena_01" then
		color = Color.AthenaVoice
	elseif upgradeName == "NPC_Dionysus_01" then
		color = Color.DionysusVoice
	end
	return color
end

function mod.GetLootColorFromTrait(traitName)
	local color = Color.Red
	if config.ColorblindMode == true then
		return color
	end
	for upgradeName, boonData in pairs(mod.BoonData) do
		if Contains(boonData, traitName) then
			color = mod.GetLootColor(upgradeName)
		end
	end
	return color
end

function mod.RemoveAllTraits()
	for i, traitData in pairs(CurrentRun.Hero.Traits) do
		RemoveTrait(CurrentRun.Hero, traitData.Name)	
	end
end

function mod.RemoveAllBoons()
	for i, traitData in pairs(CurrentRun.Hero.Traits) do
		-- Only remove boons
		if traitData.RarityLevels ~= nil and traitData.Slot ~= "Keepsake" and traitData.Slot ~= "Aspect" and traitData.UpgradeResourceCost == nil then
			RemoveTrait(CurrentRun.Hero, traitData.Name)
		end
	end
end

function mod.ReloadEquipment()
	EquipWeaponUpgrade(CurrentRun.Hero, { SkipNewTraitHighlight = true, SkipUIUpdate = true })
	EquipKeepsake(CurrentRun.Hero, GameState.LastAwardTrait, { FromLoot = true, SkipNewTraitHighlight = true, AddToCache = true })
	EquipFamiliar(nil, { Unit = CurrentRun.Hero, FamiliarName = GameState.EquippedFamiliar })
	EquipMetaUpgrades(CurrentRun.Hero, { SkipNewTraitHighlight = true })
end

function mod.ClearAllBoons()
	mod.RemoveAllBoons()
	-- mod.ReloadEquipment()
	-- ClearUpgrades()
end

function mod.IsBoonTrait(traitName)
	for i, lootset in pairs(LootSetData) do
		for k, loot in pairs(lootset) do
			if loot.Icon == "BoonSymbolHermes" and loot.TraitIndex[traitName] then
				return true
			elseif loot.Icon == "BoonSymbolChaos" and Contains(loot.PermanentTraits, traitName) then
				return true
			elseif loot.Icon == "BoonSymbolChaos" and Contains(loot.TemporaryTraits, traitName) then
				return true
			elseif loot.Icon == "WeaponUpgradeSymbol" and loot.TraitIndex[traitName] then
				return true
			end
		end
	end
end

function CreateNewCustomRun(room)
	local prevRun = CurrentRun
	local args = args or {}
	SetupRunData()
	ResetUI()

	rom.game.CurrentRun = {}
	RunStateInit()

	if args.RunOverrides ~= nil then
		OverwriteTableKeys( CurrentRun, args.RunOverrides )
	end

	for name, value in pairs(GameState.ShrineUpgrades) do
		ShrineUpgradeExtractValues(name)
	end

	CurrentRun.ActiveBounty = args.ActiveBounty
	CurrentRun.ForceNextEncounterData = args.Encounter
	CurrentRun.Hero = CreateNewHero(prevRun, args)

	if GameState.WorldUpgrades.WorldUpgradeUnusedWeaponBonus ~= nil then
		if prevRun ~= nil and prevRun.BonusUnusedWeaponName ~= nil and CurrentRun.Hero.Weapons[prevRun.BonusUnusedWeaponName] then
			if GameState.WorldUpgrades.UnusedWeaponBonusAddGems then
				AddTrait(CurrentRun.Hero, "UnusedWeaponBonusTraitAddGems")
			else
				AddTrait(CurrentRun.Hero, "UnusedWeaponBonusTrait")
			end
		end
	end

	local bountyData = BountyData[args.ActiveBounty]
	if bountyData ~= nil and bountyData.StartingTraits ~= nil then
		LoadActiveBountyPackages()
		for i, traitData in ipairs( bountyData.StartingTraits ) do
			AddTrait( CurrentRun.Hero, traitData.Name, traitData.Rarity, { FromLoot = true })
		end
	end

	-- EquipKeepsake(CurrentRun.Hero, GameState.LastAwardTrait, { FromLoot = true, SkipNewTraitHighlight = true })
	-- EquipAssist(CurrentRun.Hero, GameState.LastAssistTrait, { SkipNewTraitHighlight = true })
	-- EquipFamiliar(nil, { Unit = CurrentRun.Hero, FamiliarName = GameState.EquippedFamiliar, SkipNewTraitHighlight = true })
	-- EquipWeaponUpgrade(CurrentRun.Hero, { SkipNewTraitHighlight = true })
	-- EquipMetaUpgrades(CurrentRun.Hero, { SkipNewTraitHighlight = true })
	mod.LoadState(true)
	UpdateRunHistoryCache(CurrentRun)

	CurrentRun.BonusUnusedWeaponName = GetRandomUnequippedWeapon()
	CurrentRun.ActiveBiomeTimer = GetNumShrineUpgrades("BiomeSpeedShrineUpgrade") > 0
	CurrentRun.NumRerolls = GetTotalHeroTraitValue( "RerollCount" )
	CurrentRun.NumTalentPoints = GetTotalHeroTraitValue("TalentPointCount")
	CurrentRun.ActiveBountyClears = GameState.PackagedBountyClears[CurrentRun.ActiveBounty] or 0
	CurrentRun.ActiveBountyAttempts = GameState.PackagedBountyAttempts[CurrentRun.ActiveBounty] or 0
	CurrentRun.SpellCharge = 5000

	if ConfigOptionCache.EasyMode then
		CurrentRun.EasyModeLevel = GameState.EasyModeLevel
	end

	InitHeroLastStands(CurrentRun.Hero)

	InitializeRewardStores(CurrentRun)
	--SelectBannedEliteAttributes( CurrentRun )

	CurrentRun.CurrentRoom = CreateRoom(room, args)


	-- if args.RoomName ~= nil then
	-- 	CurrentRun.CurrentRoom = CreateRoom(RoomData[args.RoomName], args)
	-- else
	-- 	CurrentRun.CurrentRoom = ChooseStartingRoom(CurrentRun, args)
	-- end

	AddResource("Money", CalculateStartingMoney(), "RunStart")

	return CurrentRun
end

function StartNewCustomRun(room)
	--TODO hook player death by boss
	AddInputBlock({ Name = "StartOver" })

	for index, familiarName in ipairs(FamiliarOrderData) do
		local familiarData = FamiliarData[familiarName]
		local familiar = familiarData.Unit
		if familiar then
			CleanupEnemy(familiar)
			familiarData.Unit = nil
		end
	end

	local currentRun = CurrentRun
	EndRun(currentRun)
	CurrentHubRoom = nil
	PreviousDeathAreaRoom = nil

	HideCombatUI("StartOver")
	currentRun = CreateNewCustomRun(room)
	StopMusicianMusic({ Duration = 1.0 })
	ResetObjectives()

	SetConfigOption({ Name = "FlipMapThings", Value = false })
	SetConfigOption({ Name = "BlockGameplayTimer", Value = false })

	AddTimerBlock(currentRun, "StartOver")

	-- RequestSave({ StartNextMap = currentRun.CurrentRoom.Name, SaveName = "_Temp", DevSaveName = CreateDevSaveName(currentRun) })
	ValidateCheckpoint({ Value = true })

	UnblockCombatUI( "StartOver" )
	WaitForSpeechFinished()
	RemoveInputBlock({ Name = "StartOver" })
	RemoveTimerBlock( currentRun, "StartOver" )
	AddInputBlock({ Name = "MapLoad" })
	AddTimerBlock( CurrentRun, "MapLoad" )

	LoadMap({ Name = currentRun.CurrentRoom.Name, ResetBinks = true })
end

function mod.KillPlayer()
	CurrentRun.Hero.IsDead = false
	Kill(CurrentRun.Hero)
end

function mod.SaveState()
	if CurrentRun.Hero.Traits ~= nil then
		local wp = GetEquippedWeapon()
		local aspect = GameState.LastWeaponUpgradeName[wp]
		local aspectLevel = GetWeaponUpgradeLevel(aspect)
		data.SavedState = {
			Traits = {},
			MetaUpgrades = {},
			Weapon = wp,
			Aspect = { Name = aspect, Rarity = TraitRarityData.WeaponRarityUpgradeOrder[aspectLevel] },
			Keepsake = GameState.LastAwardTrait,
			Assist = GameState.LastAssistTrait,
			Familiar = GameState.EquippedFamiliar,
			Hex = nil
		}
		for i, traitData in pairs(CurrentRun.Hero.Traits) do
			if
				not traitData.MetaUpgrade
				and traitData.Name ~= data.SavedState.Weapon
				and traitData.Name ~= data.SavedState.Aspect.Name
				and traitData.Name ~= data.SavedState.Keepsake
				and traitData.Name ~= data.SavedState.Assist
				and traitData.Name ~= data.SavedState.Familiar
			then
				if traitData.Slot and traitData.Slot == "Spell" then
					data.SavedState.Hex = traitData.Name
				else
					table.insert(data.SavedState.Traits, { Name = traitData.Name, Rarity = traitData.Rarity, StackNum = traitData.StackNum })
				end
			elseif traitData.MetaUpgrade then
				table.insert(data.SavedState.MetaUpgrades, {
					TraitName = traitData.Name,
					Rarity = traitData.Rarity,
					CustomMultiplier = traitData.CustomMultiplier,
					SourceName = traitData.Name
				})
			end
		end
		SaveCheckpoint({ DevSaveName = CreateDevSaveName(CurrentRun) })
		PlaySound({ Name = "/SFX/WrathEndingWarning", Id = CurrentRun.Hero.ObjectId })
		thread(InCombatTextArgs,
			{
				TargetId = CurrentRun.Hero.ObjectId,
				Text = mod.Locale.SaveStateSaved,
				SkipRise = false,
				SkipFlash = false,
				Duration = 1.5,
				ShadowScaleX = 1.5,
			})
	end
end

function mod.LoadState(newRun)
	if data.SavedState ~= nil then
		if newRun == nil then
			mod.RemoveAllTraits()
			ClearUpgrades()
		end
		if GameState.LastAwardTrait == "ReincarnationKeepsake" then
			RemoveLastStand(CurrentRun.Hero, "ReincarnationKeepsake")
			CurrentRun.Hero.MaxLastStands = CurrentRun.Hero.MaxLastStands - 1
		end
		EquipPlayerWeapon(WeaponData[data.SavedState.Weapon], { LoadPackages = true })
		if data.SavedState.Keepsake ~= nil then
			EquipKeepsake(CurrentRun.Hero, data.SavedState.Keepsake, { FromLoot = true, SkipNewTraitHighlight = true })
		end
		if data.SavedState.Assist ~= nil then
			EquipAssist(CurrentRun.Hero, data.SavedState.Assist, { SkipNewTraitHighlight = true })
		end
		if data.SavedState.Familiar ~= nil then
			EquipFamiliar(nil, { Unit = CurrentRun.Hero, FamiliarName = data.SavedState.Familiar, SkipNewTraitHighlight = true })
		end
		if data.SavedState.Aspect.Name ~= nil then
			AddTraitToHero({
				TraitName = data.SavedState.Aspect.Name,
				Rarity = data.SavedState.Aspect.Rarity,
				SkipNewTraitHighlight = true,
				SkipQuestStatusCheck = true,
				SkipActivatedTraitUpdate = true,
			})
		end
		for _, traitData in pairs(data.SavedState.Traits) do
			AddTraitToHero({
				TraitData = GetProcessedTraitData({
					Unit = CurrentRun.Hero,
					TraitName = traitData.Name,
					Rarity = traitData.Rarity,
					StackNum = traitData.StackNum
				}),
				SkipNewTraitHighlight = true,
				SkipQuestStatusCheck = true,
				SkipActivatedTraitUpdate = true,
			})
		end
		if data.SavedState.Hex ~= nil then
			AddTraitToHero({
				TraitName = data.SavedState.Hex,
				SkipNewTraitHighlight = true,
				SkipQuestStatusCheck = true,
				SkipActivatedTraitUpdate = true,
			})
			-- CurrentRun.Hero.SlottedSpell = DeepCopyTable(SpellData[data.SavedState.Hex])
			-- CurrentRun.Hero.SlottedSpell.Talents = DeepCopyTable(CreateTalentTree(SpellData[data.SavedState.Hex]))
		end
		for _, traitData in pairs(data.SavedState.MetaUpgrades) do
			AddTraitToHero({
				SkipNewTraitHighlight = true,
				SkipQuestStatusCheck = true,
				SkipActivatedTraitUpdate = true,
				TraitName = traitData.TraitName,
				Rarity = traitData.Rarity,
				CustomMultiplier = traitData.CustomMultiplier,
				SourceName = traitData.SourceName,
			})
		end
		if newRun == nil then
			PlaySound({ Name = "/SFX/WrathEndingWarning", Id = CurrentRun.Hero.ObjectId })
			thread(InCombatTextArgs,
				{
					TargetId = CurrentRun.Hero.ObjectId,
					Text = mod.Locale.SaveStateLoaded,
					SkipRise = false,
					SkipFlash = false,
					Duration = 1.5,
					ShadowScaleX = 1.5,
				})
		end
	end
end

function mod.GoToTrainingRoom()
	local prevRun = CurrentRun
	CurrentRun.Hero = CreateNewHero(prevRun)
	CurrentRun.Hero.IsDead = true
	LoadMap({ Name = "Hub_PreRun", ResetBinks = true })
end

function mod.PopulateConsumableData()
	local consumableData = DeepCopyTable(ConsumableData)
	consumableData["BaseConsumable"] = nil
	consumableData["BaseMetaRoomReward"] = nil
	consumableData["BaseResource"] = nil
	consumableData["BaseSuperResource"] = nil
	consumableData["BaseWellShopConsumable"] = nil
	consumableData["Tier1Consumable"] = nil
	consumableData["RandomStoreItem"] = nil

	for key, consumable in pairs(consumableData) do
		if consumable.AddResources then
			consumableData[key] = nil
		else
			if consumable.Cost then
				consumable.Cost = 0
			end
			if consumable.ResourceCosts then
				consumable.ResourceCosts = {
					Money = 0
				}
			end
			if consumable.PurchaseRequirements then
				consumable.PurchaseRequirements = nil
			end
			if consumable.HealFraction and type(consumable.HealFraction) == "table" then
				consumable.HealFraction = RandomFloat(consumable.HealFraction.BaseMin, consumable.HealFraction.BaseMax)
			end
			if consumable.HealthCost and type(consumable.HealthCost) == "table" then
				consumable.HealthCost = RandomInt(consumable.HealthCost.BaseMin, consumable.HealthCost.BaseMax)
			end
		end
	end

	mod.ConsumableData = consumableData
end

ModUtil.Path.Wrap("CheckBounties", function(base, source, args)
	if source.KillHeroOnCompletion then
		mod.KillPlayer()
		return true
	else
		return base(source, args)
	end
end)

ModUtil.LoadOnce(function()
	for key, value in pairs(mod.BoonData) do
		mod.PopulateBoonData(key)
	end
	mod.PopulateConsumableData()
end)

mod.Internal = ModUtil.UpValues(function()
	return setupMainData, mod.mouseOverCommandItem, mod.mouseOffCommandItem
end)

setupMainData()
