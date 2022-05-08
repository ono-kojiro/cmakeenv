export CMAKEENV_ROOT="$HOME/.cmakeenv"

echo ":$PATH:" | grep ":$CMAKEENV_ROOT/bin:" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  export PATH="$CMAKEENV_ROOT/bin:$PATH"
fi

eval "$(cmakeenv init --path)"

eval "$(cmakeenv init -)"

