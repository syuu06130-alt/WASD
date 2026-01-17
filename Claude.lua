-- Stealth WASD Controller Hub (Mobile Optimized)
-- 完全動作保証版 - スマホ対応WASD移動
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealthWASDHub"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- メインフレーム
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 180)
MainFrame.Position = UDim2.new(0.5, -140, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
MainFrame.ZIndex = 100
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- タイトルバー
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 101
TitleBar.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Text = "⚡ WASD Controller"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 102
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
MinimizeBtn.ZIndex = 102
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
CloseBtn.ZIndex = 102
CloseBtn.Parent = TitleBar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- スクロールコンテンツ
local ScrollingContent = Instance.new("ScrollingFrame")
ScrollingContent.Size = UDim2.new(1, -10, 1, -40)
ScrollingContent.Position = UDim2.new(0, 5, 0, 35)
ScrollingContent.BackgroundTransparency = 1
ScrollingContent.ScrollBarThickness = 4
ScrollingContent.CanvasSize = UDim2.new(0, 0, 0, 200)
ScrollingContent.ZIndex = 101
ScrollingContent.Parent = MainFrame

-- 状態管理
local minimizeLevel = 0
local wasdButtons = {}
local moveConnections = {}

-- 移動処理関数（新しいRoblox推奨方式）
local function startMoving(direction)
    if moveConnections[direction] then return end
    
    moveConnections[direction] = RunService.Heartbeat:Connect(function()
        if not character or not character.Parent then return end
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        local moveVector = Vector3.new()
        local camera = workspace.CurrentCamera
        local cameraCFrame = camera.CFrame
        
        if direction == "W" then
            moveVector = (cameraCFrame.LookVector * Vector3.new(1, 0, 1)).Unit
        elseif direction == "S" then
            moveVector = -(cameraCFrame.LookVector * Vector3.new(1, 0, 1)).Unit
        elseif direction == "A" then
            moveVector = -(cameraCFrame.RightVector * Vector3.new(1, 0, 1)).Unit
        elseif direction == "D" then
            moveVector = (cameraCFrame.RightVector * Vector3.new(1, 0, 1)).Unit
        end
        
        -- Humanoid:Move を使用（推奨方式）
        humanoid:Move(moveVector, false)
    end)
end

local function stopMoving(direction)
    if moveConnections[direction] then
        moveConnections[direction]:Disconnect()
        moveConnections[direction] = nil
    end
    
    -- 全ての移動が停止したらHumanoidをリセット
    local anyMoving = false
    for _, conn in pairs(moveConnections) do
        if conn then anyMoving = true break end
    end
    if not anyMoving then
        humanoid:Move(Vector3.new(0, 0, 0), false)
    end
end

-- WASDボタン生成関数（モバイル完全対応）
local function createWASDButton(name, color, direction, posX, posY)
    local btn = Instance.new("TextButton")
    local size = UserInputService.TouchEnabled and 70 or 60
    btn.Size = UDim2.new(0, size, 0, size)
    btn.Position = UDim2.new(posX, -size/2, posY, -size/2)
    btn.AnchorPoint = Vector2.new(0, 0)
    btn.BackgroundColor3 = color
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 28
    btn.BackgroundTransparency = 0.15
    btn.BorderSizePixel = 2
    btn.BorderColor3 = Color3.fromRGB(150, 150, 150)
    btn.ZIndex = 200
    btn.Parent = ScreenGui
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0.2, 0)
    btnCorner.Parent = btn
    
    -- タッチとマウス両方に対応
    btn.MouseButton1Down:Connect(function()
        startMoving(direction)
        btn.BackgroundTransparency = 0.4
    end)
    
    btn.MouseButton1Up:Connect(function()
        stopMoving(direction)
        btn.BackgroundTransparency = 0.15
    end)
    
    btn.TouchTap:Connect(function()
        startMoving(direction)
        wait(0.1)
        stopMoving(direction)
    end)
    
    -- タッチの長押し対応
    local touching = false
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            touching = true
            startMoving(direction)
            btn.BackgroundTransparency = 0.4
        end
    end)
    
    btn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            touching = false
            stopMoving(direction)
            btn.BackgroundTransparency = 0.15
        end
    end)
    
    return btn
end

-- WASDボタン生成
local WASDGenBtn = Instance.new("TextButton")
WASDGenBtn.Size = UDim2.new(0.9, 0, 0, 40)
WASDGenBtn.Position = UDim2.new(0.05, 0, 0, 10)
WASDGenBtn.Text = "📱 Generate WASD Buttons"
WASDGenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
WASDGenBtn.TextColor3 = Color3.fromRGB(180, 220, 255)
WASDGenBtn.Font = Enum.Font.GothamBold
WASDGenBtn.TextSize = 14
WASDGenBtn.ZIndex = 102
WASDGenBtn.Parent = ScrollingContent
local WASDCorner = Instance.new("UICorner")
WASDCorner.CornerRadius = UDim.new(0, 10)
WASDCorner.Parent = WASDGenBtn

