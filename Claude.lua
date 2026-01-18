-- Stealth WASD Controller Hub (Complete Edition)
-- 全PC操作機能搭載版
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
MainFrame.Size = UDim2.new(0, 320, 0, 250)
MainFrame.Position = UDim2.new(0.5, -160, 0.1, 0)
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
TitleBar.Size = UDim2.new(1, 0, 0, 35)
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
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ WASD Controller Pro"
TitleLabel.TextColor3 = config.accentColor
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.TextStrokeTransparency = 0.5
TitleLabel.Parent = TitleBar

-- コントロールボタン作成関数
local function createControlButton(text, position, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 28, 0, 28)
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
createControlButton("−", UDim2.new(1, -36, 0.5, 0), function()
    minimized = not minimized
    if minimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0, 320, 0, 35)
        }):Play()
        if ContentFrame then ContentFrame.Visible = false end
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0, 320, 0, 250)
        }):Play()
        if ContentFrame then ContentFrame.Visible = true end
    end
end)

-- 閉じるボタン
createControlButton("×", UDim2.new(1, -6, 0.5, 0), function()
    ScreenGui:Destroy()
end)

-- コンテンツフレーム（スクロール可能）
ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -12, 1, -45)
ContentFrame.Position = UDim2.new(0, 6, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ScrollBarThickness = 5
ContentFrame.ScrollBarImageColor3 = config.accentColor
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 1050)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

-- 状態管理
local wasdButtons = {}
local isDraggingLocked = false

-- ドラッグ機能
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

-- 汎用ボタン生成関数
local function createGeneratorButton(text, yPos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.92, 0, 0, 38)
    btn.Position = UDim2.new(0.04, 0, 0, yPos)
    btn.Text = text
    btn.BackgroundColor3 = config.buttonColor
    btn.TextColor3 = color
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = ContentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = config.buttonHoverColor}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = config.buttonColor}):Play()
    end)
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- キーボタン生成関数
local function createKeyButton(name, color, keyCode, posX, posY, width, height)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, width or 50, 0, height or 50)
    btn.Position = UDim2.new(posX, -(width or 50)/2, posY, -(height or 50)/2)
    btn.BackgroundColor3 = color
    btn.Text = name
    btn.TextColor3 = config.textColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = height and height > 50 and 16 or 20
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.TextStrokeTransparency = 0.5
    btn.Parent = ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = btn
    
    local isPressing = false
    
    btn.MouseButton1Down:Connect(function()
        isPressing = true
        btn.BackgroundColor3 = config.accentColor
        pcall(function() keypress(keyCode) end)
    end)
    
    btn.MouseButton1Up:Connect(function()
        if isPressing then
            isPressing = false
            btn.BackgroundColor3 = color
            pcall(function() keyrelease(keyCode) end)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isPressing then
                isPressing = false
                btn.BackgroundColor3 = color
                pcall(function() keyrelease(keyCode) end)
            end
        end
    end)
    
    makeDraggable(btn)
    return btn
end

-- 🔒 固定/解除ボタン
createGeneratorButton("🔓 Unlock All Buttons", 8, Color3.fromRGB(255, 255, 150), function()
    isDraggingLocked = not isDraggingLocked
    if isDraggingLocked then
        ContentFrame:FindFirstChild("TextButton").Text = "🔒 Lock All Buttons"
        ContentFrame:FindFirstChild("TextButton").TextColor3 = Color3.fromRGB(255, 150, 150)
    else
        ContentFrame:FindFirstChild("TextButton").Text = "🔓 Unlock All Buttons"
        ContentFrame:FindFirstChild("TextButton").TextColor3 = Color3.fromRGB(255, 255, 150)
    end
end)

