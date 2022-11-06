function _vs_install --on-event vs_install
    for cmd in fd fzf tree
        if not which $cmd &> /dev/null
            set_color yellow; echo "Warning: cannot find command '$cmd'. See https://github.com/alexrutar/vs#dependencies for more details."; set_color normal
        end
    end
end

function _vs_uninstall --on-event vs_uninstall
    functions --erase vs
    functions --erase __vs_list_sessions
    functions --erase __vs_list_session_dirs
    functions --erase __vs_run_session
    functions --erase __vs_delete_session
    functions --erase __vs_rename
end
