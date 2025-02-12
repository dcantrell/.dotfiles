# .zshrc
# Settings used by all zsh invocations

setopt prompt_subst

# this is so things like "scp host:path/* ." work
unsetopt nomatch

# zsh modules
autoload -U zcalc
autoload -U compinit

# only show RPROMPT on active prompt
setopt transient_rprompt

# Completions
fpath=(~/.zfunctions/functions $fpath)
rm -rf ~/.zcompdump ; compinit

# Command history
HISTSIZE=2000
SAVEHIST=${HISTSIZE}
HISTFILE=${HOME}/.history
export HISTSIZE SAVEHIST HISTFILE
setopt hist_ignore_all_dups
setopt hist_ignore_space

# Who am i
NAME="David Cantrell"
EMAIL="dcantrell@burdell.org"

# git-annex variables
ANNEXHOST="kevlar.burdell.org"
ANNEXPATH="/srv/annex"
LOCALANNEX="${HOME}/annex"

# Function to name terminal windows with an arbitrary string
# Usage:  wname "STRING"
# e.g., wname mutt
wname() {
    echo -en "\033]0;$@\007";
}

# dotfiles git command wrapper
dotf() {
    env GIT_AUTHOR_EMAIL="${EMAIL}" \
        GIT_COMMITTER_EMAIL="${EMAIL}" \
    git --git-dir=${HOME}/.dotfiles/.git --work-tree=${HOME} $*
}

# Add and remove /opt bin dirs to the PATH
optin() {
    pkg="$1"
    desired_dir="/opt/${pkg}/bin"

    if [ -z "${pkg}" ]; then
        echo "Usage: optin [package in /opt" >&2
        echo "Example:  optin xz" >&2
    elif [ -d ${desired_dir} ]; then
        echo "PATH before: ${PATH}"

        pathdirs=(${(@s.:.)PATH})

        if (( ! $pathdirs[(Ie)${desired_dir}] )); then
            pathdirs+=(${desired_dir})
        fi

        PATH="${(@j.:.)pathdirs}"
        export PATH

        echo "PATH after: ${PATH}"
    fi
}

optout() {
    pkg="$1"
    desired_dir="/opt/${pkg}/bin"

    if [ -z "${pkg}" ]; then
        echo "Usage: optout [package in /opt" >&2
        echo "Example:  optout xz" >&2
    elif [ -d ${desired_dir} ]; then
        echo "PATH before: ${PATH}"

        pathdirs=(${(@s.:.)PATH})

        if [ ${pathdirs[(r)${desired_dir}]} = ${desired_dir} ]; then
            pathdirs[${pathdirs[(i)${desired_dir}]}]=()
        fi

        PATH="${(@j.:.)pathdirs}"
        export PATH

        echo "PATH after: ${PATH}"
    fi
}

# git-annex helpers

