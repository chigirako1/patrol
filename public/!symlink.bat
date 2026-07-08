chcp 65001

rem 管理者権限で実行する

:: バッチファイルがある場所にカレントディレクトリを変更
cd /d %~dp0

pwsh -c "new-item -ItemType SymbolicLink -path 'pxv' -value 'D:\hoge\pxv'"


pause


rem mklink /D hoge "C:\abc\a"
