@ECHO off
IF %1 == -k GOTO Keep1
    docker run --rm -v "%CD%:/project" -w "/project" "hub.tollwerk.net/tollwerk/a2pdfua" -o "%~n1.pdf" "%~nx1"
GOTO End1

:Keep1
    docker run --rm -v "%CD%:/project" -w "/project" "hub.tollwerk.net/tollwerk/a2pdfua" -o "%~n2.pdf" -k "%~nx2"
GOTO End1

:End1
