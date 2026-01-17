-- Stealth WASD Controller Hub (Fixed Edition v2)
-- WS/AD切り替え、0.1秒間隔、固定機能付き
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- 設定
local config = {
    accentColor = Color3.fromRGB(0, 170, 255),
    bgColor = Color3.fromRGB(15, 15, 15),
    buttonColor = Color3.fromRGB(35, 35, 45),
    buttonHoverColor = Color3.fromRGB(50, 50, 65),
    textColor = Color3.fromRGB(255, 255, 255)
}

-- メインGUI作成
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealthWASDHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- CoreGuiに配置（保護）
pcall(function()
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
    else
        ScreenGui.Parent = game:GetService("CoreGui")
    end
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- メインフレーム
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 220)
MainFrame.Position = UDim2.new(0.5, -140, 0.1, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0)
MainFrame.BackgroundColor3 = config.bgColor
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = config.accentColor
MainStroke.Thickness = 2
MainStroke.Transparency = 0.7
MainStroke.Parent = MainFrame

-- タイトルバー
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 33)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 12)
TitleFix.Position = UDim2.new(0, 0, 1, -12)
TitleFix.BackgroundColor3 = Color3.fromRGB(25, 25, 33)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -70, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ WASD Controller"
TitleLabel.TextColor3 = config.accentColor
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextStrokeTransparency = 0.5
TitleLabel.Parent = TitleBar

-- コントロールボタン作成関数
local function createControlButton(text, position, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 25, 0, 25)
    btn.Position = position
    btn.AnchorPoint = Vector2.new(1, 0.5)
    btn.BackgroundColor3 = config.buttonColor
    btn.Text = text
    btn.TextColor3 = config.textColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = TitleBar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = config.buttonHoverColor}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = config.buttonColor}):Play()
    end)
    
    return btn
end

local minimized = false
local ContentFrame

-- 最小化ボタン
createControlButton("−", UDim2.new(1, -32, 0.5, 0), function()
    minimized = not minimized
    if minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0, 280, 0, 30)
        }):Play()
        if ContentFrame then ContentFrame.Visible = false end
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0, 280, 0, 220)
        }):Play()
        if ContentFrame then ContentFrame.Visible = true end
    end
end)

-- 閉じるボタン
createControlButton("×", UDim2.new(1, -5, 0.5, 0), function()
    ScreenGui:Destroy()
end)

-- コンテンツフレーム（スクロール可能）
ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -10, 1, -40)
ContentFrame.Position = UDim2.new(0, 5, 0, 35)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ScrollBarThickness = 4
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 450)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

-- 状態管理
local wasdButtons = {}
local fastClickButtons = {}
local isDraggingLocked = false

-- ドラッグ機能追加関数
local function makeDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if isDraggingLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging and not isDraggingLocked then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- WASDボタン作成関数（サイズ縮小 + ドラッグ可能）
local function createWASDButton(name, color, keyCode, posX, posY)
    local size = UserInputService.TouchEnabled and 55 or 50  -- 小さくした
    
    local btn = Instance.new("TextButton")
    btn.Name = "WASD_" .. name
    btn.Size = UDim2.new(0, size, 0, size)
    btn.Position = UDim2.new(posX, -size/2, posY, -size/2)
    btn.AnchorPoint = Vector2.new(0, 0)
    btn.BackgroundColor3 = color
    btn.Text = name
    btn.TextColor3 = config.textColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 24
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.TextStrokeTransparency = 0.5
    btn.Parent = ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(120, 120, 120)
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = btn
    
    local isPressing = false
    
    -- ホバーエフェクト
    btn.MouseEnter:Connect(function()
        if not isPressing then
            TweenService:Create(btn, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(
                    math.min(color.R * 255 * 1.3, 255),
                    math.min(color.G * 255 * 1.3, 255),
                    math.min(color.B * 255 * 1.3, 255)
                )
            }):Play()
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if not isPressing then
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = color}):Play()
        end
    end)
    
    -- マウスダウン（長押し開始）
    btn.MouseButton1Down:Connect(function()
        isPressing = true
        TweenService:Create(btn, TweenInfo.new(0.05), {
            Size = UDim2.new(0, size * 0.95, 0, size * 0.95),
            BackgroundColor3 = config.accentColor
        }):Play()
        
        pcall(function()
            keypress(keyCode)
        end)
    end)
    
    -- マウスアップ（長押し終了）
    btn.MouseButton1Up:Connect(function()
        if isPressing then
            isPressing = false
            TweenService:Create(btn, TweenInfo.new(0.05), {
                Size = UDim2.new(0, size, 0, size),
                BackgroundColor3 = color
            }):Play()
            
            pcall(function()
                keyrelease(keyCode)
            end)
        end
    end)
    
    -- 画面外に出た時も離す
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isPressing then
                isPressing = false
                TweenService:Create(btn, TweenInfo.new(0.05), {
                    Size = UDim2.new(0, size, 0, size),
                    BackgroundColor3 = color
                }):Play()
                pcall(function()
                    keyrelease(keyCode)
                end)
            end
        end
    end)
    
    -- ドラッグ可能にする
    makeDraggable(btn)
    
    return btn
