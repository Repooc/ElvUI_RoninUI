local AddOnName, Engine = ...
local E, L = unpack(ElvUI)
local D = E.Distributor
local PI = E.PluginInstaller

local config = Engine.Config
local hexElvUIBlue = '|cff1785d1'

local function HidePopups()
	for i = 1, 4 do
		--* Hide all relevant popups
		local popup = _G['StaticPopup'..i]
		if popup and popup:IsShown() then
			popup:Hide()
		end

		--* Hide ElvUI popups
		popup = _G['ElvUI_StaticPopup'..i]
		if popup and popup:IsShown() then
			popup:Hide()
		end
	end
end

local function BigWigsDesc1Text()
	if _G.PluginInstallFrame:IsShown() and _G.PluginInstallFrame.Title:GetText() == Engine.InstallerData.Title and _G.PluginInstallFrame.CurrentPage == 6 then
		_G.PluginInstallFrame.Desc1:SetText(E:IsAddOnEnabled('BigWigs') and format('%sCurrent Profile:|r %s%s|r|n%s(|rBigWigs Config %s>|r Options %s>|r Profiles%s)|r', '|cffFFD900', '|cff5CE1E6', Engine.BigWigs:GetCurrentProfileName(), hexElvUIBlue, hexElvUIBlue, hexElvUIBlue, hexElvUIBlue) or 'BigWigs is not enabled to setup.')
	end
end

local function BigWigsDesc3Text()
	return not E:IsAddOnEnabled('BigWigs') and '|cffFF3333WARNING:|r Details! is not enabled to configure.' or ''
end

local function DetailsDesc1Text()
	_G.PluginInstallFrame.Desc1:SetText(E:IsAddOnEnabled('Details') and format('%sCurrent Profile:|r %s%s|r|n%s(|rDetails Config %s>|r Options %s>|r Profiles%s)|r', '|cffFFD900', '|cff5CE1E6', Details:GetCurrentProfileName(), hexElvUIBlue, hexElvUIBlue, hexElvUIBlue, hexElvUIBlue) or '')
end

local function DetailsDesc2Text()
	return E:IsAddOnEnabled('Details') and format('|cffFFD900This page will setup the Details profile for %s|r', config.Title) or ''
end

local function DetailsDesc3Text()
	return E:IsAddOnEnabled('Details') and '|cffFF3333WARNING:|r Details! is not enabled to configure.' or ''
end

local function ElvUIProfileDescText()
	return format('%sCurrent Profile:|r %s%s|r|n%s(|rElvUI Config %s>|r Profiles %s>|r Profile Tab%s)|r', '|cffFFD900', '|cff5CE1E6', E.data:GetCurrentProfile(), hexElvUIBlue, hexElvUIBlue, hexElvUIBlue, hexElvUIBlue)
end

local function MRTDesc1Text()
	local text = ''
	if E:IsAddOnEnabled('MRT') then
		local curProfile = (not VMRT.Profile or VMRT.Profile == 'default' and 'Default') or VMRT.Profile
		text = format('%sCurrent Profile:|r %s%s|r|n%s(|rMRT Config %s>|r Options %s>|r Profiles%s)|r', '|cffFFD900', '|cff5CE1E6', curProfile, hexElvUIBlue, hexElvUIBlue, hexElvUIBlue, hexElvUIBlue)
	else
		if E.Retail then
			text = '|cffFF3333WARNING:|r MRT is not enabled to configure.'
		else
			text = '|cffFF3333WARNING:|r MRT is not available for this WoW flavor to configure.'
		end
	end

	_G.PluginInstallFrame.Desc1:SetText(text)
end

local function OmniBarDesc1Text()
	_G.PluginInstallFrame.Desc1:SetText(E:IsAddOnEnabled('OmniBar') and format('%sCurrent Profile:|r %s%s|r|n%s(|rOmniBar Config %s>|r Profiles%s)|r', '|cffFFD900', '|cff5CE1E6', OmniBar.db:GetCurrentProfile(), hexElvUIBlue, hexElvUIBlue, hexElvUIBlue) or '')
end

