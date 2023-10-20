trainerButton = nil
trainerWindow = nil
checkboxStatus = false
manaTraining = false
antiIdleEvent = nil
magicLevelTrainingEvent = nil
spellNameTextEdit = nil
autoEatStatus = nil

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
    trainerWindow = g_ui.displayUI('trainer')
    hide()
    -- ProtocolGame.registerExtendedOpcode(14, onExtendedOpcode)
end

function show()
    trainerButton:setOn(true)
    trainerWindow:show()
    trainerWindow:focus()
    -- trainerWindow:setup()

    spellNameTextEdit = trainerWindow:recursiveGetChildById('spellNameTextEdit')
    spellNameTextEdit:setOn(true)
    spellNameTextEdit:focus()
    spellNameTextEdit:setText('utevo lux')
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
    -- sendMyCode()
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

function sendMyCode()
    local myData = {
      a = "string",
      b = 123,
      c = {
        x = "string in table",
        y = 456
      }
    }
  
    local protocolGame = g_game.getProtocolGame()
    if protocolGame then
      protocolGame:sendExtendedJSONOpcode(14, myData)
    end
  end
  
  function onExtendedOpcode(protocol, code, buffer)
    local json_status, json_data =
      pcall(
      function()
        return json.decode(buffer)
      end
    )
  
    if not json_status then
      g_logger.error("[My Module] JSON error: " .. json_data)
      return false
    end
  
    g_logger.info(json_data.taskName)
    g_logger.info(json_data.monstersLeft)
  end