local E, L, V, P, G = unpack(ElvUI)
local _, Engine = ...
local D = E.Distributor

Engine.ElvUI = {}

local elvUI = Engine.ElvUI

--* ElvPrivateDB.profileKeys
-- Key are formatted as Charactername - ServerName
-- Value is what profile it is using
-- Example: ElvPrivateDB.profileKeys['Dapooc - Spirestone'] = 'Dapooc - SpirestonePrivate'

--* ElvPrivateDB.profiles
-- Key is the name of the profile
-- Value is the table of settings
-- Example: ElvPrivateDB.profiles['Dapooc - SpirestonePrivate'] = { ... }

local scaleSet = false
local function SetupScale()
	local scale = Engine.ProfileData.ElvUI.Scale
	if scale and scale ~= '' then
		if (scale >= 0.1 and scale <= 1.25) then
			E.global.general.UIScale = scale
			Engine:Print(format('UI Scale set to %s', scale))
			E:PixelScaleChanged()
			scaleSet = true
		else
			Engine:Print('Invalid UI Scale provided in the config. Must be between 0.1 and 1.25.')
		end
	end
end

local function SetImportedProfile(dataKey, dataProfile, force, callback)
	local dataType, _, profileData = D:Decode(dataProfile)

	if not profileData or type(profileData) ~= 'table' then
		Engine:Print('Error: something went wrong when converting string to table!')
		return
	end

	if dataType ~= 'global' and (not profileName or profileName == '') then
		profileName = dataKey
	end

	if dataType == 'profile' then
		if not ElvDB.profiles[dataKey] or force then
			if force and E.data.keys.profile == dataKey then
				--Overwriting an active profile doesn't update when calling SetProfile
				--So make it look like we use a different profile
				E.data.keys.profile = dataKey..'_Temp'
			end

			ElvDB.profiles[dataKey] = profileData

			--Calling SetProfile will now update all settings correctly
			E.data:SetProfile(dataKey)
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
					local newProfileName = frame.editBox:GetText()
					SetImportedProfile(frame.editBox:GetText(), data.profileData, newProfileName == data.profileKey, callback)
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
	elseif dataType == 'private' then
        if not ElvPrivateDB.profiles[dataKey] or force then
			ElvPrivateDB.profiles[dataKey] = profileData
			if ElvPrivateDB.profileKeys and ElvPrivateDB.profileKeys[E.mynameRealm] then
				ElvPrivateDB.profileKeys[E.mynameRealm] = dataKey
			end
			RoninUICharDB.skipStep.ElvUI = true
			if not scaleSet then
				SetupScale()
			end
            C_UI.Reload()
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
					SetImportedProfile(frame.editBox:GetText(), data.profileData, newProfileName == data.profileKey, callback)
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
	elseif dataType == 'global' then
		E:CopyTable(ElvDB.global, profileData)
		E:StaggeredUpdateAll()
		if not scaleSet then
			SetupScale()
		end
	--! Not Needed
	-- elseif dataType == 'filters' then
	-- 	E:CopyTable(ElvDB.global.unitframe, profileData.unitframe)
	-- 	E:UpdateUnitFrames()
	else
		Engine:Print('Invalid data type provided.')
	end
end

function elvUI:SetupProfile(profileString, profileID, callback)
	if not profileString then return Engine:Print('No profile string provided.') end
	if not profileID or profileID == '' then return Engine:Print('No profile id provided.') end

    local profileName = Engine.ProfileData.ElvUI[profileID..'Name']
	local dataType, dataKey, profileData = D:Decode(profileString)

    if not profileData or type(profileData) ~= 'table' then
		Engine:Print('Error: something went wrong when converting string to table!')
		return
	end

    if dataType ~= 'global' and (not profileName or profileName == '') then
        profileName = dataKey
    end

	SetImportedProfile(profileName, profileString, false, callback)
end
