# To the extent possible under law, the author(s) have dedicated all 
# copyright and related and neighboring rights to this software to the 
# public domain worldwide. This software is distributed without any warranty. 
# You should have received a copy of the CC0 Public Domain Dedication along 
# with this software. 
# If not, see <http://creativecommons.org/publicdomain/zero/1.0/>. 

# base-files version 4.2-4

# ~/.bash_profile: executed by bash(1) for login shells.

# The latest version as installed by the Cygwin Setup program can
# always be found at /etc/defaults/etc/skel/.bash_profile

# Modifying /etc/skel/.bash_profile directly will prevent
# setup from updating it.

# The copy in your home directory (~/.bash_profile) is yours, please
# feel free to customise it to create a shell
# environment to your liking.  If you feel a change
# would be benifitial to all, please feel free to send
# a patch to the cygwin mailing list.

# User dependent .bash_profile file

#reset path to original value:
PATH="$(getconf PATH):./:${ORIGINAL_PATH}"

# source the users bashrc if it exists
if [ -f "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi

# Set PATH so it includes user's private bin if it exists
if [ -d "${USERPROFILE}/Documents/bin" ] ; then
  echo "added ${USERPROFILE}/Documents/bin to path!"
  PATH="${USERPROFILE}/Documents/bin:${PATH}"
fi

# Set MANPATH so it includes users' private man if it exists
# if [ -d "${HOME}/man" ]; then
#   MANPATH="${HOME}/man:${MANPATH}"
# fi

# Set INFOPATH so it includes users' private info if it exists
# if [ -d "${HOME}/info" ]; then
#   INFOPATH="${HOME}/info:${INFOPATH}"
# fi

# set current working directory conditionally
if [[ -z "${project_root}" ]]; then
	cd /cygdrive/c
else
	cd ${project_root}
fi
#cd /cygdrive/c
alias hlog='git log --date-order --all --graph --format="%C(green)%h %C(yellow)%an %C(blue bold)%ar %Creset%s     %C(red bold)%d"'
alias gitstatus='git fetch; hlog -20; git status'
alias desk='cd /cygdrive/c/Users/ssjme/Desktop'
alias difflast='git diff @{1}..'
alias kpull='git stash; git pull; git stash pop'
alias peek='git fetch; hlog -10'
# ssh-agent initialization ####################################################
# source: https://askubuntu.com/a/634573
SSH_ENV=$HOME/.ssh/environment
function start_ssh_agent {
    echo "Initializing new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add
}
# only start the ssh-agent if it is not currently running #
if [ -f "${SSH_ENV}" ]; then
     . "${SSH_ENV}" > /dev/null
     ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_ssh_agent;
    }
else
    start_ssh_agent;
fi
# END ssh-agent initialization ################################################
ssh-add ~/.ssh/n9
