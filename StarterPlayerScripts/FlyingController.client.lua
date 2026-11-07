local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local flightSpeed = 70
local toggleKey = Enum.KeyCode.F

local flying = false
local character
local humanoid
local rootPart
local bodyVelocity
local bodyGyro
local flightConnection

local function getCharacterParts()
	character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
end

local function stopFlying()
	flying = false

	if flightConnection then
		flightConnection:Disconnect()
		flightConnection = nil
	end

	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end

	if bodyGyro then
		bodyGyro:Destroy()
		bodyGyro = nil
	end

	if humanoid then
		humanoid.AutoRotate = true
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

local function startFlying()
	getCharacterParts()
	if flying then
		return
	end

	flying = true
	humanoid.AutoRotate = false

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Name = "FlightVelocity"
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.P = 10000
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.Parent = rootPart

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.Name = "FlightGyro"
	bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bodyGyro.P = 10000
	bodyGyro.CFrame = rootPart.CFrame
	bodyGyro.Parent = rootPart

	flightConnection = RunService.RenderStepped:Connect(function()
		if not character.Parent or humanoid.Health <= 0 then
			stopFlying()
			return
		end

		local camera = workspace.CurrentCamera
		local direction = humanoid.MoveDirection
		local vertical = 0

		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			vertical += 1
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			vertical -= 1
		end

		local cameraDirection = camera.CFrame.LookVector
		local movement = direction * flightSpeed + Vector3.new(0, vertical * flightSpeed, 0)
		bodyVelocity.Velocity = movement
		bodyGyro.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + cameraDirection)
	end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == toggleKey then
		if flying then
			stopFlying()
		else
			startFlying()
		end
	end
end)

player.CharacterAdded:Connect(function()
	stopFlying()
	getCharacterParts()
end)

getCharacterParts()
