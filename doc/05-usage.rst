###################################
基本的な使い方
###################################

************************
現状のバージョンを確認
************************

現状のバージョンを確認するには cmakeenv version コマンドを実行する。
  
  ::

   $ cmakeenv version
   system

************************
グローバルバージョン変更
************************

個人で利用するCMakeのバージョンを変更する。
  
  ::

   $ cmakeenv global 3.25.0

   $ cmakeenv versions
     system
   * 3.25.0

   $ cmake --version
   cmake version 3.25.0

   CMake suite maintained and supported by Kitware (kitware.com/cmake).
