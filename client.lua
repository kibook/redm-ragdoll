local isKnockedOut
local ragdollMode = GetResourceKvpInt("ragdollMode")

RegisterNetEvent("ragdoll:resetWalk")

local function IsUsingKeyboard(padIndex)
	return Citizen.InvokeNative(0xA571D46727E2B718, padIndex)
end

local function knockOut(ped)
	if not CanPedRagdoll(PlayerPedId()) then
		return
	end

	isKnockedOut = not isKnockedOut

	if isKnockedOut then
		SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true, 0, false, false) -- Prevent weapon being dropped
		ClearPedTasksImmediately(ped)
		TaskKnockedOut(ped, -1, true)
	else
		TaskKnockedOut(ped, 0, false)
		TriggerServerEvent("ragdoll:resetWalk")
	end
end

RegisterCommand("ragdoll", function(source, args, raw)
	SetPedToRagdoll(PlayerPedId(), -1, -1, 0, 0, 0, 0)
end)

RegisterCommand("ko", function(source, args, raw)
	knockOut(PlayerPedId())
end)

RegisterCommand("ragdollmode", function(source, args, raw)
	ragdollMode = (ragdollMode + 1) % 2

	local name

	if ragdollMode == 0 then
		name = "ragdoll"
	else
		name = "knockout"
	end

	TriggerEvent("chat:addMessage", {
		color = {255, 255, 128},
		args = {"Ragdoll mode", name}
	})

	SetResourceKvpInt("ragdollMode", ragdollMode)
end)

AddEventHandler("ragdoll:resetWalk", function(playerServerId)
	SetPedConfigFlag(GetPlayerPed(GetPlayerFromServerId(playerServerId)), 336, false) -- Removes injured walk style
end)

Citizen.CreateThread(function()
	TriggerEvent("chat:addSuggestion", "/ragdoll", "Go into ragdoll mode temporarily")
	TriggerEvent("chat:addSuggestion", "/ko", "Knock yourself out (use again to wake up)")

	while true do
		if IsUsingKeyboard(0) and IsControlJustPressed(0, `INPUT_OPEN_JOURNAL`) then
			local ped = PlayerPedId()

			if ragdollMode == 0 then
				SetPedToRagdoll(ped, 3000, 3000, 0, 0, 0, 0)
			else
				knockOut(ped)
			end
		end

		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do
		local ped = PlayerPedId()

		if IsPedDeadOrDying(ped) then
			isKnockedOut = false
			TriggerServerEvent("ragdoll:resetWalk")
		end

		Citizen.Wait(500)
	end
end)
