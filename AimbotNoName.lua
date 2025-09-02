local fov = 136
local smoothness = 0.581
local fovVisible = true
local teamCheck = false
local wallCheck = true
local aimKey = Enum.KeyCode.T
local visibilityCheck = true

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Cam = workspace.CurrentCamera

-- Dibujar círculo FOV
local FOVring = Drawing.new("Circle")
FOVring.Visible = false
FOVring.Thickness = 2
FOVring.Color = Color3.fromRGB(128, 0, 128)
FOVring.Filled = false
FOVring.Radius = fov
FOVring.Position = Cam.ViewportSize / 2
FOVring.Transparency = 0.7

local isAiming = false
local isMenuOpen = false
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

-- UI principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotMenu"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Botón toggle principal
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 120, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.Text = "AIMBOT: OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.TextColor3 = Color3.fromRGB(255, 50, 50)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.ZIndex = 10
ToggleButton.Parent = ScreenGui

local UICornerToggle = Instance.new("UICorner")
UICornerToggle.CornerRadius = UDim.new(0, 6)
UICornerToggle.Parent = ToggleButton

-- Menú principal
local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 250, 0, 320)
MenuFrame.Position = UDim2.new(0, 10, 0, 60)
MenuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MenuFrame.BorderSizePixel = 0
MenuFrame.Visible = false
MenuFrame.ZIndex = 5
MenuFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MenuFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 6
TopBar.Parent = MenuFrame

local UICornerTop = Instance.new("UICorner")
UICornerTop.CornerRadius = UDim.new(0, 10)
UICornerTop.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.15, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "AIMBOT MENU v1.0"
Title.TextColor3 = Color3.fromRGB(220, 220, 220)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.ZIndex = 7
Title.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(0.85, 0, 0, 0)
CloseButton.Text = "X"
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.ZIndex = 7
CloseButton.Parent = TopBar

local UICornerClose = Instance.new("UICorner")
UICornerClose.CornerRadius = UDim.new(0, 10)
UICornerClose.Parent = CloseButton

-- Contenedor de opciones con scroll
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -40)
ScrollFrame.Position = UDim2.new(0, 5, 0, 35)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
ScrollFrame.ZIndex = 6
ScrollFrame.Parent = MenuFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ScrollFrame

-- Opciones del menú
local options = {
    {
        type = "slider",
        name = "FOV Size",
        min = 50,
        max = 300,
        default = fov,
        callback = function(value)
            fov = value
            FOVring.Radius = value
        end
    },
    {
        type = "slider",
        name = "Smoothness",
        min = 0.1,
        max = 1.0,
        default = smoothness,
        step = 0.01,
        callback = function(value)
            smoothness = value
        end
    },
    {
        type = "color",
        name = "FOV Color",
        default = FOVring.Color,
        callback = function(value)
            FOVring.Color = value
        end
    },
    {
        type = "toggle",
        name = "Show FOV",
        default = fovVisible,
        callback = function(value)
            fovVisible = value
            FOVring.Visible = value and isAiming
        end
    },
    {
        type = "toggle",
        name = "Team Check",
        default = teamCheck,
        callback = function(value)
            teamCheck = value
        end
    },
    {
        type = "toggle",
        name = "Wall Check",
        default = wallCheck,
        callback = function(value)
            wallCheck = value
        end
    },
    {
        type = "toggle",
        name = "Visibility Check",
        default = visibilityCheck,
        callback = function(value)
            visibilityCheck = value
        end
    },
    {
        type = "keybind",
        name = "Aim Key",
        default = aimKey,
        callback = function(value)
            aimKey = value
        end
    },
    {
        type = "button",
        name = "Save Settings",
        callback = function()
            saveSettings()
        end
    },
    {
        type = "button",
        name = "Reset Settings",
        callback = function()
            resetSettings()
        end
    }
}

