-- Cinemagraph Mode by Chris Linton
-- Extension loops a single video until the total time played passes the number
-- set below. Meant to loop cinemagraph files while still cycling them over time.

-- Total time (in seconds) to repeat each video across multiple repeats
-- before moving to next.
play_time_limit = 20

function descriptor()
    return { title = "Cinemagraph Mode" ;
             version = "0.1" ;
             author = "Chris Linton" ;
             capabilities = {"playing-listener","meta-listener"} }
end

function activate()
    time_played = 0
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
                time_played = time_played + (item:duration() / 12)

                if previous_item ~= item:name() then 
                    vlc.playlist.repeat_("on")
                end

                if time_played >= play_time_limit then
                    previous_item = item:name()
                    vlc.playlist.repeat_("off")
                    time_played = 0
                end
            end
        end
    end
end