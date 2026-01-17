-- Grok's Stealth WASD Controller Hub (Cool Black Design)
-- 超コンパクトUI, WASD長押し移動, WA/SD高速クリック (0.5秒交互高速), スクロール可能
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealthWASDHub"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- メインフレーム（クールな黒デザイン, コンパクト）
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 180)  -- コンパクト化
MainFrame.Position = UDim2.new(0.5, -140, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
MainFrame.Parent = ScreenGui

-- 角を丸く
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- タイトルバー
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)  -- コンパクト
TitleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Text = "⚡ Stealth WASD"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16  -- コンパクト
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- 最小化ボタン（3段階）
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)  -- コンパクト
MinimizeBtn.Position = UDim2.new(1, -60, 0, 3)
MinimizeBtn.Text = "−"
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeBtn.TextColor3 = Color3.new(1,1,1)
MinimizeBtn.Parent = TitleBar
local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 8)
MinimizeCorner.Parent = MinimizeBtn

-- 閉じるボタン
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)  -- コンパクト
CloseBtn.Position = UDim2.new(1, -30, 0, 3)
CloseBtn.Text = "×"
CloseBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Parent = TitleBar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- コンテンツエリア（スクロール可能）
local ScrollingContent = Instance.new("ScrollingFrame")
ScrollingContent.Size = UDim2.new(1, -10, 1, -40)  -- コンパクト調整
ScrollingContent.Position = UDim2.new(0, 5, 0, 35)
ScrollingContent.BackgroundTransparency = 1
ScrollingContent.ScrollBarThickness = 4
ScrollingContent.CanvasSize = UDim2.new(0, 0, 0, 300)  -- スクロール量調整
ScrollingContent.Parent = MainFrame

-- 状態
local minimizeLevel = 0 -- 0:フル, 1:中, 2:超小

-- 小型フロートボタン生成関数（WASD用）
local function createFloatButton(name, color, keyCode, isMobile)
    local btn = Instance.new("TextButton")
    btn.Size = UserInputService.TouchEnabled and UDim2.new(0, 60, 0, 60) or UDim2.new(0, 50, 0, 50)  -- スマホ最適
    btn.BackgroundColor3 = color
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 24
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(100, 100, 100)
    btn.Parent = ScreenGui
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0) -- 円形
    btnCorner.Parent = btn

    local pressing = false
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            pressing = true
            VirtualUser:SendKeyEvent(true, keyCode, false, game)
            if isMobile then
                VirtualUser:CaptureController()
            end
        end
    end)
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            pressing = false
            VirtualUser:SendKeyEvent(false, keyCode, false, game)
        end
    end)

    -- ドラッグ可能
    local dragging = false
    local dragStart, startPos
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
        end
    end)
    btn.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return btn
end

-- WASDボタン生成ボタン
local WASDGenBtn = Instance.new("TextButton")
WASDGenBtn.Size = UDim2.new(0.9, 0, 0, 40)  -- コンパクト
WASDGenBtn.Position = UDim2.new(0.05, 0, 0, 10)
WASDGenBtn.Text = "Generate WASD Buttons"
WASDGenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
WASDGenBtn.TextColor3 = Color3.fromRGB(180, 220, 255)
WASDGenBtn.Font = Enum.Font.Gotham
WASDGenBtn.Parent = ScrollingContent
local WASDCorner = Instance.new("UICorner")
WASDCorner.CornerRadius = UDim.new(0, 10)
WASDCorner.Parent = WASDGenBtn

WASDGenBtn.MouseButton1Click:Connect(function()
    -- 画面中央下部に配置 (スマホ最適)
    local centerX = 0.5
    local bottomY = 0.95
    local offset = UserInputService.TouchEnabled and 70 or 60

    -- W (上)
    local wBtn = createFloatButton("W", Color3.fromRGB(50, 50, 100), Enum.KeyCode.W, false)
    wBtn.Position = UDim2.new(centerX, -offset/2, bottomY, -offset * 1.5)

    -- A (左)
    local aBtn = createFloatButton("A", Color3.fromRGB(50, 100, 50), Enum.KeyCode.A, false)
    aBtn.Position = UDim2.new(centerX, -offset * 1.5, bottomY, -offset/2)

    -- S (下)
    local sBtn = createFloatButton("S", Color3.fromRGB(100, 50, 50), Enum.KeyCode.S, false)
    sBtn.Position = UDim2.new(centerX, -offset/2, bottomY, offset/2)

    -- D (右)
    local dBtn = createFloatButton("D", Color3.fromRGB(100, 100, 50), Enum.KeyCode.D, false)
    dBtn.Position = UDim2.new(centerX, offset/2, bottomY, -offset/2)
end)

