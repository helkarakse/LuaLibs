local function nbtToTable(typ, val)
	if typ == "compound" then
		local rv = {}
		for _, key in ipairs(val.getKeys()) do
			local typ2, val2 = val.getValue(key)
			rv[key] = nbtToTable(typ2, val2)
		end
		return {type="compound", value=rv}
	elseif typ == "list" then
		local n = val.getSize()
		local rv = {}
		for k = 0, n - 1 do
			local typ2, val2 = val.get(k)
			rv[k+1] = nbtToTable(typ2, val2)
		end
		return {type="list", value=rv}
	elseif typ == "string" or typ == "double" or typ == "float" or typ == "byte" or typ == "short" or typ == "int" or typ == "long" then
		return {type=typ, value=val}
	elseif typ == "intArray" or typ == "byteArray" then
		local rv = {}
		for k = 0, val.getLength() - 1 do
			rv[k+1] = val.get(k)
		end
		return {type=typ, value=rv}
	else
		error("unimplemented tag type: "..typ)
	end
end

local function tableToNbt(typ, tag, tbl)
	assert(type(tag) == "table" and tbl.type == typ and tag.getType() == typ)
	if typ == "compound" then
		for _, key in ipairs(tag.getKeys()) do
			if not tbl.value[key] then
				tag.remove(key)
			end
		end
		for key, value in pairs(tbl.value) do
			if value.type == "compound" or value.type == "list" then
				tag.setValue(key, value.type)
				tableToNbt(value.type, select(2, tag.getValue(key)), value)
			elseif value.type == "intArray" or value.type == "byteArray" then
				tag.setValue(key, value.type, #value.value)
				tableToNbt(value.type, select(2, tag.getValue(key)), value)
			elseif value.type == "string" or value.type == "double" or value.type == "float" or value.type == "byte" or value.type == "short" or value.type == "int" then
				tag.setValue(key, value.type, value.value)
			elseif value.type == "long" then
				tag.setValue(key, value.type, value.value[1], value.value[2])
			else
				error("unimplemented tag type: "..value.type)
			end
		end
	elseif typ == "list" then
		while tag.getSize() > 0 do
			tag.remove(0)
		end
		for _, value in ipairs(tbl.value) do
			if value.type == "compound" or value.type == "list" then
				tag.add(tag.getSize(), value.type)
				tableToNbt(value.type, select(2, tag.get(tag.getSize() - 1)), value)
			elseif value.type == "intArray" or value.type == "byteArray" then
				tag.add(tag.getSize(), value.type, #value.value)
				tableToNbt(value.type, select(2, tag.get(tag.getSize() - 1)), value)
			elseif value.type == "string" or value.type == "double" or value.type == "float" or value.type == "byte" or value.type == "short" or value.type == "int" then
				tag.add(tag.getSize(), value.type, value.value)
			elseif value.type == "long" then
				tag.add(tag.getSize(), value.type, value.value[1], value.value[2])
			else
				error("unimplemented tag type: "..value.type)
			end
		end
	elseif typ == "intArray" or typ == "byteArray" then
		for k = 0, tag.getLength() - 1 do
			tag.set(k, tbl.value[k+1])
		end
	else
		error("unimplemented tag type: "..typ)
	end
end

function readTileNBT(te)
	te.readNBT()
	return nbtToTable("compound", te.getNBT())
end

function writeTileNBT(te, nbt)
	tableToNbt("compound", te.getNBT(), nbt)
	te.writeNBT()
end