local function OmniCDDesc1Text()
	_G.PluginInstallFrame.Desc1:SetText(E:IsAddOnEnabled('OmniCD') and format('%sCurrent Profile:|r %s%s|r|n%s(|rOmniCD Config %s>|r Profiles%s)|r', '|cffFFD900', '|cff5CE1E6', OmniCD[1].DB:GetCurrentProfile(), hexElvUIBlue, hexElvUIBlue, hexElvUIBlue) or '')
end

local function PlaterDesc1Text()
	return E:IsAddOnEnabled('Plater') and format('%sCurrent Profile:|r %s%s|r|n%s(|rPlater Config %s>|r Profiles %s>|r Profile Settings%s)|r', '|cffFFD900', '|cff5CE1E6', Plater.db:GetCurrentProfile(), hexElvUIBlue, hexElvUIBlue, hexElvUIBlue, hexElvUIBlue) or ''
end

local function WeakAuraButtonText(profileID)
	if not profileID then return Engine:Print('Invalid profile id argument.') end
	local profileString = Engine.ProfileData.WeakAuras[profileID..'String']
	if not profileString or profileString == '' then return Engine:Print('No profile string provided.') end
	local doesExist = Engine.WeakAuras:doesAuraExist(profileString)
	local profileNum = tonumber(profileID:match('%d+'))

	if _G.PluginInstallFrame:IsShown() and _G.PluginInstallFrame.Title:GetText() == Engine.InstallerData.Title and _G.PluginInstallFrame.CurrentPage == 11 then
		_G.PluginInstallFrame['Option'..profileNum]:SetText(doesExist and format('%s\n%s(|r%s%s)|r', Engine.ProfileData.WeakAuras[profileID..'ButtonText'], hexElvUIBlue, '|cff99ff33Detected|r', hexElvUIBlue) or Engine.ProfileData.WeakAuras[profileID..'ButtonText'])
	end
end

local function WeakAuraClassButtonText()
	local color = E:ClassColor(E.myclass, true)
	local prettyText = color:WrapTextInColorCode(E.myLocalizedClass)
	local profileString = Engine.ProfileData.WeakAuras.CLASS[E.myclass]
	local doesExist = Engine.WeakAuras:doesAuraExist(profileString)
	local classPackString = format(Engine.ProfileData.WeakAuras.Profile2ButtonText, prettyText)

	if _G.PluginInstallFrame:IsShown() and _G.PluginInstallFrame.Title:GetText() == Engine.InstallerData.Title and _G.PluginInstallFrame.CurrentPage == 11 then
		_G.PluginInstallFrame.Option2:SetText(doesExist and format('%s\n%s(|r%s%s)|r', classPackString, hexElvUIBlue, '|cff99ff33Detected|r', hexElvUIBlue) or classPackString)
	end
end

local function SetupProfileButton(addon, profileID, callback)
	if not addon or not Engine.ProfileData[addon] then return Engine:Print('Invalid addon argument.') end
	if not profileID then return Engine:Print('Invalid profile id argument.') end

	local isClassPack = addon == 'WeakAuras' and profileID == 'Profile2'
	local profileString = isClassPack and Engine.ProfileData.WeakAuras.CLASS[E.myclass] or Engine.ProfileData[addon][profileID..'String']

	if not profileString then return Engine:Print('No profile string provided.') end

	Engine[addon]:SetupProfile(profileString, profileID, callback)
end

local function SetupOptionPreview()
	if not PluginInstallFrame.optionPreview then
		_G.PluginInstallFrame.optionPreview = _G.PluginInstallFrame:CreateTexture()
		_G.PluginInstallFrame.optionPreview:SetAllPoints(_G.PluginInstallFrame)
	end
end

