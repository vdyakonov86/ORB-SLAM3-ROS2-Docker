dir=$PWD

echo $dir/Datasets/EuRoC
# mkdir -p $dir/Datasets/EuRoC
# wget -O $dir/Datasets/EuRoC/MH_01_easy.zip http://robotics.ethz.ch/~asl-datasets/ijrr_euroc_mav_dataset/machine_hall/MH_01_easy/MH_01_easy.zip
unzip $dir/Datasets/EuRoC/MH_01_easy.zip -d $dir/Datasets/EuRoC/MH01

# https://cvg.cit.tum.de/rgbd/dataset/freiburg1/rgbd_dataset_freiburg1_xyz.tgz