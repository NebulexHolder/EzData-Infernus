--[[

MIT License

Copyright (c) 2025 Nebulex (https://www.roblox.com/communities/16793860/Nebulex)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

]]

------------
--Services--
------------

local HttpService = game:GetService("HttpService")

----------
--Tables--
----------

local Infernus = {}

-------------
--Functions--
-------------

function Infernus:DoOperation(Firebase: string, Scope: string, Key: string, AuthKey: string, URL: string, OperationData: {})
	
	local ToSend 
	local Success, Err =	pcall(function()
		
		local OperationType = OperationData["T"]
		local OperationData = OperationData["D"] -- Not always will be given
		
		print(OperationType == "URL" and URL .. ".json?auth=" .. AuthKey or (OperationType == "RO" or OperationType == "ROD") and URL .. "/" .. Firebase .. ".json?auth=" .. AuthKey or Scope and URL .. "/" .. Firebase .. "/" .. Scope .. "/" .. Key .. ".json?auth=" .. AuthKey or URL .. "/" .. Firebase .. "/" .. Key .. ".json?auth=" .. AuthKey)

		ToSend = {

			Url = OperationType == "URL" and URL .. ".json?auth=" .. AuthKey or (OperationType == "RO" or OperationType == "ROD") and URL .. "/" .. Firebase .. ".json?auth=" .. AuthKey or Scope and URL .. "/" .. Firebase .. "/" .. Scope .. "/" .. Key .. ".json?auth=" .. AuthKey or URL .. "/" .. Firebase .. "/" .. Key .. ".json?auth=" .. AuthKey,
			Method = OperationType == "S" and "PUT" or (OperationType == "G" or OperationType == "RO" or OperationType == "URL") and "GET" or (OperationType == "R" or OperationType == "ROD") and "DELETE" or OperationType == "P" and "PATCH",
			Body = OperationData and typeof(OperationData) == "table" and HttpService:JSONEncode(OperationData) or OperationData and tostring(OperationData),
			Headers = {
				["Content-Type"] = "application/json",
				--["Authorization"] = "Bearer " .. AuthKey
			},

		}
		
	end)
	
	if not Success then
		
		warn(Err, OperationData)
		
	end

	local Success, Data = pcall(function()
		
		return HttpService:RequestAsync(ToSend)

	end)

	if not Success then
		
		task.wait(3)
		return Infernus:DoOperation(Firebase, Scope, Key, AuthKey, URL, OperationData) -- Retry

	end
	
	if not Data.Success then
		warn("Firebase error:", Data.StatusCode, Data.Body)
		return nil
	end

	return Data

end

function Infernus:Setup(AuthKey: string, URL: string)

	local Firebase = {}
	function Firebase:GetFireBase(Name: string, Scope: string)

		local MainFirebase = {}
		function MainFirebase:GetAsync(Key: string)

			assert(Key, "EzData-Infernus; GetAsync failed because no valid key was given!")

			local GrabbedData = Infernus:DoOperation(Name, Scope, Key, AuthKey, URL, {["T"] = "G"})
			if not GrabbedData or not GrabbedData["Body"] then

				return

			end

			return HttpService:JSONDecode(GrabbedData["Body"])

		end

		function MainFirebase:SetAsync(Key: string, Data)

			assert(Key, "EzData-Infernus; GetAsync failed because no valid key was given!") -- Throw an error if no key was given
			assert(Data, "EzData-Infernus; SetAsync failed because no valid data was given!") -- Throw an error if no data was given

			Infernus:DoOperation(Name, Scope, Key, AuthKey, URL, {["T"] = "S", ["D"] = Data})

		end

		function MainFirebase:PatchAsync(Key: string, Data)

			assert(Key, "EzData-Infernus; PatchAsync failed because no valid key was given!") -- Throw an error if no key was given
			assert(Data, "EzData-Infernus; PatchAsync failed because no valid data was given!") -- Throw an error if no data was given

			Infernus:DoOperation(Name, Scope, Key, AuthKey, URL, {["T"] = "P", ["D"] = Data})

		end

		function MainFirebase:RemoveAsync(Key: string)

			assert(Key, "EzData-Infernus; RemoveAsync failed because no valid key was given!") -- Throw an error if no key was given
			Infernus:DoOperation(Name, Scope, Key, AuthKey, URL, {["T"] = "R"})

		end

		function MainFirebase:GetRootAsync()

			local GrabbedData = Infernus:DoOperation(Name, Scope, nil, AuthKey, URL, {["T"] = "RO"})
			if not GrabbedData or not GrabbedData["Body"] then

				return

			end

			return HttpService:JSONDecode(GrabbedData["Body"])

		end
		
		function MainFirebase:PurgeRootAsync()
			
			local function Confirm() -- Extra precaution because this can cause some serious damage
				
				Infernus:DoOperation(Name, nil, nil, AuthKey, URL, {["T"] = "ROD"})
				
			end
			
			return Confirm
			
		end

		return MainFirebase

	end

	function Firebase:GetRootAsync()

		local GrabbedData = Infernus:DoOperation(nil, nil, nil, AuthKey, URL, {["T"] = "URL"})
		if not GrabbedData or not GrabbedData["Body"] then

			return

		end

		return HttpService:JSONDecode(GrabbedData["Body"])

	end

	return Firebase

end

--------
--Main--
--------

return Infernus

