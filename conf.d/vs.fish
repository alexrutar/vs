function __vs_install --on-event vs_install
    for cmd in fd fzf tree
        if not which $cmd &> /dev/null
            set_color yellow; echo -n "Warning: "; echo "cannot find command '$cmd'. See https://github.com/alexrutar/vs#dependencies for more details."; set_color normal
        end
    end
end

function __vs_uninstall --on-event vs_uninstall
    functions --erase vs __vs_list_sessions __vs_list_session_dirs __vs_run_session __vs_delete_session __vs_rename __vs_echo_help __vs_install __vs_uninstall
end
