# Environment variables
set -gx EDITOR nvim
set -gx CLICOLOR 1
set -gx LESS_TERMCAP_mb '\E[01;31m'
set -gx LESS_TERMCAP_md '\E[01;31m'
set -gx LESS_TERMCAP_me '\E[0m'
set -gx LESS_TERMCAP_se '\E[0m'
set -gx LESS_TERMCAP_so '\E[01;44;33m'
set -gx LESS_TERMCAP_ue '\E[0m'
set -gx LESS_TERMCAP_us '\E[01;32m'

set -gx PATH ~/.local/bin ~/.npm-global/bin $PATH

# Sudo Neovim with user config
alias sudovim="sudo -E nvim"
alias svim="sudo -E nvim"

git config --global user.name "Gabriel Boni Vicari"
git config --global user.email "gabriel@mantis-ai.com"

if status is-interactive
    set -l ssh_agent_env ~/.ssh/ssh-agent-env

    if test -f $ssh_agent_env
        source $ssh_agent_env >/dev/null
    end

    if not ssh-add -l >/dev/null 2>&1
        if test -n "$SSH_AGENT_PID"
            kill $SSH_AGENT_PID >/dev/null 2>&1
        end

        eval (ssh-agent -c) >/dev/null
        echo "set -gx SSH_AUTH_SOCK $SSH_AUTH_SOCK;" >$ssh_agent_env
        echo "set -gx SSH_AGENT_PID $SSH_AGENT_PID;" >>$ssh_agent_env

        ssh-add ~/.ssh/mantis_ai >/dev/null 2>&1
    end

    set -gx SSH_AUTH_SOCK $SSH_AUTH_SOCK
    set -gx SSH_AGENT_PID $SSH_AGENT_PID
end

set -gx FZF_DEFAULT_OPTS '--pointer=" " --header="" --prompt="" --height="40%" --border="horizontal" --info="inline-right" --border-label="Search" --preview="[[ ! -f {} || ! {} =~ \.(png|jpg|jpeg|gif|bmp|webp|tiff)\$ ]] && cat {}" --bind "focus:transform-header:file --brief {}"'

function set_starship_config
    if test (tput cols) -ge 120
        set -gx STARSHIP_CONFIG $HOME/.config/starship.toml
    else
        set -gx STARSHIP_CONFIG $HOME/.config/starship-minimal.toml
    end
end

if status is-interactive
    set fish_greeting

    set_starship_config

    function __starship_on_resize --on-signal WINCH
        set_starship_config
        commandline -f repaint
    end

    set fish_color_valid_path normal
    set fish_color_autosuggestion brblack
    set fish_color_command normal
    set fish_color_param normal
    set fish_color_redirection normal
    set fish_color_quote normal
    set fish_color_error normal
    set fish_color_operator normal
    set fish_color_escape normal
    set fish_color_end normal
    set fish_color_comment normal
    set fish_color_match normal
    set fish_color_selection normal
    set fish_color_search_match normal
    set fish_color_history_current normal

    set fish_pager_color_completion normal
    set fish_pager_color_description normal
    set fish_pager_color_prefix normal
    set fish_pager_color_progress normal

    if command -q fzf
        fzf --fish | source
    end

    starship init fish | source
end

function fastfetch_centered -d "Run fastfetch centered on screen"
    set terminal_width (tput cols)
    set fastfetch_width 116
    set left_padding (math "($terminal_width - $fastfetch_width) / 2")

    if test $left_padding -gt 0
        /usr/bin/fastfetch --logo-padding-left $left_padding
    else
        /usr/bin/fastfetch
    end
end

alias fastfetch fastfetch_centered
alias da 'date "+%Y-%m-%d %A %T %Z"'
alias vim nvim
alias vi nvim
alias nv 'nvim .'
alias cp 'cp -i'
alias mv 'mv -i'
alias mkdir 'mkdir -p'
alias ps 'ps auxf'
alias ping 'ping -c 10'
alias less 'less -R'
alias cls clear
alias cdh 'cd ~'
alias cdm ' cd ~/MantisAI'
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'
alias quit exit
alias shutdown 'shutdown now'

if command -q eza
    alias ls 'eza --icons'
    alias lad 'eza -Alh --icons'
    alias lsd 'eza --classify=always -h --icons'
    alias lld 'eza -a --classify=always -h --icons'
else if command -q lsd
    alias lad 'lsd -Alh'
    alias lsd 'lsd -Fh'
    alias lld 'lsd -aFh'
end

if command -q bat
    alias cat bat
end

if command -q thefuck
    alias fuck thefuck
end

if command -q eza
    alias tree 'eza --tree --icons --git-ignore'
else if command -q tree
    alias tree 'tree -CAhF --dirsfirst'
end

alias clear "printf '\033[2J\033[3J\033[1;1H'"
alias q 'qs -c ii'
alias ld lazydocker

alias logs "sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:\$//g' | grep -v '[0-9]\$' | xargs tail -f"

if command -q fzf
    alias fzf "fzf --pointer=' ' --height='40%' --preview='[[ ! -f {} || ! {} =~ \.(png|jpg|jpeg|gif|bmp|webp|tiff)\$ ]] && cat {}' --bind 'focus:transform-header:file --brief {}'"
end

function ftext -d "Search for text in all files in current folder"
    if command -q less
        grep -iIHrn --color=always $argv[1] . | less -r
    else
        grep -iIHrn --color=always $argv[1] .
    end
end

function cpp -d "Copy file with progress bar"
    if command -q pv
        pv $argv[1] >$argv[2]
    else
        echo "pv not available, using regular cp"
        cp $argv[1] $argv[2]
    end
end

function cpg -d "Copy and go to directory"
    if test -d $argv[2]
        cp $argv[1] $argv[2]; and cd $argv[2]
    else
        cp $argv[1] $argv[2]
    end
