function _vs_install --on-event vs_install
    for cmd in fd fzf tree
        if not which $cmd
            echo "Warning: cannot find command '$cmd'. See https://github.com/alexrutar/vs#dependencies for more details."
        end
    end
end

function _vs_uninstall --on-event vs_uninstall
    functions --erase vs
    functions --erase __vs_list_sessions
    functions --erase __vs_list_session_dirs
end
