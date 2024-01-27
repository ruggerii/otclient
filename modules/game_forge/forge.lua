
local window = nil



function init()
    connect(g_game, {
        onGameStart = onGameStart,
        onGameEnd = destroy
    })
    window = g_ui.displayUI('forge')
    g_keyboard.bindKeyDown('Escape', hideWindow)

    window:setVisible(false)
    ProtocolGame.registerExtendedOpcode(216, parseOpcodeForge)
end


function terminate()

    ProtocolGame.unregisterExtendedOpcode(216, parseOpcodeForge)
end


function parseOpcodeForge(protocol, opcode, data)

    local decodedData = json.decode(data)
    if decodedData['operation'] == 'openWindow' then
        toggleWindow()
    end

end


function toggleWindow()
    if (not g_game.isOnline()) then
        return
    end

    if (window:isVisible()) then
        hideWindow()
    else
        window:setVisible(true)
    end
end

function hideWindow() 
    window:setVisible(false)
    window.item:setItemId(nil)
end

function onChooseItemByDrag(self, mousePos, item, widgetId)
    g_logger.info('onChooseItemByDrag ' .. dump(item))
    g_logger.info('mousePos ' .. dump(mousePos))
    window[widgetId]:setItemId(item:getId())
    
end