WASDGenBtn.MouseButton1Click:Connect(function()
    for _, btn in pairs(wasdButtons) do
        btn:Destroy()
    end
    wasdButtons = {}
    
    -- 画面下部中央に配置（十字型）
    local centerX = 0.5
    local centerY = 0.85
    local spacing = 0.08
    
    -- W(上), A(左), S(下), D(右)
    wasdButtons.W = createWASDButton("W", Color3.fromRGB(70, 70, 150), "W", centerX, centerY - spacing)
    wasdButtons.A = createWASDButton("A", Color3.fromRGB(70, 150, 70), "A", centerX - spacing, centerY)
    wasdButtons.S = createWASDButton("S", Color3.fromRGB(150, 70, 70), "S", centerX, centerY + spacing)
    wasdButtons.D = createWASDButton("D", Color3.fromRGB(150, 150, 70), "D", centerX + spacing, centerY)
end)

-- WA高速クリック
local WAGenBtn = Instance.new("TextButton")
WAGenBtn.Size = UDim2.new(0.9, 0, 0, 40)
WAGenBtn.Position = UDim2.new(0.05, 0, 0, 60)
WAGenBtn.Text = "⚡ Generate WA Fast Click"
WAGenBtn.BackgroundColor3 = Color3.fromRGB(30, 50, 30)
WAGenBtn.TextColor3 = Color3.fromRGB(180, 255, 200)
WAGenBtn.Font = Enum.Font.GothamBold
WAGenBtn.TextSize = 14
WAGenBtn.ZIndex = 102
WAGenBtn.Parent = ScrollingContent
local WACorner = Instance.new("UICorner")
WACorner.CornerRadius = UDim.new(0, 10)
WACorner.Parent = WAGenBtn

WAGenBtn.MouseButton1Click:Connect(function()
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 70)
    btn.Position = UDim2.new(0.1, -35, 0.7, -35)
    btn.BackgroundColor3 = Color3.fromRGB(100, 60, 120)
    btn.Text = "WA\n⚡"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.BackgroundTransparency = 0.15
    btn.BorderSizePixel = 2
    btn.BorderColor3 = Color3.fromRGB(150, 100, 180)
    btn.ZIndex = 200
    btn.Parent = ScreenGui
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0.25, 0)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        spawn(function()
            local startTime = tick()
            while tick() - startTime < 0.5 do
                startMoving("W")
                wait(0.025)
                stopMoving("W")
                startMoving("A")
                wait(0.025)
                stopMoving("A")
            end
        end)
    end)
end)

-- SD高速クリック
local SDGenBtn = Instance.new("TextButton")
SDGenBtn.Size = UDim2.new(0.9, 0, 0, 40)
SDGenBtn.Position = UDim2.new(0.05, 0, 0, 110)
SDGenBtn.Text = "⚡ Generate SD Fast Click"
SDGenBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
SDGenBtn.TextColor3 = Color3.fromRGB(255, 180, 200)
SDGenBtn.Font = Enum.Font.GothamBold
SDGenBtn.TextSize = 14
SDGenBtn.ZIndex = 102
SDGenBtn.Parent = ScrollingContent
local SDCorner = Instance.new("UICorner")
SDCorner.CornerRadius = UDim.new(0, 10)
SDCorner.Parent = SDGenBtn

SDGenBtn.MouseButton1Click:Connect(function()
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 70)
    btn.Position = UDim2.new(0.9, -35, 0.7, -35)
    btn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
    btn.Text = "SD\n⚡"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.BackgroundTransparency = 0.15
    btn.BorderSizePixel = 2
    btn.BorderColor3 = Color3.fromRGB(100, 180, 100)
    btn.ZIndex = 200
    btn.Parent = ScreenGui
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0.25, 0)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        spawn(function()
            local startTime = tick()
            while tick() - startTime < 0.5 do
                startMoving("S")
                wait(0.025)
                stopMoving("S")
                startMoving("D")
                wait(0.025)
                stopMoving("D")
            end
        end)
    end)
end)

-- 最小化機能
MinimizeBtn.MouseButton1Click:Connect(function()
    minimizeLevel = (minimizeLevel + 1) % 3
    if minimizeLevel == 0 then
        MainFrame.Size = UDim2.new(0, 280, 0, 180)
        MinimizeBtn.Text = "−"
        ScrollingContent.Visible = true
    elseif minimizeLevel == 1 then
        MainFrame.Size = UDim2.new(0, 280, 0, 30)
        MinimizeBtn.Text = "□"
        ScrollingContent.Visible = false
    else
        MainFrame.Size = UDim2.new(0, 120, 0, 30)
        MinimizeBtn.Text = "⚡"
        ScrollingContent.Visible = false
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    for _, conn in pairs(moveConnections) do
        if conn then conn:Disconnect() end
    end
    ScreenGui:Destroy()
end)

-- UIドラッグ
local dragging = false
local dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
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
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

print("✅ WASD Controller Loaded - Mobile Optimized & Working!")
