@echo off
cd installer
call build-installer-windows.bat
cd ..
dart run ./package.dart windows