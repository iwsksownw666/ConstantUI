# ConstantUI — 从 康.lua 提取的独立 UI 库

从 `康.lua`（Constant.cc，by axure）里把整套界面原样剥出来，做成一个**可直接 loadstring 的 library**。
包含 **UI 框架层 + 完整的原版菜单**（5 个窗口 / 12 个 Tab / 24 个 Section / 381 个控件），
一字未改结构。作弊逻辑（Ragebot / ESP / Aim / Movement 的实现）不在库里，被一层占位表接管，
所以菜单能长得和原版一模一样，点下去也不报错。

```
ui_extract/
├── ConstantUI.lua      ← 库本体（单文件，1.62 MB，含内嵌字体/图标 base64 + 完整菜单）
├── example.lua         ← 用法示例（加载即出原版菜单 + 接管 flag / 主题 / 配置）
├── minimal.lua         ← 50 行最小骨架（只加载、不接管）
├── README.md           ← 本文档
├── _build/             ← 提取过程留档（header / core / decls / stub / menu_core / footer + build.py）
└── _test/              ← 离线冒烟测试（mock Roblox API，非交付物）
```

---

## 0. 加载即得原版菜单

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/iwsksownw666/ConstantUI/main/ConstantUI.lua"))()
```

加载完成的那一刻，原版那套界面就已经建好了：

| 窗口 | Tab | Section |
|---|---|---|
| **Configurations**（主窗，`RightAlt` 开关） | Legit | Aim Assist · Trigger Bot · Silent Aim · Misc |
| | Rage | Ragebot · Knifebot |
| | Visuals | Player ESP · Tracers · Targeting · World ESP · Others |
| | Misc | Primary · Secondary |
| | Settings | Settings · Configurations |
| **Environment** | Players | （玩家列表 + 聊天框） |
| | Options | — |
| **Theme** | （左右分栏，无 Tab） | 主题 / 强调色 / 字体 |
| **Lua** | Editor | 脚本编辑器 |
| | Options | A · B |
| **Activity** | Players | — |
| | Chat | — |

外加 `Watermark`、`KeybindsList`、`Dock`（底部窗口切换条）。
全部 **381 个控件**都已注册进 `UI.Flags`，用 `GetFlag` / `SetFlag` 直接读写。

---

## 1. 怎么用

```lua
-- 本地
local UI = loadfile("ConstantUI.lua")()

-- 远程（放到你自己的 raw 地址）
local UI = loadstring(game:HttpGet("https://.../ConstantUI.lua"))()

-- 库里已自动 getgenv().ConstantUI = 自身，别的脚本可直接取
local UI = getgenv().ConstantUI
```

加载时库会自己做完这些事：建文件目录 → 导入字体/图标（写进 `getconstant.cc/`）→ 建 ScreenGui Overlay → 挂输入事件 → 生成通知栏 → **构建原版完整菜单**。

```lua
-- 原版菜单已经建好了，不需要你再 Window({...})
-- 如果你确实想加自己的第 6 个窗口：
local Window = UI:Window({
    Name    = "constant.cc",
    Size    = Vector2.new(450, 600),   -- 也可 UDim2.new(0,450,0,600)
    Bind    = Enum.KeyCode.RightAlt,   -- 开关热键
    Visible = true,
    HasTabs = true                     -- 想要顶部标签栏就必须 true
})
```


---

## 2. 层级

```
Library (UI)
└── Window            : UI:Window{...}
    ├── Tab           : Window:Tab{...}        -- 需要 HasTabs = true
    │   ├── Section   : Tab:Section{...}
    │   │   ├── Toggle / Slider / Dropdown / TextBox / Button / Label
    │   │   ├── CodeBox / List / Groupbox / ExpandableToggle / ExpandableLabel
    │   │   └── 元素上的附加件： :Colorpicker{} / :Keybind{}
    │   ├── MultiSection : Tab:MultiSection{ Sections = {...} }  → 返回数组
    │   └── Bar       : Tab:Bar{...}
    ├── Watermark     : Window:Watermark{...}
    └── KeybindsList  : Window:KeybindsList{...}
