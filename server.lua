RegisterNetEvent("ragdoll:resetWalk")

AddEventHandler("ragdoll:resetWalk", function()
	TriggerClientEvent("ragdoll:resetWalk", -1, source)
end)
