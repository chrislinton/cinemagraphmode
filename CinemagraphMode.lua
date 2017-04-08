play_count_limit = 4

function descriptor()
    return { title = "Cinemagraph Mode" ;
             version = "0.1" ;
             author = "Chris Linton" ;
             capabilities = {} }
end

function activate()
    play_count = 0
    vlc.playlist.repeat_("on")
    vlc.playlist.loop("on")
    update_playback_mode()
end

function input_changed()
    -- related to capabilities={"input-listener"} in descriptor()
    -- triggered by Start/Stop media input event
    update_playback_mode()
end

function meta_changed()
    -- related to capabilities={"meta-listener"} in descriptor()
    -- triggered by available media input meta data?
    play_count = play_count + 1
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
                vlc.msg.dbg("Playcount "..play_count.." for "..item:name().." (time played: ".. ..")")

                if play_count == 12 and previous_item ~= item:name() then vlc.playlist.repeat_("on") end

                if (play_count / 12) >= play_count_limit then
                    previous_item = item:name()
                    vlc.playlist.repeat_("off")
                    play_count = 0
                end
            end
        end
    end
end

function deactivate()
    vlc.playlist.repeat_("off")
end

function close()
    vlc.deactivate()
end