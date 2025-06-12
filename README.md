# EzData-Infernus

This is a guide on how to setup and use Infernus. I made it pretty similar to Datastores, BUT you'll still need to set some stuff up on the firebase website.

## Setup

Temp

### Setup Function

<pre> Infernus:Setup(Authkey, URL) </pre>

This function serves as the setup function to actually link the module to your **firebase project**. You'll need to run the function with the **auth-key** & **URL** you got from the setup steps. 

### Main Functions

<pre> Firebase:GetFireBase(Name, Scope) </pre>

This function works exactly like :GetDatastore() does in the roblox API. You'll need to include the name of the firebase you want to grab and optionally a scope.

<pre> Firebase:GetRootAsync() </pre>

This function will return every **firebase** in your **firebase project** and thats about it.

### Data Functions

<pre> MainFirebase:GetAsync(Key) </pre>

Works pretty much the exact same as :GetAsync() with the DatastoreService API, just provide it a key and it'll give you whatever data is stored in it

<pre> MainFirebase:SetAsync(Key, Data) </pre>

This one also works pretty much the same as :SetAsync() in the DatastoreService API, pretty much just give it a key and some data to save and you'll be good.

<pre> MainFirebase:RemoveAsync(Key) </pre>

This one again works the same as :RemoveAsync() in the DatastoreService API, it'll delete all the data from the provided key.

<pre> MainFirebase:PatchAsync(Key, Data) </pre>

This function works similar to :SetAsync BUT it will only set stuff that's been changed so for example if you have a key set as like {["Test"] = 3, ["Test2"] = 5} if you run the function and set the data argument as {["Test"] = 8} it would result in {["Test"] = 8, ["Test2"] = 5} It basically keeps the values you didnt change the same and only changes whatever you sent over, its better for performance over :SetAsync()

<pre> MainFirebase:GetRootAsync() </pre>

Running this will return a table of all the keys in the **firebase**



