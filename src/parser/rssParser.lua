--[[

	RSS Data Parser Version 1.0 Dev
	Do not modify, copy or distribute without permission of author
	Helkarakse, 20131128
]]

-- Libraries
os.loadAPI("xml")
os.loadAPI("functions")

-- Vars
local tagChannel
local parser = xml.XL:new()

-- Main Functions
-- Parses the xml string and outputs the table data
function parseData(xmlString)
	parser:from_string(xmlString)
	tagChannel = parser:find(parser:root(), "channel")
end

-- Returns the title of the feed
function getTitle()
	return tagChannel[1][1][1]
end

-- Returns the description of the feed
function getDescription()
	return tagChannel[1][2][1]
end

-- Returns the link component of the feed
function getLink()
	return tagChannel[1][3][1]
end

-- Returns the published date of the feed
function getPubDate()
	return tagChannel[1][4][1]
end

-- Gets a specific item given an id or all items given no id
function getItems(id)
	local specificId = tonumber(id) or 0
	if (specificId == 0) then
		-- no specific id passed, assume return all
		local array = {}
		for i = 6, #tagChannel[1] do
			table.insert(array, tagChannel[1][i])
		end
		
		return array
	else
		-- return specific item
		return tagChannel[1][id + 5]
	end
end

-- Returns the title, link, description, date and guid for the item
function parseItem(item)
	return functions.stripCData(item[1][1]), item[2][1], item[3][1], item[4][1], item[5][1]
end

-- Converts the date from RFC 822 to a shorter version
-- Crippled due to conflicts with os.time and os.date
function convertDate(inputDate)
	local monthArray = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
	local pattern = "(%a+)%, (%d+) (%a+) (%d+) (%d+):(%d+):(%d+) ([%+%-])(%d+)"
	local xDayName, xDay, xMonth, xYear, xHour, xMin, xSec, xOffset, xOffsetAmount = inputDate:match(pattern)
	-- Commented out due to conflict with cc os.time()
	-- local timestamp = os.time({year = xYear, month = xMonth, day = xDay, hour = xHour, min = xMin, sec = xSec})
	
    if (xOffset == "-") then
    	xOffsetAmount = xOffsetAmount * -1
    end
    
    -- Commented out due to conflict with cc os.date()
	-- timestamp = timestamp + xOffsetAmount
	-- return os.date("%c", timestamp)
	
	return xDay .. " " .. xMonth .. " " .. xYear .. " " .. xHour .. ":" .. xMin
end