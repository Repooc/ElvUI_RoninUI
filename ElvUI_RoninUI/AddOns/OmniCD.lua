local E, L = unpack(ElvUI)
local _, Engine = ...

Engine.OmniCD = {}

local omniCD = Engine.OmniCD

local function SetImportedProfile(profileType, profileKey, profileData, callback, profileID)
    if not profileData then return end

	if profileType == 'cds' then
		E.PopupDialogs.RONINUI_OMNICD_IMPORT_EDITOR = {
			text = 'Importing Custom Spells will reload UI. Press Cancel to abort.',
			button1 = ACCEPT,
			button2 = CANCEL,
			OnAccept = function(_, data)
				OmniCD[1].ProfileSharing:CopyCustomSpells(data)
				C_UI.Reload()
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3
		}
		E:StaticPopup_Show('RONINUI_OMNICD_IMPORT_EDITOR', nil, nil, profileData)
	else
		E.PopupDialogs.RONINUI_OMNICD_IMPORT_PROFILE = {
			text = 'Press Accept to save profile %s. Addon will switch to the imported profile.',
			button1 = ACCEPT,
			button2 = CANCEL,
			OnAccept = function(_, data)
				OmniCD[1].ProfileSharing:CopyProfile(data.profileType, data.profileKey, data.profileData)
				OmniCD[1]:ACR_NotifyChange()
				if callback and type(callback) == 'function' then callback('OmniCD', profileID) end
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			preferredIndex = 3
		}
		E:StaticPopup_Show('RONINUI_OMNICD_IMPORT_PROFILE', format('|cffffd200%s|r', profileKey), nil, {profileType=profileType, profileKey=profileKey, profileData=profileData})
	end
end

function omniCD:Decode(data)
	local profileType, profileKey, profileData = OmniCD[1].ProfileSharing:Decode(data)
	if not profileData then
		return
	end

	local prefix = '[IMPORT-%s]%s'
	local n = 1
	local key
	while true do
		key = format(prefix, n, profileKey)
		if not OmniCDDB.profiles[key] then
			profileKey = key
			break
		end
		n = n + 1
	end

    return profileType, profileKey, profileData
end

function omniCD:SetupProfile(profileString, profileID, callback)
	if not E:IsAddOnEnabled('OmniCD') then Engine:Print('OmniCD is |cffff3300disabled|r!') return end
	if not profileString then return Engine:Print('No profile string provided.') end

	local profileName = Engine.ProfileData.OmniCD[profileID..'Name']
	local profileType, profileKey, profileData = omniCD:Decode(profileString)
	profileKey = not profileName or profileName == '' and profileKey or profileName

    SetImportedProfile(profileType, profileKey, profileData, callback, profileID)
end
