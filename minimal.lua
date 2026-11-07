--[[
	ConstantUI 最小骨架 —— 复制整段粘进执行器就能跑
	开关键：RightAlt     库来源：https://github.com/iwsksownw666/ConstantUI
]]

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/iwsksownw666/ConstantUI/main/ConstantUI.lua"))()

local Window = UI:Window({
	Name = "my menu",
	Size = Vector2.new(450, 600),
	Bind = Enum.KeyCode.RightAlt,
	HasTabs = true,
	Visible = true,
})

local Tab = Window:Tab({ Name = "Main", Opened = true })
local Section = Tab:Section({ Name = "General", Side = "Left", Size = 260 })

Section:Toggle({
	Name = "Enabled",
	Flag = "Enabled",
	Default = false,
	Callback = function(Value)
		print("Enabled =", Value)
	end
})

Section:Slider({
	Name = "Speed",
	Min = 1, Max = 100, Default = 25,
	Decimals = 1, Prefix = "x",
	Flag = "Speed",
	Callback = function(Value)
		print("Speed =", Value)
	end
})

Section:Dropdown({
	Name = "Mode",
	Options = { "Legit", "Rage" },
	Default = "Legit",
	Flag = "Mode",
	Callback = function(Value)
		print("Mode =", Value)
	end
})

Section:Button({
	Name = "Do something",
	Callback = function()
		print("clicked; current speed =", UI.Flags["Speed"]:Get())
	end
})

Section:Label({ Text = "Menu Key" }):Keybind({
	Default = Enum.KeyCode.RightAlt,
	Mode = "Toggle",
	Modes = {},
	Flag = "MenuKey",
})

UI:Notify({ Text = "loaded", Time = 3 })
