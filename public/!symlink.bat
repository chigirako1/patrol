chcp 65001

rem 管理者権限で実行する

:: バッチファイルがある場所にカレントディレクトリを変更
cd /d %~dp0

rem r18
pwsh -c "new-item -ItemType SymbolicLink -path 'pxv' -value 'D:\r18\dlPic\pxv'"
pwsh -c "new-item -ItemType SymbolicLink -path 'twt' -value 'D:\r18\dlPic\twitter'"
pwsh -c "new-item -ItemType SymbolicLink -path 'nje' -value 'D:\r18\dlPic\Nijie'"

rem pxv/twt/nje 最新
pwsh -c "new-item -ItemType SymbolicLink -path 'f_dl' -value 'D:\download'"
pwsh -c "new-item -ItemType SymbolicLink -path 'd_dl' -value 'D:\dl\AnkPixiv'"


pause


rem mklink /D hoge "C:\abc\a"
