# If $NOZSH is not set and bash is started as a login or non-login
# shell, exec zsh in its place as long as it's available.

if [ -z "${NOZSH}" ]; then
    case ${TERM} in
        xterm|xterm-256color|rxvt-unicode|rxvt-unicode-256color|tmux)
            if which zsh >/dev/null 2>&1 ; then
                SHELL=$(which zsh) ; export SHELL
                if [[ -o login ]]; then
                    exec zsh -l
                else
                    exec zsh
                fi
            fi
            ;;
    esac
fi