Dock / Notify / Card / Config / Unload 都挂在 Library 上
```

### Window

| 参数 | 类型 | 默认 | 说明 |
|---|---|---|---|
| Name | string | "Configurations" | 窗口标题 |
| Size | Vector2 / UDim2 | 450×600 | 尺寸 |
| Bind | Enum.KeyCode | RightAlt | 开关热键 |
| Callback | function(Visible) | – | 显隐回调 |
| HasTabs | bool | false | 是否显示标签栏 |
| Visible | bool | false | 初始是否显示 |
| Disabled | bool | false | 禁用交互 |

### Tab / Section

```lua
local Tab = Window:Tab{ Name = "Combat", Opened = true }

local Left  = Tab:Section{ Name = "Aimbot", Side = "Left",  Size = 300 }
local Right = Tab:Section{ Name = "Misc",   Side = "Right", Fill = true }

-- 一个 Section 位置放多页（返回 Section 数组）
local Multi = Tab:MultiSection{ Name = "Player ESP", Sections = { "A", "B" }, Side = "Left" }
local Sub = Multi[1]
```

`Tab:Bar{}` 用于在标签页顶部加一条自定义工具条（可带搜索框）：
`Side`、`Buttons`、`ButtonsSide`、`TextBox`、`Placeholder`、`Callback`、`Offset`。

---

## 3. 控件

所有控件都支持：`Flag`（存取值用）、`Category`（分组）、`Unsafe` / `Indev` / `Blocked`（角标标记）、`Hidden`（建了但不显示）。

### Toggle

```lua
local T = Section:Toggle{
    Name = "Enabled", Flag = "Enabled", Default = true,
    Callback = function(Value) end
}
T.Set(true)      -- 程序改值（会触发 Callback）
T.Get()          -- 读值
```

### Slider

```lua
Section:Slider{
    Name = "FOV", Min = 1, Max = 90, Default = 5,
    Decimals = 0.1, Prefix = "°", Flag = "FOV",
    Callback = function(Value) end
}
```

### Dropdown

```lua
Section:Dropdown{
    Name = "Mode", Options = { "A", "B" }, Default = "A",
    Flag = "Mode", Callback = function(Value) end
}
-- 多选：Default 传 table
Section:Dropdown{ Name = "Multi", Options = {"A","B"}, Default = {"A"} }
-- Min = 限制最多选几个；Size = 行数
```

### TextBox

```lua
Section:TextBox{
    Name = "Nick", Placeholder = "input", Default = "",
    RequireSubmit = true, ResetOnSubmit = false, Flag = "Nick",
    Callback = function(Text) end
}
```

### Button

```lua
Section:Button{
    Name = "Apply", CallbackText = "Done!",  -- 点击后按钮文字临时变这个
    Confirm = false,                        -- true = 再点一次才生效
    Callback = function() end
}
```

### Label / Keybind / Colorpicker

```lua
Section:Label{ Text = "Menu Key", Icon = UI.Images["Folder Icon"] }

Section:Label{ Text = "Menu Key" }:Keybind{
    Default = Enum.KeyCode.RightAlt,
    Mode = "Toggle",                     -- Always On / Toggle / Held / Off Hold
    Modes = { "Toggle", "Held" },        -- 允许用户切换的模式
    Flag = "MenuKey",
    Changed = function(Value) end,       -- Value = { "KeyCode"/"MouseButton1", "Name" }
    Activated = function() end
}

