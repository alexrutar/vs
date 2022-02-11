function __vs_list_sessions --argument session_dir
    fd --extension vim --hidden --no-ignore --base-directory $session_dir --exec echo {.}
end

function __vs_list_session_dirs --argument session_dir
    fd --type d --hidden --no-ignore --base-directory $session_dir --exclude "*.lock" --strip-cwd-prefix | sed 's/$/\//'
end

function __vs_run_session --argument vim_cmd_args session_name session_file session_lock
    if mkdir $session_lock &> /dev/null
        fish --no-config --command 'trap "rmdir $argv[2]" INT TERM EXIT; $argv[3..] '$vim_cmd_args $session_file $session_lock $argv[5..]
    else
        echo "Session '$session_name' already running!" >&2
        return 1
    end
end

function vs --argument command session_name new_session_name --description "Manage vim session files"
    set --local vs_version 0.5

    # establish defaults
    set --query VS_SESSION_DIR
    or set --query XDG_DATA_HOME && set --local VS_SESSION_DIR "$XDG_DATA_HOME/vs"
    or set --local VS_SESSION_DIR "$HOME/.local/share/vs"

    set --query VS_VIM
    or set --local VS_VIM (which vim)


    # normalize session dir
    set --local VS_SESSION_DIR (string trim --chars '/' --right $VS_SESSION_DIR)
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
            echo '                            Default: ~/.local/share/vs'
            echo '       VS_VIM              Vim executable'
            echo "                            Default:" (which vim)


        case open
            if not test -n "$session_name"
                set --local fzf_session (__vs_list_sessions $VS_SESSION_DIR | sort | fzf --height 40% --border --tac)
                if test -n "$fzf_session"
                    set session_name "$fzf_session"
                else
                    return 0
                end
            end

            set --local session_lock "$VS_SESSION_DIR/$session_name.lock"
            set --local session_file "$VS_SESSION_DIR/$session_name.vim"

            if test -f $session_file
                __vs_run_session '-S $argv[1]' $session_name $session_file $session_lock $VS_VIM
            else
                echo "Could not find session '$session_name'" >&2
                return 1
            end


        case init
            set --local session_lock "$VS_SESSION_DIR/$session_name.lock"
            set --local session_file $VS_SESSION_DIR/$session_name.vim

            if test -f $session_file
                echo "Cannot overwrite existing session '$session_name'" >&2
                return 1
            else
                mkdir --parents (dirname $session_file)
                __vs_run_session '"+silent Obsess $argv[1]" +term' $session_name $session_file $session_lock $VS_VIM
            end


        case rename mv
            set --local source
            set --local target

            # don't mangle directory names
            if test -d $VS_SESSION_DIR/$session_name
                set source $VS_SESSION_DIR/$session_name
                set target $VS_SESSION_DIR/$new_session_name
                mkdir --parents $target
            else
                set source $VS_SESSION_DIR/$session_name.vim
                if test -d $VS_SESSION_DIR/$new_session_name
                    or string match -e '/' $new_session_name &> /dev/null
                    set target $VS_SESSION_DIR/$new_session_name
                    mkdir --parents $target
                else
                    set target $VS_SESSION_DIR/$new_session_name.vim
                    mkdir --parents (dirname $target)
                end
            end

            mv --interactive $source $target


        case delete rm
            set --local source
            if test -d $VS_SESSION_DIR/$session_name
                set source $VS_SESSION_DIR/$session_name
            else
                set source $VS_SESSION_DIR/$session_name.vim
            end
            rm --recursive --interactive $source


        case list ls
            if isatty 1
                __vs_list_sessions $VS_SESSION_DIR | tree --fromfile . --noreport
            else
                __vs_list_sessions $VS_SESSION_DIR | sort
            end


        case _cleanup
            fd --extension lock --base-directory $VS_SESSION_DIR --exec rmdir


        case _list_all
            begin; __vs_list_sessions $VS_SESSION_DIR; __vs_list_session_dirs $VS_SESSION_DIR; end | sort


        case '*'
            echo "vs: Unknown command: \"$command\"" >&2
            return 1
    end
end
