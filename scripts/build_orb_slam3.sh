cd /ws/src/ORB_SLAM3
sudo sed -i 's/++11/++14/g' CMakeLists.txt # build fix
chmod +x build.sh
./build.sh