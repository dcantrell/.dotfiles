# .bash_profile is executed for login shells, .bashrc is executed for
# interactive non-login shells.  We want the same behavior for both,
# so we source .bashrc from .bash_profile.
#
# The only thing this does is start up zsh as the actual shell.  This
# is for systems where chsh(1) does not work or is not permitted on
# accounts.

if [ -f "${HOME}/.bashrc" ]; then
    . "${HOME}/.bashrc"
fi
