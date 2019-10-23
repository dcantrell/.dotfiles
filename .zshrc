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
autoload -Uz vcs_info

# Command history
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=${HOME}/.history

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
GPGKEY=62977BB9C841B965
GPG_TTY="$(tty)"
SSH_AUTH_SOCK="/run/user/$(id -u)/gnupg/S.gpg-agent.ssh"

# As of GNU coreutils 8.25, the ls(1) command will wrap filenames
# with spaces in single quotes if the output device is a tty.  This
# is strange and unusual and unwelcome.  This variable will restore
# the expected behavior of ls:
QUOTING_STYLE=literal

# Show vcs branch and type information in the right prompt
zstyle ':vcs_info:*' actionformats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
zstyle ':vcs_info:*' enable git cvs svn

vcs_info_wrapper() {
    vcs_info
    if [ -n "$vcs_info_msg_0_" ]; then
        echo "%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
    fi
}

# Command prompt settings
PROMPT="[%n@%m %1~]%(!.#.$) "
RPROMPT=$'$(vcs_info_wrapper)'

# Prevent GTK scrollbar autohide
GTK_OVERLAY_SCROLLING=0

export PROMPT RPROMPT
export PATH NAME EDITOR VISUAL PAGER
export GPGKEY GPG_TTY SSH_AUTH_SOCK
export QUOTING_STYLE
export GTK_OVERLAY_SCROLLING

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
