local window = nil
local selectedEntry = nil
local consoleEvent = nil
local taskButton
local playerTask = nil
local rewardSelected = nil

taskListVisible = true

function init()
    connect(g_game, {
        onGameStart = onGameStart,
        onGameEnd = destroy
    })

    window = g_ui.displayUI('tasks')
    window:setVisible(false)
    g_keyboard.bindKeyDown('Ctrl+T', toggleWindow)
    g_keyboard.bindKeyDown('Escape', hideWindowzz)
	taskButton = modules.client_topmenu.addLeftGameButton('taskButton', tr('Tasks'), '/modules/game_tasks/images/taskIcon', toggleWindow)
    ProtocolGame.registerExtendedOpcode(215, parseOpcode)
end

function terminate()
    disconnect(g_game, {
        onGameEnd = destroy
    })
    ProtocolGame.unregisterExtendedOpcode(215, parseOpcode)
    taskButton:destroy()
    destroy()
end

function onGameStart()
    if (window) then
        window:destroy()
        window = nil
    end

    window = g_ui.displayUI('tasks')
    window:setVisible(false)
    window.listSearch.search.onKeyPress = onFilterSearch
end

function destroy()
    if (window) then
        window:destroy()
        window = nil
    end
end

function parseOpcode(protocol, opcode, data)
    updateTasks(data)
end

function sendOpcode(data)
    local protocolGame = g_game.getProtocolGame()

    if protocolGame then
        protocolGame:sendExtendedJSONOpcode(215, data)
    end
end

function onTaskSelect(list, focusedChild, unfocusedChild, reason)
    if focusedChild then
        selectedEntry = tonumber(focusedChild:getId())

        if (not selectedEntry) then
            return true
        end

        window.finishButton:hide()
        window.startButton:hide()
        window.abortButton:hide()
        local children = window.selectionList:getChildren()

        for _, child in ipairs(children) do
            local id = tonumber(child:getId())

            if (selectedEntry == id) then
                local kills = child.kills:getText()

                if (child.progress:getWidth() == 159) then
                    window.finishButton:show()
                elseif (kills:find('/')) then
                    window.abortButton:show()
                else
                    window.startButton:show()
                end
            end
        end
    end
end

function onFilterSearch()
    addEvent(function()
        local searchText = window.listSearch.search:getText():lower():trim()
        local children = window.selectionList:getChildren()

        if (searchText:len() >= 1) then
            for _, child in ipairs(children) do
                local text = child.name:getText():lower()

                if (text:find(searchText)) then
                    child:show()
                else
                    child:hide()
                end
            end
        else
            for _, child in ipairs(children) do
                child:show()
            end
        end
    end)
end

function start()
    if (not selectedEntry) then
        return not setTaskConsoleText("Please select monster from monster list.", "red")
    end

    sendOpcode({
        action = 'start',
        entry = selectedEntry
    })
end

function finish()
    if (not selectedEntry) then
        return not setTaskConsoleText("Please select monster from monster list.", "red")
    end

    sendOpcode({
        action = 'finish',
        entry = selectedEntry
    })
end

function abort()
    local cancelConfirm = nil

    if (cancelConfirm) then
        cancelConfirm:destroy()
        cancelConfirm = nil
    end

    if (not selectedEntry) then
        return not setTaskConsoleText("Please select monster from monster list.", "red")
    end

    local yesFunc = function()
        cancelConfirm:destroy()
        cancelConfirm = nil
        sendOpcode({
            action = 'cancel',
            entry = selectedEntry
        })
    end

    local noFunc = function()
        cancelConfirm:destroy()
        cancelConfirm = nil
    end

    cancelConfirm = displayGeneralBox(tr('Tasks'), tr("Do you really want to abort this task?"), {
        {
            text = tr('Yes'),
            callback = yesFunc
        },
        {
            text = tr('No'),
            callback = noFunc
        },
        anchor = AnchorHorizontalCenter
    }, yesFunc, noFunc)
end

