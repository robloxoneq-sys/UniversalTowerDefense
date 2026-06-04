local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- รีโมทต่างๆ
local KnitServices = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index")["sleitnick_knit@1.7.0"].knit.Services
local VoteRemote = KnitServices.WaveService.RF.Vote
local PlaceUnitRemote = KnitServices.TowerService.RF.PlaceUnit
local UpgradeUnitRemote = KnitServices.TowerService.RF.UpgradeUnit
local UseAbilityRemote = KnitServices.TowerService.RE.UseAbility

local UnitsFolder = Workspace:WaitForChild("Ignore"):WaitForChild("Units")
local gameUI = playerGui:WaitForChild("GameUI")
local timeFrame = gameUI.HUD.Upper.WaveInformations.Container:WaitForChild("Time")

-- ฟังก์ชันสำหรับแปลงเวลา "นาที:วินาที" เป็น วินาทีทั้งหมด (เช่น "00:14" -> 14 วินาที)
local function timeToSeconds(timeStr)
    local minutes, seconds = timeStr:match("(%d+):(%d+)")
    if minutes and seconds then
        return (tonumber(minutes) * 60) + tonumber(seconds)
    end
    return 0
end

-- ฟังก์ชันค้นหา TextLabel ข้างใน Time Frame
local function getTimeLabel()
    for _, child in ipairs(timeFrame:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("TextBox") then
            return child
        end
    end
    return nil
end

-- เริ่มทำงานสคริปต์
VoteRemote:InvokeServer(true)
task.wait(0.5)

print("กำลังค้นหา TextLabel ของเวลา...")
local timeLabel = nil
repeat
    timeLabel = getTimeLabel()
    if not timeLabel then task.wait(0.5) end
until timeLabel
print("เจอ TextLabel เวลาแล้ว!")

-- ลูปเช็คเวลาจนกว่าจะถึง 00:14 ขึ้นไป (14 วินาทีขึ้นไป)
print("กำลังรอให้เวลาเป็น 00:14 ขึ้นไป...")
repeat
    local currentSeconds = timeToSeconds(timeLabel.Text)
    task.wait(0.1)
until currentSeconds >= 14  -- 14 วินาที มีค่าเท่ากับเวลา "00:14"

print("เวลาถึงกำหนดแล้ว! (`" .. timeLabel.Text .. "`) กำลังวางยูนิต...")
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

print("สคริปต์หลักทำงานเสร็จสิ้น! เริ่มทำงานระบบ Auto-Lobby...")

-- ระบบคลิกหน้าจอ / กลับล็อบบี้อัตโนมัติ
local resultFrame = gameUI.MissionResultFrame

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
