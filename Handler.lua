local HttpService = game:GetService("HttpService");
local FirebaseService = require(script.Parent.FirebaseService);
local database = FirebaseService:GetFirebase("Saves");
game.Players.PlayerAdded:Connect(function(player)
	local playeruserid = player.UserId
	

	local newPlayerData = {Username = player.Name; ACCode = 0; RGCode = 0; NBLXCode = 0; PCode = 0; RMCode = 0; FullCode = 0 };
	database:SetAsync(playeruserid, HttpService:JSONEncode(newPlayerData));
end)
local chars = "123456789"

local function getCode(length)
	local code = ""
	for i = 1, length do
		local randNum = math.random(1, chars:len())
		code = code .. chars:sub(randNum, randNum)
	end
	return code
end



local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local purchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory")


local productFunctions = {}

productFunctions['censored'] = function(receipt, player)
	print("player bought")
	local CodeforAC = "AC" .. getCode(5)
	print(CodeforAC)
	database:SetAsync(player.UserId.."/ACCode", CodeforAC)
	--database
end


productFunctions['censored'] = function(receipt, player)
	print("player bought")
	local CodeforAC = "P" .. getCode(5)
	print(CodeforAC)
	database:SetAsync(player.UserId.."/PCode", CodeforAC)
	--database
end


productFunctions['censored'] = function(receipt, player)
	print("player bought")
	local CodeforAC = "FULLC" .. getCode(5)
	print(CodeforAC)
	database:SetAsync(player.UserId.."/FullCode", CodeforAC)
	--database
end


productFunctions['censored'] = function(receipt, player)
	print("player bought")
	local CodeforAC = "NBL" .. getCode(5)
	print(CodeforAC)
	database:SetAsync(player.UserId.."/NBLXCode", CodeforAC)
	--database
end


productFunctions['censored'] = function(receipt, player)
	print("player bought")
	local CodeforAC = "RM" .. getCode(5)
	print(CodeforAC)
	database:SetAsync(player.UserId.."/RMCode", CodeforAC)
	--database
end


productFunctions['censored'] = function(receipt, player)
	print(player.UserId)
	print("player bought")
	local CodeforAC = "RG" .. getCode(5)
	print(CodeforAC)
	database:SetAsync(player.UserId.."/RGCode", CodeforAC)
	--database
end

-- The core 'ProcessReceipt' callback function
local function processReceipt(receiptInfo)

	-- Determine if the product was already granted by checking the data store  
	local playerProductKey = receiptInfo.PlayerId .. "_" .. receiptInfo.PurchaseId
	local purchased = false
	local success, errorMessage = pcall(function()
		purchased = purchaseHistoryStore:GetAsync(playerProductKey)
	end)
	-- If purchase was recorded, the product was already granted
	if success and purchased then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	elseif not success then
		error("Data store error:" .. errorMessage)
	end

	-- Find the player who made the purchase in the server
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		-- The player probably left the game
		-- If they come back, the callback will be called again
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Look up handler function from 'productFunctions' table above
	local handler = productFunctions[receiptInfo.ProductId]

	-- Call the handler function and catch any errors
	local success, result = pcall(handler, receiptInfo, player)
	if not success or not result then
		warn("Error occurred while processing a product purchase")
		print("\nProductId:", receiptInfo.ProductId)
		print("\nPlayer:", player)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Record transaction in data store so it isn't granted again
	local success, errorMessage = pcall(function()
		purchaseHistoryStore:SetAsync(playerProductKey, true)
	end)
	if not success then
		error("Cannot save purchase data: " .. errorMessage)
	end

	-- IMPORTANT: Tell Roblox that the game successfully handled the purchase
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Set the callback; this can only be done once by one script on the server! 
MarketplaceService.ProcessReceipt = processReceipt
