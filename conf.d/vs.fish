function _vs_install --on-event vs_install
    if not which fd
        echo "Warning: cannot find command 'fd'. See https://github.com/alexrutar/vs#dependencies for more details."
    end
    if not which fzf
        echo "Warning: cannot find command 'fzf'. See https://github.com/alexrutar/vs#dependencies for more details."
    end
end

function _vs_uninstall --on-event vs_uninstall
    functions --erase vs
    functions --erase __vs_list_sessions
    functions --erase __vs_list_session_dirs
end
