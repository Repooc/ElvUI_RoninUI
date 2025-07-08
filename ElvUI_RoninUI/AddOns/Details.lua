local _, Engine = ...
local E, L = unpack(ElvUI)

Engine.Details = {}

local details = Engine.Details

local function hasProfile(profileName)
	if not E:IsAddOnEnabled('Details') then return nil end
	for _, name in ipairs(Details:GetProfileList()) do
		if name == profileName then
			return true
		end
	end
	return false
end

local function SetImportedProfile(dataKey, dataProfile, force, callback, profileID)
	if not hasProfile(dataKey) or force then
		Details:ImportProfile(dataProfile, dataKey)

		if Details:GetCurrentProfileName() ~= dataKey then
			Details:ApplyProfile(dataKey)
		end
		if callback and type(callback) == 'function' then callback('Details', profileID) end
	else
		E.PopupDialogs.RONINUI_PROFILE_EXISTS = {
			text = 'The profile you tried to import already exists. Choose a new name or accept to overwrite the existing profile.',
			button1 = ACCEPT,
			button2 = CANCEL,
			hasEditBox = 1,
			editBoxWidth = 350,
			maxLetters = 127,
			OnAccept = function(frame, data)
						local newProfileName = frame.editBox:GetText()
						if data.profileKey == newProfileName and hasProfile(newProfileName) then Details:EraseProfile(newProfileName) end
						SetImportedProfile(newProfileName, data.profileData, true, callback, profileID)
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

function details:SetupProfile(profile, profileID, callback)
	if not E:IsAddOnEnabled('Details') then Engine:Print('Details is |cffff3300disabled|r!') return end
	if not profile then return Engine:Print('No profile string provided.') end

	local profileName = Engine.ProfileData.Details[profileID..'Name']
	if not profileName or profileName == '' then return Engine:Print('No profile name provided.') end

	SetImportedProfile(profileName, profile, false, callback, profileID)
end
