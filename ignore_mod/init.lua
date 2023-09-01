-------------------------------------------
-- Command:
--   /ignore <player2> -or- /ignore <player2> <player1> (if moderator priv)
-- For player command: /ignore OtherPlayrName
-- For Staff/admin command (with moderator priv): /ignore OtherPlayerName OnBehalfPlayerName
-- Intercept with the /pm commands and filter before sending it to the main 
-------------------------------------------


local S = minetest.get_translator("ignore")

-- Register /ignore command
minetest.register_chatcommand("ignore", {
    privs = {
        interact = true,
    },
    func = function(name, param)
        local msg1 = S("Ignored messages from: ") .. param
        local msg2 = S("Allowed messages from: ") .. param

        local name2, _ = param:match("(%S+)(.*)")
        local name3, _ = _:match("(%S+)(.*)")

        local player1 = minetest.get_player_by_name(name)
        local p1meta = player1:get_meta()

        local s = p1meta:get_string("ignore:names")

        local ignored_names = {}
        if s then
            ignored_names = minetest.deserialize(s)
        else
            minetest.log("debug", "Creating a new ignore list for player: "..name)
        end

        -- for _, key in ipairs(ignored_names) do
        --     print(_..": "..key)
        -- end

        local msg = msg1
        if ignored_names[name2] then
            -- remove the ignored player
            ignored_names[name2] = false

            -- set the message to allowed message
            msg = msg2
        else
            -- add the ignored player
            ignored_names[name2] = true
        end

        s = minetest.serialize(ignored_names)
        print("ignore:names ["..name.."]: "..string.sub(s, 7))

        p1meta:set_string("ignore:names", s)

        return true, msg
    end,
})

local colored_name = function(name)
    -- 
    return name
end

local intercept_msg_for_ignore = function(name, param)
    local name2, _ = param:match("(%S+)(.*)")

    local player1 = minetest.get_player_by_name(name2)
    if not player1 then return false, "Player offline." end

    local p1meta = player1:get_meta()

    local s = p1meta:get_string("ignore:names")

    local ignored_names = {}
    if s then
        ignored_names = minetest.deserialize(s)

        if ignored_names[name] then
            minetest.log("action", "Ignored DM from "..colored_name(name).." to "..colored_name(name2)..":".._)
            return false, S("Message ignored.")
        end
    end

    minetest.chat_send_player(name2, "DM from "..colored_name(name)..":".._)
    minetest.log("action", "DM from "..colored_name(name).." to "..colored_name(name2)..":".._)

    return true, S("Message sent.")
end

minetest.register_chatcommand("msg", {privs = { interact = true, }, func = intercept_msg_for_ignore, })
minetest.register_chatcommand("m", {privs = { interact = true, }, func = intercept_msg_for_ignore, })
minetest.register_chatcommand("pm", {privs = { interact = true, }, func = intercept_msg_for_ignore, })


-- -- Intercept chat message
-- minetest.register_on_chat_message(function(name, message)
--     -- minetest.chat_send_all("Person "..name.." chatted: "..message)
--     if message:sub(1, 1) == "/" then
--         print(name .. " ran chat command")
--     elseif minetest.check_player_privs(name, { shout = true }) then
--         print(name .. " said " .. message)
--     else
--         print(name .. " tried to say " .. message ..
--                 " but doesn't have shout")
--     end

--     return false
-- end)



print("-!- Initialized ignore_mod v30jun23")
