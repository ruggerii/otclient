InventorySlotStyles = {
    [InventorySlotHead] = 'HeadSlot',
    [InventorySlotNeck] = 'NeckSlot',
    [InventorySlotBack] = 'BackSlot',
    [InventorySlotBody] = 'BodySlot',
    [InventorySlotRight] = 'RightSlot',
    [InventorySlotLeft] = 'LeftSlot',
    [InventorySlotLeg] = 'LegSlot',
    [InventorySlotFeet] = 'FeetSlot',
    [InventorySlotFinger] = 'FingerSlot',
    [InventorySlotAmmo] = 'AmmoSlot'
}

inventoryWindow = nil
inventoryPanel = nil
inventoryButton = nil
purseButton = nil



-- COMBAT CONTROLS

combatControlsButton = nil
combatControlsWindow = nil
fightOffensiveBox = nil
fightBalancedBox = nil
fightDefensiveBox = nil
chaseModeButton = nil
safeFightButton = nil
whiteDoveBox = nil
whiteHandBox = nil
yellowHandBox = nil
redFistBox = nil
mountButton = nil
pvpModesPanel = nil
fightModeRadioGroup = nil
pvpModeRadioGroup = nil

function init()
    connect(LocalPlayer, {
        onInventoryChange = onInventoryChange,
        onBlessingsChange = onBlessingsChange
    })
    connect(g_game, {
        onGameStart = online,
        onGameEnd = offline
    })

    g_keyboard.bindKeyDown('Ctrl+I', toggle)

    inventoryButton = modules.client_topmenu.addRightGameToggleButton('inventoryButton', tr('Inventory') .. ' (Ctrl+I)',
                                                                      '/images/topbuttons/inventory', toggle)
    inventoryButton:setOn(true)

    inventoryWindow = g_ui.loadUI('inventory')
    inventoryWindow:disableResize()
    inventoryPanel = inventoryWindow:getChildById('contentsPanel')

    purseButton = inventoryPanel:getChildById('purseButton')
    local function purseFunction()
        local purse = g_game.getLocalPlayer():getInventoryItem(InventorySlotPurse)
        if purse then
            g_game.use(purse)
        end
    end
    purseButton.onClick = purseFunction

    refresh()
    -- inventoryWindow:setup()
    if g_game.isOnline() then
        inventoryWindow:setupOnStart()
    end


    -- INIT Combat Controls

fightOffensiveBox = inventoryWindow:recursiveGetChildById('fightOffensiveBox')
fightBalancedBox = inventoryWindow:recursiveGetChildById('fightBalancedBox')
fightDefensiveBox = inventoryWindow:recursiveGetChildById('fightDefensiveBox')

chaseModeButton = inventoryWindow:recursiveGetChildById('chaseModeBox')
safeFightButton = inventoryWindow:recursiveGetChildById('safeFightBox')


whiteDoveBox = inventoryWindow:recursiveGetChildById('whiteDoveBox')
whiteHandBox = inventoryWindow:recursiveGetChildById('whiteHandBox')
yellowHandBox = inventoryWindow:recursiveGetChildById('yellowHandBox')
redFistBox = inventoryWindow:recursiveGetChildById('redFistBox')

fightModeRadioGroup = UIRadioGroup.create()
fightModeRadioGroup:addWidget(fightOffensiveBox)
fightModeRadioGroup:addWidget(fightBalancedBox)
fightModeRadioGroup:addWidget(fightDefensiveBox)

-- pvpModeRadioGroup = UIRadioGroup.create()
-- pvpModeRadioGroup:addWidget(whiteDoveBox)
-- pvpModeRadioGroup:addWidget(whiteHandBox)
-- pvpModeRadioGroup:addWidget(yellowHandBox)
-- pvpModeRadioGroup:addWidget(redFistBox)

connect(fightModeRadioGroup, {
onSelectionChange = onSetFightMode
})
-- connect(pvpModeRadioGroup, {
-- onSelectionChange = onSetPVPMode
-- })
connect(chaseModeButton, {
onCheckChange = onSetChaseMode
})
connect(safeFightButton, {
onCheckChange = onSetSafeFight
})
connect(g_game, {
onGameStart = online,
onGameEnd = offline,
onFightModeChange = update,
onChaseModeChange = update,
onSafeFightChange = update,
onPVPModeChange = update,
onWalk = check,
onAutoWalk = check
})

connect(LocalPlayer, {
onOutfitChange = onOutfitChange
})

if g_game.isOnline() then
online()
end

inventoryWindow:setup()

