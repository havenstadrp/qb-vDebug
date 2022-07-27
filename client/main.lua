local debug = false
local VehData, value_x, value_y, value_z = {}, 0.0, 0.0, 0.0

local function round(num)
	return num + (2^52 + 2^51) - (2^52 + 2^51)
end

local function drawTxt(x, y, width, height, scale, text, r,g,b,a)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(0.315, 0.315)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

local function drawCenterMass(carPos, forPos, backPos, LPos, RPos, forPos2, backPos2, LPos2, RPos2)
	DrawLine(carPos,forPos, 255,0,0,255)
	DrawLine(carPos,backPos, 255,0,0,255)
	DrawLine(carPos,LPos, 255,255,0,255)
	DrawLine(carPos,RPos, 255,255,0,255)           
	DrawLine(forPos,forPos2, 255,0,255,255)
	DrawLine(backPos,backPos2, 255,0,255,255)
	DrawLine(LPos,LPos2, 255,255,255,255)
	DrawLine(RPos,RPos2, 255,255,255,255)
end

local function displayEntityData(veh, vehModel, speed)
	if GetVehicleCurrentGear(veh) == 0 then currGear = "R" else currGear = GetVehicleCurrentGear(veh) end
	if (GetVehicleCurrentRpm(veh)*6000) < 1201 then currRPM = 0.0 else currRPM = (GetVehicleCurrentRpm(veh)*6000) end
	drawTxt(0.85, 0.44, 0.4,0.4,0.30, "Model: " .. vehModel, 55, 215, 55, 240)
	drawTxt(0.85, 0.4625, 0.4,0.4,0.30, "Engine: " .. GetVehicleEngineHealth(veh), 55, 215, 55, 240)
	drawTxt(0.85, 0.4850, 0.4,0.4,0.30, "Body: " .. GetVehicleBodyHealth(veh), 55, 215, 55, 240)
	drawTxt(0.85, 0.5075, 0.4,0.4,0.30, "Tank: " .. GetVehiclePetrolTankHealth(veh), 55, 215, 55, 240)
	drawTxt(0.85, 0.54, 0.4,0.4,0.30, "Gear: " .. currGear .. "/" .. GetVehicleHighGear(veh), 55, 215, 55, 240)
	drawTxt(0.85, 0.5625, 0.4,0.4,0.30, "RPM: " .. math.ceil(currRPM), 55, 215, 55, 240)
	drawTxt(0.85, 0.5850, 0.4,0.4,0.30, "Speed: " .. math.ceil(speed), 55, 215, 55, 240)
end

local function displayButtonLabel(ped, veh, x, y, z)
	if Config.ResetLabel ~= "nil" then 
		drawTxt(0.62, 1.16, 0.4,0.4,0.30, "["..Config.ResetLabel.."]: Reset Data", 255, 214, 129, 255)
	end
	if Config.UseTeleport then
		drawTxt(0.72, 1.16, 0.4,0.4,0.30, "["..Config.TeleportToCoordsLabel.."]: Teleport", 255, 214, 129, 255)
		if (IsControlJustReleased(1, Config.TeleportToCoordsKey)) then
			SetEntityCoordsNoOffset(veh, Config.TeleportToCoords, false, false, false, false)
			SetEntityHeading(veh, Config.TeleportToCoordsHeading)
		end
	end
	if Config.UseFlip then
		if IsControlJustPressed(1, Config.Flip) then
			SetPedCoordsKeepVehicle(ped, x, y, z)
		end
	end
end

RegisterNetEvent("vDebug:toggle",function()
	local msg, status
	debug = not debug
	if debug then msg = "Activated" else msg = "Deactivated" end
	if debug then status = "success" else status = "error" end
	QBCore.Functions.Notify("[vDebug Tool]: "..msg, status)
end)

CreateThread(function()
	while true do
		local sleep = 1000
		if debug then
			if IsPedInAnyVehicle(PlayerPedId(), false) then
				sleep = 0
				if DoesEntityExist(veh) then
					for k,v in pairs(VehData) do
						value_x, value_y, value_z = v.value.x, v.value.y, v.value.z 
						break
					end
				end
			end
        end
		Wait(sleep)
	end
end)

