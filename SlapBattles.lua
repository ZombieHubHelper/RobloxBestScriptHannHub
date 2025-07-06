local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "AbilityButtonGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

-- Create red button
local button = Instance.new("TextButton")
button.Name = "AbilityButton"
button.Text = "Use Ability"
button.Size = UDim2.new(0, 150, 0, 60)
button.Position = UDim2.new(0.8, 0, 0.7, 0) -- Start in bottom-right corner
button.AnchorPoint = Vector2.new(0.5, 0.5)
button.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 22
button.AutoButtonColor = false
button.Parent = gui

-- Add rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.3, 0)
corner.Parent = button

-- Button styling
button.BackgroundTransparency = 0.2
local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(150, 40, 40)
stroke.Parent = button

-- Dragging variables
local dragInput, dragStart, startPos
local dragThreshold = 10 -- Pixels before considering it a drag
local isDragging = false

-- Position clamping function
local function clampPosition(position, buttonSize, screenSize)
	return Vector2.new(
		math.clamp(position.X, buttonSize.X/2, screenSize.X - buttonSize.X/2),
		math.clamp(position.Y, buttonSize.Y/2, screenSize.Y - buttonSize.Y/2)
	)
end

-- Input handling
button.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		dragStart = input.Position
		startPos = button.AbsolutePosition
		isDragging = false
		
		-- Visual feedback
		button.BackgroundTransparency = 0.1
	end
end)

button.InputChanged:Connect(function(input)
	if input == dragInput then
		-- Calculate drag distance
		local delta = (input.Position - dragStart)
		
		-- Check if we've passed drag threshold
		if delta.Magnitude > dragThreshold and not isDragging then
			isDragging = true
		end
		
		-- Handle dragging
		if isDragging then
			local newPos = startPos + delta
			local screenSize = gui.AbsoluteSize
			local buttonSize = button.AbsoluteSize
			
			-- Apply position clamping
			newPos = clampPosition(newPos, buttonSize, screenSize)
			
			-- Update position
			button.Position = UDim2.new(
				0, newPos.X,
				0, newPos.Y
			)
		end
	end
end)

button.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		-- Reset visual state
		button.BackgroundTransparency = 0.2
		
		-- Fire ability if not dragged
		if not isDragging then
			game:GetService("ReplicatedStorage").GeneralAbility:FireServer()
		end
		
		-- Reset dragging state
		isDragging = false
		dragInput = nil
	end
end)

-- Additional setup for smoother dragging
game:GetService("UserInputService").InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch and input == dragInput then
		-- Update drag position during movement
		local delta = (input.Position - dragStart)
		
		if isDragging then
			local newPos = startPos + delta
			local screenSize = gui.AbsoluteSize
			local buttonSize = button.AbsoluteSize
			
			newPos = clampPosition(newPos, buttonSize, screenSize)
			button.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
		end
	end
end)
