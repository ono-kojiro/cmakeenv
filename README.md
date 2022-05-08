# cmakeenv (like pyenv, plenv)

## SETUP
### git-clone cmakeenv to $HOME/.cmakeenv/bin/

     $ git clone https://github.com/ono-kojiro/cmakeenv.git $HOME/.cmakeenv

### source cmakeenv.bashrc

     $ source $HOME/.cmakeenv/cmakeenv.bashrc

## BUILD
###  run "cmakeenv install 3.23.1"

    $ cmakeenv install 3.23.1

## SELECT VERSION

### show avaiable versions

    $ cmakeenv versions
    * system
      3.23.1

### select specific version
    $ cmakeenv global 3.23.1
    
    $ cmakeenv versions
      system
    * 3.23.1
    
    $ cmake --version
    cmake version 3.23.1
    ....
    ....

