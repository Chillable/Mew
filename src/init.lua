export type Service = {

	Name: string,
	Extensions: { Extension },
	[any]: any,
}

export type Extension = {

	BeforeInit: (service: Service) -> nil,
	BeforeStart: (service: Service) -> nil,
}

local Mew = {}

local Promise = require(script.Parent.Promise)

local Debug = require(script.Debug)

local Services: { Service } = {}
local Extensions: { Extension } = {}

local started = false

local startCompleted = false
local onStart = Instance.new("BindableEvent")

local function CallExtensions(service: Service, func)

	for _, extension in ipairs(service.Extensions) do

		if typeof(extension[func]) == "function" then

			extension[func](service)

		end

	end

end


function Mew.AddExtension(module: table)

	Debug.assert(typeof(module) == "Instance", "Instance expected, got " .. typeof(module))

    if module:IsA("ModuleScript") then

        table.insert(Extensions, require(module))

    end

end

function Mew.AddService(module: table)

	Debug.assert(typeof(module) == "Instance", "Instance expected, got " .. typeof(module))

	if module:IsA("ModuleScript") then

		local service = require(module)

		Debug.assert(typeof(service.Name) ~= "nil", "Service name is required")
		Debug.assert(typeof(service.Name) == "string", "Service name must be a string, got " .. typeof(service.Name))

		if service.Extensions ~= nil then

			Debug.assert(typeof(service.Extensions) == "table", "Service extensions must be a table, got " .. typeof(service.Extensions))

		else

			service.Extensions = {}

		end

		table.insert(Services, service)

		return service

	end

end

function Mew.Start()

	return Promise.new(function(resolve)

		Debug.assert(not started, "Mew already started")

		started = true

		local promises = {}

        for _, service in pairs(Services) do
            
            for _, extension in pairs(Extensions) do

                table.insert(service.Extensions, extension)
    
            end

        end

		for _, service in pairs(Services) do

			if not (typeof(service.Init) == "function") then

				continue

			end

			table.insert(promises, Promise.new(function(r)

                CallExtensions(service, "BeforeInit")

					r(service:Init())

				end))

		end

		Promise.all(promises):await()

		resolve()

	end):andThen(function()

		for _, service in pairs(Services) do

			if not (typeof(service.Start) == "function") then

				continue

			end

			task.spawn(function()

                CallExtensions(service, "BeforeStart")

				debug.setmemorycategory(service.Name)

				service:Start()

			end)

		end

		startCompleted = true

	end)

end

function Mew.OnStart()

	if startCompleted then

		return Promise.resolve()

	end

	return Promise.fromEvent(onStart.Event)

end

return Mew
