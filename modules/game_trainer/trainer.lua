trainerButton = nil
trainerWindow = nil
checkboxStatus = false
manaTraining = false
autoEaterStatus = false
antiIdleEvent = nil
magicLevelTrainingEvent = nil
autoEaterEvent = nil
spellNameTextEdit = nil
autoEatStatus = nil
FOODS = {
    3725,
    3577, -- meat
    3578, -- fish
    3579, -- ham
    3580, -- dragon ham
    3582, -- bread
    3583, -- brown bread
    3595, -- carrot
    3597, -- corn
    3600,
    3601,
    3602,
}
player = nil
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
        '/images/topbuttons/robot', toggle)
    g_keyboard.bindKeyDown('Escape', hide)
    trainerWindow = g_ui.displayUI('trainer')
    hide()
    
    -- ProtocolGame.registerExtendedOpcode(14, onExtendedOpcode)
end

function show()
    trainerButton:setOn(true)
    trainerWindow:show()
    trainerWindow:focus()
    -- trainerWindow:setup()

    player = g_game.getLocalPlayer()
end

function hide()
    trainerButton:setOn(false)
    trainerWindow:hide()
end

function terminate()
    trainerWindow:destroy()
    trainerButton:destroy()
    player = nil
    if antiIdleEvent ~= nil then
        antiIdleEvent:cancel()
        antiIdleEvent = nil
    end
    if magicLevelTrainingEvent ~=nil then
        magicLevelTrainingEvent:cancel()
        magicLevelTrainingEvent = nil
    end
    if autoEaterEvent ~= nil then
        autoEaterEvent:cancel()
        autoEaterEvent = nil
    end
    -- ProtocolGame.unregisterExtendedOpcode(14, onExtendedOpcode)
end

function changeStatus()
    checkbox = trainerWindow:recursiveGetChildById('antiIdleCheck')
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

function onMiniWindowOpen()
    trainerButton:setOn(true)
end

function onMiniWindowClose()
    trainerButton:setOn(false)
end

function online()
    trainerWindow:setupOnStart() -- load character window configuration
    hide()
end

function offline()
    trainerWindow:setParent(nil, true)
end

function startMagicLevelTraining()
    if g_game.isOnline() then
        minMana = tonumber(trainerWindow:recursiveGetChildById('minMana'):getText())
        spellText = trainerWindow:recursiveGetChildById('spellNameTextEdit'):getText()
        if type(minMana) == "number" then
            if(tonumber(player:getMana()) > minMana) then
                modules.game_console.sendMessage(spellText)
            end
        end
    end
    magicLevelTrainingEvent = scheduleEvent(startMagicLevelTraining, 3000)
end

function magLevelTrainer()
    checkbox = trainerWindow:recursiveGetChildById('manaTrainingCheckBox')
    manaTraining = not manaTraining
    checkbox:setChecked(manaTraining)

    if manaTraining then
        startMagicLevelTraining()
    else
        magicLevelTrainingEvent:cancel()
        magicLevelTrainingEvent = nil
    end
end

  function startAutoEaterEvent() 
    for k, v in pairs(FOODS) do
        item = player:getItem(v)
        if item ~= nil then
            g_game.use(item)
            break
        end
    end
    autoEaterEvent = scheduleEvent(startAutoEaterEvent, 60000)
end

function autoEater()
        checkbox = trainerWindow:recursiveGetChildById('autoEatCheckBox')
        autoEaterStatus = not autoEaterStatus
        checkbox:setChecked(autoEaterStatus)
    
        if autoEaterStatus then
            startAutoEaterEvent()
        else
            autoEaterEvent:cancel()
            autoEaterEvent = nil
        end
    end