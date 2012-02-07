ToolTip = {}

-- private variables
local toolTipLabel
local currentHoveredWidget

-- private functions
local function moveToolTip(tooltip)
  if not tooltip:isVisible() then return end

  local pos = g_window.getMousePosition()
  pos.y = pos.y + 1
  local xdif = g_window.getSize().width - (pos.x + tooltip:getWidth())
  if xdif < 2 then
    pos.x = pos.x - tooltip:getWidth() - 3
  else
    pos.x = pos.x + 10
  end
  tooltip:setPosition(pos)
end

local function onWidgetHoverChange(widget, hovered)
  if hovered then
    if widget.tooltip then
      ToolTip.display(widget.tooltip)
      currentHoveredWidget = widget
    end
  else
    if widget == currentHoveredWidget then
      ToolTip:hide()
      currentHoveredWidget = nil
    end
  end
end

local function onWidgetStyleApply(widget, styleName, styleNode)
  if styleNode.tooltip then
    widget.tooltip = styleNode.tooltip
  end
end

-- public functions
function ToolTip.init()
  toolTipLabel = createWidget('Label', rootWidget)
  toolTipLabel:setId('toolTip')
  toolTipLabel:setBackgroundColor('#111111bb')
  connect(toolTipLabel, { onMouseMove = moveToolTip })

  connect(UIWidget, {  onStyleApply = onWidgetStyleApply,
                       onHoverChange = onWidgetHoverChange})
end

function ToolTip.terminate()
  disconnect(UIWidget, { onStyleApply = onWidgetStyleApply,
                         onHoverChange = onWidgetHoverChange })

  currentHoveredWidget = nil
  toolTipLabel:destroy()
  toolTipLabel = nil

  ToolTip = nil
end

function ToolTip.display(text)
  if text == nil then return end
  toolTipLabel:setText(text)
  toolTipLabel:resizeToText()
  toolTipLabel:resize(toolTipLabel:getWidth() + 4, toolTipLabel:getHeight() + 4)
  toolTipLabel:show()
  toolTipLabel:raise()
  toolTipLabel:enable()
  moveToolTip(toolTipLabel)
end

function ToolTip.hide()
  toolTipLabel:hide()
end

-- UIWidget extensions
function UIWidget:setTooltip(text)
  self.tooltip = text
end

function UIWidget:getTooltip()
  return self.tooltip
end

