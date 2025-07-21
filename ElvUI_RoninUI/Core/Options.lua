local E, L, V, P, G = unpack(ElvUI)
local ACH = E.Libs.ACH
local PI = E.PluginInstaller
local AddOnName, Engine = ...

local tconcat, sort = table.concat, sort
local config = Engine.Config

local function SortList(a, b)
	return E:StripString(a) < E:StripString(b)
end
sort(config.Credits, SortList)
local CREDITS_STRING = tconcat(config.Credits, '|n')
local hexElvUIBlue = '|cff1785d1'

local CLASS_SORT_ORDER = _G.CLASS_SORT_ORDER
local sortedClasses = E:CopyTable({}, CLASS_SORT_ORDER)
sort(sortedClasses)

local ClassInfoByFile = {}
for _, classInfo in pairs(E.ClassInfoByID) do
	local colorTbl = E:ClassColor(classInfo.classFile)
	colorTbl = (colorTbl and colorTbl.colorStr) or 'ff666666'
	local colorName = format('|c%s%s|r', colorTbl, classInfo.className)

	ClassInfoByFile[classInfo.classFile] = {
		classID = classInfo.classID,
		className = classInfo.className,
		colorName = colorName
	}
end

local function GetBlizzardProfile()
	if not E.Retail then return end
	local EMO = E.Libs.EditModeOverride
	EMO:LoadLayouts()
	return EMO:GetActiveLayout() or UNKNOWN
end

local function GetCurrentProfile(addon, profile)
	if addon == 'blizzard' then
		return GetBlizzardProfile()
	elseif addon == 'elvui' and profile == 'general' then
		return E.data:GetCurrentProfile()
	elseif addon == 'elvui' and profile == 'private' then
		return E.charSettings:GetCurrentProfile()
	elseif addon == 'details' then
		return Details and Details:GetCurrentProfileName()
	elseif addon == 'bigwigs' then
		return Engine.BigWigs:GetCurrentProfileName()
	elseif addon == 'omnicd' then
		return OmniCD and OmniCD[1].DB:GetCurrentProfile()
	elseif addon == 'plater' then
		return Plater and Plater.db:GetCurrentProfile()
	end
end

local function SetCurrentProfileHeader(addon, profileID)
	if not addon or not Engine.ProfileData[addon] then return Engine:Print('Invalid addon argument.') end
	if not profileID or profileID == '' then return Engine:Print('Invalid profile id argument.') end

	local curProfile, disabledText = '', '|cffff3300AddOn Disabled|r'
	if addon == 'Blizzard' then
		curProfile = GetBlizzardProfile() or disabledText
	elseif addon == 'ElvUI' and (profileID == 'Profile1' or profileID == 'Profile2') then
		curProfile =  E.data:GetCurrentProfile()
	elseif addon == 'ElvUI' and profileID == 'Private1' then
		curProfile =  E.charSettings:GetCurrentProfile()
	elseif addon == 'Details' then
		curProfile =  E:IsAddOnEnabled('Details') and Details:GetCurrentProfileName() or disabledText
	elseif addon == 'BigWigs' then
		curProfile = E:IsAddOnEnabled('BigWigs') and Engine.BigWigs:GetCurrentProfileName() or disabledText
	elseif addon == 'MRT' then
		if E:IsAddOnEnabled('MRT') then
			local tempProfile = (not VMRT.Profile or VMRT.Profile == 'default' and 'Default') or VMRT.Profile
			curProfile = tempProfile
		else
			curProfile = disabledText
		end
	elseif addon == 'OmniBar' then
		curProfile = E:IsAddOnEnabled('OmniBar') and OmniBar.db:GetCurrentProfile() or disabledText
	elseif addon == 'OmniCD' then
		curProfile = E:IsAddOnEnabled('OmniCD') and OmniCD and OmniCD[1].DB:GetCurrentProfile() or disabledText
	elseif addon == 'Plater' then
		curProfile = E:IsAddOnEnabled('Plater') and Plater and Plater.db:GetCurrentProfile() or disabledText
	end

	return format('Current Profile: |cff5CE1E6%s|r', curProfile)
end

