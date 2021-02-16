function UpdateSave(reset)
  local changeXml = (not reset and self.UI.getXml()) or nil
  local dataToSave = {
    ["countTime"] = countTime, ["changeXml"] = changeXml,
    ["fildForTime"] = fildForTime, ["selectedTime"] = selectedTime
  }
  local savedData = JSON.encode(dataToSave)
  self.script_state = savedData
end

function onLoad(savedData)
  countTime, selectedTime = 1, 1
  fildForTime = {}
  Wait.Frames(|| Confer(savedData), 15)
end
function Confer(savedData)
  originalXml = self.UI.getXml()
  RebuildAssets()
  if(savedData ~= "") then
    local loadedData = JSON.decode(savedData)
    countTime = loadedData.countTime or 1
    selectedTime = loadedData.selectedTime or 1
    fildForTime = loadedData.fildForTime or {}
    SetNewMonth(_, _, not (countTime < 2))
  end
end

function PanelTool()
  if(self.UI.getAttribute("panelTool", "active") == "false") then
    self.UI.show("panelTool")
    self.UI.show("panelClose")
  else
    self.UI.hide("panelTool")
    self.UI.hide("panelClose")
  end
  Wait.Frames(UpdateSave, 5)
end

function PanelTool2()
  if(self.UI.getAttribute("panelTool2", "active") == "false") then
    self.UI.show("panelTool2")
  else
    self.UI.hide("panelTool2")
  end
  Wait.Frames(UpdateSave, 5)
end

function SetNewMonth(_, _, isLoad)
  if(not isLoad) then
    fildForTime[tostring(countTime)] = {name = "", R = 0, G = 0, B = 0, light = 0, ambient = 0}
    countTime = countTime + 1
  end

  local allXml = originalXml

  newType = ""
  for i,v in pairs(fildForTime) do
    newType = newType .. [[
      <Row preferredHeight='40'>
        <Cell columnSpan='5' dontUseTableCellBackground='true'>
          <InputField id='name]]..i..[[' class='inputName' text=']]..v.name..[['/>
        </Cell>
        <Cell columnSpan='1'>
          <InputField id='R]]..i..[[' class='inputValue' color='#44944a' placeholder='value' characterValidation='Integer'
            text=']]..v.R..[['/>
        </Cell>
        <Cell columnSpan='1'>
          <InputField id='G]]..i..[[' class='inputValue' color='#44944a' placeholder='value' characterValidation='Integer'
            text=']]..v.G..[['/>
        </Cell>
        <Cell columnSpan='1'>
          <InputField id='B]]..i..[[' class='inputValue' color='#44944a' placeholder='value' characterValidation='Integer'
            text=']]..v.B..[['/>
        </Cell>
        <Cell columnSpan='1'>
          <InputField id='light]]..i..[[' class='inputValue' color='#44944a' placeholder='value' characterValidation='Decimal'
            text=']]..v.light..[['/>
        </Cell>
        <Cell columnSpan='1'>
          <InputField id='ambient]]..i..[[' class='inputValue' color='#44944a' placeholder='value' characterValidation='Decimal'
            text=']]..v.ambient..[['/>
        </Cell>
      </Row>
    ]]
  end

  local searchString = "<NewRowS />"
  local searchStringLength = #searchString

  local indexFirst = allXml:find(searchString)
  
  local startXml = allXml:sub(1, indexFirst + searchStringLength)
  local endXml = allXml:sub(indexFirst + searchStringLength)

  startXml = startXml .. newType .. endXml
  self.UI.setXml(startXml)
  EnlargeHeightPanel()
  Wait.Frames(|| SetTypeTimeLoad(), 5)
  Wait.Frames(|| UpdateSave(), 7)
end

function SetTypeTimeLoad()
  for i,v in pairs(fildForTime) do
    if(tonumber(i) == selectedTime) then
      SetTypeTime(i)
    end
  end
end

function EnlargeHeightPanel()
  if(countTime > 3) then
    --preferredHeight=40 cellSpacing='2'
    local newHeightPanel = countTime*40 + 42
    Wait.Frames(|| self.UI.setAttribute("TLSet", "height", newHeightPanel), 5)
    Wait.Frames(|| self.UI.setAttribute("TLUse", "height", newHeightPanel), 5)
  end
end

function PlusTime()
  if(selectedTime + 1 >= countTime) then SetTypeTime(1) return end
  SetTypeTime(selectedTime + 1)
end
function MinusTime()
  if(selectedTime - 1 < 1) then SetTypeTime(countTime) return end
  SetTypeTime(selectedTime - 1)
end
function SetTypeTime(id)
  selectedTime = tonumber(selectedTime)
  if(selectedTime > 0) then
    self.UI.setAttribute("nameT", "text", fildForTime[tostring(id)].name)
    self.UI.setAttribute("nameT"..selectedTime, "id", "nameT"..id)
  else
    self.UI.setAttribute("nameT", "text", fildForTime[tostring(id)].name)
    self.UI.setAttribute("nameT", "id", "nameT" .. id)
  end
  selectedTime = tonumber(id)
  SetLight(tostring(id))
  Wait.Frames(UpdateSave, 5)
end
function SetLight(number)
  Lighting.ambient_intensity = fildForTime[number].ambient or 1
  Lighting.light_intensity = fildForTime[number].light or 1
  Lighting.setLightColor({
    (fildForTime[number].R or 160) / 255,
    (fildForTime[number].G or 160) / 255,
    (fildForTime[number].B or 160) / 255
  })
  Lighting.apply()
end

function SetNameTime(_, input, id)
  id = id:sub(5, #id)
  fildForTime[id].name = input
  Wait.Frames(|| UpdateSave(), 5)
end

function SetValueLight(_, input, id)
  if(id:find("R")) then
    id = id:sub(2, #id)
    fildForTime[id].R = tonumber(input)
  elseif(id:find("G")) then
    id = id:sub(2, #id)
    fildForTime[id].G = tonumber(input)
  elseif(id:find("B")) then
    id = id:sub(2, #id)
    fildForTime[id].B = tonumber(input)
  elseif(id:find("light")) then
    id = id:sub(6, #id)
    fildForTime[id].light = tonumber(input)
  elseif(id:find("ambient")) then
    id = id:sub(8, #id)
    fildForTime[id].ambient = tonumber(input)
  end
  Wait.Frames(|| UpdateSave(), 5)
end

function Reset()
  countTime, selectedTime = 1, 1
  fildForTime = {}
  self.UI.setXml(originalXml)
  UpdateSave(true)
end

function RebuildAssets()
  local root = 'https://raw.githubusercontent.com/RobMayer/TTSLibrary/master/ui/'
  local assets = {
    {name = 'uiGear', url = root .. 'gear.png'},
    {name = 'uiBars', url = root .. 'bars.png'},
    {name = 'uiPlus', url = root .. 'plus.png'},
    {name = 'uiMinus', url = root .. 'minus.png'},
    {name = 'uiClose', url = root .. 'close.png'},
  }
  self.UI.setCustomAssets(assets)
end