local function SetupOptionScripts(script, texture)
	if script == 'onEnter' then
		_G.PluginInstallFrame.optionPreview:SetTexture(texture)
		if texture and texture ~= '' then
			--* Not sure which one is feels better
			-- UIFrameFadeIn(PluginInstallFrame.optionPreview, 0.5, 0, 0.7)
			-- UIFrameFadeOut(PluginInstallFrame.tutorialImage, 0.4, 1, 0)
			-- UIFrameFadeOut(PluginInstallFrame.Desc1, 0.4, 1, 0)
			-- UIFrameFadeOut(PluginInstallFrame.Desc2, 0.4, 1, 0)
			-- UIFrameFadeOut(PluginInstallFrame.Desc3, 0.4, 1, 0)
			-- UIFrameFadeOut(PluginInstallFrame.Desc4, 0.4, 1, 0)
			-- UIFrameFadeOut(PluginInstallFrame.SubTitle, 0.4, 1, 0)

			UIFrameFadeIn(_G.PluginInstallFrame.optionPreview, 0.5, _G.PluginInstallFrame.optionPreview:GetAlpha(), 0.7)
			UIFrameFadeOut(_G.PluginInstallFrame.tutorialImage, 0.4, _G.PluginInstallFrame.tutorialImage:GetAlpha(), 0)
			UIFrameFadeOut(_G.PluginInstallFrame.Title, 0.4, _G.PluginInstallFrame.Title:GetAlpha(), 0)
			UIFrameFadeOut(_G.PluginInstallFrame.Prev, 0.4, _G.PluginInstallFrame.Prev:GetAlpha(), 0)
			UIFrameFadeOut(_G.PluginInstallFrame.Status, 0.4, _G.PluginInstallFrame.Status:GetAlpha(), 0)
			UIFrameFadeOut(_G.PluginInstallFrame.Next, 0.4, _G.PluginInstallFrame.Next:GetAlpha(), 0)
			UIFrameFadeOut(_G.PluginInstallFrame.Desc1, 0.4, _G.PluginInstallFrame.Desc1:GetAlpha(), 0)
			UIFrameFadeOut(_G.PluginInstallFrame.Desc2, 0.4, _G.PluginInstallFrame.Desc2:GetAlpha(), 0)
			UIFrameFadeOut(_G.PluginInstallFrame.Desc3, 0.4, _G.PluginInstallFrame.Desc3:GetAlpha(), 0)
			UIFrameFadeOut(_G.PluginInstallFrame.Desc4, 0.4, _G.PluginInstallFrame.Desc4:GetAlpha(), 0)
			UIFrameFadeOut(_G.PluginInstallFrame.SubTitle, 0.4, _G.PluginInstallFrame.SubTitle:GetAlpha(), 0)
		end
	elseif script == 'onLeave' then
		--* Not sure which one is feels better
		-- UIFrameFadeOut(PluginInstallFrame.optionPreview, 0.5, 0.7, 0)
		-- UIFrameFadeIn(PluginInstallFrame.tutorialImage, 0.4, 0, 1)
		-- UIFrameFadeIn(PluginInstallFrame.Desc1, 0.4, 0, 1)
		-- UIFrameFadeIn(PluginInstallFrame.Desc2, 0.4, 0, 1)
		-- UIFrameFadeIn(PluginInstallFrame.Desc3, 0.4, 0, 1)
		-- UIFrameFadeIn(PluginInstallFrame.Desc4, 0.4, 0, 1)
		-- UIFrameFadeIn(PluginInstallFrame.SubTitle, 0.4, 0, 1)

		UIFrameFadeOut(_G.PluginInstallFrame.optionPreview, 0.5, _G.PluginInstallFrame.optionPreview:GetAlpha(), 0)
		UIFrameFadeIn(_G.PluginInstallFrame.tutorialImage, 0.4, _G.PluginInstallFrame.tutorialImage:GetAlpha(), 1)
		UIFrameFadeIn(_G.PluginInstallFrame.Title, 0.4, _G.PluginInstallFrame.Title:GetAlpha(), 1)
		UIFrameFadeIn(_G.PluginInstallFrame.Prev, 0.4, _G.PluginInstallFrame.Prev:GetAlpha(), 1)
		UIFrameFadeIn(_G.PluginInstallFrame.Status, 0.4, _G.PluginInstallFrame.Status:GetAlpha(), 1)
		UIFrameFadeIn(_G.PluginInstallFrame.Next, 0.4, _G.PluginInstallFrame.Next:GetAlpha(), 1)
		UIFrameFadeIn(_G.PluginInstallFrame.Desc1, 0.4, _G.PluginInstallFrame.Desc1:GetAlpha(), 1)
		UIFrameFadeIn(_G.PluginInstallFrame.Desc2, 0.4, _G.PluginInstallFrame.Desc2:GetAlpha(), 1)
		UIFrameFadeIn(_G.PluginInstallFrame.Desc3, 0.4, _G.PluginInstallFrame.Desc3:GetAlpha(), 1)
		UIFrameFadeIn(_G.PluginInstallFrame.Desc4, 0.4, _G.PluginInstallFrame.Desc4:GetAlpha(), 1)
		UIFrameFadeIn(_G.PluginInstallFrame.SubTitle, 0.4, _G.PluginInstallFrame.SubTitle:GetAlpha(), 1)
	end
