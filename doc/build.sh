#!/usr/bin/env sh

#set -e
top_dir="$(cd "$(dirname "$0")" > /dev/null 2>&1 && pwd)"
cd $top_dir

filename="cmakeenv"
title="cmakeenv"
author=`git config --get user.name`

output_dir="output"

ret=0

tools="sphinx-quickstart latexmk uplatex"

for tool in $tools ; do
  echo "check tool, $tool"
  num=`which $tool | wc -l`
  if [ "$num" -eq 0 ]; then
    echo "ERROR : no such tool, $tool"
    ret=$(expr $ret + 1)
  fi
done

if [ "$ret" -ne 0 ]; then
  exit $ret
fi

prepare()
{
  # for uplatex, latexmk, cmap.sty
  sudo apt install \
    texlive-lang-japanese \
    latexmk \
    texlive-latex-extra
}

init()
{
  sphinx-quickstart \
    -p "$title" \
    -a "$author" \
    -v 0.1 \
    -r 1 \
    -l "ja" \
    -q \
    $output_dir
}

add_number()
{
  cat << 'EOS' > tmp.txt
   :numbered:
EOS
  # maxdepthの下に :numbered: を追加
  sed -i -e "/:maxdepth: 2/r tmp.txt" $output_dir/index.rst

  # "Indices and tables" を "索引と表" に置換
  sed -i -e "s/Indices and tables/索引と表/" $output_dir/index.rst

  # 目次で表示する深さを6に変更
  sed -i -e "s/:maxdepth: 2/:maxdepth: 6/" $output_dir/index.rst

  rm -f tmp.txt
}

add_extensions()
{
  echo "add docxsphinx plugin"
  conf_py="$output_dir/conf.py"
  sed -i -e "s/extensions = \[\]/extensions = ['docxsphinx']/" $conf_py

  mkdir -p ${output_dir}/source/ 
  cp -f template.docx ${output_dir}/source/

  echo "apply template.docx"
  cat - << 'EOS' > tmp.py
docx_template = 'template.docx'
EOS

  # ファイルの末尾に tmp.py を追加
  sed -i -e '$r tmp.py' $conf_py
  rm -f tmp.py
}

change_theme()
{
  sed -i -e "s/html_theme = 'alabaster'/html_theme = 'sphinxdoc'/" $output_dir/conf.py
}

change_docclass()
{
  cat << EOS > tmp.py

latex_documents = [
  (
    'index',
    '${filename}.tex',
    '${title}',
    '${author}',
    'manual',
  )
]

latex_elements = {
  'papersize' : 'a4paper',
  'classoptions' : ',uplatex,dvipdfmx',
  'extraclassoptions' : 'openany,report,oneside',
  'preamble' : r'\usepackage{mypackage}',
  'fontpkg'  : r'\usepackage{courier}',
}

latex_docclass = {
  'howto'  : 'jsbook',
  'manual' : 'jsbook',
}

numfig = True

numfig_format = {
  'section' : '%s',
}

EOS

  # ファイルの末尾に tmp.py を追加
  sed -i -e '$r tmp.py' $output_dir/conf.py
  rm -f tmp.py
}

add_figures()
{
  mkdir -p $output_dir/figures
  mkdir -p $output_dir/images
  #cp -f /usr/share/gitweb/static/git-logo.png $output_dir/figures/
  
  #if [ ! -e "python.png" ]; then
  #  wget https://sphinx-users.jp/_images/python.png
  #fi
  #if [ -e "python.png" ]; then
  #  cp -f python.png $output_dir/images/
  #fi

}

add_pages()
{
  mkdir -p $output_dir/pages/
  find ./ -maxdepth 1 -type f -name "*.rst" -exec cp -f {} $output_dir/pages/ \;

  echo '   ' > tmp.txt
  find ./ -maxdepth 1 -type f -name "*.rst" | sort | sed 's|^.|   /pages|' >> tmp.txt
  sed -i -e '/:caption: Contents:/r tmp.txt' $output_dir/index.rst
  rm -f tmp.txt
}

add_pdfs()
{
  mkdir -p $output_dir/pdfs
  #cp -f source/hello.pdf ${output_dir}/pdfs/
}

html()
{
  cd $output_dir
  make html
  cd ${top_dir}
}

pdf()
{
  mkdir -p ${output_dir}/_build/latex
  #cp -f ${top_dir}/myjsbook.cls ${project}/_build/latex

  cp -f mypackage.sty ${output_dir}/_build/latex/
  cd $output_dir
  make latexpdf
  cd ${top_dir}
  cp -f ${output_dir}/_build/latex/${filename}.pdf .
}

docx()
{
  cd $output_dir
  make docx
  cd ${top_dir}
  cp -f ${output_dir}/_build/docx/cmakeenv-0.1.docx .
}

pdf2()
{
  dvipdfmx -S -P 0x0000 -o ${filename}-enc.pdf \
    ./output/_build/latex/${filename}.dvi
}

clean()
{
  cd $output_dir
  make clean
  cd ${top_dir}
}

mclean()
{
  rm -rf $output_dir
}

all()
{
  mclean
  init
  add_extensions
  change_theme
  change_docclass
  add_number
  add_pages
  add_pdfs
  add_figures
  html
  pdf
}

args=""
while [ $# -ne 0 ]; do
  case $1 in
    -h )
      usage
      exit 1
      ;;
    -v )
      verbose=1
      ;;
    * )
      args="$args $1"
      ;;
  esac

  shift
done

if [ -z "$args" ]; then
  all
fi

for arg in $args; do
  num=`LANG=C type $arg | grep 'function' | wc -l`

  if [ $num -ne 0 ]; then
    $arg
  else
    echo "ERROR : $arg is not shell function"
    exit 1
  fi
done