-- WA高速クリック生成ボタン
local WAGenBtn = Instance.new("TextButton")
WAGenBtn.Size = UDim2.new(0.9, 0, 0, 40)
WAGenBtn.Position = UDim2.new(0.05, 0, 0, 60)
WAGenBtn.Text = "Generate WA Fast Click"
WAGenBtn.BackgroundColor3 = Color3.fromRGB(30, 50, 30)
WAGenBtn.TextColor3 = Color3.fromRGB(180, 255, 200)
WAGenBtn.Font = Enum.Font.Gotham
WAGenBtn.Parent = ScrollingContent
local WACorner = Instance.new("UICorner")
WACorner.CornerRadius = UDim.new(0, 10)
WACorner.Parent = WAGenBtn

WAGenBtn.MouseButton1Click:Connect(function()
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = UDim2.new(0.02, 0, 0.8, -30)  -- 左下寄り
    btn.BackgroundColor3 = Color3.fromRGB(80, 40, 80)
    btn.Text = "WA"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(100, 100, 100)
    btn.Parent = ScreenGui
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        -- 0.5秒間 WA 交互高速クリック (高速ループ)
        local startTime = tick()
        local keys = {Enum.KeyCode.W, Enum.KeyCode.A}
        local index = 1
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if tick() - startTime >= 0.5 then
                connection:Disconnect()
                return
            end
            VirtualUser:SendKeyEvent(true, keys[index], false, game)
            wait(0.01)  -- 高速交互
            VirtualUser:SendKeyEvent(false, keys[index], false, game)
            index = index % 2 + 1
        end)
    end)

    -- ドラッグ機能 (共通)
    local dragging = false
    local dragStart, startPos
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
        end
    end)
    btn.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end)

-- SD高速クリック生成ボタン
local SDGenBtn = Instance.new("TextButton")
SDGenBtn.Size = UDim2.new(0.9, 0, 0, 40)
SDGenBtn.Position = UDim2.new(0.05, 0, 0, 110)
SDGenBtn.Text = "Generate SD Fast Click"
SDGenBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
SDGenBtn.TextColor3 = Color3.fromRGB(255, 180, 200)
SDGenBtn.Font = Enum.Font.Gotham
SDGenBtn.Parent = ScrollingContent
local SDCorner = Instance.new("UICorner")
SDCorner.CornerRadius = UDim.new(0, 10)
SDCorner.Parent = SDGenBtn

SDGenBtn.MouseButton1Click:Connect(function()
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 60)
    btn.Position = UDim2.new(0.98, -60, 0.8, -30)  -- 右下寄り
    btn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
    btn.Text = "SD"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(100, 100, 100)
    btn.Parent = ScreenGui
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        -- 0.5秒間 SD 交互高速クリック
        local startTime = tick()
        local keys = {Enum.KeyCode.S, Enum.KeyCode.D}
        local index = 1
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if tick() - startTime >= 0.5 then
                connection:Disconnect()
                return
            end
            VirtualUser:SendKeyEvent(true, keys[index], false, game)
            wait(0.01)  -- 高速交互
            VirtualUser:SendKeyEvent(false, keys[index], false, game)
            index = index % 2 + 1
        end)
    end)

    -- ドラッグ機能 (共通)
    local dragging = false
    local dragStart, startPos
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
        end
    end)
    btn.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end)

-- 3段階最小化
MinimizeBtn.MouseButton1Click:Connect(function()
    minimizeLevel = (minimizeLevel + 1) % 3
    if minimizeLevel == 0 then -- フル
        MainFrame.Size = UDim2.new(0, 280, 0, 180)
        MinimizeBtn.Text = "−"
        ScrollingContent.Visible = true
    elseif minimizeLevel == 1 then -- 中
        MainFrame.Size = UDim2.new(0, 280, 0, 30)
        MinimizeBtn.Text = "□"
        ScrollingContent.Visible = false
    else -- 超小
        MainFrame.Size = UDim2.new(0, 120, 0, 30)
        MinimizeBtn.Text = "⚡"
        ScrollingContent.Visible = false
    end
end)

-- 閉じる
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- メインUIドラッグ
local dragging = false
local dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

print("Stealth WASD Controller Hub Loaded - Compact & Mobile Optimized ⚡")
