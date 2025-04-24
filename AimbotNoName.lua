--// Aimbot Script - Creado por LuisK1ng7

local fov = 136
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Cam = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local isAiming = false
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

-- FOV Visual
local FOVring = Drawing.new("Circle")
FOVring.Visible = false
FOVring.Thickness = 2
FOVring.Color = Color3.fromRGB(255, 0, 0)
FOVring.Filled = false
FOVring.Radius = fov
FOVring.Position = Cam.ViewportSize / 2

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "LuisAimbotUI"

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 150, 0, 40)
ToggleButton.Position = UDim2.new(0, 10, 0, 10)
ToggleButton.Text = "LuisK1ng7 - Aimbot OFF"
ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleButton.TextColor3 = Color3.fromRGB(255, 60, 60)
ToggleButton.Font = Enum.Font.GothamBlack
ToggleButton.TextSize = 14
ToggleButton.Parent = ScreenGui

-- Credito
local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(0, 200, 0, 20)
Credit.Position = UDim2.new(0, 10, 0, 55)
Credit.BackgroundTransparency = 1
Credit.Text = "Mod hecho por: LuisK1ng7"
Credit.TextColor3 = Color3.fromRGB(255, 0, 0)
Credit.Font = Enum.Font.GothamSemibold
Credit.TextSize = 12
Credit.Parent = ScreenGui

-- CHAMS en rojo
local function applyChams(player)
    if player == LocalPlayer then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    if not character:FindFirstChild("ChamsHighlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ChamsHighlight"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(128, 0, 0)
        highlight.FillTransparency = 0.3
        highlight.OutlineTransparency = 0
        highlight.Adornee = character
        highlight.Parent = character
    end
end

-- ESP con Nombre y Vida
local function createESP(player)
    if player == LocalPlayer then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "LuisESP"
    billboard.Adornee = nil
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Text = player.Name
    nameLabel.Parent = billboard

    local hpLabel = Instance.new("TextLabel")
    hpLabel.Size = UDim2.new(1, 0, 0.5, 0)
    hpLabel.Position = UDim2.new(0, 0, 0.5, 0)
    hpLabel.BackgroundTransparency = 1
    hpLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    hpLabel.TextStrokeTransparency = 0.5
    hpLabel.Font = Enum.Font.GothamBold
    hpLabel.TextSize = 14
    hpLabel.Text = "HP: 100"
    hpLabel.Parent = billboard

    local function updateHP()
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            hpLabel.Text = "HP: " .. math.floor(char.Humanoid.Health)
        end
    end

    player.CharacterAdded:Connect(function(char)
        task.wait(1)
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")
        billboard.Adornee = hrp
        billboard.Parent = hrp
        hum:GetPropertyChangedSignal("Health"):Connect(updateHP)
        updateHP()
    end)

    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        billboard.Adornee = player.Character.HumanoidRootPart
        billboard.Parent = player.Character.HumanoidRootPart
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum then
            hum:GetPropertyChangedSignal("Health"):Connect(updateHP)
            updateHP()
        end
    end
end

-- Aplicar Chams y ESP
for _, player in ipairs(Players:GetPlayers()) do
    player.CharacterAdded:Connect(function()
        task.wait(1)
        applyChams(player)
        createESP(player)
    end)
    applyChams(player)
    createESP(player)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        applyChams(player)
        createESP(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if player.Character and player.Character:FindFirstChild("ChamsHighlight") then
        player.Character.ChamsHighlight:Destroy()
    end
end)

-- Target Logic
local function getTarget()
    local nearest, minDistance = nil, math.huge
    local center = Cam.ViewportSize / 2
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local hp = player.Character:FindFirstChild("Humanoid")
            if head and hrp and hp and hp.Health > 0 then
                local screenPos, visible = Cam:WorldToViewportPoint(head.Position)
                if visible and screenPos.Z > 0 then
                    local ray = workspace:Raycast(
                        Cam.CFrame.Position,
                        (head.Position - Cam.CFrame.Position).Unit * 1000,
                        raycastParams
                    )
                    if ray and ray.Instance:IsDescendantOf(player.Character) then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist < minDistance and dist < fov then
                            minDistance = dist
                            nearest = head.Position
                        end
                    end
                end
            end
        end
    end
    return nearest
end

-- Aim función
local function aim(pos)
    local cf = Cam.CFrame
    local dir = (pos - cf.Position).Unit
    local smooth = 0.581
    local look = cf.LookVector:Lerp(dir, smooth)
    Cam.CFrame = CFrame.new(cf.Position, cf.Position + look)
end

-- FOV Update
RunService.Heartbeat:Connect(function()
    FOVring.Position = Cam.ViewportSize / 2
    FOVring.Radius = fov * (Cam.ViewportSize.Y / 1080)
    if isAiming then
        local target = getTarget()
        if target then
            aim(target)
        end
    end
end)

-- Toggle función
local function toggle()
    isAiming = not isAiming
    FOVring.Visible = isAiming
    ToggleButton.Text = "LuisK1ng7 - Aimbot " .. (isAiming and "ON" or "OFF")
    ToggleButton.TextColor3 = isAiming and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 60, 60)
end

ToggleButton.MouseButton1Click:Connect(toggle)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.T then
        toggle()
    end
end)
