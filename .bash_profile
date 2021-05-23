# source the users bashrc if it exists
if [ -f "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi
# Set PATH so it includes user's private bin if it exists
if [ -d "${USERPROFILE}/Documents/bin" ] ; then
  PATH="${USERPROFILE}/Documents/bin:${PATH}"
  echo "added ${USERPROFILE}/Documents/bin to path!"
fi
# set current working directory conditionally
#if [[ -z "${project_root}" ]]; then
#	cd /cygdrive/c
#else
#	cd ${project_root}
#fi
#cd ~
# custom aliases
alias hlog='git log --date-order --all --graph --format="%C(green)%h %C(yellow)%an %C(blue bold)%ar %Creset%s     %C(red bold)%d"'
alias gitstatus='git fetch; hlog -20; git status'
#alias desk='cd /cygdrive/c/Users/ssjme/Desktop'
alias difflast='git diff @{1}..'
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