end

function terminate()
    disconnect(LocalPlayer, {
        onInventoryChange = onInventoryChange,
        onBlessingsChange = onBlessingsChange
    })
    disconnect(g_game, {
        onGameStart = online,
        onGameEnd = offline
    })

    g_keyboard.unbindKeyDown('Ctrl+I')

    inventoryWindow:destroy()
    inventoryButton:destroy()

    inventoryWindow = nil
    inventoryPanel = nil
    inventoryButton = nil
    purseButton = nil

    -- COMBAR CONTROLS terminate
    if g_game.isOnline() then
        offline()
    end
    if fightModeRadioGroup ~= nil then
        fightModeRadioGroup:destroy()
    end
    -- pvpModeRadioGroup:destroy()
    if combatControlsWindow ~= nil then
    combatControlsWindow:destroy()
    end
    if combatControlsButton ~= nil then
    combatControlsButton:destroy()
    end
    disconnect(g_game, {
        onGameStart = online,
        onGameEnd = offline,
        onFightModeChange = update,
        onChaseModeChange = update,
        onSafeFightChange = update,
        onPVPModeChange = update,
        onWalk = check,
        onAutoWalk = check
    })

    disconnect(LocalPlayer, {
        onOutfitChange = onOutfitChange
    })

    combatControlsButton = nil
    combatControlsWindow = nil
    fightOffensiveBox = nil
    fightBalancedBox = nil
    fightDefensiveBox = nil
    chaseModeButton = nil
    safeFightButton = nil
    whiteDoveBox = nil
    whiteHandBox = nil
    yellowHandBox = nil
    redFistBox = nil
    mountButton = nil
    pvpModesPanel = nil
    fightModeRadioGroup = nil
    pvpModeRadioGroup = nil

end

function toggleAdventurerStyle(hasBlessing)
    for slot = InventorySlotFirst, InventorySlotLast do
        local itemWidget = inventoryPanel:getChildById('slot' .. slot)
        if itemWidget then
            itemWidget:setOn(hasBlessing)
        end
    end
end

function online()
    inventoryWindow:setupOnStart() -- load character window configuration
    refresh()

    -- Combat Controls
    local player = g_game.getLocalPlayer()
    if player then
        local char = g_game.getCharacterName()

        local lastCombatControls = g_settings.getNode('LastCombatControls')

        if not table.empty(lastCombatControls) then
            if lastCombatControls[char] then
                g_game.setFightMode(lastCombatControls[char].fightMode)
                g_game.setChaseMode(lastCombatControls[char].chaseMode)
                g_game.setSafeFight(lastCombatControls[char].safeFight)
                if lastCombatControls[char].pvpMode then
                    g_game.setPVPMode(lastCombatControls[char].pvpMode)
                end
            end
        end

        -- if g_game.getFeature(GamePlayerMounts) then
        --     mountButton:setVisible(true)
        --     mountButton:setChecked(player:isMounted())
        -- else
        --     mountButton:setVisible(false)
        -- end

        -- if g_game.getFeature(GamePVPMode) then
        --     pvpModesPanel:setVisible(true)
        --     combatControlsWindow:setHeight(combatControlsWindow.extendedControlsHeight)
        -- else
        --     pvpModesPanel:setVisible(false)
        --     combatControlsWindow:setHeight(combatControlsWindow.simpleControlsHeight)
        -- end
    end

    update()
end

function offline()
    inventoryWindow:setParent(nil, true)

    -- Combat Controls
    local lastCombatControls = g_settings.getNode('LastCombatControls')
    if not lastCombatControls then
        lastCombatControls = {}
    end

    local player = g_game.getLocalPlayer()
    if player then
        local char = g_game.getCharacterName()
        lastCombatControls[char] = {
            fightMode = g_game.getFightMode(),
            chaseMode = g_game.getChaseMode(),
            safeFight = g_game.isSafeFight()
        }

        if g_game.getFeature(GamePVPMode) then
            lastCombatControls[char].pvpMode = g_game.getPVPMode()
        end

        -- save last combat control settings
        g_settings.setNode('LastCombatControls', lastCombatControls)
    end
end

function refresh()
    local player = g_game.getLocalPlayer()
    for i = InventorySlotFirst, InventorySlotPurse do
        if g_game.isOnline() then
            onInventoryChange(player, i, player:getInventoryItem(i))
        else
            onInventoryChange(player, i, nil)
        end
        toggleAdventurerStyle(player and Bit.hasBit(player:getBlessings(), Blessings.Adventurer) or false)
    end

    purseButton:setVisible(g_game.getFeature(GamePurseSlot))
