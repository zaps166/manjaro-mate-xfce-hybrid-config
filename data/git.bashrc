
getGitBranch()
{
    checksum=$(git rev-parse --short HEAD 2> /dev/null)
    branch=$(git symbolic-ref --short HEAD 2> /dev/null)
    if [[ -z $branch ]] && [[ ! -z $checksum ]]; then
        taghash=$(git rev-list --tags --max-count=1 2> /dev/null)
        if [[ ! -z $taghash ]] && [[ $taghash = $checksum* ]]; then
            branch=$(git describe --tags)
        fi
    fi
    if [[ ! -z $branch ]] && [[ ! -z $checksum ]]; then
        echo -e " ($branch $checksum)"
    elif [[ ! -z $checksum ]]; then
        echo -e " ($checksum)"
    elif [[ ! -z $branch ]]; then
        echo -e " ($branch)"
    fi
}

if [[ ${EUID} == 0 ]] ; then
    PS1='\[\033[01;31m\][$? \u@\h\[\033[01;36m\] \w\[\033[01;31m\]]\[\033[01;35m\]$(getGitBranch)\[\033[01;31m\]\$\[\033[00m\] '
else
    PS1='\[\033[01;32m\][$? \u@\h\[\033[01;37m\] \w\[\033[01;32m\]]\[\033[01;35m\]$(getGitBranch)\[\033[01;32m\]\$\[\033[00m\] '
fi
