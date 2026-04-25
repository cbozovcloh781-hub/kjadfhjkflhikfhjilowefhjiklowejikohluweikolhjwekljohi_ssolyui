---@diagnostic disable: undefined-global
-- Ssoly UI - Quick Loader
-- Paste this in your executor to test the UI

-- REPLACE WITH YOUR GITHUB URL AFTER UPLOAD
local GITHUB_URL = "https://raw.githubusercontent.com/YOUR_USERNAME/ssoly-ui/main/"

print("Loading Ssoly UI...")

-- Load library
local Ssoly = loadstring(game:HttpGet(GITHUB_URL .. "init.lua"))()

-- Load test script
loadstring(game:HttpGet(GITHUB_URL .. "test.lua"))()

print("Ssoly UI loaded successfully!")