local function UpdateCurrentProfileHeder(addon, profileID)
	if not addon or not Engine.ProfileData[addon] then return Engine:Print('Invalid addon argument.') end
	if not profileID or profileID == '' then return Engine:Print('Invalid profile id argument.') end
	if not E.Options.args.RoninUI.args.steps.args[addon].args[profileID..'Header'] then return Engine:Print('Invalid profile id argument.') end
	E.Options.args.RoninUI.args.steps.args[addon].args[profileID..'Header'].name = SetCurrentProfileHeader(addon, profileID)
	E:RefreshGUI()
end

local function SetWeakAuraHeader(profileID)
	if not profileID or profileID == '' then return Engine:Print('Invalid profile id argument.') end

	local profileString, buttonText
	if profileID ~= 'Profile1' then
		profileString = Engine.ProfileData.WeakAuras.CLASS[profileID]

		local classInfo = ClassInfoByFile[profileID]
		local className = classInfo.className
		local colorTbl = E:ClassColor(profileID)
		colorTbl = (colorTbl and colorTbl.colorStr) or 'ff666666'
		local colorName = format('|c%s%s|r', colorTbl, className)

		buttonText = format(Engine.ProfileData.WeakAuras.Profile2ButtonText, colorName)
	else
		profileString = Engine.ProfileData.WeakAuras[profileID..'String']
		buttonText = Engine.ProfileData.WeakAuras[profileID..'ButtonText']
	end

	if not profileString or profileString == '' then return Engine:Print('No profile string provided.') end
	local doesExist = Engine.WeakAuras:doesAuraExist(profileString)
	local statusText = (not E:IsAddOnEnabled('WeakAuras') and '|cffff3300AddOn Disabled|r') or doesExist and '|cff99ff33Detected|r' or '|cffff3300Not Detected|r'

	return format('%s %s(|r%s%s)|r', buttonText, hexElvUIBlue, statusText, hexElvUIBlue)
end

local function UpdateWeakAuraHeader(profileID)
	if not profileID or profileID == '' then return Engine:Print('Invalid profile id argument.') end
	if not E.Options.args.RoninUI.args.steps.args.WeakAuras.args[profileID..'Header'] then return Engine:Print('Invalid profile id argument.') end

	local classInfo = ClassInfoByFile[profileID]
	local className = classInfo.className
	local colorTbl = E:ClassColor(profileID)
	colorTbl = (colorTbl and colorTbl.colorStr) or 'ff666666'
	local colorName = format('|c%s%s|r', colorTbl, className)

	E.Options.args.RoninUI.args.steps.args.WeakAuras.args[profileID..'Header'].name = SetWeakAuraHeader(profileID)
	E:RefreshGUI()
end

local function SetupProfileButton(addon, profileID, callback)
	if not addon or not Engine.ProfileData[addon] then return Engine:Print('Invalid addon argument.') end
	if not profileID then return Engine:Print('Invalid profile id argument.') end

	local profileString = Engine.ProfileData[addon][profileID..'String']

	local profileString
	if addon == 'WeakAuras' and profileID ~= 'Profile1' then
		profileString = Engine.ProfileData.WeakAuras.CLASS[profileID]
	else
		profileString = Engine.ProfileData[addon][profileID..'String']
	end

	if not profileString then return Engine:Print('No profile string provided.') end

	Engine[addon]:SetupProfile(profileString, profileID, callback)
end