end

function toggle()
    if inventoryButton:isOn() then
        inventoryWindow:close()
        inventoryButton:setOn(false)
    else
        inventoryWindow:open()
        inventoryButton:setOn(true)
    end
end

function onMiniWindowOpen()
    inventoryButton:setOn(true)
end

function onMiniWindowClose()
    inventoryButton:setOn(false)
end

-- hooked events
function onInventoryChange(player, slot, item, oldItem)
    if slot > InventorySlotPurse then
        return
    end

    if slot == InventorySlotPurse then
        if g_game.getFeature(GamePurseSlot) then
            purseButton:setEnabled(item and true or false)
        end
        return
    end

    local itemWidget = inventoryPanel:getChildById('slot' .. slot)
    if item then
        itemWidget:setStyle('InventoryItem')
        itemWidget:setItem(item)
    else
        itemWidget:setStyle(InventorySlotStyles[slot])
        itemWidget:setItem(nil)
    end
end

function onBlessingsChange(player, blessings, oldBlessings)
    local hasAdventurerBlessing = Bit.hasBit(blessings, Blessings.Adventurer)
    if hasAdventurerBlessing ~= Bit.hasBit(oldBlessings, Blessings.Adventurer) then
        toggleAdventurerStyle(hasAdventurerBlessing)
    end
end



--  COMBAR CONTROLS
function update()
    local fightMode = g_game.getFightMode()
    if fightMode == FightOffensive then
        fightModeRadioGroup:selectWidget(fightOffensiveBox)
    elseif fightMode == FightBalanced then
        fightModeRadioGroup:selectWidget(fightBalancedBox)
    else
        fightModeRadioGroup:selectWidget(fightDefensiveBox)
    end

    local chaseMode = g_game.getChaseMode()
    chaseModeButton:setChecked(chaseMode == ChaseOpponent)

    local safeFight = g_game.isSafeFight()
    safeFightButton:setChecked(not safeFight)

    if g_game.getFeature(GamePVPMode) then
        local pvpMode = g_game.getPVPMode()
        local pvpWidget = getPVPBoxByMode(pvpMode)
        if pvpWidget then
            -- pvpModeRadioGroup:selectWidget(pvpWidget)
        end
    end
end

function check()
    if modules.client_options.getOption('autoChaseOverride') then
        if g_game.isAttacking() and g_game.getChaseMode() == ChaseOpponent then
            g_game.setChaseMode(DontChase)
        end
    end
end

function onSetFightMode(self, selectedFightButton)
    if selectedFightButton == nil then
        return
    end
    local buttonId = selectedFightButton:getId()
    local fightMode
    if buttonId == 'fightOffensiveBox' then
        fightMode = FightOffensive
    elseif buttonId == 'fightBalancedBox' then
        fightMode = FightBalanced
    else
        fightMode = FightDefensive
    end
    g_game.setFightMode(fightMode)
end

function toggleChaseMode()
    chaseModeButton:setChecked(not chaseModeButton:isChecked())
end

function onSetChaseMode(self, checked)
    local chaseMode
    if checked then
        chaseMode = ChaseOpponent
    else
        chaseMode = DontChase
    end
    g_game.setChaseMode(chaseMode)
end

function onSetSafeFight(self, checked)
    g_game.setSafeFight(not checked)
end

function onSetPVPMode(self, selectedPVPButton)
    if selectedPVPButton == nil then
        return
    end

    local buttonId = selectedPVPButton:getId()
    local pvpMode = PVPWhiteDove
    if buttonId == 'whiteDoveBox' then
        pvpMode = PVPWhiteDove
    elseif buttonId == 'whiteHandBox' then
        pvpMode = PVPWhiteHand
    elseif buttonId == 'yellowHandBox' then
        pvpMode = PVPYellowHand
    elseif buttonId == 'redFistBox' then
        pvpMode = PVPRedFist
    end

    g_game.setPVPMode(pvpMode)
end

-- function onMountButtonClick(self, mousePos)
--     local player = g_game.getLocalPlayer()
--     if player then
--         player:toggleMount()
--     end
-- end

function getPVPBoxByMode(mode)
    local widget = nil
    if mode == PVPWhiteDove then
        widget = whiteDoveBox
    elseif mode == PVPWhiteHand then
        widget = whiteHandBox
    elseif mode == PVPYellowHand then
        widget = yellowHandBox
    elseif mode == PVPRedFist then
        widget = redFistBox
    end
    return widget
end