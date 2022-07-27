QBCore.Commands.Add("vehdebug", "Vehicle debugger for tune balancing", {}, false, function(source)
    local src = source
    TriggerClientEvent("vDebug:toggle", src)
end, Config.Permission)
