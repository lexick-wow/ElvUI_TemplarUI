--Cache Lua / WoW API
local format = string.format
local GetCVarBool = GetCVarBool
local ReloadUI = ReloadUI
local StopMusic = StopMusic
local GetAddOnMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata

--Don't worry about this
local addon, ns = ...
local Version = GetAddOnMetadata(addon, "Version")

--Change this line and use a unique name for your plugin.
local MyPluginName = "Templar UI"

--Create references to ElvUI internals
local E, L, V, P, G = unpack(ElvUI)

--Create reference to LibElvUIPlugin
local EP = LibStub("LibElvUIPlugin-1.0")

--Create a new ElvUI module so ElvUI can handle initialization when ready
local mod = E:NewModule(MyPluginName, "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0");

--This function will hold your layout settings
local function SetupLayout(layout)

	--import eltruism nameplates
	if E.private.nameplates.enable then
		ElvUI_EltreumUI:SetupNamePlates('ElvUI')
	end

	--import gradient mode
	ElvUI_EltreumUI:GradientMode()
	
	--profile specific settings (layouts)
	if layout == "TemplarUI" then
		mod:TemplarUI()
	end

	--fix the colors after the profile
	mod:FixClassColors()

	--Update ElvUI
	E:StaggeredUpdateAll()

	--Show message about layout being set
	PluginInstallStepComplete.message = "Layout Set"
	PluginInstallStepComplete:Show()
end

--This function is executed when you press "Skip Process" or "Finished" in the installer.
local function InstallComplete()
	if GetCVarBool("Sound_EnableMusic") then
		StopMusic()
	end

	--Set a variable tracking the version of the addon when layout was installed
	E.db[MyPluginName].install_version = Version
	E.private.install_complete = E.version

	ReloadUI()
end

--This is the data we pass on to the ElvUI Plugin Installer.
--The Plugin Installer is reponsible for displaying the install guide for this layout.
local InstallerData = {
	Title = "Installation",
	Name = MyPluginName,
	tutorialImage = "Interface\\AddOns\\ElvUI_TemplarUI\\logo.tga", --If you have a logo you want to use, otherwise it uses the one from ElvUI
	Pages = {
		[1] = function()
			PluginInstallFrame.SubTitle:SetText("Welcome to the installation for |cffEA4747T|cffCD3D3De|cffA53030m|cffA72D2Dp|cffB43535l|cffA12828a|cff982222r|cffffffffUI")
			PluginInstallFrame.Desc1:SetText("This installation process will guide you through a few steps and create a new ElvUI profile.")
			PluginInstallFrame.Desc2:SetText("Please press the continue button if you wish to go through the installation process, otherwise click the 'Skip Process' button.")
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", InstallComplete)
			PluginInstallFrame.Option1:SetText("Skip Process")
		end,
		[2] = function()
			PluginInstallFrame.SubTitle:SetText("Layouts")
			PluginInstallFrame.Desc1:SetText("These are the layouts that are available. Please click a button below to apply the layout of your choosing.")
			PluginInstallFrame.Desc2:SetText("Importance: |cff07D400High|r")
			PluginInstallFrame.Option1:Show()
			-- PluginInstallFrame.Option1:SetScript("OnClick", function() SetupLayout("TemplarUI") end) -- This is the normal way of doing it.
			PluginInstallFrame.Option1:SetScript("OnClick", function() 
				E.data:SetProfile("TemplarUI") -- this will create a new profile with the name supplied
				SetupLayout("TemplarUI") --this will apply the profile to the current profile
			end)
			PluginInstallFrame.Option1:SetText("TemplarUI")
			
			-- 4 buttons is the max per "page", so you'll need to add another page for more profiles, as you can see, 3 is now another page and 4 is now the complete install page
		end,
		[3] = function()
			_G.PluginInstallFrame.SubTitle:SetFormattedText('Github')
			_G.PluginInstallFrame.Desc1:SetText(L["Lookup Github if you have any questions or issues"])
			_G.PluginInstallFrame.Option1:Enable()
			_G.PluginInstallFrame.Option1:Show()
			_G.PluginInstallFrame.Option1:SetScript('OnClick', function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://github.com/lexick-wow/ElvUI_TemplarUI')  end)
			_G.PluginInstallFrame.Option1:SetText('Github')
		end,
		[4] = function()
			PluginInstallFrame.SubTitle:SetText("Installation Complete")
			PluginInstallFrame.Desc1:SetText("You have completed the installation process.")
			PluginInstallFrame.Desc2:SetText("Please click the button below in order to finalize the process and automatically reload your UI.")
			PluginInstallFrame.Option1:Show()
			PluginInstallFrame.Option1:SetScript("OnClick", InstallComplete)
			PluginInstallFrame.Option1:SetText("Finished")
		end,
	},
	StepTitles = {
		[1] = "Welcome",
		[2] = "Layouts",
		[3] = "Github",
		[4] = "Installation Complete",
	},
	StepTitlesColor = {1, 1, 1},
	StepTitlesColorSelected = {0.91, 0.27, 0.27},
	StepTitleWidth = 200,
	StepTitleButtonWidth = 180,
	StepTitleTextJustification = "RIGHT",
}

--This function holds the options table which will be inserted into the ElvUI config
local function InsertOptions()
	E.Options.args.MyPluginName = {
		order = 100,
		type = "group",
		name = "|cffEA4747T|cffCD3D3De|cffA53030m|cffA72D2Dp|cffB43535l|cffA12828a|cff982222r|cffffffffUI",
		args = {
			header1 = {
				order = 1,
				type = "header",
				name = MyPluginName,
			},
			description1 = {
				order = 2,
				type = "description",
				name = format("%s is a layout for ElvUI.", "|cffEA4747T|cffCD3D3De|cffA53030m|cffA72D2Dp|cffB43535l|cffA12828a|cff982222r|cffffffffUI"),
			},
			spacer1 = {
				order = 13,
				type = "description",
				name = "\n\n\n",
			},
			header2 = {
				order = 14,
				type = "header",
				name = "Installation",
			},
			description2 = {
				order = 15,
				type = "description",
				name = "The installation guide should pop up automatically after you have completed the ElvUI installation. If you wish to re-run the installation process for this layout then please click the button below.",
			},
			spacer2 = {
				order = 16,
				type = "description",
				name = "",
			},
			install = {
				order = 17,
				type = "execute",
				name = "Install",
				desc = "Run the installation process.",
				func = function() E:GetModule("PluginInstaller"):Queue(InstallerData); E:ToggleOptions(); end,
			},
		},
	}
end

--Create a unique table for our plugin
P[MyPluginName] = {}

--This function will handle initialization of the addon
function mod:Initialize()

	--hide Eltruism install since you are going to apply settings anyway
	if _G["PluginInstallFrame"] and _G["PluginInstallFrame"].Title and E.db[MyPluginName].install_version == nil then
		if _G["PluginInstallFrame"].Title:GetText() ~= nil and _G["PluginInstallFrame"].Title:GetText() == ElvUI_EltreumUI.Name then
			local PI = E:GetModule('PluginInstaller')
			PI.CloseInstall()
		end
	end

	--Initiate installation process if ElvUI install is complete and our plugin install has not yet been run
	if E.private.install_complete and E.db[MyPluginName].install_version == nil then
		E:GetModule("PluginInstaller"):Queue(InstallerData)
	end

	--Insert our options table when ElvUI config is loaded

	EP:RegisterPlugin(addon, InsertOptions)
end

--Register module with callback so it gets initialized when ready
E:RegisterModule(mod:GetName())
