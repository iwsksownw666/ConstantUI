--[[
	ConstantUI 最小骨架 —— 复制整段粘进执行器就能跑
	加载完就是原版那套完整菜单（5 窗口 / 12 Tab / 381 控件）
	库来源：https://github.com/iwsksownw666/ConstantUI
]]

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/iwsksownw666/ConstantUI/main/ConstantUI.lua"))()

-- 到这一行，界面已经全出来了。下面谁都不写也能用。
UI:Notify({ Text = "ConstantUI loaded", Time = 3 })

-- 想接管就接管：
-- UI:SetAccent(Color3.fromRGB(120, 170, 255))
-- UI:SetFlag("Aimbot", "Enabled", true)
-- print("FOV =", UI:GetFlag("FOV"))
-- UI:SaveConfig("my_setup")
