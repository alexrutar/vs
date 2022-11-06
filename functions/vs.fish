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
        echo "Session '$session_name' already running!" >&2
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
        echo "Could not delete session '$session_name': session already running!" >&2
        return 1
    end
end


function __vs_rename --argument source target
    mv --interactive $source $target
end


function vs --argument command session_name new_session_name --description "Manage vim session files"
    set --function vs_version 0.7

    # establish defaults
    set --query VS_SESSION_DIR
    or set --query XDG_DATA_HOME && set --function VS_SESSION_DIR "$XDG_DATA_HOME/vs"
    or set --function VS_SESSION_DIR "$HOME/.local/share/vs/sessions"

    set --query VS_VIM_CMD
    or set --function VS_VIM_CMD (which vim)


    # normalize session dir
    set --function VS_SESSION_DIR (string trim --chars '/' --right $VS_SESSION_DIR)
    mkdir -p $VS_SESSION_DIR


    # main argument processing
    switch $command
        case -v --version
            echo "vs, version $vs_version"


        case '' -h --help help
            echo 'Usage: vs open [SESSION]   Open the session'
            echo '       vs init SESSION     Start up a new session'
            echo '       vs delete SESSION   Delete the session'
            echo '       vs rename OLD NEW   Rename the session'
            echo '       vs list             List available sessions'
            echo 'Options:'
            echo '       -v | --version      Print version'
            echo '       -h | --help         Print this help message'
            echo 'Variables:'
            echo '       VS_SESSION_DIR      Saved session directory'
            echo '                            Default: ~/.local/share/vs/sessions'
            echo '       VS_VIM_CMD          Vim executable'
            echo '                            Default:' (which vim)


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
                    echo "Missing session name" >&2
                    return 1
                end
            end

            set --function session_lock "$VS_SESSION_DIR/$session_name.lock"
            set --function session_file "$VS_SESSION_DIR/$session_name.vim"

            if test -f $session_file
                __vs_run_session '-S $argv[1]' $session_name $session_file $session_lock $VS_VIM_CMD
            else
                echo "Could not find session '$session_name'" >&2
                return 1
            end


        case init
            set --function session_lock "$VS_SESSION_DIR/$session_name.lock"
            set --function session_file $VS_SESSION_DIR/$session_name.vim

            if test -f $session_file
                echo "Cannot overwrite existing session '$session_name'" >&2
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
                    echo "Cannot overwrite existing file!" >&2
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
                        echo "Cannot overwrite existing file!" >&2
                        return 1
                    end
                    mkdir --parents $target
                else

                    # source and target are both files
                    set --function target $VS_SESSION_DIR/$new_session_name.vim
                    if test -e $target
                        echo "Cannot overwrite existing file!" >&2
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
                and which tree &> /dev/null
                __vs_list_sessions $session_name | tree --fromfile . --noreport
            else
                __vs_list_sessions $session_name
            end


        case _cleanup
            # lockfiles are empty directories
            fd --base-directory $VS_SESSION_DIR --type empty --type directory --exec rmdir


        case _list_all
            begin; __vs_list_sessions $VS_SESSION_DIR; __vs_list_session_dirs $VS_SESSION_DIR; end | sort


        case '*'
            echo "vs: Unknown command: \"$command\"" >&2
            return 1
    end
end
