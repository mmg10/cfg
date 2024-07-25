# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/home/ubuntu/.oh-my-zsh/

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"


# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  dirhistory
  common-aliases
  sudo
  colored-man-pages
  colorize
  cp
  zsh-syntax-highlighting
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration

export PATH=$PATH:/home/ubuntu/.local/bin

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi


# Misc Settings
export HF_HUB_ENABLE_HF_TRANSFER=1

# Set personal aliases, 
#

alias l="ls -sAh"
alias pip="mypip"
alias upd="sudo apt update; sudo apt upgrade"
alias ven="venf"
alias gitaa="gitaaf"
alias gitcc="gitccf"
alias yb='yt-dlp -f 22 -o '\''%(title)s.%(ext)s'\'
alias ypb='yt-dlp -f 22 -o '\''%(playlist_index)02d - %(title)s.%(ext)s'\'
alias ydb='yt-dlp -f 22 -o '\''%(upload_date)s - %(title)s.%(ext)s'\'

alias y='yt-dlp --write-description -f 22 -o '\''%(title)s.%(ext)s'\'
alias yd='yt-dlp --write-description -f 22 -o '\''%(upload_date)s - %(title)s.%(ext)s'\'
alias yp='yt-dlp --write-description -f 22 -o '\''%(playlist_index)02d - %(title)s.%(ext)s'\'

function mypip() {
    #do things with parameters like $1 such as
    python -m pip "$@"
}

function textsearch() {
    #do things with parameters like $1 such as
    find ./ -type f -exec grep -Hn "$1" {} \;
}


function venf() {
    #do things with parameters like $1 such as
    if [[ ! "$1" ]]
    then
    	ls ~/envs
    elif [[ "$1" = "-c" ]]
    then
    	python -m venv ~/envs/"$2"
    	source ~/envs/"$2"/bin/activate
    	pip install pip --upgrade
    elif [[ "$1" ]]
    then
    	source ~/envs/"$1"/bin/activate
    fi
}

function gitccf() {
    if [[ ! "$1" ]]
    then
    	echo "Please add a commit message!!!"
    elif [[ "$1" ]]
    then
        git checkout --orphan TEMP_BRANCH
        git add -A
        git commit -am "$1"
        git branch -D main
        git branch -m main
        git push -f origin main
    fi
}

function gitaaf() {
    if [[ ! "$1" ]]
    then
    	echo "Please add a commit message!!!"
    elif [[ "$1" ]]
    then
    	git add -A
        git commit -am "$1"
        git push -f origin main
    fi
}

function rname(){
    rename "s/${1}/${2}/g" *
}

function dld(){
    while IFS= read -r url; do
        url=$(echo "$url" | tr -d '[:space:]')  # Remove leading/trailing whitespaces
        if [ -n "$url" ]; then
            # Extract filename from the URL
            filename=$(basename "$url")
            echo "Downloading: $url to $filename"
            aria2c -c -x 16 -s 16 -k 1M -o "$filename" "$url"
        fi
    done < "$1"
}

function duration(){
    for file in *.(mp4|mkv)(N); do
        echo -n $(ffprobe $file 2>&1 | grep 'Duration' | cut -d',' -f1 | cut -d' ' -f4 | cut -d'.' -f1)
        echo " $(ls -sh $file)"
    done
}

function compress(){
    i=1
    for file in *.*; do
        echo "compressing $file"
        tar -cf out/$i.tar "$file"
        i=$((i+1))
    done
}

function vcomp(){
    for file in *.mp4; do
        ffmpeg -i "$f" -loglevel warning -hide_banner -stats -vcodec libx265 -acodec copy out/"${f%.mp4}_.mp4";
    done
}

eval "$(oh-my-posh --init --shell zsh --config ~/.oh-my-zsh/gmay_mine.omp.json)"
