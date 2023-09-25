sudo apt install gcc build-essential make -y
wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda_11.8.0_520.61.05_linux.run
sudo sh cuda_11.8.0_520.61.05_linux.run
sudo nvidia-persistenced
echo '# sudo nvidia-smi -ac 5001,1590 # for g4dn'
echo '# sudo nvidia-smi -ac 6250,1710 # for g5'
echo '# sudo nvidia-smi -ac 877,1530 # for p3'


#echo 'export CUDA_HOME=/usr/local/cuda-11.8/' >> ~/.zshrc
#echo 'export PATH=/usr/local/cuda-11.8/bin:$PATH' >> ~/.zshrc
#echo 'export CPATH=/usr/local/cuda-11.8/include:$CPATH' >> ~/.zshrc
#echo 'export LIBRARY_PATH=/usr/local/cuda-11.8/lib64:$LIBRARY_PATH' >> ~/.zshrc
#echo 'export LD_LIBRARY_PATH=/usr/local/cuda-11.8/lib64:/usr/local/cuda-11.8/extras/CUPTI/lib64:$LD_LIBRARY_PATH' >> ~/.zshrc
