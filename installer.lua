local shell = require("shell")
local term = require("term")
local filesystem = require("filesystem")
local internet = require("internet")

local programListUrl = "https://raw.githubusercontent.com/Navatusein/GTNH-OC-Installer/refs/heads/main/programs.lua"

---@class ProgramDescription
---@field name string
---@field description string
---@field url string
local program = {}

---Download and install tar utility
local function downloadTarUtility()
  if filesystem.exists("/bin/tar.lua") then
    return
  end

  local tarManUrl = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/usr/man/tar.man"
  local tarBinUrl = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/home/bin/tar.lua"

  shell.setWorkingDirectory("/usr/man")
  shell.execute("wget -fq "..tarManUrl)
  shell.setWorkingDirectory("/bin")
  shell.execute("wget -fq "..tarBinUrl)
end

---Download and install program
---@param program ProgramDescription
local function downloadProgram(program)
  term.write("Installing "..program.name.."\n")

  shell.execute("wget -fq "..program.url.." program.tar")
  shell.execute("tar -xf program.tar")
  shell.execute("rm program.tar")

  term.write("Installation complete\n")
end

---Get program list from url
---@param programListUrl string
---@return ProgramDescription[]
local function getProgramList(programListUrl)
  local request = internet.request(programListUrl)
  local result = ""

  for chunk in request do
    result = result..chunk
  end

  return load(result)()
end

---Choose program
---@param programList ProgramDescription[]
---@return ProgramDescription
local function chooseProgram(programList)
  for key, value in pairs(programList) do
    term.write("["..key.."] "..value.name.."\n")
    term.write("    "..value.description.."\n\n")
  end

  term.write("\nSelect program to install [1-"..tostring(#programList).."]\n")

  local _, startRow = term.getCursor()

  while true do
    term.write("===>")

    local userInput = tonumber(io.read())

    if userInput and userInput >= 1 and userInput <= #programList then
      return programList[userInput]
    end

    term.setCursor(1, startRow)
    term.clearLine()
  end
end

---Make auto run
local function makeAutoRun()
  term.write("\nCreate auto run [y/n]\n")
  term.write("===>")

  local userInput = io.read()

  term.clear()

  if string.lower(userInput) == "y" then
    local file = assert(io.open("/home/.shrc", "w"))
    file:write("main")
    file:close()

    term.write("Auto run created\n")
  else
    term.write("Auto run ignored\n")
  end
end

---Main
local function main()
  term.clear()
  term.write("Welcome to Navatusein's programs installer\n\n")

  downloadTarUtility()
  local programList = getProgramList(programListUrl)
  local programUrl = chooseProgram(programList)

  shell.setWorkingDirectory("/home")

  makeAutoRun()
  downloadProgram(programUrl)
end

main()