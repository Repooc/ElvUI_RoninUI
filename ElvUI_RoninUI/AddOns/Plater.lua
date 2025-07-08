local _, Engine = ...
local E = unpack(ElvUI)

Engine.Plater = {}

local plater = Engine.Plater

local function hasProfile(profileName)
	if not profileName or profileName == '' then Engine:Print('You need to provide a profile name to check for.') return nil end

	return Plater.db.profiles[profileName] and true or false
end

local function SetImportedProfile(dataKey, dataProfile, force, callback)
	if not hasProfile(dataKey) or force then
		Plater.ImportAndSwitchProfile(dataKey, dataProfile, force, nil, true)
		RoninUICharDB.skipStep.Plater = true
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

function plater:SetupProfile(profileString, profileID, callback)
	if not E:IsAddOnEnabled('Plater') then Engine:Print(format('%s is |cffff3300disabled|r!', 'Plater')) return end
	if not profileString then return Engine:Print('No profile string provided.') end

	local profileName = Engine.ProfileData.Plater[profileID..'Name']
	if not profileName or profileName == '' then return Engine:Print('No profile name provided in the config for this profile.') end

	SetImportedProfile(profileName, profileString, false, callback)
end
