--[[

	TickData Version 0.1 Dev
	Retrieves tick information from remote server
	Do not modify, copy or distribute without permission of author
	Helkarakse, 20131210
	
]]

os.loadAPI("functions")

local fileName = "profile.txt"
local downloadDelay = 30
local remoteUrl = ""

local downloadLoop = function()
	while true do
		-- download the file
		local data = http.get(remoteUrl)
		if (data) then
			local file = fs.open(fileName,"w")
			file.write(data.readAll())
			file.close()
		end
		sleep(downloadDelay)
	end
end

local function init()
	parallel.waitForAll(downloadLoop)
end

init()