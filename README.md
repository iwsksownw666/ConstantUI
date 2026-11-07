# ConstantUI

**Constant.cc 界面框架 · 独立提取版** — 从 `康.lua` 里剥出来的那套 Roblox 自绘菜单 UI，做成了可以直接 `loadstring` 的单文件库。

<p align="left">
  <img alt="luau" src="https://img.shields.io/badge/Luau-Roblox-00a2ff">
  <img alt="size" src="https://img.shields.io/badge/size-1.45%20MB-2ea043">
  <img alt="license" src="https://img.shields.io/badge/license-MIT-3da639">
  <img alt="status" src="https://img.shields.io/badge/tests-29%20passed-success">
</p>

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/iwsksownw666/ConstantUI/main/ConstantUI.lua"))()
```

> 只有 UI。ESP / Aimbot / Ragebot / Movement 之类全部丢掉了，剩下一套干净的菜单框架。

---

## 它长什么样

`Window → Tab → Section → Element` 四层，左侧栏一列 Section、右侧一列 Section，控件带描边、渐变、Tween 动画：

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/iwsksownw666/ConstantUI/main/ConstantUI.lua"))()

local Window = UI:Window({
    Name    = "constant.cc",
    Size    = Vector2.new(450, 600),
    Bind    = Enum.KeyCode.RightAlt,
    HasTabs = true,          -- 想要顶部标签栏就必须给 true
})

local Tab = Window:Tab({ Name = "Main", Opened = true })
local Section = Tab:Section({ Name = "General", Side = "Left", Size = 260 })

Section:Toggle({
    Name = "Enabled", Flag = "Enabled", Default = true,
    Callback = function(Value) print(Value) end
})
```

完整可跑示例见 [`example.lua`](example.lua)：三页菜单 + 配置页 + 水印 + 键位列表 + Dock。
只想快速上手就看 [`minimal.lua`](minimal.lua)（50 行骨架，粘上就跑）。

---

## 特性

| | |
|---|---|
| **控件** | Toggle / Slider / Dropdown(多选、限选数) / TextBox / CodeBox(行号+复制) / Button(可二次确认) / Label / List / Groupbox / ExpandableToggle / ExpandableLabel / Bar |
| **附加件** | 任意元素挂 `:Colorpicker{}`（含透明度、HSV 拾色）、`:Keybind{}`（Always On / Toggle / Held / Off Hold 四种模式） |
| **附加组件** | `Watermark`（动态文本）、`KeybindsList`（自动汇总所有键位）、`Dock`（左上角窗口切换条）、`Notify` / `Card` |
| **配置** | 一键存/读/删/列表、AutoLoad（按游戏名分档），纯 JSON |
| **主题** | 完整 Theme 表（Accent / Contrast A~D / Outline / 各控件配色），`SetAccent` 一句换色，主题可另存为 json |
| **资源** | 4 套字体 + 整套图标以 base64 内嵌，运行时解码写入 `getconstant.cc/` 并 `getcustomasset` 转资源，不依赖外链 |
| **热重载** | `UI:Unload()` 销毁全部 Gui 与连接，重复注入不会叠框 |

---

## API 速查

### 层级

```
Library (UI)
└── Window            UI:Window{...}
    ├── Tab           Window:Tab{...}          (需 HasTabs = true)
    │   ├── Section   Tab:Section{...}
    │   │   └── 控件 …
    │   ├── MultiSection  Tab:MultiSection{ Sections = {...} }   → 返回数组
    │   └── Bar       Tab:Bar{...}
    ├── Watermark     Window:Watermark{...}
    └── KeybindsList  Window:KeybindsList{...}
Dock / Notify / Card / Config / Unload 挂在 Library 上
```

### Window

| 参数 | 类型 | 默认 |
|---|---|---|
| `Name` | string | "Configurations" |
| `Size` | Vector2 / UDim2 | 450×600 |
| `Bind` | Enum.KeyCode | RightAlt |
| `Callback` | function(Visible) | – |
| `HasTabs` | bool | false |
| `Visible` | bool | false |
| `Disabled` | bool | false |

### Tab / Section

```lua
local Tab = Window:Tab{ Name = "Combat", Opened = true }

local Left  = Tab:Section{ Name = "Aimbot", Side = "Left",  Size = 300 }
local Right = Tab:Section{ Name = "Misc",   Side = "Right", Fill = true }

local Multi = Tab:MultiSection{ Name = "ESP", Sections = { "A", "B" }, Side = "Left" }
local Sub   = Multi[1]
```

### 控件

