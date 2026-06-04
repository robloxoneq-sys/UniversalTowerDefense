local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local KnitServices = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index")["sleitnick_knit@1.7.0"].knit.Services
local VoteRemote = KnitServices.WaveService.RF.Vote
local PlaceUnitRemote = KnitServices.TowerService.RF.PlaceUnit
local UpgradeUnitRemote = KnitServices.TowerService.RF.UpgradeUnit
local UseAbilityRemote = KnitServices.TowerService.RE.UseAbility

local UnitsFolder = Workspace:WaitForChild("Ignore"):WaitForChild("Units")

VoteRemote:InvokeServer(true)
task.wait(0.5)

local function checkPosition(unit, targetPos)
    if not unit or not unit:IsA("Position") and not unit:IsA("Model") then return false end
    local currentPos = unit:GetPivot().Position
    return (currentPos - targetPos).Magnitude < 0.5
end

local targetPos1 = Vector3.new(5428.521, 4.4000001, -3043.79248)
local targetPos2 = Vector3.new(5428.521, 4.4000001, -3046.5022)
local targetPos3 = Vector3.new(5428.521, 4.4000001, -3049.25537)

print("กำลังรอให้ Unit 1, 2, 3 อยู่ในตำแหน่งที่กำหนด...")
repeat
    local u1 = UnitsFolder:FindFirstChild("1")
    local u2 = UnitsFolder:FindFirstChild("2")
    local u3 = UnitsFolder:FindFirstChild("3")
    
    local c1 = u1 and (u1:GetPivot().Position - targetPos1).Magnitude < 0.1
    local c2 = u2 and (u2:GetPivot().Position - targetPos2).Magnitude < 0.1
    local c3 = u3 and (u3:GetPivot().Position - targetPos3).Magnitude < 0.1
    
    task.wait(0.1)
until c1 and c2 and c3

print("ตำแหน่งตรงแล้ว! กำลังวางยูนิต...")
PlaceUnitRemote:InvokeServer(
    1,
    CFrame.new(5425.6098632812, 2.75, -3036.8666992188, 1, 0, 0, 0, 1, 0, 0, 0, 1)
)

print("กำลังรอให้ Unit 1, 2, 3 หายไป...")
repeat
    task.wait(0.1)
until not UnitsFolder:FindFirstChild("1") and not UnitsFolder:FindFirstChild("2") and not UnitsFolder:FindFirstChild("3")

print("Unit 1, 2, 3 หายหมดแล้ว! กำลังอัปเกรดยูนิตที่เหลือ...")
for _, v in pairs(UnitsFolder:GetChildren()) do
    task.spawn(function()
        UpgradeUnitRemote:InvokeServer(v.Name)
    end)
end

print("กำลังรอตรวจจับ Unit '7'...")
repeat
    task.wait(0.1)
until UnitsFolder:FindFirstChild("7")

print("พบ Unit '7' แล้ว! กำลังวางยูนิตเพิ่ม...")
PlaceUnitRemote:InvokeServer(
    1,
    CFrame.new(5425.6098632812, 2.75, -3036.8666992188, 1, 0, 0, 0, 1, 0, 0, 0, 1)
)

print("รอ 5 วินาที...")
task.wait(5)

print("กำลังเปิดใช้งานสกิลให้กับทุกยูนิต...")
for _, v in pairs(UnitsFolder:GetChildren()) do
    task.spawn(function()
        local args = {
            [1] = v.Name,
            [2] = 1
        }
        UseAbilityRemote:FireServer(unpack(args))
    end)
end

print("สคริปต์ทำงานเสร็จสิ้นทั้งหมดเรียบร้อย!")

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")

local plr = Players.LocalPlayer
local resultFrame = plr.PlayerGui.GameUI.MissionResultFrame

while task.wait() do
    if resultFrame.Enabled then
        local button = resultFrame.Main.Content.Description.Actions.Container.Lobby.TextButton

        GuiService.SelectedObject = button

        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)

        task.wait(1)
    else
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
end