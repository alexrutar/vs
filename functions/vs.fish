function __vs_FAIL --argument message
    set_color red; echo -n "Error: " >&2; set_color normal
    echo $message >&2
    return 1
end


function __vs_list_sessions --argument session_dir
    if test -n "$session_dir"
        and test -d $VS_SESSION_DIR/$session_dir
        set --function search_opts --search-path $session_dir
    end
    fd $search_opts \
        --extension vim \
        --hidden \
        --no-ignore \
        --base-directory $VS_SESSION_DIR \
        --exec echo {.}
end


function __vs_list_session_dirs --argument session_dir
    fd --type d --hidden --no-ignore --base-directory $session_dir --exclude "*.lock" --strip-cwd-prefix | sed 's/$//'
end


function __vs_run_session --argument vim_cmd_args session_name session_file session_lock
    if mkdir $session_lock &> /dev/null
        fish --no-config --command 'trap "rmdir $argv[2]" INT TERM HUP EXIT; $argv[3..] '$vim_cmd_args $session_file $session_lock $argv[5..]
    else
        __vs_FAIL "Session '$session_name' already running!"
        return 1
    end
end


function __vs_delete_session --argument session_name
    set --function session_lock $VS_SESSION_DIR/$session_name.lock
    set --function session_file $VS_SESSION_DIR/$session_name.vim
    if mkdir $session_lock &> /dev/null
        rm --force $session_file
        rmdir $session_lock
        # clean up empty directory
        rmdir --parents --ignore-fail-on-non-empty (path dirname $VS_SESSION_DIR/$session_name)
    else
        __vs_FAIL "Could not delete session '$session_name': session already running!"
        return 1
    end
end


function __vs_rename --argument source target
    mv --interactive $source $target
end


function __vs_echo_help
    set_color cyan; echo 'Usage:'; set_color normal
    echo '    vs open [SESSION]   Open the session'
    echo '    vs init SESSION     Start a new session'
    echo '    vs delete SESSION   Delete the session'
    echo '    vs rename OLD NEW   Rename the session'
    echo '    vs list             List available sessions'
    echo
    set_color cyan; echo 'Options:'; set_color normal
    echo '    -h/--help           Print this help message'
    echo '    -v/--version        Print version'
    echo
    set_color cyan; echo 'Variables:'; set_color normal
    echo '    VS_SESSION_DIR      Saved session directory'
    echo '                         Default: ~/.local/share/vs/sessions'
    echo '    VS_VIM_CMD          Vim executable'
    echo '                         Default:' (which vim)
end


function vs --argument command session_name new_session_name --description "Manage vim session files"
    set --function vs_version 1.0

    # establish defaults
    set --query VS_SESSION_DIR
    or set --query XDG_DATA_HOME && set --function VS_SESSION_DIR "$XDG_DATA_HOME/vs"
    or set --function VS_SESSION_DIR "$HOME/.local/share/vs/sessions"

    set --query VS_VIM_CMD
    or set --function VS_VIM_CMD (which vim)


    # normalize session dir
    set --function VS_SESSION_DIR (string trim --chars '/' --right $VS_SESSION_DIR)
    mkdir -p $VS_SESSION_DIR

    # parse options
    set --local options (fish_opt --short=v --long=version)
    set --local options $options (fish_opt --short=h --long=help)

    if not argparse $options -- $argv
        __vs_echo_help >&2
        return 1
    end

    set --local command $argv[1]
    set --local session_name $argv[2]
    set --local new_session_name $argv[3]

    if set --query _flag_help
        __vs_echo_help
        return 0
    end

    if set --query _flag_version
        echo "vs (version $vs_version)"
        return 0
    end

    if test -z "$command"
        echo "tpr: missing subcommand" >&2
        __vs_echo_help >&2
        return 1
    end


    # main argument processing
    switch $command
        case open
            if not test -n "$session_name"
                if which fzf &> /dev/null
                    set --function fzf_session (__vs_list_sessions $VS_SESSION_DIR | sort | fzf --height 40% --border --tac)
                    if test -n "$fzf_session"
                        set session_name "$fzf_session"
                    else
                        return 0
                    end
                else
                    __vs_FAIL "Missing session name"
                    return 1
                end
            end

            set --function session_lock "$VS_SESSION_DIR/$session_name.lock"
            set --function session_file "$VS_SESSION_DIR/$session_name.vim"

            if test -f $session_file
                __vs_run_session '-S $argv[1]' $session_name $session_file $session_lock $VS_VIM_CMD
            else
                __vs_FAIL "Could not find session '$session_name'"
                return 1
            end


        case init
            set --function session_lock "$VS_SESSION_DIR/$session_name.lock"
            set --function session_file $VS_SESSION_DIR/$session_name.vim

            if test -f $session_file
                __vs_FAIL "Cannot overwrite existing session '$session_name'"
                return 1
            else
                mkdir --parents (dirname $session_file)
                __vs_run_session '"+silent Obsess $argv[1]" +term' $session_name $session_file $session_lock $VS_VIM_CMD
            end


        case rename mv
            if test -d $VS_SESSION_DIR/$session_name

                # source and target are both directories
                set --function source $VS_SESSION_DIR/$session_name
                set --function target $VS_SESSION_DIR/$new_session_name
                if test -e $target/(path basename $session_name)
                    __vs_FAIL "Cannot overwrite existing file!"
                    return 1
                end
                mkdir --parents $target
            else
                set --function source $VS_SESSION_DIR/$session_name.vim
                if test -d $VS_SESSION_DIR/$new_session_name
                    or test (string sub -s -1 $new_session_name) = '/'

                    # source is a file, target is a directory
                    set --function target $VS_SESSION_DIR/$new_session_name
                    if test -e $target/(path basename $session_name).vim
                        __vs_FAIL "Cannot overwrite existing file!"
                        return 1
                    end
                    mkdir --parents $target
                else

                    # source and target are both files
                    set --function target $VS_SESSION_DIR/$new_session_name.vim
                    if test -e $target
                        __vs_FAIL "Cannot overwrite existing file!"
                        return 1
                    end
                    mkdir --parents (dirname $target)
                end
            end

            __vs_rename $source $target


        case delete rm
            if test -d $VS_SESSION_DIR/$session_name
                __vs_list_sessions $session_name | while read line; __vs_delete_session $line; end
            else
                __vs_delete_session $session_name
            end


        case list ls
            if isatty 1
                and type -q tree
                __vs_list_sessions $session_name | tree --fromfile . --noreport
            else
                __vs_list_sessions $session_name
            end


        case delete-lockfiles
            # lockfiles are empty directories
            fd --base-directory $VS_SESSION_DIR --type empty --type directory --exec rmdir


        case _list_all
            begin; __vs_list_sessions $VS_SESSION_DIR; __vs_list_session_dirs $VS_SESSION_DIR; end | sort


        case '*'
            __vs_FAIL "Unknown command: '$command'"
            return 1
    end
end
