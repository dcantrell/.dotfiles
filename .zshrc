# .zshrc
# Settings used by all zsh invocations

setopt PROMPT_SUBST
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS

# this is so things like "scp host:path/* ." work
unsetopt NOMATCH

# zsh modules
autoload -U zcalc

# Command history
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=${HOME}/.history

# Function to name terminal windows with an arbitrary string
# Usage:  wname "STRING"
# e.g., wname mutt
wname() {
    echo -en "\033]0;$@\007";
}

# Make sure we have some basic PATH
[ -z "${PATH}" ] && PATH=/usr/bin:/usr/local/bin

# Protect files and directories
if [ ! -z "${HOME}" ]; then
    chmod 0711 "${HOME}"
    [ -d "${HOME}/etc" ] && chmod 0700 "${HOME}/etc"
fi

# Something is making this directory appear, stop!  02-Mar-2011
[ -d "${HOME}/Desktop" ] && rmdir "${HOME}/Desktop" 2>/dev/null

# Amend the PATH
if [ ! -z "${PATH}" ]; then
    tPATH=" $(echo ${PATH} | sed -e 's/:/\ /g')"

    echo "${tPATH}" | grep -q "${HOME}/bin" || PATH="${HOME}/bin:${PATH}"
    echo "${tPATH}" | grep -q "/usr/local/sbin" || PATH="${PATH}:/usr/local/sbin"
    echo "${tPATH}" | grep -q "/usr/sbin" || PATH="${PATH}:/usr/sbin"
    echo "${tPATH}" | grep -q "/sbin" || PATH="${PATH}:/sbin"
fi

# Pull in photo tools
[ -d "${HOME}/photos/bin" ] && PATH=${PATH}:${HOME}/photos/bin

# Things installed by pip and maybe other package managers
[ -d "${HOME}/.local/bin" ] && PATH=${PATH}:${HOME}/.local/bin
[ -d "${HOME}/.cabal/bin" ] && PATH=${PATH}:${HOME}/.cabal/bin

# Make sure we have the right ssh config permissions
[ -f "${HOME}/.ssh/config" ] && chmod 0644 "${HOME}/.ssh/config"

# Make sure emacs has directories in place
[ -d ${HOME}/.emacs.d ] || mkdir -p ${HOME}/.emacs.d
[ -d ${HOME}/.emacs.d/autosaves ] || mkdir -p ${HOME}/.emacs.d/autosaves
[ -d ${HOME}/.emacs.d/backups ] || mkdir -p ${HOME}/.emacs.d/backups

# Make sure mbsync has directories
if [ -f ${HOME}/.mbsyncrc ]; then
    grep -v ^# ${HOME}/.mbsyncrc | grep "Path " | awk '{ print $2; }' | \
    while read maildirname ; do
        mdn="$(eval echo "${maildirname}")"
        [ -d "${mdn}" ] || mkdir -p "${mdn}"
    done
fi

# Command aliases
alias less="less -F -R -X"
alias ls="ls -FC --color=tty"
alias bc="bc -q -l"
alias ftp="tnftp"
alias pwgen="pwgen -c -n -y 16 1"
alias emacs="emacs -nw"
alias dotfiles='git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME'
alias vim='printf "Use Emacs.\n"'

# Other environment variables
NAME="David Cantrell"
EDITOR="emacs -nw"
VISUAL="emacs -nw"
PAGER="less -F -R -X"

# GnuPG and agent settings
#
# Go ahead and force start the agent
gpg-connect-agent /bye >/dev/null 2>&1

# Various settings for GnuPG
GPGKEY=62977BB9C841B965
GPG_TTY="$(tty)"
export GPGKEY GPG_TTY

# Ensure we are connected to the agent
# (The -q option to gpg-connect-agent lies, it's still noisy.)
echo UPDATESTARTUPTTY | gpg-connect-agent >/dev/null 2>&1

# Run the ssh-agent or connect to an already running one
# NOTE:  To get this block working, make sure you start with no .ssh/agent.env
# file and no running ssh-agent.
AGENT_ENV=${HOME}/.ssh/agent.env

if [ -f ${AGENT_ENV} ]; then
    eval $(cat ${AGENT_ENV})

    if [ ! "$(ps -q $SSH_AGENT_PID -o comm=)" = "ssh-agent" ]; then
        unset SSH_AGENT_PID
        unset SSH_AUTH_SOCK
        rm -f ${AGENT_ENV}
        ssh-agent | grep -v ^echo > ${AGENT_ENV}
        eval $(cat ${AGENT_ENV})
    fi
else
    pid="$(pgrep ssh-agent)"

    if [ -z "${pid}" ]; then
        ssh-agent | grep -v ^echo > ${AGENT_ENV}
        eval $(cat ${AGENT_ENV})
    fi
fi

# As of GNU coreutils 8.25, the ls(1) command will wrap filenames
# with spaces in single quotes if the output device is a tty.  This
# is strange and unusual and unwelcome.  This variable will restore
# the expected behavior of ls:
QUOTING_STYLE=literal

# Show vcs branch and type information in the right prompt
[ -f ~/bin/zsh-git-prompt.sh ] && . ~/bin/zsh-git-prompt.sh

# Command prompt settings
PROMPT="[%n@%m %1~]%(!.#.$) "
RPROMPT=$'$(git_super_status)'

# Prevent GTK scrollbar autohide
GTK_OVERLAY_SCROLLING=0

export PROMPT RPROMPT
export PATH NAME EDITOR VISUAL PAGER
export QUOTING_STYLE
export GTK_OVERLAY_SCROLLING

# Home and End keys (especially inside tmux)
bindkey "\E[1~" beginning-of-line
bindkey "\E[4~" end-of-line

# Make sure latest irssi scripts are in use
if [ -d /usr/share/irssi/scripts ]; then
    IRSSI_SCRIPTS_DIR=/usr/share/irssi/scripts
elif [ -d /usr/local/share/irssi/scripts ]; then
    IRSSI_SCRIPTS_DIR=/usr/local/share/irssi/scripts
fi

IRSSI_SCRIPTS="splitlong usercount"

if [ -d "${IRSSI_SCRIPTS_DIR}" -a -d "${HOME}/.irssi/scripts" ]; then
    cd "${HOME}/.irssi/scripts"
    for s in ${IRSSI_SCRIPTS} ; do
        [ "${s}" = "autorun" ] && continue
        if [ -r "${IRSSI_SCRIPTS_DIR}/${s}" ]; then
            rm -f "${s}"
            ln -sf ${IRSSI_SCRIPTS_DIR}/${s} .
        fi
    done
    cd ${HOME}
fi

# Load all irssi scripts at startup
if [ -d "${HOME}/.irssi/scripts" ]; then
    cd "${HOME}/.irssi/scripts"
    [ ! -d autorun ] && mkdir autorun
    for s in * ; do
        ( cd autorun
          [ -r "${s}" ] && rm -f ${s}
          ln -sf ../${s} .
        )
    done
    cd ${HOME}
fi
