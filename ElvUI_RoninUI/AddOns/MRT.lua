local E, L = unpack(ElvUI)
local _, Engine = ...
local LibDeflate = E.Libs.Deflate

Engine.MRT = {}

local mrt = Engine.MRT

function mrt:hasProfile(profileName)
	if not E:IsAddOnEnabled('MRT') then return nil end
	return VMRT.Profiles[profileName] and true or false
end

local MAJOR_KEYS = {
	['Addon'] = true,
	['Profiles'] = true,
	['Profile'] = true,
	['ProfileKeys'] = true,
}

local function SaveCurrentProfiletoDB()
	local profileName = VMRT.Profile or 'default'
	local saveDB = {}
	VMRT.Profiles[profileName] = saveDB

	for key, val in pairs(VMRT) do
		if not MAJOR_KEYS[key] then
			saveDB[key] = val
		end
	end
end

local function SetImportedProfile(dataKey, dataProfile, force, callback)
	if not mrt:hasProfile(dataKey) or force then
		if VMRT.Profile == dataKey then
			for k, v in pairs(dataProfile) do
				VMRT[k] = v
			end
		else
			SaveCurrentProfiletoDB()
			VMRT.Profiles[dataKey] = dataProfile
			VMRT.Profile = dataKey
			VMRT.ProfileKeys[GMRT.SDB.charKey] = dataKey
			local loadDB = VMRT.Profiles[dataKey]

			for key,val in pairs(VMRT) do
				if not MAJOR_KEYS[key] then
					VMRT[key] = nil
				end
			end

			for key,val in pairs(loadDB) do
				if not MAJOR_KEYS[key] then
					VMRT[key] = val
				end
			end

		end
		RoninUICharDB.skipStep.MRT = true
		if callback and type(callback) == 'function' then callback() end
		Engine:Print(format('Profile added as |cff5CE1E6%s|r\nA reload is needed to take effect. Finish the install process which will reload the ui at the end.', dataKey))
		E:StaticPopup_Show('CONFIG_RL')
	else
		E.PopupDialogs.RONINUI_MRT_PROFILE_EXISTS = {
			text = L["The profile you tried to import already exists. Choose a new name or accept to overwrite the existing profile."],
			button1 = ACCEPT,
			button2 = CANCEL,
			hasEditBox = 1,
			editBoxWidth = 350,
			maxLetters = 127,
			OnAccept = function(frame, data)
				if data.profileKey == frame.editBox:GetText() and mrt:hasProfile(frame.editBox:GetText()) then Details:EraseProfile(frame.editBox:GetText()) end
				SetImportedProfile(frame.editBox:GetText(), data.profileData, true)
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
		E:StaticPopup_Show('RONINUI_MRT_PROFILE_EXISTS', nil, nil, { profileKey = dataKey, profileData = dataProfile })
	end
end

function mrt:SetupProfile(encodedString, profileID, callback)
	if not E:IsAddOnEnabled('MRT') then return end
	if not encodedString or encodedString == '' then return Engine:Print('No profile provided.') end
	if not profileID or profileID == '' then return Engine:Print('No Profile ID provided.') end

	local profileName = Engine.ProfileData.MRT[profileID..'Name']
	if not profileName or profileName == '' then return Engine:Print('No profile name provided.') end

	local headerLen = encodedString:sub(1, 4) == 'EXRT' and 6 or 5
	local header = encodedString:sub(1, headerLen)
	if (header:sub(1, headerLen - 1) ~= 'EXRTP' and header:sub(1, headerLen - 1) ~= 'MRTP') or (header:sub(headerLen, headerLen) ~= '0' and header:sub(headerLen, headerLen) ~= '1') then
		Engine:Print('Invalid or unsupported format')
		return
	end

	local newEncodedString = encodedString:sub(headerLen + 1)
	local uncompressed = header:sub(headerLen, headerLen) == '0'

	local decoded = LibDeflate:DecodeForPrint(newEncodedString)
	local decompressed = uncompressed and decoded or LibDeflate:DecompressDeflate(decoded)

	if not decompressed then
		Engine:Print('Import string is broken.')
		return
	end

	local _, clientVersion, tableData = strsplit(',', decompressed, 3)
	if ((clientVersion == '0' and not GMRT.isClassic) or (clientVersion == '1' and GMRT.isClassic)) then
		local successful, res = pcall(GMRT.F.TextToTable, tableData)

		if successful and res then
			SetImportedProfile(profileName, res, false, callback)
		else
			Engine:Print('Import unsuccessful'..(res and '\nError code: '..res or ''))
		end
	else
		Engine:Print('This profile is for another game version')
	end
end
