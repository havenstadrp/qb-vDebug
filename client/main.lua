local debug, displayed = false, false
local ped, veh, vehModel, speed = nil, nil, nil, 0

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

local function drawLines(carPos, forPos, backPos, LPos, RPos, forPos2, backPos2, LPos2, RPos2)
	DrawLine(carPos,forPos, 255,0,0,255)
	DrawLine(carPos,backPos, 255,0,0,255)
	DrawLine(carPos,LPos, 255,255,0,255)
	DrawLine(carPos,RPos, 255,255,0,255)           
	DrawLine(forPos,forPos2, 255,0,255,255)
	DrawLine(backPos,backPos2, 255,0,255,255)
	DrawLine(LPos,LPos2, 255,255,255,255)
	DrawLine(RPos,RPos2, 255,255,255,255)
end

local function updateTime(accel, brake, mph, units, speed1, speed2, speed3, speed4)
    SendNUIMessage({
        action = 'UPDATE_TIME',
        data = {
			accel = accel,
			brake = brake,
			mph = mph,
			units = units,
			speed1 = speed1,
			speed2 = speed2,
			speed3 = speed3,
			speed4 = speed4,
			step1 = Config.SpeedSteps[1],
			step2 = Config.SpeedSteps[2],
			step3 = Config.SpeedSteps[3],
			step4 = Config.SpeedSteps[4],
		}
    })
    Wait(1)
end

local function updateVeh(veh, vehModel, speed, topSpeed)
	if GetVehicleCurrentGear(veh) == 0 then currGear = "R" else currGear = GetVehicleCurrentGear(veh) end
	if (GetVehicleCurrentRpm(veh)*6000) < 1201 then currRPM = 0.0 else currRPM = (GetVehicleCurrentRpm(veh)*6000) end
	if speed == -1 then speed = 0 end
    SendNUIMessage({
        action = 'UPDATE_VEH',
        data = {
			model = vehModel,
			engine = math.ceil(GetVehicleEngineHealth(veh)),
			body = math.ceil(GetVehicleBodyHealth(veh)),
			tank = math.ceil(GetVehiclePetrolTankHealth(veh)),
			gear = currGear .. "/" .. GetVehicleHighGear(veh),
			rpm = math.ceil(currRPM),
			mph = math.ceil(speed),
			topSpeed = math.ceil(topSpeed),
		}
    })
    Wait(1)
end

local function resetData()
    SendNUIMessage({
        action = 'RESET_DATA',
    })
    Wait(1)
end

local function showUI()
    SendNUIMessage({
        action = 'SHOW_UI',
		data = {
			reset = Config.ResetLabel,
			teleport = Config.TeleportToCoordsLabel,
		}
    })
    Wait(1)
end

local function hideUI()
    SendNUIMessage({
        action = 'HIDE_UI',
    })
    Wait(1)
end

local function checkControls(ped, veh, x, y, z)
	if Config.UseFlip then
		if IsControlJustPressed(1, Config.Flip) then
			SetPedCoordsKeepVehicle(ped, x, y, z)
		end
	end
	if (IsControlJustReleased(1, Config.TeleportToCoordsKey)) then
		SetEntityCoordsNoOffset(veh, Config.TeleportToCoords, false, false, false, false)
		SetEntityHeading(veh, Config.TeleportToCoordsHeading)
	end
	if (IsControlJustReleased(1, Config.Reset)) then
		topSpeed = 0
		accelTime = 0
		brakeTime = 0
		speedStep1 = 0
		speedStep2 = 0
		speedStep3 = 0
		speedStep4 = 0
		startAccelTime = 0
		startBrakeTime = 0
		startAccelTime = GetGameTimer()
		resetData()
		PlaySoundFrontend(-1, "Apt_Style_Purchase", "DLC_APT_Apartment_SoundSet")
	end
	if (IsControlJustPressed(0, 32) and not IsControlPressed(0, 18)) or IsControlJustReleased(0, 18) then
		accelTime = 0
		speedStep1 = 0
		speedStep2 = 0
		speedStep3 = 0
		speedStep4 = 0
		startAccelTime = GetGameTimer()
	end
	if IsControlPressed(0, 32) then
		accelTime = GetGameTimer() - startAccelTime
	end
	if IsControlJustPressed(0, 8) and GetEntitySpeed(ped) > 0.0 then
		brakeTime = 0
		startBrakeTime = GetGameTimer()
	end
	if IsControlPressed(0, 8) and GetEntitySpeed(ped) > 5 then
		brakeTime = GetGameTimer() - startBrakeTime
	end
