--[[
	===============================================================
	ConstantUI · 示例
	---------------------------------------------------------------
	这份库 = 原版「康.lua」的完整界面，一字未改：
	  · Menu Library 层（原文件 509–8327 行）
	  · 完整菜单构建层（原文件 8411–12567 行）
	    - Configurations 主窗：Legit(4) / Rage(2) / Visuals(5) / Misc(2) / Settings(2)
	    - Environment 窗：Players / Options
	    - Theme 窗
	    - Lua 窗：Editor / Options
	    - Activity 窗：Players / Chat
	    - Watermark / KeybindsList / Dock
	    - 381 个控件，全部注册进 Flags

	所以：加载 → 菜单原样出现。你不需要再手写任何一个 Toggle。
	===============================================================
]]

--------------------------------------------------------------------
-- 方式 A：一行从 GitHub 拉（执行器里直接丢进去就行）
--------------------------------------------------------------------
local Library = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/iwsksownw666/ConstantUI/main/ConstantUI.lua"
))()

--------------------------------------------------------------------
-- 方式 B：本地文件（把 ConstantUI.lua 放进执行器工作目录）
--------------------------------------------------------------------
-- local Library = loadstring(readfile("ConstantUI.lua"))()

--------------------------------------------------------------------
-- 方式 C：作为模块 require（放进 scripts/ 或 require 目录）
--------------------------------------------------------------------
-- local Library = require(path.to.ConstantUI)

--------------------------------------------------------------------
-- 到这一步，界面已经全出来了。下面全是可选的「接管」操作
--------------------------------------------------------------------

-- 1. 换强调色（原版 Accent，默认偏红）
Library:SetAccent(Color3.fromRGB(120, 170, 255))

-- 2. 读 / 写某条 flag
--    原版 flag 有两种命名：扁平 "Name" 和分组 "Category" -> "Name"
print("Aimbot 是否开启:", Library:GetFlag("Aimbot", "Enabled"))
print("FOV 当前值:", Library:GetFlag("FOV"))
print("所有配置名:", table.concat(Library:ListConfigs(), ", "))

-- 设置（等价于用户手动拖动控件）
Library:SetFlag("Aimbot", "Enabled", true)
Library:SetFlag("FOV", 120)

-- 3. 遍历全部控件，导出当前值
local function DumpFlags()
	local Out = {}

	local Walk
	Walk = function(Group, Prefix)
		for Key, Value in pairs(Group) do
			if typeof(Value) == "table" and typeof(Value.Get) == "function" then
				local Value2 = Value.Get()
				Out[#Out + 1] = string.format("%s%s = %s", Prefix, Key, tostring(Value2))
			elseif typeof(Value) == "table" and typeof(Key) == "string" then
				Walk(Value, Prefix .. Key .. ".")
			end
		end
	end

	Walk(Library.Flags, "")

	return Out
end

local FlagsDump = DumpFlags()
print(string.format("共 %d 条 flag", #FlagsDump))

-- 4. 配置持久化（存到 getconstant.cc/Configs/*.cfg）
Library:SaveConfig("my_setup")
Library:LoadConfig("my_setup")
Library:SetAutoload("my_setup")  -- 下次加载自动套用

-- 5. 找到某个窗口，手动开关
local Environment = Library:FindWindow("Environment")
if Environment then
	Environment:Toggle(true)
end

-- 6. 通知
Library:Toast("ConstantUI loaded", 3)

-- 7. 卸载（销毁所有 Gui、断开全部连接）
-- Library:Unload()

--------------------------------------------------------------------
-- 附：如果你想要的是「空框架，自己搭菜单」（不用原版那套）
--------------------------------------------------------------------
-- 库导出的是 Library 本体，控件构造函数都在：
--
--   local Win = Library:Window({ Name = "MyScript", Size = UDim2.fromOffset(600, 400), HasTabs = true })
--   local Tab = Win:Tab({ Name = "Main" })
--   local Sec = Tab:Section({ Name = "General", Side = "Left" })
--   Sec:Toggle({ Name = "Enabled", Flag = "Enabled", Default = true })
--   Sec:Slider({ Name = "Speed", Flag = "Speed", Min = 1, Max = 100, Default = 50 })
--   Sec:Dropdown({ Name = "Mode", Flag = "Mode", Options = { "A", "B" }, Default = "A" })
--   Sec:Button({ Name = "Click", Callback = function() print("hi") end })
--
-- 注意：原版菜单已经在 Library:Window 里自动建好了（5 个窗口），
-- 所以你要是自己再建窗口，会是第 6 个，两个并存。