# cloneannex - Clone the local git-annex repos.  Use this once when
# setting up a new system or if you nuke the local annex.  This
# function requires network access.
cloneannex() {
    if ! ping -c 1 -q ${ANNEXHOST} >/dev/null 2>&1 ; then
        echo "*** ${ANNEXHOST} is unreachable, check network" >&2
        exit 1
    fi

    [ -d "${LOCALANNEX}" ] || mkdir -p "${LOCALANNEX}"
    CWD="$(pwd)"

    ssh "${ANNEXHOST}" ls -1d "${ANNEXPATH}"/*.git | sort | while read -r p ; do
        bp="$(basename "${p}")"
        subdir="$(basename "${bp}" .git)"
        git -C "${LOCALANNEX}" clone ${ANNEXHOST}:${ANNEXPATH}/${bp}
        ( cd "${LOCALANNEX}" ; ${ANNEXHOST}:${ANNEXPATH}/${bp} )
        ( cd "${LOCALANNEX}"/"${subdir}" ; git config user.name "${NAME}" )
        ( cd "${LOCALANNEX}"/"${subdir}" ; git config user.email "${EMAIL}" )
        ( cd "${LOCALANNEX}"/"${subdir}" ; git annex init . )
    done

    cd "${CWD}" || exit 1
}

# syncannex - Run git annex sync --content on all annex repos.
syncannex() {
    if [ ! -d "${LOCALANNEX}" ]; then
        echo "*** no local annex, exiting" >&2
        exit 1
    fi

    if ! ping -c 1 -q ${ANNEXHOST} >/dev/null 2>&1 ; then
        echo "*** ${ANNEXHOST} is unreachable, check network" >&2
        exit 1
    fi

    cd "${LOCALANNEX}" || exit 1
    CWD="$(pwd)"

    for repodir in * ; do
        git -C "${LOCALANNEX}"/"${repodir}" annex sync --content
    done

    cd "${CWD}" || exit 1
}

# linkannex - Symlink git-annex directories to $HOME
linkannex() {
    cd "${LOCALANNEX}" || exit 1
    CWD="$(pwd)"

    for repodir in * ; do
        [ -r "${HOME}"/"${repodir}" ] || ln -s annex/"${repodir}" "${HOME}"/"${repodir}"
    done

    cd "${CWD}" || exit 1
}

# unlocktree - This can't be an alias because of the pipe
unlocktree() {
    find . -type f -print0 | xargs -0 git annex unlock
}

# Make sure we have some basic PATH
[ -z "${PATH}" ] && PATH=/usr/bin:/usr/local/bin

# Protect files and directories
if [ ! -z "${HOME}" ]; then
    chmod 0711 "${HOME}"
    [ -d "${HOME}"/etc ] && chmod 0700 "${HOME}"/etc
fi

# Something is making this directory appear, stop!  02-Mar-2011
[ -d "${HOME}"/Desktop ] && rmdir "${HOME}"/Desktop 2>/dev/null

# But I am using this for what appears on the desktop.  08-Feb-2025
[ -d "${HOME}"/local ] || mkdir -p "${HOME}"/local

# Amend the PATH
if [ ! -z "${PATH}" ]; then
    pathdirs=(${(@s.:.)PATH})
    desired=(${HOME}/bin /usr/local/sbin /usr/sbin /sbin)

    for desired_dir in $desired ; do
        if (( ! $pathdirs[(Ie)${desired_dir}] )); then
            pathdirs+=(${desired_dir})
        fi
    done

    PATH="${(@j.:.)pathdirs}"
fi

# Pull in photo tools
[ -d "${HOME}"/photos/bin ] && PATH=${PATH}:${HOME}/photos/bin

# Things installed by pip and maybe other package managers
[ -d "${HOME}"/.local/bin ] && PATH=${PATH}:${HOME}/.local/bin
[ -d "${HOME}"/.cabal/bin ] && PATH=${PATH}:${HOME}/.cabal/bin

# Make sure we have the right ssh config permissions
[ -f "${HOME}"/.ssh/config ] && chmod 0644 "${HOME}/.ssh/config"

# Make sure mbsync has directories
if [ -f "${HOME}"/.mbsyncrc ]; then
    grep -v "^#" "${HOME}"/.mbsyncrc | grep "Path " | awk '{ print $2; }' | \
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
    alias cp="cp -ivp"
    alias rm="rm -iv"
    alias mv="mv -iv"
    alias ln="ln -iv"
    alias df="df -x tmpfs -x squashfs"
fi

alias ngrep="grep -I -n"
alias less="less -F -R -X"
alias bc="bc -q -l"
alias ftp="tnftp"
alias pwgen="pwgen -c -n -y 16 1"

# Aliases specific to Fedora/RHEL/CentOS and derivatives
if [ -r /etc/fedora-release ] || [ -r /etc/redhat-release ] || [ -r /etc/centos-release ]; then
    alias rmdebugrpms='sudo yum remove $(rpm -qa | /bin/grep -E "\-debug(info|source)" | /bin/grep -v debuginfod) --noautoremove'
    alias scuttle="sudo systemctl"
fi

# Other environment variables
PAGER="less -F -R -X"

# Emacs setup
ALTERNATE_EDITOR=""
EDITOR="emacs -nw"
VISUAL="${EDITOR}"
alias emacs="emacs -nw"
alias vi='printf "Use Emacs.\n"'
alias vim='printf "Use Emacs.\n"'

# Make sure emacs has directories in place
[ -d "${HOME}"/.emacs.d ] || mkdir -p "${HOME}"/.emacs.d
[ -d "${HOME}"/.emacs.d/autosaves ] || mkdir -p "${HOME}"/.emacs.d/autosaves
[ -d "${HOME}"/.emacs.d/backups ] || mkdir -p "${HOME}"/.emacs.d/backups

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
AGENT_ENV="${HOME}"/.ssh/agent.env

if [ -f "${AGENT_ENV}" ]; then
    eval $(cat "${AGENT_ENV}")

    if [ ! "$(ps -p $SSH_AGENT_PID -o comm=)" = "ssh-agent" ]; then
        unset SSH_AGENT_PID
        unset SSH_AUTH_SOCK
        /bin/rm -f "${AGENT_ENV}"
        ssh-agent | /bin/grep -v ^echo > "${AGENT_ENV}"
        eval $(cat "${AGENT_ENV}")
    fi
else
    pid="$(pgrep ssh-agent)"

    if [ -z "${pid}" ]; then
        ssh-agent | grep -v ^echo > "${AGENT_ENV}"
        eval $(cat "${AGENT_ENV}")
    fi
fi

# As of GNU coreutils 8.25, the ls(1) command will wrap filenames
# with spaces in single quotes if the output device is a tty.  This
# is strange and unusual and unwelcome.  This variable will restore
# the expected behavior of ls:
QUOTING_STYLE=literal

# Show vcs branch and type information in the right prompt
[ -f ~/.zfunctions/prompt/zsh-git-prompt.sh ] && . ~/.zfunctions/prompt/zsh-git-prompt.sh

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

# Make delete work
bindkey "^[[3~" delete-char

# Generate this file like this:
#     pass git pull
#     pass rht/jira > ~/.jirarc
#     chmod 0600 ~/.jirarc
if [ -f ${HOME}/.jirarc ]; then
    . ${HOME}/.jirarc
fi
