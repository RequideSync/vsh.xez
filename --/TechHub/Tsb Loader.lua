
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0
TweenService:Create(blur, TweenInfo.new(0.5), {Size = 24}):Play()

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "AutoTechLoader"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(1, 0, 1, 0)
frame.BackgroundTransparency = 1

local bg = Instance.new("Frame", frame)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
bg.BackgroundTransparency = 1
bg.ZIndex = 0
TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 0.3}):Play()

local word = "Tech [ v0.3 ]"
local letters = {}

local function tweenOutAndDestroy()
	for _, label in ipairs(letters) do
		TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 1, TextSize = 20}):Play()
	end
	TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
	TweenService:Create(blur, TweenInfo.new(0.5), {Size = 0}):Play()
	wait(0.6)
	screenGui:Destroy()
	blur:Destroy()
end

for i = 1, #word do
	local char = word:sub(i, i)

	local label = Instance.new("TextLabel")
	label.Text = char
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 1 
	label.TextTransparency = 1
	label.TextScaled = false
	label.TextSize = 10
	label.Size = UDim2.new(0, 60, 0, 60)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.new(0.5, (i - (#word / 2 + 0.5)) * 65, 0.5, 0)
	label.BackgroundTransparency = 1
	label.Parent = frame

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 170, 255)), -- biru muda cerah
		ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 100, 160))   -- biru muda gelap
	})
	gradient.Rotation = 90
	gradient.Parent = label

	local tweenIn = TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 0, TextSize = 60})
	tweenIn:Play()

	table.insert(letters, label)
	wait(0.25)
end

wait(2)

tweenOutAndDestroy()
repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character

if not game:IsLoaded() then
    game.Loaded:Wait()
end

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
    button.BackgroundColor3 = Color3.fromRGB(173, 216, 230)
    button.BackgroundTransparency = 0.7
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
local discordButton = createButton("Discord", 135)

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

discordButton.MouseButton1Click:Connect(
    function()
        task.spawn(
            function()
                pcall(
                    function()
                        setclipboard("https://discord.gg/GGm3VU8k")
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
    if input.KeyCode == Enum.KeyCode.P then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

updateUIButtons()