Toggle:Colorpicker{
    Color = Color3.fromRGB(60, 67, 120),
    Transparency = 0,                    -- true = 带透明度滑块
    Side = "Right", Flag = "Col",
    Callback = function(Color, Transparency) end
}
```

> Toggle / Slider / Dropdown / TextBox / Button / Label 都能挂 `:Keybind` 和 `:Colorpicker`（它们带 `Elements` 元表）。
> **Keybind / Colorpicker 自身不能再链式调用** —— 需要两个就先取变量。

### 其它

```lua
Section:CodeBox{ Default = "-- lua", Size = 334, Flag = "Code" }   -- 带行号的代码框 + 复制
Section:List{ Options = { ["A"] = {"1","Neutral"} }, Rows = {"Class","Priority"}, Size = 311, Clickable = true }
Section:ExpandableToggle{ Name = "Sub", Opened = false, Size = 208, Callback = fn }   -- 可展开的子项容器
Section:ExpandableLabel{ Text = "Sub", Icon = ..., Size = 208 }
Section:Groupbox{ Groups = { {"A", Image, UDim2.new(0,8,0,8)} }, OpenIndex = 1 }      -- 返回多个 Section
```

---

## 4. 窗口开关

原版 5 个窗口按创建顺序补上了名字（`Library:Window` 收下 `Name` 但从没存进窗口对象，
原版 `Library:Find` / `Dock.Find` 因此永远返回 nil —— 这里补好了）：

```lua
UI:FindWindow("Environment")         -- 拿到窗口对象，拿不到返回 nil
UI:GetWindows()                      -- 全部窗口数组

UI:OpenWindow("Environment")         -- 等于点一下 Dock 上的 Environment
UI:CloseWindow("Lua")
UI:ToggleWindow("Activity")          -- 无参 = 取反
UI:ToggleWindow("Activity", false)   -- 指定状态

-- 对象上也有
local W = UI:FindWindow("Theme")
W.Open()  W.Close()  W.Toggle()
```

窗口名：`Configurations` / `Environment` / `Theme` / `Lua` / `Activity`。

---

## 5. 旗标（Flags）与配置

```lua
UI.Flags["Enabled"]:Get()            -- 未分组 flag
UI.Flags["Category"]["Name"]:Get()   -- 分组 flag  (控件传了 Category)
UI:GetFlag("Enabled")                -- 简写
UI:SetFlag("Enabled", true)
```

配置读写（存到 `getconstant.cc/Configs/<名字>.cfg`）：

```lua
UI:SaveConfig("legit")        -- 新建 / 覆盖
UI:LoadConfig("legit")
UI:DeleteConfig("legit")
UI:ListConfigs()              -- { "legit", ... }
UI:SetAutoload("legit")       -- 下次进游戏自动载入
UI:GetAutoload()
UI.Config("Get")              -- 原始 JSON 字符串
```

Lua 插件目录（`getconstant.cc/Luas`）：

```lua
UI.Lua("List")
UI.Lua("Save", "name.lua", source)
UI.Lua("Load", "name.lua", modules)
UI.Lua("Unload", "name.lua")
```

---

## 6. 主题 / 换色

```lua
UI:SetAccent(Color3.fromRGB(200, 60, 60))    -- 换强调色（最常用）

-- 整套换肤：Theme 表结构见 ConstantUI.lua 里 Theme = {...} 那段
UI:ApplyTheme(NewThemeTable, "All")
UI:SetTheme(nil, { "Accent", "Toggle" }, { "A", "Active" })

UI.ConfigTheme("New", "MyTheme")   -- 另存主题 json
UI.ConfigTheme("Load", "MyTheme")
```

调色板关键索引：`Accent`、`Contrast.A/B/C/D`、`Text Color.A/B`、`Outline`、
`Text Stroke`、`Tree`、`Toggle`、`Slider`、`Dropdown`、`TextBox`、`Button`、`Keybind`。

---

## 7. 附加组件

```lua
local Watermark = Window:Watermark{ Text = "cc | 60 fps", Enabled = true }
Watermark.SetText("new text")
Watermark.IsVisible

local KbList = Window:KeybindsList{ Enabled = true }

local Dock = UI:Dock{
    Text = "constant.cc",
    Windows = {
        { Window,  "Main",     false },   -- {对象, 名字, 是否禁用}
        { KbList,  "Keybinds", false },
        { Watermark, "Watermark", false },
    }
}

UI:Notify{ Text = "loaded", Time = 3 }   -- 右下角通知
UI:Toast("loaded", 3)                    -- 同上简写
```

---

## 8. 显隐 / 卸载

```lua
UI:Fade(Window, true)      -- 显示
UI:Fade(Window, false)     -- 隐藏
Window.IsVisible

