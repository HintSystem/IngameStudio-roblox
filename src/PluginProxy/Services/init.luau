local Services = {}

local Created = {}
local function getService(className: string)
	local Service = script:FindFirstChild(className)

	if not Service then
		return nil
	elseif Created[className] then
		return Created[className]
	end
		
	Service = require(Service)
	Created[className] = Service
	return Service 
end

function Services:FindService(className: string)
	local Service = getService(className)
	if not Service then
		return game:FindService(className)
	end
	return Service
end

function Services:GetService(className: string)
	local Service = getService(className)
	print("Tried accessing service", className)

	if not Service then
		return game:GetService(className)
	end
	return Service
end

return Services
