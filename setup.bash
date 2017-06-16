#!/usr/bin/env bash
# ======================================================================
#  Launch server environment on new systems
# ======================================================================
# Notes
# ----------------------------------------------------------------------
# 
#   ncurses:
#
#     may need `export CPPFLAGS="-P"` before configure 
#     https://stackoverflow.com/questions/37475222/ncurses-6-0-compilation-error-error-expected-before-int
#   
#   tmux:
#     
#     https://github.com/tmux/tmux
#

home="$HOME/.local"
src="$home/src"
lib="$home/lib"
inc="$home/include"

local_prefix=$home

os=$(uname -s)

case $os in
  "Darwin")
    nprocs=$(sysctl -n hw.ncpu)
    ;;
  "Linux")
    nprocs=$(nproc)
    ;;
  : | * | ? )
    :
    ;;
esac

[[ ! -d $src ]] && mkdir -p $src || :
links=( 
  'https://sourceforge.net/projects/levent/files/libevent/libevent-2.0/libevent-2.0.22-stable.tar.gz'
  'ftp://invisible-island.net/ncurses/ncurses.tar.gz'
  'http://downloads.sourceforge.net/project/tmux/tmux/tmux-2.0/tmux-2.0.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Ftmux%2Ffiles%2Ftmux%2F&ts=1432604315&use_mirror=iweb'
  'http://selenic.com/hg/archive/tip.tar.gz'
  'ftp://ftp.mpi-sb.mpg.de/pub/tex/mirror/ftp.dante.de/pub/tex/biblio/bibtex/utils/bibsort.zip'
)
names=(
  'libevent'
  'ncurses'
  'tmux'
  'Mercurial'
  'bibsort'
)
optis=(
  ' '
  ' '
  "CFLAGS=-I${inc}/ncurses LDFLAGS=-L${lib}"
)

dcmi() { # download-configure-make-install
  link=$1
  name=$2
  opts=${@:3}
  curl -L $link | tar xz && cd "${name}*" && \
    ./configure --prefix=$myprefix $options && make -j $nprocs all && \
    make -j $nprocs install && cd $src || exit 15
}

for k in ${!links[@]}; do
  dcmi ${links[$k]} ${names[$k]} ${optis[$k]}
done

which -s conda && conda_flag=1 || conda_flag=0

if [[ $conda_flag -eq 1 ]]; then
  python_config_dir=$(
    conda info --all | grep 'conda location' | cut -d ' ' -f 3 
  )
fi
# vim
# hg pull && hg update
git pull
# Should checkout lastest stable branch
./configure --prefix=$local_prefix              \
  --enable-pythoninterp=yes --enable-gui        \
  --with-python-config-dir=$python_config_dir   \
  --enable-perlinterp  --enable-rubyinterp      \
  --enable-luainterp=yes --with-features=huge   \
  --enable-multibyte --with-compiledby=Jason
make -j $nprocs

## open mpi
# Determine CC, CXX, FC before configure...
./configure CC=gcc CXX=g++ FC=gfortran --prefix=$local_prefix
./configure CC=icc CXX=icpc FC=ifort --prefix=$local_prefix