end

function mvg -d "Move and go to directory"
    if test -d $argv[2]
        mv $argv[1] $argv[2]; and cd $argv[2]
    else
        mv $argv[1] $argv[2]
    end
end

function mkdirg -d "Create and go to directory"
    mkdir -p $argv[1]
    cd $argv[1]
end

function up -d "Go up specified number of directories"
    set d ""
    set limit $argv[1]
    for i in (seq 1 $limit)
        set d $d/..
    end
    set d (echo $d | sed 's/^\///')
    if test -z "$d"
        set d ..
    end
    cd $d
end

function cd -d "Change directory and list contents"
    if test (count $argv) -gt 0
        builtin cd $argv
        and if command -q eza
            eza --icons
        else if command -q lsd
            lsd -Fh
        else
            ls -la
        end
    else
        builtin cd ~
        and if command -q eza
            eza --icons
        else if command -q lsd
            lsd -Fh
        else
            ls -la
        end
    end
end

function !! -d "Repeat last command"
    set -l last_cmd (history | head -1)
    if test -n "$last_cmd"
        echo $last_cmd
        eval $last_cmd
    else
        echo "No command in history"
    end
end

function pwdtail -d "Return last 2 fields of working directory"
    pwd | awk -F/ '{nlast = NF -1;print $nlast"/"$NF}'
end

function distribution -d "Show current distribution"
    set dtype unknown

    if test -r /etc/os-release
        set ID (grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
        set ID_LIKE (grep '^ID_LIKE=' /etc/os-release | cut -d= -f2 | tr -d '"')

        switch $ID
            case fedora rhel centos
                set dtype redhat
            case sles 'opensuse*'
                set dtype suse
            case ubuntu debian
                set dtype debian
            case gentoo
                set dtype gentoo
            case arch manjaro
                set dtype arch
            case slackware
                set dtype slackware
            case '*'
                if test -n "$ID_LIKE"
                    if string match -q '*fedora*' "$ID_LIKE"; or string match -q '*rhel*' "$ID_LIKE"; or string match -q '*centos*' "$ID_LIKE"
                        set dtype redhat
                    else if string match -q '*sles*' "$ID_LIKE"; or string match -q '*opensuse*' "$ID_LIKE"
                        set dtype suse
                    else if string match -q '*ubuntu*' "$ID_LIKE"; or string match -q '*debian*' "$ID_LIKE"
                        set dtype debian
                    else if string match -q '*gentoo*' "$ID_LIKE"
                        set dtype gentoo
                    else if string match -q '*arch*' "$ID_LIKE"
                        set dtype arch
                    else if string match -q '*slackware*' "$ID_LIKE"
                        set dtype slackware
                    end
                end
        end
    end

    echo $dtype
end

function ver -d "Show current OS version"
    set dtype (distribution)

    switch $dtype
        case redhat
            if test -s /etc/redhat-release
                cat /etc/redhat-release
            else
                cat /etc/issue
            end
            uname -a
        case suse
            cat /etc/SuSE-release
        case debian
            lsb_release -a
        case gentoo
            cat /etc/gentoo-release
        case arch
            cat /etc/os-release
        case slackware
            cat /etc/slackware-version
        case '*'
            if test -s /etc/issue
                cat /etc/issue
            else
                echo "Error: Unknown distribution"
                return 1
            end
    end
end

function whatsmyip -d "Show internal and external IP addresses"
    echo -n "Internal IP: "
    set internal_ip ""

    if command -q ip
        set default_interface (ip route | grep '^default' | awk '{print $5}' | head -1)
        if test -n "$default_interface"
            set internal_ip (ip addr show "$default_interface" | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | cut -d/ -f1 | head -1)
        end

        if test -z "$internal_ip"
            for interface in wlan0 eth0 en0 wlp0s20f3
                set internal_ip (ip addr show "$interface" 2>/dev/null | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | cut -d/ -f1 | head -1)
                test -n "$internal_ip"; and break
            end
        end
    else
        for interface in wlan0 eth0 en0
            set internal_ip (ifconfig "$interface" 2>/dev/null | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | head -1)
            test -n "$internal_ip"; and break
        end
    end

    if test -z "$internal_ip"
        set internal_ip (hostname -I 2>/dev/null | awk '{print $1}')
    end

    if test -z "$internal_ip"
        echo "Unable to determine"
    else
        echo $internal_ip
    end

    echo -n "External IP: "
    set external_ip ""

    for service in "ipv4.icanhazip.com" "ipv4.ip.sb" "v4.ident.me" "checkip.amazonaws.com"
        set external_ip (curl -4 -s --connect-timeout 5 --max-time 10 "$service" 2>/dev/null | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$')
        test -n "$external_ip"; and break
    end

    if test -z "$external_ip"
        for service in "ifconfig.me" "icanhazip.com" "ip.sb" "ident.me"
            set external_ip (curl -s --connect-timeout 5 --max-time 10 "$service" 2>/dev/null | head -1)
            test -n "$external_ip"; and break
        end
    end

    if test -z "$external_ip"
        echo "Unable to determine"
    else
        echo $external_ip
    end
end

alias whatismyip whatsmyip

if test -f ~/.config/fish/local.fish
    source ~/.config/fish/local.fish
end

if test -d ~/.nvm
    function nvm
        bass source ~/.nvm/nvm.sh --no-use ';' nvm $argv
    end
end

set -gx GOOGLE_APPLICATION_CREDENTIALS $HOME/.config/gcloud/voltaic-reducer-367300-b4a43c2a898f.json
set -gx GOOGLE_CLOUD_PROJECT voltaic-reducer-367300
set -gx GOOGLE_CLOUD_LOCATION global
