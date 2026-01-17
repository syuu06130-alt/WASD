-- Stealth WASD Controller Hub (Compact Design)
-- WASD長押し移動 + WA/SD高速クリック機能
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealthWASDHub"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- メインフレーム（コンパクト）
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 180)
MainFrame.Position = UDim2.new(0.5, -140, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- タイトルバー
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
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
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- 最小化ボタン
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -60, 0, 3)
MinimizeBtn.Text = "−"
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeBtn.TextColor3 = Color3.new(1,1,1)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
MinimizeBtn.Parent = TitleBar
local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 8)
MinimizeCorner.Parent = MinimizeBtn

-- 閉じるボタン
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 3)
CloseBtn.Text = "×"
CloseBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TitleBar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- スクロール可能コンテンツエリア
local ScrollingContent = Instance.new("ScrollingFrame")
ScrollingContent.Size = UDim2.new(1, -10, 1, -40)
ScrollingContent.Position = UDim2.new(0, 5, 0, 35)
ScrollingContent.BackgroundTransparency = 1
ScrollingContent.ScrollBarThickness = 4
ScrollingContent.CanvasSize = UDim2.new(0, 0, 0, 200)
ScrollingContent.Parent = MainFrame

-- 状態
local minimizeLevel = 0 -- 0:フル, 1:中, 2:超小
local wasdButtons = {}

-- WASDボタン生成関数（長押し対応）
local function createWASDButton(name, color, keyCode, posX, posY)
    local btn = Instance.new("TextButton")
    btn.Size = UserInputService.TouchEnabled and UDim2.new(0, 65, 0, 65) or UDim2.new(0, 55, 0, 55)
    btn.Position = UDim2.new(posX, 0, posY, 0)
    btn.BackgroundColor3 = color
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 24
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 2
    btn.BorderColor3 = Color3.fromRGB(120, 120, 120)
    btn.Parent = ScreenGui
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0.2, 0)
    btnCorner.Parent = btn

    local pressing = false
    local connection

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            pressing = true
            -- 長押し開始: キーを押し続ける
            connection = RunService.Heartbeat:Connect(function()
                if pressing then
                    VirtualUser:SendKeyEvent(true, keyCode, false, game)
                end
            end)
        end
    end)

    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            pressing = false
            VirtualUser:SendKeyEvent(false, keyCode, false, game)
            if connection then
                connection:Disconnect()
            end
        end
    end)

    return btn
end

-- WASDボタン生成ボタン
local WASDGenBtn = Instance.new("TextButton")
WASDGenBtn.Size = UDim2.new(0.9, 0, 0, 40)
WASDGenBtn.Position = UDim2.new(0.05, 0, 0, 10)
WASDGenBtn.Text = "📱 Generate WASD Buttons"
WASDGenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
WASDGenBtn.TextColor3 = Color3.fromRGB(180, 220, 255)
WASDGenBtn.Font = Enum.Font.GothamBold
WASDGenBtn.TextSize = 14
WASDGenBtn.Parent = ScrollingContent
local WASDCorner = Instance.new("UICorner")
WASDCorner.CornerRadius = UDim.new(0, 10)
WASDCorner.Parent = WASDGenBtn

WASDGenBtn.MouseButton1Click:Connect(function()
    -- 既存のボタンを削除
    for _, btn in pairs(wasdButtons) do
        btn:Destroy()
    end
    wasdButtons = {}

    -- 画面中央下部に配置（スマホ最適化）
    local centerX = 0.5
    local bottomY = 0.88
    local offset = UserInputService.TouchEnabled and 0.09 or 0.075

    -- WASD配置: W上, S下, A左, D右
    wasdButtons.W = createWASDButton("W", Color3.fromRGB(50, 50, 100), Enum.KeyCode.W, centerX, bottomY - offset)
    wasdButtons.S = createWASDButton("S", Color3.fromRGB(100, 50, 50), Enum.KeyCode.S, centerX, bottomY + offset)
    wasdButtons.A = createWASDButton("A", Color3.fromRGB(50, 100, 50), Enum.KeyCode.A, centerX - offset, bottomY)
    wasdButtons.D = createWASDButton("D", Color3.fromRGB(100, 100, 50), Enum.KeyCode.D, centerX + offset, bottomY)
end)

-- WA高速クリックボタン生成
local WAGenBtn = Instance.new("TextButton")
WAGenBtn.Size = UDim2.new(0.9, 0, 0, 40)
WAGenBtn.Position = UDim2.new(0.05, 0, 0, 60)
WAGenBtn.Text = "⚡ Generate WA Fast Click"
WAGenBtn.BackgroundColor3 = Color3.fromRGB(30, 50, 30)
WAGenBtn.TextColor3 = Color3.fromRGB(180, 255, 200)
WAGenBtn.Font = Enum.Font.GothamBold
WAGenBtn.TextSize = 14
WAGenBtn.Parent = ScrollingContent
local WACorner = Instance.new("UICorner")
WACorner.CornerRadius = UDim.new(0, 10)
WACorner.Parent = WAGenBtn

WAGenBtn.MouseButton1Click:Connect(function()
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 65, 0, 65)
    btn.Position = UDim2.new(0.05, 0, 0.75, 0)
    btn.BackgroundColor3 = Color3.fromRGB(80, 40, 80)
    btn.Text = "WA\n⚡"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 2
    btn.BorderColor3 = Color3.fromRGB(120, 80, 120)
    btn.Parent = ScreenGui
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0.25, 0)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        -- 0.5秒間 WA 交互高速クリック
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
            wait(0.01)
            VirtualUser:SendKeyEvent(false, keys[index], false, game)
            index = index % 2 + 1
        end)
    end)
end)

-- SD高速クリックボタン生成
local SDGenBtn = Instance.new("TextButton")
SDGenBtn.Size = UDim2.new(0.9, 0, 0, 40)
SDGenBtn.Position = UDim2.new(0.05, 0, 0, 110)
SDGenBtn.Text = "⚡ Generate SD Fast Click"
SDGenBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
SDGenBtn.TextColor3 = Color3.fromRGB(255, 180, 200)
SDGenBtn.Font = Enum.Font.GothamBold
SDGenBtn.TextSize = 14
SDGenBtn.Parent = ScrollingContent
local SDCorner = Instance.new("UICorner")
SDCorner.CornerRadius = UDim.new(0, 10)
SDCorner.Parent = SDGenBtn

SDGenBtn.MouseButton1Click:Connect(function()
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 65, 0, 65)
    btn.Position = UDim2.new(0.95, -65, 0.75, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
    btn.Text = "SD\n⚡"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 2
    btn.BorderColor3 = Color3.fromRGB(80, 120, 80)
    btn.Parent = ScreenGui
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0.25, 0)
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
            wait(0.01)
            VirtualUser:SendKeyEvent(false, keys[index], false, game)
            index = index % 2 + 1
        end)
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

print("✅ Stealth WASD Controller Hub Loaded - Compact & Mobile Optimized")
