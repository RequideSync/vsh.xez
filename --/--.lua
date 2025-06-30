
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local camera = game.Workspace.CurrentCamera
local player = game.Players.LocalPlayer

local rotationEnabled = false
local isPerformingAction = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local function createButton(name, posY)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 130, 0, 40)
    button.Position = UDim2.new(0, 0, 0, posY)
    button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    button.BackgroundTransparency = 0.5
    button.Text = name
    button.ZIndex = 1
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Garamond
    button.TextSize = 20
    button.TextStrokeTransparency = 0.8

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    local clickTween =
        TweenService:Create(
        button,
        TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 135, 0, 45)}
    )
    local releaseTween =
        TweenService:Create(
        button,
        TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 130, 0, 40)}
    )

    button.MouseEnter:Connect(
        function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 150, 0)}):Play()
        end
    )

    button.MouseLeave:Connect(
        function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
        end
    )

    button.MouseButton1Click:Connect(
        function()
            clickTween:Play()
            clickTween.Completed:Wait()
            releaseTween:Play()
        end
    )

    return button
end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 120)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = screenGui

local resetButton = createButton("M1 Reset", 0)
local emoteDashButton = createButton("Emote Dash", 45)
local toggleRotationButton = createButton("Rotation: OFF", 90)

resetButton.Parent = mainFrame
emoteDashButton.Parent = mainFrame
toggleRotationButton.Parent = mainFrame

local animationCache = {}

local function getCharacter()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return character, humanoid
end

local function playAnimation(animationId)
    local _, humanoid = getCharacter()
    if not humanoid then
        return
    end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    local animation = animationCache[animationId]
    if not animation then
        animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://" .. tostring(animationId)
        animationCache[animationId] = animation
    end

    local animTrack = animator:LoadAnimation(animation)
    animTrack.Priority = Enum.AnimationPriority.Action
    animTrack:Play()
    animTrack:AdjustSpeed(1.1)

    return animTrack
end

local function rotateCharacter(degrees)
    if isPerformingAction or not rotationEnabled then
        return
    end
    isPerformingAction = true

    local character, _ = getCharacter()
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(degrees), 0)

        local camPos = camera.CFrame.Position
        local camY = camPos.Y
        local distanceVec = camPos - rootPart.Position
        local flatVec = Vector3.new(distanceVec.X, 0, distanceVec.Z)
        local rotatedVec = CFrame.fromAxisAngle(Vector3.yAxis, math.rad(degrees)) * flatVec
        local newCamPos = rootPart.Position + rotatedVec
        camera.CFrame = CFrame.lookAt(Vector3.new(newCamPos.X, camY, newCamPos.Z), rootPart.Position)
    end

    isPerformingAction = false
end

local function sideDash(direction, distance, duration)
    if isPerformingAction then
        return
    end
    isPerformingAction = true

    local character, _ = getCharacter()
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local tween =
            TweenService:Create(
            rootPart,
            TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                CFrame = rootPart.CFrame * CFrame.new(direction * distance, 0, 0)
            }
        )
        tween:Play()
        tween.Completed:Wait()
        tween:Destroy()
    end

    isPerformingAction = false
end

local function impulseDash(direction, distance, height, power, duration)
    if isPerformingAction then
        return
    end
    isPerformingAction = true

    local character, _ = getCharacter()
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        local force = Instance.new("BodyVelocity")
        force.Velocity = (rootPart.CFrame.RightVector * direction * distance + Vector3.new(0, height, 0)).Unit * power
        force.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        force.Parent = rootPart
        task.delay(
            duration,
            function()
                force:Destroy()
            end
        )
    end

    isPerformingAction = false
end

local function Stopallanimation()
    local _, humanoid = getCharacter()
    if humanoid then
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            local success, tracks =
                pcall(
                function()
                    return animator:GetPlayingAnimationTracks()
                end
            )
            if success and tracks then
                for _, track in ipairs(tracks) do
                    track:Stop()
                end
            end
        end
    end
end

local function updateUIButtons()
    toggleRotationButton.Text = "Rotation: " .. (rotationEnabled and "ON" or "OFF")
end

resetButton.MouseButton1Click:Connect(
    function()
        task.spawn(
            function()
                pcall(
                    function()
                        Stopallanimation()
                        playAnimation(10480793962)
                        sideDash(1, 25.5, 0.24)
                        rotateCharacter(65)
                        task.wait(0.004)
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
                    end
                )
            end
        )
    end
)

emoteDashButton.MouseButton1Click:Connect(
    function()
        task.spawn(
            function()
                pcall(
                    function()
                        Stopallanimation()
                        playAnimation(10480793962)
                        rotateCharacter(89)
                        impulseDash(1, 37, 7, 90, 0.29)
                    end
                )
            end
        )
    end
)

toggleRotationButton.MouseButton1Click:Connect(
    function()
        rotationEnabled = not rotationEnabled
        updateUIButtons()
    end
)

-- getgenv().keybinds = {
--  m1reset = Enum.KeyCode.R,
--  emotedash = Enum.KeyCode.T,
--  rotation = Enum.KeyCode.H
-- }

UserInputService.InputBegan:Connect(
    function(input, gameProcessed)
        if gameProcessed or UserInputService:GetFocusedTextBox() then
            return
        end

        local binds = getgenv().keybinds
        if input.KeyCode == binds.m1reset then
            task.spawn(
                function()
                    pcall(
                        function()
                            Stopallanimation()
                            playAnimation(10480793962)
                            sideDash(1, 25.5, 0.24)
                            rotateCharacter(65)
                            task.wait(0.004)
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
                        end
                    )
                end
            )
        elseif input.KeyCode == binds.emotedash then
            task.spawn(
                function()
                    pcall(
                        function()
                            Stopallanimation()
                            playAnimation(10480793962)
                            rotateCharacter(89)
                            impulseDash(1, 37, 7, 90, 0.29)
                        end
                    )
                end
            )
        elseif input.KeyCode == binds.rotation then
            rotationEnabled = not rotationEnabled
            updateUIButtons()
        end
    end
)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == getgenv().keybinds.UIToggle then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

updateUIButtons()