end

-- 固定/解除ボタン
local LockBtn = Instance.new("TextButton")
LockBtn.Size = UDim2.new(0.9, 0, 0, 40)
LockBtn.Position = UDim2.new(0.05, 0, 0, 10)
LockBtn.Text = "🔓 Unlock All Buttons"
LockBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 30)
LockBtn.TextColor3 = Color3.fromRGB(255, 255, 150)
LockBtn.Font = Enum.Font.GothamBold
LockBtn.TextSize = 14
LockBtn.BorderSizePixel = 0
LockBtn.AutoButtonColor = false
LockBtn.Parent = ContentFrame

local LockCorner = Instance.new("UICorner")
LockCorner.CornerRadius = UDim.new(0, 10)
LockCorner.Parent = LockBtn

LockBtn.MouseButton1Click:Connect(function()
    isDraggingLocked = not isDraggingLocked
    
    if isDraggingLocked then
        LockBtn.Text = "🔒 Lock All Buttons"
        LockBtn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
        LockBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
    else
        LockBtn.Text = "🔓 Unlock All Buttons"
        LockBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 30)
        LockBtn.TextColor3 = Color3.fromRGB(255, 255, 150)
    end
end)

-- WASDボタン生成
local WASDGenBtn = Instance.new("TextButton")
WASDGenBtn.Size = UDim2.new(0.9, 0, 0, 40)
WASDGenBtn.Position = UDim2.new(0.05, 0, 0, 60)
WASDGenBtn.Text = "📱 Generate WASD Buttons"
WASDGenBtn.BackgroundColor3 = config.buttonColor
WASDGenBtn.TextColor3 = config.accentColor
WASDGenBtn.Font = Enum.Font.GothamBold
WASDGenBtn.TextSize = 14
WASDGenBtn.BorderSizePixel = 0
WASDGenBtn.AutoButtonColor = false
WASDGenBtn.Parent = ContentFrame

local WASDCorner = Instance.new("UICorner")
WASDCorner.CornerRadius = UDim.new(0, 10)
WASDCorner.Parent = WASDGenBtn

WASDGenBtn.MouseButton1Click:Connect(function()
    -- 既存削除
    for _, btn in pairs(wasdButtons) do
        btn:Destroy()
    end
    wasdButtons = {}
    
    -- 画面下部中央に十字配置
    local centerX = 0.5
    local centerY = 0.85
    local spacing = 0.07  -- 少し詰めた
    
    wasdButtons.W = createWASDButton("W", Color3.fromRGB(70, 70, 150), Enum.KeyCode.W, centerX, centerY - spacing)
    wasdButtons.A = createWASDButton("A", Color3.fromRGB(70, 150, 70), Enum.KeyCode.A, centerX - spacing, centerY)
    wasdButtons.S = createWASDButton("S", Color3.fromRGB(150, 70, 70), Enum.KeyCode.S, centerX, centerY + spacing)
    wasdButtons.D = createWASDButton("D", Color3.fromRGB(150, 150, 70), Enum.KeyCode.D, centerX + spacing, centerY)
end)

-- WS高速クリック（0.1秒ずつトグル式）
local WSGenBtn = Instance.new("TextButton")
WSGenBtn.Size = UDim2.new(0.9, 0, 0, 40)
WSGenBtn.Position = UDim2.new(0.05, 0, 0, 110)
WSGenBtn.Text = "⚡ Generate WS Fast Click"
WSGenBtn.BackgroundColor3 = config.buttonColor
WSGenBtn.TextColor3 = Color3.fromRGB(180, 255, 200)
WSGenBtn.Font = Enum.Font.GothamBold
WSGenBtn.TextSize = 14
WSGenBtn.BorderSizePixel = 0
WSGenBtn.AutoButtonColor = false
WSGenBtn.Parent = ContentFrame

