local E, L, V, P, G = unpack(ElvUI)
local PI = E.PluginInstaller
local EP = E.Libs.EP
local D = E.Distributor
local AddOnName, Engine = ...

local EnableAddOn = C_AddOns.EnableAddOn

local title = Engine.Config.Title
L["RONINUI_COMMANDS"] = format(([=[Here is a list of %s commands:
 ^/roninui|r *loadaddons|r or ^/roninui|r *enableaddons|r  -  Enables the addons needed for %s.
]=]):gsub('*', E.InfoColor):gsub('%^', E.InfoColor2), title, title)

function Engine:Print(...)
	(E.db and _G[E.db.general.messageRedirect] or _G.DEFAULT_CHAT_FRAME):AddMessage(strjoin('', Engine.Config.Title, ':|r ', ...))
end

E.PopupDialogs.RONINUI_EDITBOX = {
	text = Engine.Config.Title,
	button1 = OKAY,
	hasEditBox = 1,
	OnShow = function(self, data)
		self.editBox:SetAutoFocus(false)
		self.editBox.width = self.editBox:GetWidth()
		self.editBox:Width(280)
		self.editBox:AddHistoryLine('text')
		self.editBox.temptxt = data
		self.editBox:SetText(data)
		self.editBox:HighlightText()
		self.editBox:SetJustifyH('CENTER')
	end,
	OnHide = function(self)
		self.editBox:Width(self.editBox.width or 50)
		self.editBox.width = nil
		self.temptxt = nil
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnTextChanged = function(self)
		if self:GetText() ~= self.temptxt then
			self:SetText(self.temptxt)
		end
		self:HighlightText()
		self:ClearFocus()
	end,
	OnAccept = E.noop,
	whileDead = 1,
	preferredIndex = 3,
	hideOnEscape = 1,
}

local function GetOptions()
	for _, func in pairs(Engine.Options) do
		func()
	end
end

local addonList = {
	BigWigs = true,
	BigWigs_Core = true,
	BigWigs_KhazAlgar = true,
	BigWigs_LiberationOfUndermine = true,
	BigWigs_ManaforgeOmega = true,
	BigWigs_MistsOfPandaria = true,
	BigWigs_NerubarPalace = true,
	BigWigs_Options = true,
	BigWigs_Plugins = true,
	BigWigs_Voice = true,
	Details = true,
	Details_Compare2 = true,
	Details_DataStorage = true,
	Details_EncounterDetails = true,
	Details_RaidCheck = true,
	Details_Streamer = true,
	Details_TinyThreat = true,
	Details_Vanguard = true,
	OmniBar = true,
	OmniCD = true,
	Plater = true,
	WeakAuras = true,
	WeakAurasArchive = true,
	WeakAurasModelPaths = true,
	WeakAurasOptions = true,
}

local function EnableAddons()
	for name in pairs(addonList) do
		EnableAddOn(name, E.myname)
	end
	if E.Retail then
		EnableAddOn('MRT', E.myname)
	end
	C_UI.Reload()
end

local function chatCmdHandler(msg)
	if type(msg) ~= 'string' then return end
	msg = msg:lower()
	if msg == 'enableaddons' or msg == 'loadaddons' then
		Engine:Print(format('Enabling addons needed for %s', Engine.Config.Title))
		EnableAddons()
	else
		print(L["RONINUI_COMMANDS"])
	end
end

local function Initialize()
	if not RoninUICharDB.install_complete then
		PI:Queue(Engine.InstallerData)
	end

	E:RegisterChatCommand('roninui', chatCmdHandler)

	EP:RegisterPlugin(AddOnName, GetOptions)
end

EP:HookInitialize(AddOnName, Initialize)

hooksecurefunc(PI, 'RunInstall', function()
	if RoninUICharDB.install_complete then
		wipe(RoninUICharDB.skipStep)

		return
	end

	if _G.PluginInstallFrame.Title:GetText() ~= Engine.InstallerData.Title then
		PI:CloseInstall()
		Engine:Print(format('As part of the installation of %s profile, %s installer has been automatically skipped.', Engine.InstallerData.Title, _G.PluginInstallFrame.Title:GetText() or 'Unknown'))
	end
end)
