local E = unpack(ElvUI)
local _, Engine = ...

Engine.OmniBar = {}

local omniBar = Engine.OmniBar

local function hasProfile(profileName)
	if not E:IsAddOnEnabled('OmniBar') then return nil end
	for _, name in ipairs(_G.OmniBar.db:GetProfiles()) do
		if name == profileName then
			return true
		end
	end
	return false
end

local function SetImportedProfile(dataKey, dataProfile, force, callback)
	if not hasProfile(dataKey) or force then
		local decodedProfile = omniBar:Decode(dataProfile)
		if not decodedProfile then return Engine:Print('Failed to decode OmniBar profile.') end
		if (decodedProfile.version ~= 1) then return Engine:Print('Invalid version') end

		_G.OmniBar.db.profiles[dataKey] = decodedProfile.profile
		_G.OmniBar.db:SetProfile(dataKey)

		-- merge custom spells
		for k, v in pairs(decodedProfile.customSpells) do
			_G.OmniBar.db.global.cooldowns[k] = nil
			_G.OmniBar.options.args.customSpells.args.spellId.set(nil, k, v)
		end

		_G.OmniBar:OnEnable()
		-- LibStub("AceConfigRegistry-3.0"):NotifyChange("OmniBar")
		if callback and type(callback) == 'function' then callback() end
	else
		E.PopupDialogs.RONINUI_PROFILE_EXISTS = {
			text = 'The profile you tried to import already exists. Choose a new name or accept to overwrite the existing profile.',
			button1 = ACCEPT,
			button2 = CANCEL,
			hasEditBox = 1,
			editBoxWidth = 350,
			maxLetters = 127,
			OnAccept = function(frame, data)
				SetImportedProfile(frame.editBox:GetText(), data.profileData, true, callback)
			end,
			EditBoxOnTextChanged = function(frame)
				frame:GetParent().button1:SetEnabled(frame:GetText() ~= '')
			end,
			OnShow = function(frame, data)
				frame.editBox:SetText(data.profileKey)
				frame.editBox:SetFocus()
			end,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = true,
			preferredIndex = 3
		}
		E:StaticPopup_Show('RONINUI_PROFILE_EXISTS', nil, nil, { profileKey = dataKey, profileData = dataProfile })
	end
end

function omniBar:Decode(profileString)
	if not profileString then return end
	local LibDeflate = LibStub:GetLibrary("LibDeflate")
	local decoded = LibDeflate:DecodeForPrint(profileString)
	if (not decoded) then return Engine:Print("OmniBar profile decode error.") end
	local decompressed = LibDeflate:DecompressZlib(decoded)
	if (not decompressed) then return Engine:Print("OmniBar profile decompression error.") end
	local success, deserialized = OmniBar:Deserialize(decompressed)
	if (not success) then return Engine:Print("OmniBar profile deserialization error.") end
	return deserialized
end

function omniBar:SetupProfile(profileString, profileID, callback)
	if not E:IsAddOnEnabled('OmniBar') then return Engine:Print(format('%s is |cffff3300disabled|r!', 'OmniBar')) end
	if not profileString then return Engine:Print('No profile string provided.') end
	if not profileID or profileID == '' then return Engine:Print('No profile id provided.') end

	local profileName = Engine.ProfileData.OmniBar[profileID..'Name']
	if not profileName or profileName == '' then return Engine:Print('No profile name provided in the config for this profile.') end

	SetImportedProfile(profileName, profileString, false, callback)
end
