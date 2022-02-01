function _vs_uninstall --on-event vs_uninstall
    functions --erase vs
    functions --erase __vs_list_sessions
    functions --erase __vs_list_session_dirs
end
