local AddOnName, Engine = ...
local E = unpack(ElvUI)
local GetAddOnMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata

_G.RoninUICharDB = _G.RoninUICharDB or {}
_G.RoninUICharDB.skipStep = _G.RoninUICharDB.skipStep or {}

Engine.Config = {}
Engine.Config.Version = GetAddOnMetadata(AddOnName, 'Version')
Engine.Options = {}

local success, DRList = pcall(LibStub, 'DRList-1.0', true)
if success then
	E:AddLib('DRList', 'DRList-1.0')
end

if not RoninUICharDB.install_complete then
	if E:IsAddOnEnabled('Details') and _G._detalhes then
		_G._detalhes.is_first_run = false
		_G._detalhes:SetTutorialCVar('STREAMER_PLUGIN_FIRSTRUN', true)
	end
end
