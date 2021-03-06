﻿function UpdateSave(reset)
  local changeXml = (not reset and self.UI.getXml()) or nil
  local dataToSave = {
    ["countMonth"] = countMonth, ["changeXml"] = changeXml,
    ["fildForMonth"] = fildForMonth, ["selectedMonth"] = selectedMonth,
    ["selectedDay"] = selectedDay, ["currentYear"] = currentYear
  }
  local savedData = JSON.encode(dataToSave)
  self.script_state = savedData
end

function onLoad(savedData)
  countMonth, selectedMonth, selectedDay = 1, 1, 1
  fildForMonth = {}
  Wait.time(|| Confer(savedData), 0.5)
end
function Confer(savedData)
  originalXml = self.UI.getXml()
  RebuildAssets()
  if(savedData ~= "") then
    local loadedData = JSON.decode(savedData)
    countMonth = loadedData.countMonth or 1
    selectedMonth = loadedData.selectedMonth or 1
    selectedDay = loadedData.selectedDay or 1
    fildForMonth = loadedData.fildForMonth or {}
    currentYear = loadedData.currentYear or 0
    SetNewMonth(_, _, not (countMonth < 2), true)
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
  Wait.time(UpdateSave, 0.2)
end

function PanelTool2()
  if(self.UI.getAttribute("panelTool2", "active") == "false") then
    self.UI.show("panelTool2")
  else
    self.UI.hide("panelTool2")
  end
  Wait.time(UpdateSave, 0.2)
end

function SetNewMonth(_, _, isLoadFirst, isLoad)
  if(not isLoadFirst) then
    fildForMonth[tostring(countMonth)] = {name = "", value = 0}
    countMonth = countMonth + 1
  end

  local allXml = originalXml

  newType = ""
  for i,v in pairs(fildForMonth) do
    newType = newType .. [[
      <Row preferredHeight='40'>
        <Cell columnSpan='6' dontUseTableCellBackground='true'>
          <InputField id='name]]..i..[[' class='inputName' text=']]..v.name..[['/>
        </Cell>
        <Cell columnSpan='4'>
          <InputField id='value]]..i..[[' class='inputValue' color='#44944a' placeholder='value'
            text=']]..v.value..[['/>
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
  Wait.time(|| SetTypeMonthLoad(isLoad), 0.2)
  Wait.time(|| SetCountDays(_, _, selectedDay), 0.25)
  Wait.time(|| ChangeYears(_, currentYear), 0.3)
  Wait.time(|| UpdateSave(), 0.35)
end

function SetTypeMonthLoad(isLoad)
  SetTypeMonth(tostring(selectedMonth), isLoad)
end

function EnlargeHeightPanel()
  if(countMonth > 4) then
    --preferredHeight=40 cellSpacing='2'
    local newHeightPanel = countMonth*40 + 2
    Wait.time(|| self.UI.setAttribute("TLSet", "height", newHeightPanel), 0.2)
    Wait.time(|| self.UI.setAttribute("TLUse", "height", newHeightPanel), 0.2)
  end
end

function PlusMonth()
  if(selectedMonth + 1 >= countMonth) then
    SetTypeMonth(1)
    ChangeYears(_, currentYear + 1)
    return
  end
  SetTypeMonth(selectedMonth + 1)
end
function MinusMonth()
  if(selectedMonth - 1 < 1) then
    SetTypeMonth(countMonth - 1)
    ChangeYears(_, currentYear - 1)
    return
  end
  SetTypeMonth(selectedMonth - 1)
end
function SetTypeMonth(id, isLoad)
  selectedMonth = tonumber(selectedMonth)
  if(selectedMonth > 0) then
    self.UI.setAttribute("nameT", "text", fildForMonth[tostring(id)].name)
    self.UI.setAttribute("nameT"..selectedMonth, "id", "nameT"..id)
  else
    self.UI.setAttribute("nameT", "text", fildForMonth[tostring(id)].name)
    self.UI.setAttribute("nameT", "id", "nameT" .. id)
  end
  selectedMonth = tonumber(id)
  if(not isLoad) then SetCountDays(_, _, 1) end
  Wait.time(UpdateSave, 0.2)
end

function PlusValueDay()
  if(selectedDay + 1 > fildForMonth[tostring(selectedMonth)].value) then
    PlusMonth()
    SetCountDays(_, _, 1)
    return
  end
  SetCountDays(_, _, selectedDay + 1)
end
function MinusValueDay()
  if(selectedDay - 1 < 1) then
    MinusMonth()
    SetCountDays(_, _, fildForMonth[tostring(selectedMonth)].value)
    return
  end
  SetCountDays(_, _, selectedDay - 1)
end
function SetCountDays(_, max, value)
  if(max and max ~= "") then
    fildForMonth[tostring(selectedMonth)].value = tonumber(max)
  else
    selectedDay = tonumber(value)
    self.UI.setAttribute("valueD", "text", value)
  end
  Wait.time(|| UpdateSave(), 0.2)
end

function SetNameMonth(_, input, id)
  id = id:sub(5, #id)
  fildForMonth[id].name = input
  Wait.time(|| UpdateSave(), 0.2)
end

function SetMaxCountDays(_, input, id)
  id = id:sub(6, #id)
  fildForMonth[id].value = tonumber(input)
  Wait.time(|| UpdateSave(), 0.2)
end

function Reset()
  countMonth, selectedMonth, selectedDay = 1, 1, 1
  fildForMonth = {}
  self.UI.setXml(originalXml)
  UpdateSave(true)
end

function ChangeYears(_, input)
  if(input ~= "") then
    currentYear = tonumber(input)
    self.UI.setAttribute("idYear", "text", currentYear)
    UpdateSave()
  else
    self.UI.setAttribute("idYear", "text", currentYear or 0)
  end
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