CreateThread( function()
	local topSpeed = 0.0
    local accelTime = 0.0
    local brakeTime = 0.0
	local speedStep1 = 0.0
    local speedStep2 = 0.0
    local speedStep3 = 0.0
    local speedStep4 = 0.0
    local startAccelTime = 0.0
    local startBrakeTime = 0.0

	if Config.Speed == "KMH" then speedUnit = 3.6 else speedUnit = 2.236936 end
	if Config.Speed == "KMH" then unitLabel = "km/h" else unitLabel = "mph" end
    
    while true do 
        Wait(1)
        if debug then
			if IsPedInAnyVehicle(PlayerPedId(), false) then
				local ped = PlayerPedId()
				local veh = GetVehiclePedIsIn(ped, false)
				local vehModel = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
				local speed = GetEntitySpeed(ped) * speedUnit

				local carPos = GetEntityCoords(veh)
				local forPos = GetOffsetFromEntityInWorldCoords(veh, value_x, 1.0, value_z)
				local backPos = GetOffsetFromEntityInWorldCoords(veh, value_x, -1.0, value_z)
				local LPos = GetOffsetFromEntityInWorldCoords(veh, 1.0, value_y, value_z)
				local RPos = GetOffsetFromEntityInWorldCoords(veh, -1.0, value_y, value_z) 
	
				local forPos2 = GetOffsetFromEntityInWorldCoords(veh, value_x, 2.0, value_z)
				local backPos2 = GetOffsetFromEntityInWorldCoords(veh, value_x, -2.0, value_z)
				local LPos2 = GetOffsetFromEntityInWorldCoords(veh, 2.0, value_y, value_z)
				local RPos2 = GetOffsetFromEntityInWorldCoords(veh, -2.0, value_y, value_z)    
				
				displayEntityData(veh, vehModel, speed)
				displayButtonLabel(ped, veh, carPos.x, carPos.y, carPos.z)

				if topSpeed < speed then
					topSpeed = speed
					drawTxt(0.85, 0.6075, 0.4,0.4,0.30, "Top Speed: " .. math.ceil(topSpeed), 245, 217, 39, 255)
				elseif topSpeed > speed then
					drawTxt(0.85, 0.6075, 0.4,0.4,0.30, "Top Speed: " .. math.ceil(topSpeed), 0, 152, 255, 255)
				else
					topSpeed = 0.0
					drawTxt(0.85, 0.6075, 0.4,0.4,0.30, "Top Speed: " .. math.ceil(topSpeed), 55, 215, 55, 240)
				end

				if (IsControlJustReleased(1, Config.Reset)) then
					topSpeed = 0.0
					accelTime = 0.0
					brakeTime = 0.0
					speedStep1 = 0.0
					speedStep2 = 0.0
					speedStep3 = 0.0
					speedStep4 = 0.0
					startAccelTime = 0.0
					startBrakeTime = 0.0
					startAccelTime = GetGameTimer()
					PlaySoundFrontend(-1, "Apt_Style_Purchase", "DLC_APT_Apartment_SoundSet")
				end

				if (IsControlJustPressed(0, 32) and not IsControlPressed(0, 18)) or IsControlJustReleased(0, 18) then
					accelTime = 0.0
					speedStep1 = 0.0
					speedStep2 = 0.0
					speedStep3 = 0.0
					speedStep4 = 0.0
					startAccelTime = GetGameTimer()
				end

				if IsControlPressed(0, 32) then
					accelTime = GetGameTimer() - startAccelTime
				end

				if IsControlJustPressed(0, 8) and GetEntitySpeed(ped) > 0.0 then
					brakeTime = 0.0
					startBrakeTime = GetGameTimer()
				end

				if IsControlPressed(0, 8) and GetEntitySpeed(ped) > 5 then
					brakeTime = GetGameTimer() - startBrakeTime
				end

				drawTxt(0.99, 0.83, 0.4,0.4,0.30, "Time Accelerating: " .. accelTime / 1000, 55, 225, 55, 240)
				drawTxt(0.99, 0.8525, 0.4,0.4,0.30, "Time Braking: " .. brakeTime / 1000, 245, 35, 48, 240)

				if speed >= Config.SpeedSteps[1] and IsControlPressed(0, 32) and speedStep1 == 0 then
					speedStep1 = accelTime / 1000
				end
				if speed >= Config.SpeedSteps[2] and IsControlPressed(0, 32) and speedStep2 == 0 then
					speedStep2 = accelTime / 1000
				end
				if speed >= Config.SpeedSteps[3] and IsControlPressed(0, 32) and speedStep3 == 0 then
					speedStep3 = accelTime / 1000
				end
				if speed >= Config.SpeedSteps[4] and IsControlPressed(0, 32) and speedStep4 == 0 then
					speedStep4 = accelTime / 1000
				end

				if speedStep1 <= 0 then
					drawTxt(0.99, 0.88, 0.4,0.4,0.80, Config.SpeedSteps[1] .. unitLabel .. ": " .. speedStep1, 210, 210, 210, 240)
				else
					drawTxt(0.99, 0.88, 0.4,0.4,0.80, Config.SpeedSteps[1] .. unitLabel .. ": " .. speedStep1, 245, 217, 39, 240)
				end

				if speedStep2 <= 0 then
					drawTxt(0.99, 0.9025, 0.4,0.4,0.80, Config.SpeedSteps[2] .. unitLabel .. ": " .. speedStep2, 210, 210, 210, 240)
				else
					drawTxt(0.99, 0.9025, 0.4,0.4,0.80, Config.SpeedSteps[2] .. unitLabel .. ": " .. speedStep2, 245, 217, 39, 240)
				end

				if speedStep3 <= 0 then
					drawTxt(0.99, 0.9250, 0.4,0.4,0.80, Config.SpeedSteps[3] .. unitLabel .. ": " .. speedStep3, 210, 210, 210, 240)
				else
					drawTxt(0.99, 0.9250, 0.4,0.4,0.80, Config.SpeedSteps[3] .. unitLabel .. ": " .. speedStep3, 245, 217, 39, 240)
				end

				if speedStep4 <= 0 then
					drawTxt(0.99, 0.9475, 0.4,0.4,0.80, Config.SpeedSteps[4] .. unitLabel .. ": " .. speedStep4, 210, 210, 210, 240)
				else
					drawTxt(0.99, 0.9475, 0.4,0.4,0.80, Config.SpeedSteps[4] .. unitLabel .. ": " .. speedStep4, 245, 217, 39, 240)
				end

				drawCenterMass(carPos, forPos, backPos, LPos, RPos, forPos2, backPos2, LPos2, RPos2)
			else
				drawTxt(0.8, 0.52, 0.4,0.4,0.30, "You are not in a vehicle", 255, 75, 71, 255)
			end
        else
            Wait(5000)
        end
    end
end)