end

local function resizeInstaller(reset)
	if reset then
		--* Defaults
		_G.PluginInstallFrame:SetSize(450, 50)
		_G.PluginInstallFrame.Desc1:ClearAllPoints()
		_G.PluginInstallFrame.Desc1:SetPoint('TOPLEFT', _G.PluginInstallFrame, 'TOPLEFT', 20, -75)

		return
	end

	_G.PluginInstallFrame:SetSize(1040, 520)
	_G.PluginInstallFrame.Desc1:ClearAllPoints()
	_G.PluginInstallFrame.Desc1:SetPoint('TOP', _G.PluginInstallFrame.SubTitle, 'BOTTOM', 0, -30)
end

local function resetButtonScripts()
	for i = 1, 4 do
		_G.PluginInstallFrame['Option'..i]:SetScript('onEnter', nil)
		_G.PluginInstallFrame['Option'..i]:SetScript('onLeave', nil)
	end
end

--* Installer Template
Engine.InstallerData = {
	Title = format('%s |cffFFD900%s|r', config.Title, L["Installation"]),
	Name = config.Title,
	tutorialImage = config.Logo,
	tutorialImageSize = { 256, 256 },
	tutorialImagePoint = { 0, 0 },
	Pages = {
		[1] = function()
			SetupOptionPreview()
			resizeInstaller()
			resetButtonScripts()
			E:Delay(0.1, HidePopups)

			_G.PluginInstallFrame.SubTitle:SetFormattedText('|cffFFD900%s|r', L["Welcome"])

			_G.PluginInstallFrame.Desc1:SetFormattedText('|cff4BEB2C%s|r', format('The %s installer will guide you through some steps and apply all the profile settings needed for each layout.', config.Title))
			_G.PluginInstallFrame.Desc2:SetFormattedText('|cffFFFF00%s|r', format('%s layouts were made on a 1440p monitor using 0.56 UI Scale in ElvUI\'s options. If using another resolution or scale, you may need to adjust frame sizes & locations to ensure optimal placement for your setup.', config.Title))
			_G.PluginInstallFrame.Desc3:SetFormattedText('|cffFF3300%s|r', "Please read each step carefully before clicking any buttons!")

			_G.RoninUICharDB.skipStep = _G.RoninUICharDB.skipStep or {}
			if RoninUICharDB.skipStep.ElvUI then
				RoninUICharDB.skipStep.ElvUI = nil
				PI:SetPage(5, 4)
			elseif RoninUICharDB.skipStep.MRT then
				RoninUICharDB.skipStep.MRT = nil
				PI:SetPage(8, 7)
			elseif RoninUICharDB.skipStep.Plater then
				RoninUICharDB.skipStep.Plater = nil
				PI:SetPage(11, 10)
			end
		end,
		[2] = function()
			--* ElvUI Global Profile
			resizeInstaller()
			resetButtonScripts()

			_G.PluginInstallFrame.SubTitle:SetText(format('%sGlobal Profile (%s)|r', '|cffFFD900', E.title))

			_G.PluginInstallFrame.Desc1:SetText(format('|cff4BEB2C%s', 'This page will set up the global profile for ElvUI. The options in this profile will be shared across all characters on your account.'))
			_G.PluginInstallFrame.Desc2:SetText(format('|cffFF3300Warning: |r%s', '|cffFFD900This will overwrite your current global profile settings. There is no "undo" button for this step, please backup your WTF folder before proceeding.|r'))
			_G.PluginInstallFrame.Desc3:SetText('|cffFF3300Reminder: |r|cffFFD900This step only needs to be done once per account and is irreversable.|r')

			_G.PluginInstallFrame.Option1:SetEnabled(true)
			_G.PluginInstallFrame.Option1:SetScript('OnClick', function() SetupProfileButton('ElvUI', 'Global1') end)
			_G.PluginInstallFrame.Option1:SetText(Engine.ProfileData.ElvUI.Global1ButtonText)
			_G.PluginInstallFrame.Option1:Show()
		end,
		[3] = function()
			--* ElvUI General Profile
			resizeInstaller()
			resetButtonScripts()

			_G.PluginInstallFrame.SubTitle:SetText(format('|cffFFD900%s|r', format('General Profile (%s)', E.title)))

			_G.PluginInstallFrame.Desc1:SetText(ElvUIProfileDescText())
			_G.PluginInstallFrame.Desc2:SetText('|cff4BEB2CThis page will import the ElvUI profile you select and make it the active profile. If the profile you select already exists, it will allow you to overwrite or change the name of the selected profile.|r')

			_G.PluginInstallFrame.Option1:SetEnabled(true)
			_G.PluginInstallFrame.Option1:SetScript('OnClick', function() SetupProfileButton('ElvUI', 'Profile1') PluginInstallFrame.Desc1:SetText(ElvUIProfileDescText()) end)
			_G.PluginInstallFrame.Option1:SetScript('onEnter', function() SetupOptionScripts('onEnter', Engine.ProfileData.ElvUI.Profile1Preview) end)
			_G.PluginInstallFrame.Option1:SetScript('onLeave', function() SetupOptionScripts('onLeave') end)
			_G.PluginInstallFrame.Option1:SetText(Engine.ProfileData.ElvUI.Profile1ButtonText)
			_G.PluginInstallFrame.Option1:Show()

			_G.PluginInstallFrame.Option2:SetEnabled(true)
			_G.PluginInstallFrame.Option2:SetScript('OnClick', function() SetupProfileButton('ElvUI', 'Profile2') PluginInstallFrame.Desc1:SetText(ElvUIProfileDescText()) end)
			_G.PluginInstallFrame.Option2:SetScript('onEnter', function() SetupOptionScripts('onEnter', Engine.ProfileData.ElvUI.Profile2Preview) end)
			_G.PluginInstallFrame.Option2:SetScript('onLeave', function() SetupOptionScripts('onLeave') end)
			_G.PluginInstallFrame.Option2:SetText(Engine.ProfileData.ElvUI.Profile2ButtonText)
			_G.PluginInstallFrame.Option2:Show()
		end,
		[4] = function()
			--* ElvUI Private Profile
			resizeInstaller()
			resetButtonScripts()

			_G.PluginInstallFrame.SubTitle:SetText(format('|cffFFD900Private Profile (%s)|r', E.title))

			_G.PluginInstallFrame.Desc1:SetText(format('%sCurrent Private Profile:|r %s%s|r|n%s(|rElvUI Config %s>|r Profiles %s>|r Private Tab%s)|r', '|cffFFD900', '|cff5CE1E6', E.charSettings:GetCurrentProfile(), hexElvUIBlue, hexElvUIBlue, hexElvUIBlue, hexElvUIBlue))

			_G.PluginInstallFrame.Option1:SetEnabled(true)
			_G.PluginInstallFrame.Option1:SetScript('OnClick', function() SetupProfileButton('ElvUI', 'Private1') end)
			_G.PluginInstallFrame.Option1:SetText(Engine.ProfileData.ElvUI.Private1ButtonText)
			_G.PluginInstallFrame.Option1:Show()

			_G.PluginInstallFrame.Option2:Hide()
		end,
		[5] = function()
			--* Details
			resizeInstaller()
			resetButtonScripts()

			_G.PluginInstallFrame.SubTitle:SetFormattedText('|cffFFD900%s|r', 'Details')

			DetailsDesc1Text()
			_G.PluginInstallFrame.Desc2:SetText(DetailsDesc2Text())
			_G.PluginInstallFrame.Desc3:SetText(DetailsDesc3Text())

			_G.PluginInstallFrame.Option1:SetEnabled(E:IsAddOnEnabled('Details'))
			_G.PluginInstallFrame.Option1:SetScript('OnClick', function() SetupProfileButton('Details', 'Profile1', DetailsDesc1Text) end)
			_G.PluginInstallFrame.Option1:SetScript('onEnter', function() SetupOptionScripts('onEnter', Engine.ProfileData.Details.Profile1Preview) end)
			_G.PluginInstallFrame.Option1:SetScript('onLeave', function() SetupOptionScripts('onLeave') end)
			_G.PluginInstallFrame.Option1:SetText(Engine.ProfileData.Details.Profile1ButtonText)
			_G.PluginInstallFrame.Option1:Show()
		end,
		[6] = function()
			--* BigWigs
			resizeInstaller()
			resetButtonScripts()

			_G.PluginInstallFrame.SubTitle:SetText('|cffFFD900BigWigs|r')

			BigWigsDesc1Text()
			_G.PluginInstallFrame.Desc2:SetFormattedText('|cffFFD900%s|r', format('This page will setup the BigWigs profile for %s', config.Title))
			_G.PluginInstallFrame.Desc3:SetText(BigWigsDesc3Text())

			_G.PluginInstallFrame.Option1:SetEnabled(E:IsAddOnEnabled('BigWigs'))
			_G.PluginInstallFrame.Option1:SetScript('OnClick', function() SetupProfileButton('BigWigs', 'Profile1', BigWigsDesc1Text) end)
			_G.PluginInstallFrame.Option1:SetScript('onEnter', function() SetupOptionScripts('onEnter', Engine.ProfileData.BigWigs.Profile1Preview) end)
			_G.PluginInstallFrame.Option1:SetScript('onLeave', function() SetupOptionScripts('onLeave') end)
			_G.PluginInstallFrame.Option1:SetText(Engine.ProfileData.BigWigs.Profile1ButtonText)
			_G.PluginInstallFrame.Option1:Show()
		end,
		[7] = function()
			--* MRT
			resizeInstaller()
			resetButtonScripts()

			_G.PluginInstallFrame.SubTitle:SetText('|cffFFD900MRT|r')

			MRTDesc1Text()
			_G.PluginInstallFrame.Desc3:SetFormattedText('|cffFFD900%s|r', format('This page will setup the MRT profile for %s', config.Title))

			_G.PluginInstallFrame.Option1:SetEnabled(E.Retail and E:IsAddOnEnabled('MRT'))
			_G.PluginInstallFrame.Option1:SetScript('OnClick', function() SetupProfileButton('MRT', 'Profile1', MRTDesc1Text) end)
			_G.PluginInstallFrame.Option1:SetScript('onEnter', function() SetupOptionScripts('onEnter', Engine.ProfileData.MRT.Profile1Preview) end)
			_G.PluginInstallFrame.Option1:SetScript('onLeave', function() SetupOptionScripts('onLeave') end)
			_G.PluginInstallFrame.Option1:SetText(Engine.ProfileData.MRT.Profile1ButtonText)
			_G.PluginInstallFrame.Option1:Show()
		end,
		[8] = function()
			--* OmniBar
			resizeInstaller()
			resetButtonScripts()

			_G.PluginInstallFrame.SubTitle:SetText('|cffFFD900OmniBar (PvP Only)|r')

			OmniBarDesc1Text()
			_G.PluginInstallFrame.Desc2:SetFormattedText('|cffFFD900%s|r', format('This page will setup the OmniBar profile for %s', config.Title))

			_G.PluginInstallFrame.Option1:SetEnabled(E:IsAddOnEnabled('OmniBar'))
			_G.PluginInstallFrame.Option1:SetScript('OnClick', function() SetupProfileButton('OmniBar', 'Profile1', OmniBarDesc1Text) end)
			_G.PluginInstallFrame.Option1:SetScript('onEnter', function() SetupOptionScripts('onEnter', Engine.ProfileData.OmniBar.Profile1Preview) end)
			_G.PluginInstallFrame.Option1:SetScript('onLeave', function() SetupOptionScripts('onLeave') end)
			_G.PluginInstallFrame.Option1:SetText(Engine.ProfileData.OmniBar.Profile1ButtonText)
			_G.PluginInstallFrame.Option1:Show()

			_G.PluginInstallFrame.Option2:SetEnabled(E:IsAddOnEnabled('OmniBar'))
			_G.PluginInstallFrame.Option2:SetScript('OnClick', function() SetupProfileButton('OmniBar', 'Profile2', OmniBarDesc1Text) end)
			_G.PluginInstallFrame.Option2:SetScript('onEnter', function() SetupOptionScripts('onEnter', Engine.ProfileData.OmniBar.Profile2Preview) end)
			_G.PluginInstallFrame.Option2:SetScript('onLeave', function() SetupOptionScripts('onLeave') end)
			_G.PluginInstallFrame.Option2:SetText(Engine.ProfileData.OmniBar.Profile2ButtonText)
			_G.PluginInstallFrame.Option2:Show()
		end,
		[9] = function()
			--* OmniCD
			resizeInstaller()
			resetButtonScripts()

			_G.PluginInstallFrame.SubTitle:SetText('|cffFFD900OmniCD|r')

			OmniCDDesc1Text()
			_G.PluginInstallFrame.Desc2:SetFormattedText('|cffFFD900%s|r', format('This page will setup the OmniCD profile for %s', config.Title))

			_G.PluginInstallFrame.Option1:SetEnabled(E:IsAddOnEnabled('OmniCD'))
			_G.PluginInstallFrame.Option1:SetScript('OnClick', function() SetupProfileButton('OmniCD', 'Profile1', OmniCDDesc1Text) end)
			_G.PluginInstallFrame.Option1:SetScript('onEnter', function() SetupOptionScripts('onEnter', Engine.ProfileData.OmniCD.Profile1Preview) end)
			_G.PluginInstallFrame.Option1:SetScript('onLeave', function() SetupOptionScripts('onLeave') end)
			_G.PluginInstallFrame.Option1:SetText(Engine.ProfileData.OmniCD.Profile1ButtonText)
			_G.PluginInstallFrame.Option1:Show()

			_G.PluginInstallFrame.Option2:SetEnabled(E:IsAddOnEnabled('OmniCD'))
			_G.PluginInstallFrame.Option2:SetScript('OnClick', function() SetupProfileButton('OmniCD', 'Profile2', OmniCDDesc1Text) end)
			_G.PluginInstallFrame.Option2:SetScript('onEnter', function() SetupOptionScripts('onEnter', Engine.ProfileData.OmniCD.Profile2Preview) end)
			_G.PluginInstallFrame.Option2:SetScript('onLeave', function() SetupOptionScripts('onLeave') end)
			_G.PluginInstallFrame.Option2:SetText(Engine.ProfileData.OmniCD.Profile2ButtonText)
			_G.PluginInstallFrame.Option2:Show()
		end,
		[10] = function()
			--* Plater
			resizeInstaller()
			resetButtonScripts()

			_G.PluginInstallFrame.SubTitle:SetText('|cffFFD900Plater|r')

			_G.PluginInstallFrame.Desc1:SetText(PlaterDesc1Text())
			_G.PluginInstallFrame.Desc2:SetFormattedText('|cffFFD900%s|r', format('This page will setup the Plater profile for %s', config.Title))

			_G.PluginInstallFrame.Option1:SetEnabled(E:IsAddOnEnabled('Plater'))
			_G.PluginInstallFrame.Option1:SetScript('OnClick', function() SetupProfileButton('Plater', 'Profile1', PlaterDesc1Text) end)
			_G.PluginInstallFrame.Option1:SetScript('onEnter', function() SetupOptionScripts('onEnter', Engine.ProfileData.Plater.Profile1Preview) end)
			_G.PluginInstallFrame.Option1:SetScript('onLeave', function() SetupOptionScripts('onLeave') end)
			_G.PluginInstallFrame.Option1:SetText('Setup Plater')
			_G.PluginInstallFrame.Option1:Show()
		end,
		[11] = function()
			--* WeakAuras
			resizeInstaller()
			resetButtonScripts()

			_G.PluginInstallFrame.SubTitle:SetText('|cffFFD900WeakAuras|r')

			_G.PluginInstallFrame.Desc1:SetFormattedText('|cffFFD900%s|r', 'This step will let you import my |cff2a84cbEssentials|r and class |cffFFFFFFWeakAuras|r that I use for the layout.')
			_G.PluginInstallFrame.Desc2:SetText('|cffFFFF00Note:|r The Essentials pack only needs to be installed once per account.\nEach class pack can be imported from this page when on \nthat specific class or from the ElvUI options window.')

			_G.PluginInstallFrame.Option1:SetEnabled(E:IsAddOnEnabled('WeakAuras'))
			_G.PluginInstallFrame.Option1:SetScript('OnClick', function() SetupProfileButton('WeakAuras', 'Profile1', WeakAuraButtonText) end)
			WeakAuraButtonText('Profile1')
			_G.PluginInstallFrame.Option1:Show()

			_G.PluginInstallFrame.Option2:SetEnabled(E:IsAddOnEnabled('WeakAuras'))
			_G.PluginInstallFrame.Option2:SetScript('OnClick', function() SetupProfileButton('WeakAuras', 'Profile2', WeakAuraClassButtonText) end)
			WeakAuraClassButtonText()
			_G.PluginInstallFrame.Option2:Show()
		end,
		[12] = function()
			resizeInstaller()
			resetButtonScripts()

			_G.PluginInstallFrame.SubTitle:SetFormattedText('|cffFFD900%s|r', L["Installation Complete"])

			_G.PluginInstallFrame.Desc1:SetFormattedText('|cffFFD900%s|r', 'You have completed the installation process, please click "|cff4beb2cFinished|r" to reload the UI.')
			_G.PluginInstallFrame.Desc2:SetFormattedText('|cffFFD900%s|r', 'Special thanks to HiJack (Spell WeakAuras), Quazii (Plater Mods), \n Repooc (Installer Creation), and the TukUI Community.')
			_G.PluginInstallFrame.Desc3:SetFormattedText('|cffFFD900%s|r', 'Feel free to join my community Discord for support, questions, or feedback. Also follow me on Twitch "RoninXCVII"')

			_G.PluginInstallFrame.Option1:SetEnabled(true)
			_G.PluginInstallFrame.Option1:SetScript('OnClick', function() E:StaticPopup_Show('RONINUI_EDITBOX', nil, nil, config.Discord) end)
			_G.PluginInstallFrame.Option1:SetText(L["Discord"])
			_G.PluginInstallFrame.Option1:Show()

			_G.PluginInstallFrame.Option2:SetEnabled(true)
			_G.PluginInstallFrame.Option2:SetScript('OnClick', function()
				RoninUICharDB.install_complete = config.Version
				resizeInstaller(true)
				C_UI.Reload()
			end)
			_G.PluginInstallFrame.Option2:SetFormattedText('|cff4beb2c%s', L["Finished"])
			_G.PluginInstallFrame.Option2:Show()
		end,
	},
	StepTitles = {
		[1] = L["Welcome"],
		[2] = 'Global Profile',
		[3] = 'General Profile',
		[4] = 'Private Profile',
		[5] = 'Details',
		[6] = 'BigWigs',
		[7] = 'MRT',
		[8] = 'OmniBar',
		[9] = 'OmniCD',
		[10] = 'Plater',
		[11] = 'WeakAuras',
		[12] = L["Installation Complete"],
	},
	StepTitlesColor = config.Installer.StepTitlesColor,
	StepTitlesColorSelected = config.Installer.StepTitlesColorSelected,
	StepTitleWidth = config.Installer.StepTitleWidth,
	StepTitleButtonWidth = config.Installer.StepTitleButtonWidth,
	StepTitleTextJustification = config.Installer.StepTitleTextJustification,
}
