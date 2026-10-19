Keys = {}
Keys.__index = Keys

function Keys.Register(controls, name, description, action)
    RegisterKeyMapping(('pure-target:%s'):format(name), description, 'keyboard', controls)
    RegisterCommand(('pure-target:%s'):format(name), function()
        if action then action() end
    end, false)
    return setmetatable({ controls = controls }, Keys)
end

function Keys.RegisterToggle(controls, name, description, onPress, onRelease)
    RegisterKeyMapping(('+pure-target:%s'):format(name), description, 'keyboard', controls)
    RegisterCommand(('+pure-target:%s'):format(name), function()
        if onPress then onPress() end
    end, false)
    RegisterCommand(('-pure-target:%s'):format(name), function()
        if onRelease then onRelease() end
    end, false)
end
