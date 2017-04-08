-- Cinemagraph Mode by Chris Linton
-- Extension loops a single video until the total time played passes the number
-- set below. Meant to loop cinemagraph files while still cycling them over time.

-- Total time (in seconds) to repeat each video across multiple repeats
-- before moving to next.
play_time_limit = 30

function descriptor()
    return { title = "Cinemagraph Mode";
             version = "0.2";
             author = "Chris Linton";
             description = "Repeats a video multiple times before playing the next";
             capabilities = {"playing-listener","meta-listener"} }
end

function activate()
    time_played = 0
    item_change = false
    vlc.playlist.repeat_("on")
    vlc.playlist.loop("on")
    update_playback_mode()
end

function deactivate()
    vlc.playlist.repeat_("off")
    vlc.playlist.loop("off")
end

function meta_changed()
    update_playback_mode()
end

function playing_changed()
    update_playback_mode()
end

function update_playback_mode() 
    if vlc.input.is_playing() then
        local item = vlc.item or vlc.input.item()
        if item then
            local meta = item:metas()

            if meta then
                if item_change and previous_item ~= item:name() then 
                    vlc.playlist.repeat_("on")
                    item_change = false
                    time_played = 0
                end
                -- meta_changed seems to be called 20 times every repeat
                time_played = time_played + (item:duration() / 20)
                vlc.msg.dbg("Time played: "..time_played.." current: "..item:name())
                if previous_item ~= nil then vlc.msg.dbg("Previous: "..previous_item) end

                if time_played >= play_time_limit then
                    previous_item = item:name()
                    item_change = true
                    vlc.playlist.repeat_("off")
                end
            end
        end
    end
end