function updateTasks(data)
    decodedData = json.decode(data)
    if(decodedData['message'] == 'reward') then
        hideWindowzz()
        return
    end

    if (decodedData['rewardShopList'] ~= nil) then
        getTaskStopRewards(decodedData['rewardShopList'])
    end

    if (decodedData['message']) then
        return setTaskConsoleText(decodedData['message'], decodedData['color'])
    end

    window.taskPointsLabel:setText('Task Points: ' .. decodedData['playerTaskPoints'])

    window.selectionList:destroyChildren()
    playerTask = decodedData['playerTasks']
    local playerTaskIds = {}
    local selectionList = window.selectionList
    if next(playerTask) ~= nil then
        taskKillDone = 0
        if decodedData['monstersLeft'] ~= playerTask.toKill then
            taskKillDone = playerTask.toKill - decodedData['monstersLeft']
        end
        selectionList.onChildFocusChange = onTaskSelect
        selectionList:destroyChildren()
        
            local button = g_ui.createWidget("SelectionButton", window.selectionList)
            button:setId(playerTask.id)
            table.insert(playerTaskIds, playerTask.id)
            button.creature:setOutfit(playerTask.looktype)
            button.name:setText(playerTask.name)
            button.kills:setText('Kills: ' .. taskKillDone .. '/' .. playerTask.toKill)
            button.reward:setText(playerTask.formatedTextReward)
            if not (playerTask.taskPoints == nil) then
                  button.rewardTaskPoints:setText('Task Points: ' .. playerTask.taskPoints .. '')
                else
                      button.rewardTaskPoints:setText('Task Points: 0')
                    end
                    local progress = 159 * taskKillDone / playerTask.toKill
                    button.progress:setWidth(progress)
    end

    for _, task in ipairs(decodedData['allTasks']) do
        if (not table.contains(playerTaskIds, task.id)) then
            local button = g_ui.createWidget("SelectionButton", window.selectionList)
            button:setId(task.id)
            button.creature:setOutfit(task.looktype)
            button.name:setText(task.name)
            button.kills:setText('Kills: ' .. task.toKill)
            button.reward:setText(task.formatedTextReward)
            if not (task.taskPoints == nil) then
              button.rewardTaskPoints:setText('Task Points: ' .. task.taskPoints .. '')
            else
              button.rewardTaskPoints:setText('Task Points: 0')
            end
            button.progress:setWidth(0)
            selectionList:focusChild(button)
        end
    end
    selectionList.onChildFocusChange = onTaskSelect
    selectionList:focusChild(selectionList:getFirstChild())
    onFilterSearch()
end

function toggleWindow()
    if (not g_game.isOnline()) then
        return
    end

    if (window:isVisible()) then
        window:setVisible(false)
    else
        local children = window.selectionList:getChildren()
       --if next(children) == nil then
        sendOpcode({
            action = 'info'
        })
       -- end
        window:setVisible(true)
    end
end

function hideWindowzz()
    if (not g_game.isOnline()) then
        return
    end

    if (window:isVisible()) then
        -- sendOpcode({
        --     action = 'hide'
        -- })
        window:setVisible(false)
        window.claimReward:disable()
    end
end

function setTaskConsoleText(text, color)
    if (not color) then
        color = 'white'
    end

    window.info:setText(text)
    window.info:setColor(color)

    if consoleEvent then
        removeEvent(consoleEvent)
        consoleEvent = nil
    end

    consoleEvent = scheduleEvent(function()
        window.info:setText('')
    end, 5000)

    return true
end

function showTaskShop()
    window.selectionList:setVisible(false)
    window.listSearch:setVisible(false)
    window.rewardSelectionList:setVisible(true)
    window.rewardSelectionScroll:setVisible(true)
    window.claimReward:setVisible(true)
    window.claimReward:disable()
    -- window.rewardSelectionList:destroyChildren()
end

function showTaskList()
    window.listSearch:setVisible(true)
    window.selectionList:setVisible(true)
    window.rewardSelectionList:setVisible(false)
    window.rewardSelectionScroll:setVisible(false)
    window.claimReward:setVisible(false)
end


function onRewardSelect(list, focusedChild, unfocusedChild, reason)
    rewardSelected = tonumber(focusedChild:getId())
    if rewardSelected then
        if (not rewardSelected) then
            return true
        end

        local children = window.rewardSelectionList:getChildren()

        for _, child in ipairs(children) do
            local id = tonumber(child:getId())
            local formatedRewardTaskPoints = child.taskPoints:getText():gsub('taskPoints: ', "")
            local formatedPlayerTaskPoints = window.taskPointsLabel:getText():gsub('Task Points: ', "")
            local rewardTaskPoints = tonumber(formatedRewardTaskPoints)
            local playerTaskPoints = tonumber(formatedPlayerTaskPoints)
            if rewardSelected == id then
                if playerTaskPoints < rewardTaskPoints then
                    window.claimReward:disable()
                else window.claimReward:enable()
                end
            end
        end
        end
end

function getTaskStopRewards(rewardShopList)
    local rewardSelectionList = window.rewardSelectionList
    local children = rewardSelectionList:getChildren()
        if next(children) == nil  then
            for i, reward in ipairs(rewardShopList) do
                local button = g_ui.createWidget("RewardSelectionButton", window.rewardSelectionList)
                button:setId(reward.id)
                button.item:setItemId(reward.clientItemId)
                button.count:setText(reward.itemCount .. 'x')
                button.item:setItemCount(reward.itemCount)
                button.name:setText(reward.text)
                button.taskPoints:setText('taskPoints: ' .. reward.taskPoints)
                if reward.tooltip then
                    button:setTooltip(reward.tooltip)
                end
            end
        end
        rewardSelectionList:focusChild(nil)
        rewardSelectionList.onChildFocusChange = onRewardSelect
end

function claimReward()
    if rewardSelected then
        sendOpcode({
            action = 'claimReward',
            entry = rewardSelected
        })
    end
end