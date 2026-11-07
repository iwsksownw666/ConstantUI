--[[
	=====================================================================
	ConstantUI 示例 —— 用这套库搭一个完整菜单
	=====================================================================
	直接整段粘进执行器即可运行（默认从 GitHub raw 拉库）。
	=====================================================================
]]

-- ① 加载库（三选一）
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/iwsksownw666/ConstantUI/main/ConstantUI.lua"))()  -- 远程
-- local UI = loadfile("ConstantUI.lua")()   -- 本地
-- local UI = getgenv().ConstantUI           -- 已被其它脚本加载过

-- ② 建窗口（HasTabs = true 才会有顶部标签栏）
local Window = UI:Window({
	Name = "constant.cc",
	Size = Vector2.new(450, 600),      -- 也可写 UDim2.new(0, 450, 0, 600)
	Bind = Enum.KeyCode.RightAlt,      -- 开关键
	Visible = false,                   -- 进游戏是否直接显示
	HasTabs = true
})

--======================= Tab 1 : Main =========================
local Tab = Window:Tab({ Name = "Main", Opened = true })

local Section = Tab:Section({ Name = "General", Side = "Left", Size = 260 })

-- Toggle（可分别挂 Keybind / Colorpicker，注意这俩不返回可链式对象）
local Toggle = Section:Toggle({
	Name = "Enabled",
	Flag = "Main Enabled",
	Default = true,
	Callback = function(Value)
		print("toggle:", Value)
	end
})

Toggle:Colorpicker({
	Color = Color3.fromRGB(60, 67, 120),
	Transparency = 0,
	Flag = "Main Enabled Color",
	Callback = function(Color, Transparency)
		print("color:", Color, Transparency)
	end
})

Toggle:Keybind({
	Mode = "Toggle",
	Name = "Enabled Keybind",
	Flag = "Main Enabled Key"
})

Section:Slider({
	Name = "Speed",
	Min = 1,
	Max = 100,
	Default = 25,
	Decimals = 1,
	Prefix = "x",
	Flag = "Main Speed",
	Callback = function(Value)
		print("slider:", Value)
	end
})

Section:Dropdown({
	Name = "Mode",
	Options = { "Legit", "Rage", "Custom" },
	Default = "Legit",
	Flag = "Main Mode",
	Callback = function(Value)
		print("dropdown:", Value)
	end
})

Section:Dropdown({
	Name = "Multi",
	Options = { "A", "B", "C" },
	Default = { "A", "B" },          -- Default 传 table = 多选
	Flag = "Main Multi"
})

local NameBox = Section:TextBox({
	Name = "Nickname",
	Placeholder = "input here",
	Default = "",
	Flag = "Main Nick",
	Callback = function(Text)
		print("textbox:", Text)
	end
})

Section:Button({
	Name = "Apply",
	CallbackText = "Done!",
	Callback = function()
		print("button clicked, textbox =", NameBox.Get())
	end
})

Section:Label({ Text = "Menu Key" }):Keybind({
	Default = Enum.KeyCode.RightAlt,
	Modes = {},
	Mode = "Toggle",
	Flag = "Main Menu Key"
})

--======================= Tab 2 : Visuals =========================
local Tab2 = Window:Tab({ Name = "Visuals" })

local VisualSection = Tab2:Section({ Name = "Colors", Side = "Left", Size = 260 })

local EspToggle = VisualSection:Toggle({ Name = "ESP", Flag = "Visual Esp" })

EspToggle:Colorpicker({
	Color = Color3.fromRGB(255, 255, 255),
	Transparency = 0,
	Flag = "Visual Esp Color"
})

--======================= Tab 3 : Config =========================
local Tab3 = Window:Tab({ Name = "Config" })

local ConfigSection = Tab3:Section({ Name = "Configurations", Side = "Right", Fill = true })

local Options = UI:ListConfigs()

if #Options == 0 then
	Options = { "default" }
end

local ConfigList = ConfigSection:Dropdown({
	Name = "Config",
	Flag = "Config List",
	Exclude = true,
	Options = Options,
	Default = Options[1],
	Size = 125
})

local ConfigName = ConfigSection:TextBox({
	Placeholder = "Config Name",
	Default = ""
})

ConfigSection:Button({
	Name = "New",
	CallbackText = "Created!",
	Callback = function()
		local Name = ConfigName.Get()

		if Name and Name ~= "" then
			UI:SaveConfig(Name)

			local List = UI:ListConfigs()

			ConfigList.Options = List
			ConfigList.Set(List[1])
		end
	end
})

ConfigSection:Button({
	Name = "Load",
	Callback = function()
		local Name = ConfigList.Get()

		if Name then
			UI:LoadConfig(Name)
		end
	end
})

ConfigSection:Button({
	Name = "Save",
	Callback = function()
		local Name = ConfigList.Get()

		if Name then
			UI:SaveConfig(Name)
		end
	end
})

--======================= 附加组件 =========================
local Watermark = Window:Watermark({
	Text = "constant.cc | 60 fps",
	Enabled = true
})

local KeybindsList = Window:KeybindsList({
	Enabled = true
})

local Dock = UI:Dock({
	Text = "constant.cc",
	Windows = {
		{ Window, "Main", false },
		{ KeybindsList, "Keybinds", false },
		{ Watermark, "Watermark", false }
	}
})

--======================= 通知 =========================
UI:Notify({
	Text = "ConstantUI loaded (RightAlt to toggle)",
	Time = 4
})

--======================= 换皮（可选） =========================
-- UI:SetAccent(Color3.fromRGB(200, 60, 60))

--======================= 显示 / 隐藏 / 退出 =========================
-- 开关窗口（Bind 键已自动绑定，这里给手动调用写法）：
-- UI:Fade(Window, true)      -- 显示
-- UI:Fade(Window, false)     -- 隐藏
-- Window.IsVisible           -- 当前是否可见

-- 彻底销毁（所有 Gui + 连接 + 窗口列表）：
-- UI:Unload()
