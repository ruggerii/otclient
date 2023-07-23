




local bestiaryWindow = nil
local bestiaryButton = nil
local creaturesTable = nil


function toggle() -- Close/Open the battle window or Pressing Ctrl + B
    if bestiaryButton:isOn() then
        hide()
    else
        show()
    end
end

function init()
    g_ui.importStyle('BestiaryButton')
    bestiaryButton = modules.client_topmenu.addRightGameToggleButton('bestiaryButton', tr('Bestiary') .. ' (Ctrl+B)',
                                                               '/images/topbuttons/battle', toggle)
    bestiaryButton:setOn(false)
end

function loadCreatures()
    g_logger.info('creatures loaded')
   local widget = g_ui.createWidget('Creature', bestiaryWindow)
    -- creaturesTable = bestiaryWindow:getChildById('creaturesTable')
    -- creaturesTable:addRow({{
    --     text = 'No information'
    --     }})
end

function show()
    bestiaryButton:setOn(true)
    bestiaryWindow = g_ui.displayUI('bestiary')
    bestiaryWindow:show()
    bestiaryWindow:focus() 
    loadCreatures()
end

function hide()
    bestiaryButton:setOn(false)
    bestiaryWindow:hide()
end

function terminate()

end