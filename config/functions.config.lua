Functions = {}

Functions.addStatus = function()
    TriggerEvent('esx_status:add', 'shower', 10000)
end

Functions.progressbar = function(time)
    exports['mythic_notify']:DoHudText('inform', 'กำลังอาบน้ำ', time)
end

Functions.clearProgressbar = function()
    TriggerEvent("mythic_progbar:client:cancel")
end

Functions.showHelpTextNotification = function()
    pcall(function()
        exports.cc_text_UI:ShowHelpNotification('กด ~INPUT_CONTEXT~ เพื่ออาบน้ำ')
    end)
end

Functions.showHelpCancelTakeShower = function()
    pcall(function()
        exports.cc_text_UI:ShowHelpNotification('กด ~INPUT_VEH_DUCK~ ยกเลิกอาบน้ำ')
    end)
end

Functions.getCleanPedStatus = function(cb)
    TriggerEvent('esx_status:getStatus', 'shower', function(status)
        local shower = status.getPercent() 
        cb(shower)
    end)
end