-- Función para crear elementos de la UI
local function createOptionElement(option, index)
    local yPosition = (index - 1) * 40
    
    if option.type == "slider" then
        local optionFrame = Instance.new("Frame")
        optionFrame.Size = UDim2.new(1, 0, 0, 50)
        optionFrame.BackgroundTransparency = 1
        optionFrame.ZIndex = 7
        optionFrame.Parent = ScrollFrame
        
        local optionName = Instance.new("TextLabel")
        optionName.Size = UDim2.new(1, 0, 0, 20)
        optionName.BackgroundTransparency = 1
        optionName.Text = option.name
        optionName.TextColor3 = Color3.fromRGB(220, 220, 220)
        optionName.Font = Enum.Font.Gotham
        optionName.TextSize = 14
        optionName.TextXAlignment = Enum.TextXAlignment.Left
        optionName.ZIndex = 8
        optionName.Parent = optionFrame
        
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(1, 0, 0, 20)
        sliderFrame.Position = UDim2.new(0, 0, 0, 20)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        sliderFrame.ZIndex = 7
        sliderFrame.Parent = optionFrame
        
        local UICornerSlider = Instance.new("UICorner")
        UICornerSlider.CornerRadius = UDim.new(0, 4)
        UICornerSlider.Parent = sliderFrame
        
        local fillFrame = Instance.new("Frame")
        fillFrame.Size = UDim2.new((option.default - option.min) / (option.max - option.min), 0, 1, 0)
        fillFrame.BackgroundColor3 = Color3.fromRGB(100, 70, 200)
        fillFrame.ZIndex = 8
        fillFrame.Parent = sliderFrame
        
        local UICornerFill = Instance.new("UICorner")
        UICornerFill.CornerRadius = UDim.new(0, 4)
        UICornerFill.Parent = fillFrame
        
        local valueText = Instance.new("TextLabel")
        valueText.Size = UDim2.new(0, 40, 0, 20)
        valueText.Position = UDim2.new(1, 5, 0, 0)
        valueText.BackgroundTransparency = 1
        valueText.Text = tostring(option.default)
        valueText.TextColor3 = Color3.fromRGB(200, 200, 200)
        valueText.Font = Enum.Font.Gotham
        valueText.TextSize = 14
        valueText.ZIndex = 8
        valueText.Parent = sliderFrame
        
        local isSliding = false
        
        sliderFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isSliding = true
            end
        end)
        
        sliderFrame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isSliding = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                local xPos = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
                local ratio = xPos / sliderFrame.AbsoluteSize.X
                local value = option.min + ratio * (option.max - option.min)
                
                if option.step then
                    value = math.floor(value / option.step) * option.step
                end
                
                value = math.clamp(value, option.min, option.max)
                fillFrame.Size = UDim2.new(ratio, 0, 1, 0)
                valueText.Text = string.format(option.step and "%.2f" or "%.0f", value)
                option.callback(value)
            end
        end)
        
    elseif option.type == "toggle" then
        local optionFrame = Instance.new("Frame")
        optionFrame.Size = UDim2.new(1, 0, 0, 30)
        optionFrame.BackgroundTransparency = 1
        optionFrame.ZIndex = 7
        optionFrame.Parent = ScrollFrame
        
        local optionName = Instance.new("TextLabel")
        optionName.Size = UDim2.new(0.7, 0, 1, 0)
        optionName.BackgroundTransparency = 1
        optionName.Text = option.name
        optionName.TextColor3 = Color3.fromRGB(220, 220, 220)
        optionName.Font = Enum.Font.Gotham
        optionName.TextSize = 14
        optionName.TextXAlignment = Enum.TextXAlignment.Left
        optionName.ZIndex = 8
        optionName.Parent = optionFrame
        
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(0, 40, 0, 20)
        toggleFrame.Position = UDim2.new(0.7, 0, 0.5, -10)
        toggleFrame.BackgroundColor3 = option.default and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(120, 120, 120)
        toggleFrame.ZIndex = 7
        toggleFrame.Parent = optionFrame
        
        local UICornerToggle = Instance.new("UICorner")
        UICornerToggle.CornerRadius = UDim.new(0, 10)
        UICornerToggle.Parent = toggleFrame
        
        local toggleButton = Instance.new("Frame")
        toggleButton.Size = UDim2.new(0, 16, 0, 16)
        toggleButton.Position = UDim2.new(option.default and 0.6 or 0.05, 0, 0.1, 0)
        toggleButton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
        toggleButton.ZIndex = 8
        toggleButton.Parent = toggleFrame
        
        local UICornerButton = Instance.new("UICorner")
        UICornerButton.CornerRadius = UDim.new(0, 10)
        UICornerButton.Parent = toggleButton
        
        local isToggled = option.default
        
        toggleFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isToggled = not isToggled
                
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = TweenService:Create(toggleButton, tweenInfo, {
                    Position = UDim2.new(isToggled and 0.6 or 0.05, 0, 0.1, 0)
                })
                tween:Play()
                
                toggleFrame.BackgroundColor3 = isToggled and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(120, 120, 120)
                option.callback(isToggled)
            end
        end)
        
    elseif option.type == "color" then
        local optionFrame = Instance.new("Frame")
        optionFrame.Size = UDim2.new(1, 0, 0, 30)
        optionFrame.BackgroundTransparency = 1
        optionFrame.ZIndex = 7
        optionFrame.Parent = ScrollFrame
        
        local optionName = Instance.new("TextLabel")
        optionName.Size = UDim2.new(0.7, 0, 1, 0)
        optionName.BackgroundTransparency = 1
        optionName.Text = option.name
        optionName.TextColor3 = Color3.fromRGB(220, 220, 220)
        optionName.Font = Enum.Font.Gotham
        optionName.TextSize = 14
        optionName.TextXAlignment = Enum.TextXAlignment.Left
        optionName.ZIndex = 8
        optionName.Parent = optionFrame
        
        local colorButton = Instance.new("TextButton")
        colorButton.Size = UDim2.new(0, 60, 0, 20)
        colorButton.Position = UDim2.new(0.7, 0, 0.5, -10)
        colorButton.Text = ""
        colorButton.BackgroundColor3 = option.default
        colorButton.ZIndex = 7
        colorButton.Parent = optionFrame
        
        local UICornerColor = Instance.new("UICorner")
        UICornerColor.CornerRadius = UDim.new(0, 4)
        UICornerColor.Parent = colorButton
        
        colorButton.MouseButton1Click:Connect(function()
            local randomColor = Color3.fromRGB(math.random(50, 255), math.random(50, 255), math.random(50, 255))
            colorButton.BackgroundColor3 = randomColor
            option.callback(randomColor)
        end)
        
    elseif option.type == "keybind" then
        local optionFrame = Instance.new("Frame")
        optionFrame.Size = UDim2.new(1, 0, 0, 30)
        optionFrame.BackgroundTransparency = 1
        optionFrame.ZIndex = 7
        optionFrame.Parent = ScrollFrame
        
        local optionName = Instance.new("TextLabel")
        optionName.Size = UDim2.new(0.7, 0, 1, 0)
        optionName.BackgroundTransparency = 1
        optionName.Text = option.name
        optionName.TextColor3 = Color3.fromRGB(220, 220, 220)
        optionName.Font = Enum.Font.Gotham
        optionName.TextSize = 14
        optionName.TextXAlignment = Enum.TextXAlignment.Left
        optionName.ZIndex = 8
        optionName.Parent = optionFrame
        
        local keyButton = Instance.new("TextButton")
        keyButton.Size = UDim2.new(0, 60, 0, 20)
        keyButton.Position = UDim2.new(0.7, 0, 0.5, -10)
        keyButton.Text = option.default.Name
        keyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
        keyButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        keyButton.Font = Enum.Font.Gotham
        keyButton.TextSize = 12
        keyButton.ZIndex = 7
        keyButton.Parent = optionFrame
        
        local UICornerKey = Instance.new("UICorner")
        UICornerKey.CornerRadius = UDim.new(0, 4)
        UICornerKey.Parent = keyButton
        
        local listening = false
        
        keyButton.MouseButton1Click:Connect(function()
            listening = true
            keyButton.Text = "..."
            keyButton.BackgroundColor3 = Color3.fromRGB(120, 80, 160)
        end)
        
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if listening and not gameProcessed then
                listening = false
                aimKey = input.KeyCode
                keyButton.Text = input.KeyCode.Name
                keyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
                option.callback(input.KeyCode)
            end
        end)
        
    elseif option.type == "button" then
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 30)
        button.Text = option.name
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        button.TextColor3 = Color3.fromRGB(220, 220, 220)
        button.Font = Enum.Font.Gotham
        button.TextSize = 14
        button.ZIndex = 7
        button.Parent = ScrollFrame
        
        local UICornerButton = Instance.new("UICorner")
        UICornerButton.CornerRadius = UDim.new(0, 4)
        UICornerButton.Parent = button
        
        button.MouseButton1Click:Connect(option.callback)
    end
