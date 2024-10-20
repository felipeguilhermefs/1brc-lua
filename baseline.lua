local measurments = io.open("measurements.txt", "rb")

if not measurments then
	error("Could not open the file measurments.txt")
	os.exit(1)
end

local results = {}

-- Read each line of the file
local i = 1
for line in measurments:lines() do
	local city, temp = string.match(line, "(.*);(.*)")
	if results[city] then
		results[city].sum = results[city].sum + tonumber(temp)
		results[city].occurrences = results[city].occurrences + 1
		if tonumber(temp) < results[city].min then
			results[city].min = tonumber(temp)
		end
		if tonumber(temp) > results[city].max then
			results[city].max = tonumber(temp)
		end
	else
		results[city] = {
			["min"] = tonumber(temp),
			["max"] = tonumber(temp),
			["sum"] = tonumber(temp),
			["occurrences"] = 1
		}
	end
	if i%50000000 == 0 then
		io.stderr:write("Parsed ", i, " lines\n")
		-- Output to stderr to not parasite the results when piping
	end
	i = i + 1
end

-- Re order the results table to have then alphabetically
local t = {}
for city, result in pairs(results) do
	t[#t + 1] = { ["city"] = city, ["result"] = result}
end
table.sort(t, function (x,y) return (x.city < y.city) end)

-- Dumb function to append a ".0" to int numbers
local function number_to_string(n)
	if n == math.floor(n) then
		return tostring(n)..".0"
	else
		return tostring(n)
	end
end

local function theRounding(v) -- Copied from MikuAuahDark solution

	if v < 0 then
		return math.ceil(v - 0.5)
	else
		return math.floor(v + 0.5)
	end
end

-- Write the results
io.write("{")
local first = true
for _, value in pairs(t) do
	local city = value.city
	local result = value.result
	local mean = theRounding((result.sum / result.occurrences) * 10) / 10
	if first then
		io.write(city, "=", number_to_string(result.min), "/", number_to_string(mean), "/", number_to_string(result.max))
		first = false
	else
		io.write(", ",city, "=", number_to_string(result.min), "/", number_to_string(mean), "/", number_to_string(result.max))
	end
end
io.write("}\n")
