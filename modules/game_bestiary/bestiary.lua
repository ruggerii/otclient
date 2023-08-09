




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

function initializeCreatures()
    for i = 1, #SpelllistSettings[SpelllistProfile].spellOrder do
        local spell = SpelllistSettings[SpelllistProfile].spellOrder[i]
        local info = SpellInfo[SpelllistProfile][spell]

        local tmpLabel = g_ui.createWidget('SpellListLabel', spellList)
        tmpLabel:setId(spell)
        tmpLabel:setText(spell .. '\n\'' .. info.words .. '\'')
        tmpLabel:setPhantom(false)

        -- local iconId = tonumber(info.icon)
        -- if not iconId and SpellIcons[info.icon] then
        --     iconId = SpellIcons[info.icon][1]
        -- end

        -- if not (iconId) then
        --     perror('Spell icon \'' .. info.icon .. '\' not found.')
        -- end

        -- tmpLabel:setHeight(SpelllistSettings[SpelllistProfile].iconSize.height + 4)
        -- tmpLabel:setTextOffset(topoint((SpelllistSettings[SpelllistProfile].iconSize.width + 10) .. ' ' ..
        --                                    (SpelllistSettings[SpelllistProfile].iconSize.height - 32) / 2 + 3))
        -- tmpLabel:setImageSource(SpelllistSettings[SpelllistProfile].iconFile)
        -- tmpLabel:setImageClip(Spells.getImageClip(iconId, SpelllistProfile))
        -- tmpLabel:setImageSize(tosize(SpelllistSettings[SpelllistProfile].iconSize.width .. ' ' ..
        --                                  SpelllistSettings[SpelllistProfile].iconSize.height))
        -- tmpLabel.onClick = updateSpellInformation
    end

end

function init()
    g_ui.importStyle('BestiaryButton')
    bestiaryButton = modules.client_topmenu.addRightGameToggleButton('bestiaryButton', tr('Bestiary') .. ' (Ctrl+B)',
                                                               '/images/topbuttons/battle', toggle)
    bestiaryButton:setOn(false)
    initializeCreatures()
end

function loadCreatures()
    g_logger.info('creatures loaded')
   
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

function initializeCreatures()

    for i = 1, 12 do
        local spell = SpelllistSettings[SpelllistProfile].spellOrder[i]
        local info = SpellInfo[SpelllistProfile][spell]

        local tmpLabel = g_ui.createWidget('SpellListLabel', spellList)
        tmpLabel:setId(spell)
        tmpLabel:setText(spell .. '\n\'' .. info.words .. '\'')
        tmpLabel:setPhantom(false)

        local iconId = tonumber(info.icon)
        if not iconId and SpellIcons[info.icon] then
            iconId = SpellIcons[info.icon][1]
        end

        if not (iconId) then
            perror('Spell icon \'' .. info.icon .. '\' not found.')
        end

        tmpLabel:setHeight(SpelllistSettings[SpelllistProfile].iconSize.height + 4)
        tmpLabel:setTextOffset(topoint((SpelllistSettings[SpelllistProfile].iconSize.width + 10) .. ' ' ..
                                           (SpelllistSettings[SpelllistProfile].iconSize.height - 32) / 2 + 3))
        tmpLabel:setImageSource(SpelllistSettings[SpelllistProfile].iconFile)
        tmpLabel:setImageClip(Spells.getImageClip(iconId, SpelllistProfile))
        tmpLabel:setImageSize(tosize(SpelllistSettings[SpelllistProfile].iconSize.width .. ' ' ..
                                         SpelllistSettings[SpelllistProfile].iconSize.height))
        tmpLabel.onClick = updateSpellInformation
    end
end