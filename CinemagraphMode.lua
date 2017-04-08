repeat_period = 60 -- how long each video show run (across multiple repeats) in seconds
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
    --update_playback_mode()
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
                vlc.msg.dbg("Playcount "..play_count.." for "..item:name())

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

--[[function update_playback_mode()
  if vlc.input.is_playing() then
    local item = vlc.item or vlc.input.item()
    if item then
      local meta = item:metas()
      if meta then
        local repeat_track = meta["Playback mode"]
        if repeat_track == nil then
          repeat_track = false
        elseif string.lower(repeat_track) == "repeat" then
          repeat_track = true
        else
          repeat_track = false
        end

    local player_mode = vlc.playlist.repeat_()

    -- toggle playlist.repeat_() as required        
    if player_mode and not repeat_track then
        vlc.playlist.repeat_()
    elseif not player_mode and repeat_track then
        vlc.playlist.repeat_()
    end

    return true
  end
end]]--