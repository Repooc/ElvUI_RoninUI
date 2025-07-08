local E = unpack(ElvUI)
local _, Engine = ...
local AS = E:IsAddOnEnabled('AddOnSkins') and unpack(AddOnSkins)

Engine.AddonSkins = {}

local addonskins = Engine.AddonSkins

function addonskins:isDualEmbedEnabled()
    if not E:IsAddOnEnabled('AddOnSkins') then return Engine:Print('AddOnSkins is not enabled so we have no clue if embed is enabled...') end
	return (AS:CheckOption('EmbedSystemDual')) and true or false
end

function addonskins:isSingleEmbedEnabled()
    if not E:IsAddOnEnabled('AddOnSkins') then return Engine:Print('AddOnSkins is not enabled so we have no clue if embed is enabled...') end
	return AS:CheckOption('EmbedSystem') and true or false
end

function addonskins:isEitherEmbedEnabled()
    if not E:IsAddOnEnabled('AddOnSkins') then return Engine:Print('AddOnSkins is not enabled so we have no clue if embed is enabled...') end
	return (AS:CheckOption('EmbedSystem') or AS:CheckOption('EmbedSystemDual')) and true or false
end
