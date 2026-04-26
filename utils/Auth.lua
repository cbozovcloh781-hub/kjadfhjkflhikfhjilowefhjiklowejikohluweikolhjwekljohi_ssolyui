---@diagnostic disable: undefined-global
-- Sosalkin Hub - Authentication Module
-- Handles user authentication and premium status checking

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Auth = {}

-- Your backend API URL (replace with your actual server)
local API_URL = "https://your-api-domain.com/api/v1"

-- Cache for user data
local userCache = {}
local cacheExpiry = 300 -- 5 minutes

function Auth:CheckUserStatus(userId)
    -- Check cache first
    if userCache[userId] and userCache[userId].expiry > os.time() then
        return userCache[userId].data
    end
    
    local success, result = pcall(function()
        local response = game:HttpGet(API_URL .. "/user/status?userId=" .. userId)
        return HttpService:JSONDecode(response)
    end)
    
    if success and result then
        -- Cache the result
        userCache[userId] = {
            data = result,
            expiry = os.time() + cacheExpiry
        }
        return result
    else
        -- Fallback to default if server is down
        warn("[Sosalkin Hub] Failed to fetch user status from server, using default")
        return {
            status = "shub",
            premium = false,
            developer = false,
            expiryDate = nil
        }
    end
end

function Auth:GetHubStatus()
    local player = Players.LocalPlayer
    local userData = self:CheckUserStatus(player.UserId)
    
    -- Determine status
    if userData.developer then
        return "dev", nil
    elseif userData.premium and userData.expiryDate then
        local expiryTimestamp = userData.expiryDate
        -- Check if premium is still valid
        if expiryTimestamp > os.time() then
            return "shub+", expiryTimestamp
        else
            return "shub", nil
        end
    else
        return "shub", nil
    end
end

function Auth:IsWhitelisted()
    local player = Players.LocalPlayer
    local userData = self:CheckUserStatus(player.UserId)
    
    -- Check if user has access (free or premium)
    return userData.whitelisted or userData.premium or userData.developer
end

function Auth:GetUserData()
    local player = Players.LocalPlayer
    return self:CheckUserStatus(player.UserId)
end

-- Clear cache (useful for manual refresh)
function Auth:ClearCache()
    userCache = {}
end

return Auth
