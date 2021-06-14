# .zshrc
# Settings used by all zsh invocations

setopt prompt_subst

# this is so things like "scp host:path/* ." work
unsetopt nomatch

# zsh modules
autoload -U zcalc

# Command history
HISTSIZE=2000
SAVEHIST=${HISTSIZE}
HISTFILE=${HOME}/.history
export HISTSIZE SAVEHIST HISTFILE
setopt hist_ignore_all_dups
setopt hist_ignore_space

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
    echo "${tPATH}" | grep -q "${HOME}/.local/bin" || PATH="${HOME}/.local/bin:${PATH}"
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

# Make sure mbsync has directories
if [ -f ${HOME}/.mbsyncrc ]; then
    grep -v "^#" ${HOME}/.mbsyncrc | grep "Path " | awk '{ print $2; }' | \
    while read maildirname ; do
        mdn="$(eval echo "${maildirname}")"
        [ -d "${mdn}" ] || mkdir -p "${mdn}"
    done
fi

# Command aliases
OS="$(uname 2>/dev/null)"

if [ "${OS}" = "Darwin" ]; then
    alias ls="ls -FG"
elif [ "${OS}" = "FreeBSD" ]; then
    alias ls="ls -FCG"
else
    alias ls="ls -FC --color=tty"
    alias cp="cp -iv"
    alias rm="rm -iv"
    alias mv="mv -iv"
    alias ln="ln -iv"
fi

alias less="less -F -R -X"
alias bc="bc -q -l"
alias ftp="tnftp"
alias pwgen="pwgen -c -n -y 16 1"
alias dotfiles='git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME'

# Aliases specific to Fedora/RHEL/CentOS and derivatives
if [ -r /etc/fedora-release ] || [ -r /etc/redhat-release ] || [ -r /etc/centos-release ]; then
    alias rmdebugrpms='sudo yum remove $(rpm -qa | grep -E "debug(info|source)")'
    alias scuttle="sudo systemctl"
fi

# Other environment variables
NAME="David Cantrell"
PAGER="less -F -R -X"

# Emacs setup
ALTERNATE_EDITOR=""

if [ -z "${SSH_CONNECTION}" ]; then
    alias emacs="emacsclient -c"
    EDITOR="emacsclient -c"
else
    alias emacs="emacs -nw"
    EDITOR="emacs -nw"
fi

alias vim='printf "Use Emacs.\n"'
VISUAL="${EDITOR}"

# Make sure emacs has directories in place
[ -d ${HOME}/.emacs.d ] || mkdir -p ${HOME}/.emacs.d
[ -d ${HOME}/.emacs.d/autosaves ] || mkdir -p ${HOME}/.emacs.d/autosaves
[ -d ${HOME}/.emacs.d/backups ] || mkdir -p ${HOME}/.emacs.d/backups

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

    if [ ! "$(ps -p $SSH_AGENT_PID -o comm=)" = "ssh-agent" ]; then
        unset SSH_AGENT_PID
        unset SSH_AUTH_SOCK
        /bin/rm -f ${AGENT_ENV}
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
PROMPT="[%n@%m %1~]%# "
RPROMPT=$'$(git_super_status)'

# Prevent GTK scrollbar autohide
GTK_OVERLAY_SCROLLING=0

# Set browser command for urlscan
BROWSER="firefox --new-tab"

export PROMPT RPROMPT
export PATH NAME EDITOR VISUAL ALTERNATE_EDITOR PAGER
export QUOTING_STYLE
export GTK_OVERLAY_SCROLLING
export BROWSER

# Home and End keys (especially inside tmux)
bindkey "$(tput khome | cat -v)" beginning-of-line
bindkey "$(tput kend | cat -v)" end-of-line

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
            /bin/rm -f "${s}"
            /bin/ln -sf ${IRSSI_SCRIPTS_DIR}/${s} .
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
          [ -r "${s}" ] && /bin/rm -f ${s}
          /bin/ln -sf ../${s} .
        )
    done
    cd ${HOME}
fi