end

RegisterNetEvent("vDebug:toggle",function()
	local msg, status
	debug = not debug
	if debug then msg = "Activated" else msg = "Deactivated" end
	if debug then status = "success" else status = "error" end
	QBCore.Functions.Notify("[vDebug Tool]: "..msg, status)
end)

CreateThread( function()
	topSpeed = 0
    accelTime = 0
    brakeTime = 0
	speedStep1 = 0
    speedStep2 = 0
    speedStep3 = 0
    speedStep4 = 0
    startAccelTime = 0
    startBrakeTime = 0

	if Config.Speed == "KMH" then speedUnit = 3.6 else speedUnit = 2.236936 end
	if Config.Speed == "KMH" then unitLabel = "km/h" else unitLabel = "mph" end
    
    while true do 
        Wait(1)
        if debug then
			if IsPedInAnyVehicle(PlayerPedId(), false) then
				ped = PlayerPedId()
				veh = GetVehiclePedIsIn(PlayerPedId(), false)
				vehModel = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
				speed = (GetEntitySpeed(ped) * speedUnit) - 1

				updateVeh(veh, vehModel, speed, topSpeed)
				updateTime(accelTime / 1000, brakeTime / 1000, speed, unitLabel, speedStep1, speedStep2, speedStep3, speedStep4)

				if not displayed then
					showUI()
					displayed = true
				end
			end
        else
			if displayed then
				hideUI()
				displayed = false
				veh = nil
				vehModel = nil
			end
            Wait(5000)
        end
    end
end)

CreateThread(function()
	while true do
		Wait(1)
		if debug then
			if IsPedInAnyVehicle(PlayerPedId(), false) then
				local carPos = GetEntityCoords(veh)
				local forPos = GetOffsetFromEntityInWorldCoords(veh, 0, 1.0, 0.0)
				local backPos = GetOffsetFromEntityInWorldCoords(veh, 0, -1.0, 0.0)
				local LPos = GetOffsetFromEntityInWorldCoords(veh, 1.0, 0.0, 0.0)
				local RPos = GetOffsetFromEntityInWorldCoords(veh, -1.0, 0.0, 0.0) 
	
				local forPos2 = GetOffsetFromEntityInWorldCoords(veh, 0, 2.0, 0.0)
				local backPos2 = GetOffsetFromEntityInWorldCoords(veh, 0, -2.0, 0.0)
				local LPos2 = GetOffsetFromEntityInWorldCoords(veh, 2.0, 0.0, 0.0)
				local RPos2 = GetOffsetFromEntityInWorldCoords(veh, -2.0, 0.0, 0.0) 

				if topSpeed < speed then
					topSpeed = speed
				end
				if speed >= (Config.SpeedSteps[1]) and IsControlPressed(0, 32) and speedStep1 == 0 then
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

				checkControls(ped, veh, carPos.x, carPos.y, carPos.z)
				drawLines(carPos, forPos, backPos, LPos, RPos, forPos2, backPos2, LPos2, RPos2)
			else
				drawTxt(0.8, 0.52, 0.4,0.4,0.30, "You are not in a vehicle", 255, 75, 71, 255)
			end
		else
			Wait(5000)
		end
	end
end)
