-- Update check: 10 s after the resource starts, asks GitHub for the latest release of this script
-- and prints one line in the server console when a newer version exists. Nothing is downloaded
-- or installed. Stays silent when GitHub cannot be reached (no internet, rate limit, no release yet)
-- or answers something unexpected. Switch it off with Config.CheckUpdates = false.

if not Config.CheckUpdates then return end

local REPOSITORY = 'ma3iich/pure-target'
local DELAY = 10000 -- ms after start, so the check never slows the resource down
local resource = GetCurrentResourceName()

-- 'v1.2.0' or '1.2.0' -> { 1, 2, 0 }; nil when the text is not a version.
local function parseVersion(text)
    if type(text) ~= 'string' then return end
    local major, minor, patch = text:match('^%s*v?(%d+)%.(%d+)%.?(%d*)')
    if not major then return end
    return { tonumber(major), tonumber(minor), tonumber(patch) or 0 }
end

local function isNewer(remote, current)
    for i = 1, 3 do
        if remote[i] > current[i] then return true end
        if remote[i] < current[i] then return false end
    end
    return false
end

local function formatVersion(v)
    return ('%d.%d.%d'):format(v[1], v[2], v[3])
end

CreateThread(function()
    Wait(DELAY)

    local current = parseVersion(GetResourceMetadata(resource, 'version', 0))
    if not current then return end

    local url = ('https://api.github.com/repos/%s/releases/latest'):format(REPOSITORY)
    local headers = {
        ['User-Agent'] = resource, -- required by the GitHub API (403 without it)
        ['Accept'] = 'application/vnd.github+json',
    }

    PerformHttpRequest(url, function(status, body)
        if status ~= 200 or type(body) ~= 'string' then return end

        local ok, release = pcall(json.decode, body)
        if not ok or type(release) ~= 'table' then return end

        local latest = parseVersion(release.tag_name)
        if not latest then return end

        if isNewer(latest, current) then
            print(('^3[%s] Update available: %s -> %s  https://github.com/%s/releases/latest^0'):format(
                resource, formatVersion(current), formatVersion(latest), REPOSITORY))
        else
            print(('[%s] Up to date (%s)'):format(resource, formatVersion(current)))
        end
    end, 'GET', '', headers)
end)