end

-- Crear todas las opciones
for i, option in ipairs(options) do
    createOptionElement(option, i)
end

-- Funciones principales
local function getTarget()
    local nearest, minDistance = nil, math.huge
    local viewportCenter = Cam.ViewportSize / 2
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Team check
            if teamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChild("Humanoid")

            if head and humanoid and humanoid.Health > 0 then
                local predictedPos = head.Position
                local screenPos, visible = Cam:WorldToViewportPoint(predictedPos)
                
                -- Visibility check
                if visibilityCheck and not visible or screenPos.Z <= 0 then
                    continue
                end
                
                -- Wall check
                if wallCheck then
                    local ray = workspace:Raycast(
                        Cam.CFrame.Position,
                        (predictedPos - Cam.CFrame.Position).Unit * 1000,
                        raycastParams
                    )
                    if not ray or not ray.Instance:IsDescendantOf(player.Character) then
                        continue
                    end
                end
                
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
                if distance < minDistance and distance < fov then
                    minDistance = distance
                    nearest = predictedPos
                end
            end
        end
    end
    return nearest
end

local function aim(targetPosition)
    local currentCF = Cam.CFrame
    local targetDirection = (targetPosition - currentCF.Position).Unit
    local newLookVector = currentCF.LookVector:Lerp(targetDirection, smoothness)
    Cam.CFrame = CFrame.new(currentCF.Position, currentCF.Position + newLookVector)
