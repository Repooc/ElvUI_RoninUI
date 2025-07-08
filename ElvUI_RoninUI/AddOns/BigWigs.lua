local AddOnName, Engine = ...
local E = unpack(ElvUI)

Engine.BigWigs = {}

local bigwigs = Engine.BigWigs
local hexElvUIBlue = '|cff1785d1'

function bigwigs:GetCurrentProfileName()
	return BigWigs3DB and BigWigs3DB.profileKeys[E.mynameRealm] or UNKNOWN
end

function bigwigs:SetupProfile(profile, profileID, callback)
	if not E:IsAddOnEnabled('BigWigs') then Engine:Print('BigWigs is |cffff3300disabled|r!') return end
	if not profile then return Engine:Print('No profile string provided.') end

	local profileName = Engine.ProfileData.BigWigs[profileID..'Name']
	if not profileName or profileName == '' then return Engine:Print('No profile name provided in the config for this profile.') end

	BigWigsAPI.RegisterProfile(AddOnName, profile, profileName, function(completed)
		if completed then
			Engine:Print('BigWigs profile import process has been completed.')
			PlaySound(888)

			if callback and type(callback) == 'function' then callback() end
			return
		end
		Engine:Print('BigWigs profile import process has been cancelled. No profile has been imported.')
	end)
end
