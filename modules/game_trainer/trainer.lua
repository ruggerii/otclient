trainerButton = nil
trainerWindow = nil
checkboxStatus = false
antiIdleEvent = nil

function toggle() -- Close/Open the battle window or Pressing Ctrl + B
    if trainerButton:isOn() then
        hide()
    else
        show()
    end
end

function init()
    g_ui.importStyle('TrainerButton')
    trainerButton = modules.client_topmenu.addLeftGameToggleButton('trainerButton', tr('Trainer') .. ' (Ctrl+B)',
                                                               '/images/topbuttons/battle', toggle)
    trainerButton:setOn(false)
end

function show()
    trainerButton:setOn(true)
    trainerWindow = g_ui.displayUI('trainer')
    trainerWindow:show()
    trainerWindow:focus()
end

function hide()
    trainerButton:setOn(false)
    trainerWindow:hide()
end

function terminate()

end

function changeStatus()
    checkbox = trainerWindow:getChildById('antiIdleCheck')
    checkboxStatus = not checkboxStatus
    checkbox:setChecked(checkboxStatus)
    if checkboxStatus then
        startAntiIdle()
    elseif antiIdleEvent ~= nil then
        antiIdleEvent:cancel()
        antiIdleEvent = nil
    end
end

function startAntiIdle()
    g_game.turn(math.random(0, 4))
    antiIdleEvent = scheduleEvent(startAntiIdle, 100000)
end