```lua
-- Toggle
local T = Section:Toggle{ Name = "Enabled", Flag = "Enabled", Default = true,
                          Callback = function(v) end }
T.Set(true); T.Get()

-- Slider
Section:Slider{ Name = "FOV", Min = 1, Max = 90, Default = 5,
                Decimals = 0.1, Prefix = "°", Flag = "FOV",
                Callback = function(v) end }

-- Dropdown（Default 传 table = 多选）
Section:Dropdown{ Name = "Mode", Options = { "A", "B" }, Default = "A", Flag = "Mode" }

-- TextBox
Section:TextBox{ Name = "Nick", Placeholder = "input", RequireSubmit = true, Flag = "Nick" }

-- Button（Confirm = true 需点两次）
Section:Button{ Name = "Apply", CallbackText = "Done!", Confirm = false,
                Callback = function() end }

-- Label / Keybind / Colorpicker
Section:Label{ Text = "Menu Key" }:Keybind{
    Default = Enum.KeyCode.RightAlt, Mode = "Toggle", Flag = "MenuKey",
    Changed = function(Value) end          -- Value = { "KeyCode"|"MouseButton1", "Name" }
}

T:Colorpicker{
    Color = Color3.fromRGB(60, 67, 120), Transparency = 0, Flag = "Col",
    Callback = function(Color, Transparency) end
}

-- 其它
Section:CodeBox{ Default = "-- lua", Size = 334, Flag = "Code" }
Section:List{ Options = { ["A"] = { "1", "Neutral" } }, Rows = { "Class", "Priority" } }
Section:ExpandableToggle{ Name = "Sub", Size = 208, Callback = fn }
Section:Groupbox{ Groups = { { "A", Image, UDim2.new(0, 8, 0, 8) } } }
```

所有控件通用参数：`Flag`、`Category`、`Hidden`、`Unsafe` / `Indev` / `Blocked`（角标）。

> Toggle / Slider / Dropdown / TextBox / Button / Label 都带 `Elements` 元表，可挂 `:Keybind` / `:Colorpicker`；
> **Keybind / Colorpicker 自身不能再链式调用**，要两个就先取变量。

### Flags 与配置

```lua
UI.Flags["Enabled"]:Get()             -- 扁平 flag
UI.Flags["Category"]["Name"]:Get()    -- 分组 flag
UI:GetFlag("Enabled");  UI:SetFlag("Enabled", true)

UI:SaveConfig("legit")     -- getconstant.cc/Configs/legit.cfg
UI:LoadConfig("legit")
UI:DeleteConfig("legit")
UI:ListConfigs()
UI:SetAutoload("legit")    -- 下次进游戏自动载入
UI.Config("Get")           -- 原始 JSON
```

### 主题

```lua
UI:SetAccent(Color3.fromRGB(200, 60, 60))     -- 换强调色
UI:ApplyTheme(NewThemeTable, "All")           -- 整套换肤
UI.ConfigTheme("New", "MyTheme")              -- 另存主题
```

### 显隐 / 卸载 / 通知

```lua
UI:Fade(Window, true)  /  UI:Fade(Window, false)
UI:Notify{ Text = "loaded", Time = 3 }
UI:Unload()
```

---

## 依赖

需要在带执行器 API 的 Roblox 环境运行：

```
writefile  readfile  isfile  isfolder  makefolder  delfile  listfiles  loadfile  getcustomasset
```

缺任何一个只会在控制台 `warn` 并降级（自定义字体/图标读不出来，其余照常）。
`crypt.base64.decode` 优先使用；没有则走内置纯 Lua 解码（已对照 Python `base64` 验证，1.4 MB ≈ 0.15 s）。

改存储路径：`ConstantUI.lua` 第 268 行 `local BasePath = "getconstant.cc"`。

---

## 这个库是怎么来的

| 项目 | 内容 |
|---|---|
| 源文件 | `康.lua`（18702 行 / 1.84 MB，Constant.cc by **axure**） |
| UI 范围 | 源文件 **509 – 8327 行**（`-- Menu Library` → `Menu.Init(Library)`） |
| 处理 | 该段一字未改，只把 `: String/Table/Number` 类型注解规范成小写 |
| 垫片 | 补齐原脚本定义在 UI 块之外的全部 local：服务、`Color3/UDim2/Vector2` 构造器、`string/table/math` 别名、执行器文件 API、base64 |
| 导出层 | 把 `Menu.*` 能力挂到 `Library`，附加 `SetAccent` / `SaveConfig` / `GetFlag` 等糖，末尾 `getgenv().ConstantUI = Library` |
| 验证 | `luau-compile` 通过；用 mock 版 `game / Instance / Enum / Color3 / Signal` 在 luau CLI 里实跑 **29 项全通过**（全部控件构建、Flags 读写、配置存取、换色、卸载） |

所有致谢归原作者 **axure**（Constant.cc）。本仓库只做界面框架的提取与独立化。

## License

MIT — 见 [LICENSE](LICENSE)。