end

local function updateDrawings()
    FOVring.Position = Cam.ViewportSize / 2
    FOVring.Radius = fov * (Cam.ViewportSize.Y / 1080)
end

local function toggleAimbot()
    isAiming = not isAiming
    FOVring.Visible = fovVisible and isAiming
    ToggleButton.Text = "AIMBOT: " .. (isAiming and "ON" or "OFF")
    ToggleButton.TextColor3 = isAiming and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    
    if isAiming and not isMenuOpen then
        MenuFrame.Visible = true
        isMenuOpen = true
    end
end

local function toggleMenu()
    isMenuOpen = not isMenuOpen
    MenuFrame.Visible = isMenuOpen
end

local function saveSettings()
    -- Aquí se podrían guardar las configuraciones en el futuro
    print("Settings saved!")
end

local function resetSettings()
    -- Aquí se podrían resetear las configuraciones a los valores por defecto
    print("Settings reset!")
end

-- Conexiones de eventos
ToggleButton.MouseButton1Click:Connect(toggleAimbot)
CloseButton.MouseButton1Click:Connect(function()
    isMenuOpen = false
    MenuFrame.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == aimKey then
        toggleAimbot()
    end
end)

RunService.Heartbeat:Connect(function()
    updateDrawings()
    if isAiming then
        local target = getTarget()
        if target then
            aim(target)
        end
    end
end)

-- Hacer draggable el botón principal
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Limpieza
Players.PlayerRemoving:Connect(function()
    FOVring:Remove()
    ScreenGui:Destroy()
end)

-- Ajustar el tamaño del canvas del scroll
local function updateScrollSize()
    local totalHeight = 0
    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then
            totalHeight += child.AbsoluteSize.Y + UIListLayout.Padding.Offset
        end
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

updateScrollSize()
