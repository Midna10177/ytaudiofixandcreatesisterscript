@echo off
rem Upon running this script with paramter youtube-url or ytsearch:"my search here":
rem best audio is downloaded in a file
rem audio is converted to .wav
rem .wav is loaded into audacity
rem script waits for you to APPLY A MACRO THAT WILL EXPORT AS OGG
rem script moves new ogg from the macro-output folder into current and then deletes old original audio and .wav file
rem 
rem a sister script will be created, which will launch mpv playing the youtube url video with --audio-file=new-processed-audio
rem 
rem useful for applying effects to larger youtube video audio tracks without having to download the whole video just to play them together

echo ----------This script allows you to use a direct link or a ytsearch.----------
set format=244
call ytdl --get-id %* > idtemp
call ytdl -f bestaudio --get-filename %* > filenametemp
set /p filename=<filenametemp
set /p urlid=<idtemp
del idtemp
del filenametemp

call ytdl -f bestaudio %*

set filenamenoext=0
set fileext=0
for %%a in ("%filename%") do (
set filenamenoext=%%~na
set fileext=%%~xa
)
echo "%filenamenoext%" "%fileext%" "%urlid%"
ffmpeg -i "%filename%" "%filenamenoext%.wav"
del "%filename%"
start /min cmd /c ""C:\Program Files (x86)\DarkAudacity\darkaudacity.exe" "%cd%\%filenamenoext%.wav""


rem -----------------batch creation-----------------

echo call ytdl -f %format% -g %urlid% ^> temp.m3u > "%filenamenoext%.bat"
echo mpv temp.m3u --audio-file="%filenamenoext%.ogg" >> "%filenamenoext%.bat"
echo del temp.m3u >> "%filenamenoext%.bat"

:waitforOGGoutput
tasklist /fi "ImageName eq darkaudacity.exe" /fo csv 2>NUL | find /I "darkaudacity.exe">NUL
if "%ERRORLEVEL%"=="0" (
echo waiting for darkaudacity to exit
) else (
goto nextpart
)

timeout 5
goto waitforOGGoutput

:nextpart

del "%cd%\%filenamenoext%.wav"

move "macro-output\%filenamenoext%.ogg" .
rd macro-output
