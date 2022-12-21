cd installer
./build-installer-linux.sh
cd ..
flutter build linux
dart run ./package.dart linux