do
	local options = ACH:Group(config.Title, nil, 99, 'tab')
	E.Options.args.RoninUI = options

	local Steps = ACH:Group(L["AddOn Steps"], nil, 1)
	options.args.steps = Steps

	for name, v in next, Engine.ProfileData do
		Steps.args[name] = ACH:Group(name, nil, 10)
		Steps.args[name].args.title = ACH:Header(name, 1)
	end

	local WeakAuras = Steps.args.WeakAuras

	for class, info in next, ClassInfoByFile do
		-- local colorTbl = E:ClassColor(classFile)
		-- colorTbl = (colorTbl and colorTbl.colorStr) or 'ff666666'

		WeakAuras.args[class..'Header'] = ACH:Header(SetWeakAuraHeader(class), tIndexOf(sortedClasses, class) * 7)
		-- WeakAuras.args[class..'Button'] = ACH:Execute(format('Setup %s Pack', info.colorName), 'You can import the weakaura by clicking the button.', tIndexOf(sortedClasses, class) * 7 + 1, function() SetupProfileButton('WeakAuras', class, UpdateWeakAuraHeader) end, nil, nil, 'full')
		WeakAuras.args[class..'Button'] = ACH:Execute('Setup Pack', 'You can import the weakaura by clicking the button.', tIndexOf(sortedClasses, class) * 7 + 1, function() SetupProfileButton('WeakAuras', class, UpdateWeakAuraHeader) end, nil, nil, 'full', nil, nil, function(info) return not E:IsAddOnEnabled(info[#info-1]) end)
		WeakAuras.args[class..'Spacer'] = ACH:Spacer(tIndexOf(sortedClasses, class) * 7 + 2, 'full')
	end

	-- for classID, info in next, E.ClassInfoByID do
	-- 	local className, classFile = info.className, info.classFile
	-- 	local profileID = classFile

	-- 	local colorTbl = E:ClassColor(classFile)
	-- 	colorTbl = (colorTbl and colorTbl.colorStr) or 'ff666666'
	-- 	local colorName = format('|c%s%s|r', colorTbl, className)

	-- 	WeakAuras.args[profileID..'Header'] = ACH:Header(SetWeakAuraHeader(profileID), tIndexOf(sortedClasses, classFile) * 7)
	-- 	WeakAuras.args[profileID..'Button'] = ACH:Execute(format('Setup %s Pack', colorName), 'You can import the weakaura by clicking the button.', tIndexOf(sortedClasses, classFile) * 7 + 1, function() SetupProfileButton('WeakAuras', profileID, UpdateWeakAuraHeader) end, nil, nil, 'full')
	-- 	WeakAuras.args[profileID..'Spacer'] = ACH:Spacer(tIndexOf(sortedClasses, classFile) * 7 + 2, 'full')
	-- end
end

local function configTable()
	--! Built this earlier to reduce open time of /ec due to wa checking to see if auras exist.
	-- local options = ACH:Group(config.Title, nil, 99, 'tab')
	-- E.Options.args.RoninUI = options
	local options = E.Options.args.RoninUI
	options.args.logo = ACH:Description('', 1, nil, 'Interface\\AddOns\\ElvUI_RoninUI\\Media\\Logo512', nil, 160, 160)
	options.args.header = ACH:Header(format('|cff99ff33%s|r', config.Version), 2)
	options.args.installButton = ACH:Execute('Run Installer', 'This will launch the step by step installer.', 3, function() RoninUICharDB.install_complete = nil PI:Queue(Engine.InstallerData) E:ToggleOptions() end)

	--! Built this earlier to reduce open time of /ec due to wa checking to see if auras exist.
	-- local Steps = ACH:Group(L["AddOn Steps"], nil, 1)
	-- options.args.steps = Steps
	local Steps = options.args.steps

	-- for name, v in next, Engine.ProfileData do
	-- 	Steps.args[name] = ACH:Group(name, nil, 10)
	-- 	Steps.args[name].args.title = ACH:Header(name, 1)
	-- end

	--* BigWigs
	local BigWigs = Steps.args.BigWigs
	BigWigs.args.Profile1Header = ACH:Header(SetCurrentProfileHeader('BigWigs', 'Profile1'), 1)
	BigWigs.args.spacer = ACH:Spacer(3, 'full')
	BigWigs.args.button1 = ACH:Execute(Engine.ProfileData.BigWigs.Profile1ButtonText, 'This will import the BigWigs profile.', 4, function() SetupProfileButton('BigWigs', 'Profile1') end, nil, nil, 'full', nil, nil, function(info) return not E:IsAddOnEnabled(info[#info-1]) end)

	--* Details
	local Details = Steps.args.Details
	Details.args.Profile1Header = ACH:Header(SetCurrentProfileHeader('Details', 'Profile1'), 2)
	Details.args.spacer1 = ACH:Spacer(3, 'full')
	Details.args.Profile1Button = ACH:Execute(Engine.ProfileData.Details.Profile1ButtonText, 'This will import the Details profile.', 4, function() SetupProfileButton('Details', 'Profile1', UpdateCurrentProfileHeder) end, nil, nil, 'full', nil, nil, function() return not E:IsAddOnEnabled('Details') end)

	--* ElvUI Global Profile
	local ElvUI = Steps.args.ElvUI
	ElvUI.args.globalHeader = ACH:Header('Global', 5)
	ElvUI.args.Global1Button = ACH:Execute(Engine.ProfileData.ElvUI.Global1ButtonText, 'This will import the ElvUI global profile.', 6, function() SetupProfileButton('ElvUI', 'Global1') end, nil, nil, 'full')
	ElvUI.args.spacer1 = ACH:Spacer(7, 'full')
	ElvUI.args.generalHeader = ACH:Header('General Profile', 10)
	ElvUI.args.GeneralProfile1Header = ACH:Header(SetCurrentProfileHeader('ElvUI', 'Profile1'), 11)
	ElvUI.args.GeneralProfile1Button = ACH:Execute(Engine.ProfileData.ElvUI.Profile1ButtonText, 'This will import the ElvUI general profile.', 12, function() SetupProfileButton('ElvUI', 'Profile1') end, nil, nil, 'full')
	ElvUI.args.GeneralProfile2Button = ACH:Execute(Engine.ProfileData.ElvUI.Profile2ButtonText, 'This will import the ElvUI general profile.', 14, function() SetupProfileButton('ElvUI', 'Profile2') end, nil, nil, 'full')
	ElvUI.args.spacer2 = ACH:Spacer(15, 'full')
	ElvUI.args.privateHeader = ACH:Header('Private Profile', 20)
	ElvUI.args.Private1Header = ACH:Header(SetCurrentProfileHeader('ElvUI', 'Private1'), 21)
	ElvUI.args.Private1Button = ACH:Execute(Engine.ProfileData.ElvUI.Private1ButtonText, 'This will import the ElvUI private profile.', 22, function() SetupProfileButton('ElvUI', 'Private1') end, nil, nil, 'full')

	--* MRT
	local MRT = Steps.args.MRT
	MRT.args.Profile1Header = ACH:Header(SetCurrentProfileHeader('MRT', 'Profile1'), 2)
	MRT.args.spacer1 = ACH:Spacer(3, 'full')
	MRT.args.Profile1Button = ACH:Execute(Engine.ProfileData.MRT.Profile1ButtonText, 'This will import the MRT profile.', 4, function() SetupProfileButton('MRT', 'Profile1') end, nil, nil, 'full', nil, nil, function(info) return not E:IsAddOnEnabled(info[#info-1]) end)

	--* OmniBar
	local OmniBar = Steps.args.OmniBar
	OmniBar.args.Profile1Header = ACH:Header(SetCurrentProfileHeader('OmniBar', 'Profile1'), 2)
	OmniBar.args.spacer1 = ACH:Spacer(3, 'full')
	OmniBar.args.Profile1Button = ACH:Execute(Engine.ProfileData.OmniBar.Profile1ButtonText, 'This will import the OmniBar profile.', 10, function() SetupProfileButton('OmniBar', 'Profile1') end, nil, nil, 'full', nil, nil, function(info) return not E:IsAddOnEnabled(info[#info-1]) end)
	OmniBar.args.Profile2Button = ACH:Execute(Engine.ProfileData.OmniBar.Profile2ButtonText, 'This will import the OmniBar profile.', 10, function() SetupProfileButton('OmniBar', 'Profile2') end, nil, nil, 'full', nil, nil, function(info) return not E:IsAddOnEnabled(info[#info-1]) end)

	--* OmniCD
	local OmniCD = Steps.args.OmniCD
	OmniCD.args.Profile1Header = ACH:Header(SetCurrentProfileHeader('OmniCD', 'Profile1'), 2)
	OmniCD.args.spacer1 = ACH:Spacer(3, 'full')
	OmniCD.args.Profile1Button = ACH:Execute(Engine.ProfileData.OmniCD.Profile1ButtonText, 'This will import the OmniCD profile.', 10, function() SetupProfileButton('OmniCD', 'Profile1', UpdateCurrentProfileHeder) end, nil, nil, 'full', nil, nil, function(info) return not E:IsAddOnEnabled(info[#info-1]) end)
	OmniCD.args.Profile2Button = ACH:Execute(Engine.ProfileData.OmniCD.Profile2ButtonText, 'This will import the OmniCD profile.', 11, function() SetupProfileButton('OmniCD', 'Profile2', UpdateCurrentProfileHeder) end, nil, nil, 'full', nil, nil, function(info) return not E:IsAddOnEnabled(info[#info-1]) end)

	--* Plater
	local Plater = Steps.args.Plater
	Plater.args.Profile1Header = ACH:Header(SetCurrentProfileHeader('Plater', 'Profile1'), 2)
	Plater.args.spacer1 = ACH:Spacer(3, 'full')
	Plater.args.Profile1Button = ACH:Execute(Engine.ProfileData.Plater.Profile1ButtonText, 'This will import the Plater profile.', 10, function() SetupProfileButton('Plater', 'Profile1') end, nil, nil, 'full', nil, nil, function(info) return not E:IsAddOnEnabled(info[#info-1]) end)

	--* WeakAuras
	local WeakAuras = Steps.args.WeakAuras
	WeakAuras.args.Profile1Header = ACH:Header(SetWeakAuraHeader('Profile1'), 5)
	-- WeakAuras.args.Profile1Button = ACH:Execute(format('Setup %s', Engine.ProfileData.WeakAuras.Profile1ButtonText), 'You can import the aura by clicking the button.', 6, function(info) SetupProfileButton('WeakAuras', 'Profile1', UpdateWeakAuraHeader) end, nil, nil, 'full')
	WeakAuras.args.Profile1Button = ACH:Execute('Setup Pack', 'You can import the aura by clicking the button.', 6, function(info) SetupProfileButton('WeakAuras', 'Profile1', UpdateWeakAuraHeader) end, nil, nil, 'full', nil, nil, function(info) return not E:IsAddOnEnabled(info[#info-1]) end)
	WeakAuras.args.spacer1 = ACH:Spacer(7, 'full')

	--! Built this earlier to reduce open time of /ec due to wa checking to see if auras exist.
	-- for classID, info in next, E.ClassInfoByID do
	-- 	local className, classFile = info.className, info.classFile
	-- 	local colorTbl = E:ClassColor(classFile)
	-- 	colorTbl = (colorTbl and colorTbl.colorStr) or 'ff666666'
	-- 	local colorName = format('|c%s%s|r', colorTbl, className)

	-- 	local profileID = classFile
	-- 	local profileString = Engine.ProfileData.WeakAuras.CLASS[profileID]
	-- 	-- local doesExist = Engine.WeakAuras:doesAuraExist(profileString)

	-- 	WeakAuras.args[profileID..'Header'] = ACH:Header(SetWeakAuraHeader(profileID), tIndexOf(sortedClasses, classFile) * 7)
	-- 	WeakAuras.args[profileID..'Button'] = ACH:Execute(format('Setup %s Pack', colorName), 'You can import the weakaura by clicking the button.', tIndexOf(sortedClasses, classFile) * 7 + 1, function() SetupProfileButton('WeakAuras', profileID, UpdateWeakAuraHeader) end, nil, nil, 'full')
	-- 	WeakAuras.args[profileID..'Spacer'] = ACH:Spacer(tIndexOf(sortedClasses, classFile) * 7 + 2, 'full')
	-- end

	--* Help
	local Help = ACH:Group(L["Help"], nil, 98, 'tab')
	options.args.help = Help
	Help.args.header = ACH:Header('Get Support', 1)

	local Support = ACH:Group('', nil, 2)
	Help.args.support = Support
	Support.inline = true
	Support.args.wago = ACH:Execute(L["Wago Page"], nil, 1, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://addons.wago.io/addons/elvui-roninui') end, nil, nil, 140)
	Support.args.curse = ACH:Execute(L["Curseforge Page"], nil, 1, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://www.curseforge.com/wow/addons/elvui-roninui') end, nil, nil, 140)
	Support.args.git = ACH:Execute(L["Ticket Tracker"], nil, 2, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://github.com/Repooc/ElvUI_RoninUI/issues') end, nil, nil, 140)
	Support.args.discord = ACH:Execute(L["Discord"], nil, 3, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, Engine.Config.Discord) end, nil, nil, 140)

	local credits = ACH:Group(L["Credits"], nil, 99)
	options.args.credits = credits

	credits.args.string = ACH:Description(CREDITS_STRING, 5, 'medium')
	credits.args.spacer = ACH:Spacer(6, 'full')
	credits.args.supporterroles = ACH:Description(discordTextures, 10)
end
tinsert(Engine.Options, configTable)
