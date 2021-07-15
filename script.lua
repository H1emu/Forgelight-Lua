(function()
	CustomLua = {};

	---- NOTE(rhett): Load other scripts
	inspect = require(Client.PathScripts .. 'inspect')

    
    ---- NOTE(rhett): Enable in-game console
    Client.EnableDebugConsole = true


    ---- NOTE(rhett): Use custom namespace
	CustomLua.NAME = 'CustomLua'


	
	---- NOTE(rhett): Helper functions
	-- NOTE(rhett): This might run better than using the .. operator
	function CustomLua.StringConcat(...)
		return table.concat(arg, ' ')
	end

	-- NOTE(rhett): Print message to console
	function CustomLua.PrintToConsole(msg)
		print(CustomLua.StringConcat(CustomLua.NAME, '>>', msg))
	end

	-- NOTE(rhett): Print to in-game chat window
	function CustomLua.PrintToChat(msg)
		local message = inheritsFrom(ChatMessageBase)

		-- NOTE(rhett): Give our messages a bright color
		message.text = CustomLua.StringConcat('<font color=\'#FF00FF\'>', msg, '</font>')
		message.channelId = ChatChannels.SYSTEM_MESSAGE:GetId()

		ChatHandler:AddChatMessage(message)

		-- NOTE(rhett): Print to the console as well
		CustomLua.PrintToConsole(msg)
	end

	---- NOTE(rhett): Use custom chat commands
	function ChatHandler:SendChat(msg)
		if msg == nil then
			return
		end

		-- NOTE(rhett): Split message into args
		local args = StringUtils:Split(msg, '%s')
		CustomLua.PrintToConsole('[*] Entered: \'' .. msg .. '\'')

		-- COMMAND(rhett): ping
		-- DESCRIPTION: Check that the custom lua is working
		if msg == '/ping' then
			CustomLua.PrintToChat('[*] Pong!')

		-- COMMAND(rhett): reload
		-- DESCRIPTION: Reload this lua file
		elseif msg == '/reload' then
			CustomLua.PrintToChat('[*] Reloading custom lua')
			local file = io.open(Client.PathScripts.."\\script.lua", 'r')
			local content = file:read('*all')
			file:close()
			assert(loadstring(content))()

        -- COMMAND(rhett): lua
        -- DESCRIPTION: Run some lua from the chat/console
        elseif args[1] == '/lua' then
            local code = string.sub(msg, 6)
            CustomLua.PrintToChat('[*] Running lua')
            local res = loadstring('return ' .. code)()
            if res then
                CustomLua.PrintToChat('[*] Result: ' .. tostring(res))
            end

        -- COMMAND(rhett): inspect
        -- DESCRIPTION: Inspect lua stuff and display results in chat
        elseif args[1] == '/inspect' then
            content = inspect(_G[args[2]])
            CustomLua.PrintToChat(content)

        -- COMMAND(rhett): dumplua
        -- DESCRIPTION: Dump all the loaded lua stuff. I don't know the proper term
        elseif args[1] == '/dumplua' then
            CustomLua.PrintToChat('[*] Dumping lua')
            local logtext = inspect(_G)
            io.output(io.open(Client.PathScripts ..'LuaDump.lua', 'w'))
            io.write(logtext .. '\n')
            io.flush()
            io.close()

        -- COMMAND(meme): dumpdsrow
        -- DESCRIPTION: Dumps a specified row from a specified datasource table
        elseif args[1] == '/dumpdsrow' then
        	if not args[2] or not args[3] then
        		CustomLua.PrintToConsole('[*] Invalid DumpDsRow Usage: /dumpdsrow [dsName] [row]')
        		return
        	end
        	CustomLua.PrintToConsole('[*] DataSourceDump For DS: '..args[2].. ', Row: '..args[3])
        	DataSourceConnection:DumpRowData(args[2], tonumber(args[3]))

        -- COMMAND(meme): dumptable
        -- DESCRIPTION: Dumps a specified global lua table to console
        elseif args[1] == '/dumptable' then
        	if not args[2] then
        		CustomLua.PrintToConsole('[*] Invalid DumpTable Usage: /dumptable [table]')
        		return
        	end
        	local res = loadstring('return inspect(' .. args[2] .. ')')()
            if res then
                CustomLua.PrintToChat('[*] ' .. args[2] .. ': ' .. tostring(res))
            end

        -- COMMAND(meme): dumpds
        -- DESCRIPTION: Dumps all the key names from a specified datasource table
        elseif args[1] == '/dumpds' then
        	if not args[2] then
        		CustomLua.PrintToConsole('[*] Invalid DumpDs Usage: /dumpds [table]')
        		return
        	end
        	local dstable = loadstring('return DsTable.Find("' .. args[2] .. '")')()
        	local ds = {};
        	local dsprint = "\n";
        	if dstable then
        		for i = 1, dstable:GetColumnCount() do
        			ds[i] = ">> Column[ " .. i .. " ]: ".. dstable:GetColumnName(i-1)
        			dsprint = dsprint .. "\n>> Column[ " .. i .. " ]: ".. dstable:GetColumnName(i-1);
        		end
        	end
            CustomLua.PrintToChat('[*] ' .. args[2] .. ': ' .. dsprint)
		else
			-- NOTE(rhett): Send message as normal
			msg = Ui.MakeHtmlSafe(msg)
			Ui.ProcessChatCommand(msg)
		end
	end

	-- NOTE(rhett): Forward console commands to our chat handler
	function ConsoleWrapper:ProcessChatCommand(msg)
		ChatHandler:SendChat(msg)
	end

	CustomLua.PrintToChat('[*] CustomLua Loaded')
end)()