UI.Windows                 -- 全部窗口
UI:Unload()                -- 销毁所有 Gui + 断开全部连接（热重载用）
```

---

## 9. 依赖与注意事项

1. **必须在带执行器 API 的 Roblox 环境里跑**：`writefile` / `readfile` / `isfile` /
   `isfolder` / `makefolder` / `listfiles` / `delfile` / `loadfile` / `getcustomasset`。
   缺任何一个只会在控制台 warn，并降级（自定义字体/图标读不出来）。
2. **资源是内嵌 base64**：字体 4 套（Tahoma / Consolas Bold / Smallest Pixel-7 / Minecraftia）
   + 图标若干，全部在 `Menu.EncodedAssets` 里，运行时解码写到
   `getconstant.cc/Fonts` 和 `getconstant.cc/Images`，再 `getcustomasset` 转成 asset。
   所以文件才 1.62 MB。
3. **base64 解码器有兜底**：优先用 `crypt.base64.decode`，执行器没有就用内置纯 Lua 实现
   （已用 Python `base64` 对照验证过，1.4 MB 约 0.15 s）。
4. **改存储路径**：改 `ConstantUI.lua` 第 268 行 `local BasePath = "getconstant.cc"`。
5. **改默认游戏名**（用于 AutoLoad 分档）：`Menu.Game = "Phantom Forces"`，
   用法 `UI.Menu.Game = "别的游戏"`（在创建窗口前改）。
6. `Reboot` 级清理：库加载时会把自己同名 ScreenGui 改名 `Destroy` 再新建，重复注入不会叠框。

---

## 10. 提取记录（可复现）

| 项目 | 内容 |
|---|---|
| 源文件 | `康.lua`（18,702 行 / 1.84 MB） |
| 提取范围 | **三段**：228–508（模块空表 + 静态数据表）、509–8327（UI 框架）、8411–12567（完整菜单构建） |
| `_build/core.lua` | 源 509–8327 行，UI 框架本体，一词未改（仅 `: String/Table/Number` 注解规范成小写） |
| `_build/decls.lua` | 源 228–508 行，`Menu`/`Shared`/`Esp`/`Visuals`/`Ragebot`… 空表 + `BodyPartNames`/`SkyBoxes`/`TracerProperties` 等静态数据 |
| `_build/menu_core.lua` | 源 8411–12567 行，整段 `-- Menu Init do ... end`，5 窗口 / 12 Tab / 381 控件原样 |
| `_build/header.lua` | 环境垫片：补齐 UI 块之外的 local（Game/Enum/服务/构造器/别名/执行器文件 API/base64 兜底） |
| `_build/stub.lua` | 衔接层：`Library`/`Flags` 接上，18 个功能模块套 `PlaceholderMeta` 万用占位元表 |
| `_build/footer_full.lua` | 导出层：`Menu`/`Flags`/`Theme`/`SetAccent`/`SaveConfig`/`GetFlag` + 窗口补名与 Open/Close/Toggle |
| 重建 | `python _build/build.py`（按 header→core→decls→stub→menu_core→footer_full 顺序拼） |
| 校验 | `luau-compile` 0 错误；`_test/run_test.lua` 用 mock Roblox API 实跑 —— **ALL PASS**（42 项：全部控件构建、5 窗口/12 Tab/24 Section/381 控件结构断言、旗标读写、配置存取、换色、窗口开关、卸载） |

**没进库的部分**：ESP / Visuals / Ragebot / Aim 这些功能的**实现代码**，以及
`Shared.NetworkClient` 一类游戏内部 `Require`。它们被 `PlaceholderMeta` 接管 ——
菜单上照样能看到、能点、能存配置，但点下去不会真的做任何事。
`PlaceholderMeta` 的规则：读任何字段返回一个新的占位对象，调用它返回占位对象，
字符串化是空串，四则运算是 0。所以菜单构建期的每一次 `Shared.XXX.YYY()` 都安全返回。