local WSCorner = Instance.new("UICorner")
WSCorner.CornerRadius = UDim.new(0, 10)
WSCorner.Parent = WSGenBtn

WSGenBtn.MouseButton1Click:Connect(function()
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 70)
    btn.Position = UDim2.new(0.1, -35, 0.7, -35)
    btn.BackgroundColor3 = Color3.fromRGB(100, 60, 120)
    btn.Text = "WS\n⚡"
    btn.TextColor3 = config.textColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.TextStrokeTransparency = 0.5
    btn.Parent = ScreenGui
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0.25, 0)
    btnCorner.Parent = btn
    
    local isRunning = false
    
    btn.MouseButton1Click:Connect(function()
        isRunning = not isRunning
        
        if isRunning then
            btn.BackgroundColor3 = config.accentColor
            btn.Text = "WS\n■"
            
            spawn(function()
                while isRunning do
                    -- W を 0.1秒
                    pcall(function() keypress(Enum.KeyCode.W) end)
                    wait(0.1)
                    pcall(function() keyrelease(Enum.KeyCode.W) end)
                    
                    if not isRunning then break end
                    
                    -- S を 0.1秒
                    pcall(function() keypress(Enum.KeyCode.S) end)
                    wait(0.1)
                    pcall(function() keyrelease(Enum.KeyCode.S) end)
                end
            end)
        else
            btn.BackgroundColor3 = Color3.fromRGB(100, 60, 120)
            btn.Text = "WS\n⚡"
            pcall(function() keyrelease(Enum.KeyCode.W) end)
            pcall(function() keyrelease(Enum.KeyCode.S) end)
        end
    end)
    
    makeDraggable(btn)
    table.insert(fastClickButtons, btn)
end)

-- AD高速クリック（0.1秒ずつトグル式）
local ADGenBtn = Instance.new("TextButton")
ADGenBtn.Size = UDim2.new(0.9, 0, 0, 40)
ADGenBtn.Position = UDim2.new(0.05, 0, 0, 160)
ADGenBtn.Text = "⚡ Generate AD Fast Click"
ADGenBtn.BackgroundColor3 = config.buttonColor
ADGenBtn.TextColor3 = Color3.fromRGB(255, 180, 200)
ADGenBtn.Font = Enum.Font.GothamBold
ADGenBtn.TextSize = 14
ADGenBtn.BorderSizePixel = 0
ADGenBtn.AutoButtonColor = false
ADGenBtn.Parent = ContentFrame

local ADCorner = Instance.new("UICorner")
ADCorner.CornerRadius = UDim.new(0, 10)
ADCorner.Parent = ADGenBtn

ADGenBtn.MouseButton1Click:Connect(function()
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 70)
    btn.Position = UDim2.new(0.9, -35, 0.7, -35)
    btn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
    btn.Text = "AD\n⚡"
    btn.TextColor3 = config.textColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.TextStrokeTransparency = 0.5
    btn.Parent = ScreenGui
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0.25, 0)
    btnCorner.Parent = btn
    
    local isRunning = false
    
    btn.MouseButton1Click:Connect(function()
        isRunning = not isRunning
        
        if isRunning then
            btn.BackgroundColor3 = config.accentColor
            btn.Text = "AD\n■"
            
            spawn(function()
                while isRunning do
                    -- A を 0.1秒
                    pcall(function() keypress(Enum.KeyCode.A) end)
                    wait(0.1)
                    pcall(function() keyrelease(Enum.KeyCode.A) end)
                    
                    if not isRunning then break end
                    
                    -- D を 0.1秒
                    pcall(function() keypress(Enum.KeyCode.D) end)
                    wait(0.1)
                    pcall(function() keyrelease(Enum.KeyCode.D) end)
                end
            end)
        else
            btn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
            btn.Text = "AD\n⚡"
            pcall(function() keyrelease(Enum.KeyCode.A) end)
            pcall(function() keyrelease(Enum.KeyCode.D) end)
        end
    end)
    
    makeDraggable(btn)
    table.insert(fastClickButtons, btn)
end)

-- UIドラッグ機能
local dragging = false
local dragInput, mousePos, framePos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        
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
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)

print("✓ Stealth WASD Controller loaded!")
print("✓ WS/AD fast click (0.1s each)")
print("✓ Lock/Unlock button dragging feature added")
