-- Função para calcular a distância entre duas posições
local distance = function(pos1, pos2)
  return math.sqrt((pos1.x - pos2.x)^2 + (pos1.y - pos2.y)^2 + (pos1.z - pos2.z)^2)
end

local NPCsAndCities = {
  ["Minoru"] = "Konoha Gakure, Suna Gakure, Vila Takumi, Monte Myoboku, Forest, Amegakure no Sato, Suna Camp, Iwagakure Island, Yukigakure, Iwagakure, Vale do Fim, Kumogakure, Tsuki no Shima, Templo do Fogo, Kodai no Shima, Ilha da Lua, Ilha Genbu",
  ["Captain Bluebear"] = "Venore, Carlin",
  ["Captain Fearless"] = "Thais, Carlin",
  ["Captain Greyhound"] = "Thais, Venore",
}

local TravelWindow = setupUI([[
UIWindow
  !text: tr('Barco')
  color: lightGray
  font: sans-bold-16px  
  background-color: black
  opacity: 1.05
  anchors.verticalCenter: parent.verticalCenter
  anchors.horizontalCenter: parent.horizontalCenter
  size: 156 40

  ComboBox
    size: 160 20
    id: travelOptions
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    text-align: center
    opacity: 1.0
    color: lightGray
    font: sans-bold-16px
    margin-top: 25
]], g_ui.getRootWidget())

TravelWindow:hide()

local originalTalkFunction = NPC.talk
NPC.talk = function(text)
  if g_game.getClientVersion() >= 810 then
    originalTalkFunction(text)
  else
    say(text)
  end
end

local setOptions = function(npc)
  TravelWindow.travelOptions:clear()
  local npcName = npc:getName()
  local cities = NPCsAndCities[npcName]
  TravelWindow.travelOptions:addOption(npcName)
  for _, city in ipairs(cities:split(",")) do
    TravelWindow.travelOptions:addOption(city:trim())
  end
end
  local function botPrintMessage(message)
    modules.game_textmessage.displayGameMessage(message)
  end
  
  botPrintMessage("Auto Travel (Script) criado por: unnbottz")
local setup = function(npc)
  setOptions(npc)
  TravelWindow:show()
end

local reset = function()
  TravelWindow:hide()
  TravelWindow.travelOptions:clear()
  modules.game_interface.getRootPanel():focus()
end

TravelWindow.travelOptions.onOptionChange = function(widget, option, data)
  if TravelWindow:isVisible() then
    say('hi')
    schedule(100, function()
      NPC.talk(option)
    end)
    schedule(700, function()
      NPC.talk('yes')
    end)
  end
end

local getTravelNPC = function()
  for name, _ in pairs(NPCsAndCities) do
    local npc = getCreatureByName(name)
    if npc then
      local npcPosition = npc:getPosition()
      local playerPosition = g_game.getLocalPlayer():getPosition()
      if distance(npcPosition, playerPosition) <= 2 then
        return npc
      end
    end
  end
end

onPlayerPositionChange(function(old, new)
  local npc = getTravelNPC()
  if npc and not TravelWindow:isVisible() then
    setup(npc)
  elseif not npc and TravelWindow:isVisible() then
    reset()
  end
end)