#ddev-generated
export PATH=$HOME/.local/bin:$HOME/.local/share/pnpm:$PATH

# Per-project bash accu
export HISTFILE=$HOME/.local/.bash_history
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
shopt -s cmdhist
shopt -s histappend

# Save timestamps (Format: YYYY-MM-DD HH:MM:SS)
export HISTTIMEFORMAT="%F %T "

# Keep file size reasonable for performance
export HISTSIZE=2000
export HISTFILESIZE=5000
