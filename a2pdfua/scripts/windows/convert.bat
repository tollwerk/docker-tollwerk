@ECHO off
docker run --rm -v "%CD%:/project" -w "/project" "hub.tollwerk.net/tollwerk/a2pdfua" -o "%~n1.pdf" "%~nx1"