-- 📱 WASDボタン
createGeneratorButton("📱 Generate WASD Buttons", 54, config.accentColor, function()
    for _, btn in pairs(wasdButtons) do btn:Destroy() end
    wasdButtons = {}
    
    local centerX, centerY, spacing = 0.5, 0.85, 0.065
    wasdButtons.W = createKeyButton("W", Color3.fromRGB(70, 70, 150), Enum.KeyCode.W, centerX, centerY - spacing)
    wasdButtons.A = createKeyButton("A", Color3.fromRGB(70, 150, 70), Enum.KeyCode.A, centerX - spacing, centerY)
    wasdButtons.S = createKeyButton("S", Color3.fromRGB(150, 70, 70), Enum.KeyCode.S, centerX, centerY + spacing)
    wasdButtons.D = createKeyButton("D", Color3.fromRGB(150, 150, 70), Enum.KeyCode.D, centerX + spacing, centerY)
end)

-- ⚡ WS高速クリック
createGeneratorButton("⚡ Generate WS Fast Click", 100, Color3.fromRGB(180, 255, 200), function()
    local btn = createKeyButton("WS\n⚡", Color3.fromRGB(100, 60, 120), nil, 0.1, 0.7, 70, 70)
    local isRunning = false
    btn.MouseButton1Click:Connect(function()
        isRunning = not isRunning
        if isRunning then
            btn.BackgroundColor3 = config.accentColor
            btn.Text = "WS\n■"
            spawn(function()
                while isRunning do
                    pcall(function() keypress(Enum.KeyCode.W) end)
                    wait(0.1)
                    pcall(function() keyrelease(Enum.KeyCode.W) end)
                    if not isRunning then break end
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
end)

-- ⚡ AD高速クリック
createGeneratorButton("⚡ Generate AD Fast Click", 146, Color3.fromRGB(255, 180, 200), function()
    local btn = createKeyButton("AD\n⚡", Color3.fromRGB(60, 120, 60), nil, 0.9, 0.7, 70, 70)
    local isRunning = false
    btn.MouseButton1Click:Connect(function()
        isRunning = not isRunning
        if isRunning then
            btn.BackgroundColor3 = config.accentColor
            btn.Text = "AD\n■"
            spawn(function()
                while isRunning do
                    pcall(function() keypress(Enum.KeyCode.A) end)
                    wait(0.1)
                    pcall(function() keyrelease(Enum.KeyCode.A) end)
                    if not isRunning then break end
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
end)

-- ⬜ Space
createGeneratorButton("⬜ Generate Space Button", 192, Color3.fromRGB(200, 200, 255), function()
    createKeyButton("SPACE", Color3.fromRGB(80, 80, 120), Enum.KeyCode.Space, 0.5, 0.92, 120, 55)
end)

-- 🖱️ 左クリック
createGeneratorButton("🖱️ Generate Left Click", 238, Color3.fromRGB(255, 200, 200), function()
    local btn = createKeyButton("🖱️\nClick", Color3.fromRGB(120, 60, 60), nil, 0.85, 0.5, 65, 65)
    btn.MouseButton1Click:Connect(function()
        pcall(function() mouse1click() end)
        btn.BackgroundColor3 = config.accentColor
        wait(0.1)
        btn.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
    end)
end)

-- ⬆️ Shift / ⌨️ Ctrl / 🔧 E
createGeneratorButton("⬆️ Generate Shift", 284, Color3.fromRGB(200, 255, 200), function()
    createKeyButton("SHIFT", Color3.fromRGB(60, 100, 80), Enum.KeyCode.LeftShift, 0.15, 0.5, 65, 65)
end)

createGeneratorButton("⌨️ Generate Ctrl", 330, Color3.fromRGB(255, 220, 180), function()
    createKeyButton("CTRL", Color3.fromRGB(100, 80, 60), Enum.KeyCode.LeftControl, 0.15, 0.6, 65, 65)
end)

createGeneratorButton("🔧 Generate E (Interact)", 376, Color3.fromRGB(180, 255, 255), function()
    createKeyButton("E", Color3.fromRGB(60, 120, 120), Enum.KeyCode.E, 0.6, 0.7, 55, 55)
end)

-- 🔢 数字キー 1-9
createGeneratorButton("🔢 Generate Number Keys (1-9)", 422, Color3.fromRGB(255, 200, 100), function()
    for i = 1, 9 do
        local keyCode = Enum.KeyCode["Key" .. i]
        createKeyButton(tostring(i), Color3.fromRGB(80, 60, 100), keyCode, 0.1 + (i - 1) * 0.09, 0.08, 45, 45)
    end
end)

-- ⌨️ F1-F12キー
createGeneratorButton("⌨️ Generate F1-F12 Keys", 468, Color3.fromRGB(200, 150, 255), function()
    for i = 1, 12 do
        local keyCode = Enum.KeyCode["F" .. i]
        local row = math.floor((i - 1) / 6)
        local col = (i - 1) % 6
        createKeyButton("F" .. i, Color3.fromRGB(100, 80, 120), keyCode, 0.15 + col * 0.13, 0.15 + row * 0.08, 50, 40)
    end
end)

-- 📋 Tab / Esc / Enter
createGeneratorButton("📋 Generate Tab", 514, Color3.fromRGB(150, 200, 255), function()
    createKeyButton("TAB", Color3.fromRGB(70, 90, 120), Enum.KeyCode.Tab, 0.15, 0.35, 60, 50)
end)

createGeneratorButton("🚪 Generate Escape", 560, Color3.fromRGB(255, 150, 150), function()
    createKeyButton("ESC", Color3.fromRGB(120, 60, 60), Enum.KeyCode.Escape, 0.08, 0.08, 50, 45)
end)

createGeneratorButton("↩️ Generate Enter", 606, Color3.fromRGB(150, 255, 150), function()
    createKeyButton("ENTER", Color3.fromRGB(60, 120, 80), Enum.KeyCode.Return, 0.85, 0.35, 70, 50)
end)

-- 🖱️ 右クリック
createGeneratorButton("🖱️ Generate Right Click", 652, Color3.fromRGB(255, 180, 180), function()
    local btn = createKeyButton("R\nClick", Color3.fromRGB(100, 50, 50), nil, 0.85, 0.6, 65, 65)
    btn.MouseButton1Click:Connect(function()
        pcall(function() mouse2click() end)
        btn.BackgroundColor3 = config.accentColor
        wait(0.1)
        btn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
    end)
end)

-- 🖱️ マウスホールド（長押しクリック）
createGeneratorButton("🖱️ Generate Mouse Hold", 698, Color3.fromRGB(200, 100, 200), function()
    local btn = createKeyButton("HOLD\nClick", Color3.fromRGB(80, 40, 80), nil, 0.75, 0.65, 70, 65)
    local isHolding = false
    btn.MouseButton1Click:Connect(function()
        isHolding = not isHolding
        if isHolding then
            btn.BackgroundColor3 = config.accentColor
            btn.Text = "HOLD\n■"
            pcall(function() mouse1press() end)
        else
            btn.BackgroundColor3 = Color3.fromRGB(80, 40, 80)
            btn.Text = "HOLD\nClick"
            pcall(function() mouse1release() end)
        end
    end)
end)

-- 📜 スクロール上下
createGeneratorButton("📜 Generate Scroll Up/Down", 744, Color3.fromRGB(180, 220, 255), function()
    local btnUp = createKeyButton("🔼\nScroll", Color3.fromRGB(60, 80, 120), nil, 0.92, 0.4, 60, 55)
    local btnDown = createKeyButton("🔽\nScroll", Color3.fromRGB(60, 80, 100), nil, 0.92, 0.5, 60, 55)
    
    btnUp.MouseButton1Click:Connect(function()
        pcall(function() mouse1scroll(120) end)
        btnUp.BackgroundColor3 = config.accentColor
        wait(0.1)
        btnUp.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
    end)
    
    btnDown.MouseButton1Click:Connect(function()
        pcall(function() mouse1scroll(-120) end)
        btnDown.BackgroundColor3 = config.accentColor
        wait(0.1)
        btnDown.BackgroundColor3 = Color3.fromRGB(60, 80, 100)
    end)
end)

-- ⌨️ Q/R/T/Y/G/H/X/C/V/Z (追加キー)
createGeneratorButton("⌨️ Generate Extra Keys (Q/R/T/X/C/V)", 790, Color3.fromRGB(220, 200, 255), function()
    local extraKeys = {
        {name="Q", code=Enum.KeyCode.Q, x=0.3, y=0.3},
        {name="R", code=Enum.KeyCode.R, x=0.4, y=0.3},
        {name="T", code=Enum.KeyCode.T, x=0.5, y=0.3},
        {name="X", code=Enum.KeyCode.X, x=0.3, y=0.4},
        {name="C", code=Enum.KeyCode.C, x=0.4, y=0.4},
        {name="V", code=Enum.KeyCode.V, x=0.5, y=0.4}
    }
    for _, key in ipairs(extraKeys) do
        createKeyButton(key.name, Color3.fromRGB(90, 70, 110), key.code, key.x, key.y, 50, 50)
    end
end)

-- 🔄 Backspace / Delete
createGeneratorButton("🔄 Generate Backspace/Delete", 836, Color3.fromRGB(255, 200, 150), function()
    createKeyButton("⌫\nBKSP", Color3.fromRGB(100, 70, 50), Enum.KeyCode.Backspace, 0.9, 0.15, 65, 50)
    createKeyButton("DEL", Color3.fromRGB(120, 70, 50), Enum.KeyCode.Delete, 0.9, 0.22, 60, 45)
end)

-- ⬅️➡️ 矢印キー
createGeneratorButton("⬅️➡️ Generate Arrow Keys", 882, Color3.fromRGB(200, 255, 255), function()
    createKeyButton("▲", Color3.fromRGB(50, 90, 90), Enum.KeyCode.Up, 0.75, 0.45, 48, 48)
    createKeyButton("◄", Color3.fromRGB(50, 90, 90), Enum.KeyCode.Left, 0.7, 0.5, 48, 48)
    createKeyButton("▼", Color3.fromRGB(50, 90, 90), Enum.KeyCode.Down, 0.75, 0.5, 48, 48)
    createKeyButton("►", Color3.fromRGB(50, 90, 90), Enum.KeyCode.Right, 0.8, 0.5, 48, 48)
end)

-- Alt
createGeneratorButton("⌨️ Generate Alt", 928, Color3.fromRGB(255, 220, 200), function()
    createKeyButton("ALT", Color3.fromRGB(90, 70, 60), Enum.KeyCode.LeftAlt, 0.25, 0.6, 60, 55)
end)

-- 📐 PageUp/PageDown/Home/End
createGeneratorButton("📐 Generate Page/Home/End Keys", 974, Color3.fromRGB(200, 200, 150), function()
    createKeyButton("PgUp", Color3.fromRGB(70, 70, 60), Enum.KeyCode.PageUp, 0.92, 0.3, 55, 40)
    createKeyButton("PgDn", Color3.fromRGB(70, 70, 60), Enum.KeyCode.PageDown, 0.92, 0.35, 55, 40)
    createKeyButton("Home", Color3.fromRGB(60, 70, 70), Enum.KeyCode.Home, 0.08, 0.3, 55, 40)
    createKeyButton("End", Color3.fromRGB(60, 70, 70), Enum.KeyCode.End, 0.08, 0.35, 55, 40)
end)

-- UIドラッグ
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

print("✓ WASD Controller Pro loaded!")
print("✓ All PC controls available!")
print("✓ Scroll to see all 20+ button generators!")
