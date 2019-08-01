# Nvidia-GPUの場合
FROM nvidia/cudagl:10.0-devel-ubuntu16.04

# cuDNNのインストール
COPY ./cuDNN/libcudnn7_7.4.1.5-1+cuda10.0_amd64.deb /root/cuDNN/
COPY ./cuDNN/libcudnn7-dev_7.4.1.5-1+cuda10.0_amd64.deb /root/cuDNN/
COPY ./cuDNN/libcudnn7-doc_7.4.1.5-1+cuda10.0_amd64.deb /root/cuDNN/
RUN dpkg -i /root/cuDNN/libcudnn7_7.4.1.5-1+cuda10.0_amd64.deb
RUN dpkg -i /root/cuDNN/libcudnn7-dev_7.4.1.5-1+cuda10.0_amd64.deb
RUN dpkg -i /root/cuDNN/libcudnn7-doc_7.4.1.5-1+cuda10.0_amd64.deb

# aptのミラーを日本に変更し更新
RUN sed -i.bak -e 's;http://archive.ubuntu.com;http://jp.archive.ubuntu.com;g' /etc/apt/sources.list
RUN apt-get update \
 && apt-get -y upgrade

# 汎用パッケージインストール
RUN apt-get install -y --no-install-recommends software-properties-common \
 && add-apt-repository -y ppa:jonathonf/vim \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
              git vim sudo wget openssh-server \
              xterm mesa-utils x11-apps

# python関係のパッケージインストール
RUN apt-get install -y --no-install-recommends \
            python3.5-dev python3-tk \
 && wget https://bootstrap.pypa.io/get-pip.py \
 && python3 get-pip.py \
 && pip3 install --upgrade pip

# pythonの標準的な数値計算パッケージのインストール
COPY into_container/requirements_basic.txt /ingredients/
RUN pip3 install -r /ingredients/requirements_basic.txt

# ディープラーニングライブラリのインストール
COPY into_container/requirements_dnn.txt /ingredients/
RUN pip3 install -r /ingredients/requirements_dnn.txt

# open ai gymのインストール
RUN apt-get install -y --no-install-recommends \
        unzip libglu1-mesa-dev libgl1-mesa-dev libosmesa6-dev xvfb patchelf ffmpeg
COPY into_container/requirements_gym.txt /ingredients/
RUN pip3 install -r /ingredients/requirements_gym.txt \
 && pip3 uninstall -y pyglet \
 && pip3 install pyglet==1.3.2

# 強化学習関係のインストール
RUN apt-get install -y --no-install-recommends \
        cmake libopenmpi-dev zlib1g-dev \
        python3-opengl libjpeg-dev \
        swig libboost-all-dev libsdl2-dev

COPY into_container/requirements_rl.txt /ingredients/
RUN pip3 install -r /ingredients/requirements_rl.txt

# その他パッケージのインストール
COPY into_container/requirements_other.txt /ingredients/
RUN pip3 install -r /ingredients/requirements_other.txt

# aptの掃除
RUN apt-get clean \
 && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# sshの設定
# sshサービスの起動とリモートでGPUを使うための設定
RUN ( echo "#!/bin/bash"; \
      echo ""; \
      echo "service ssh start"; \
      echo "tail -f /dev/null"; ) > /root/entrypoint.sh && \
      chmod +x /root/entrypoint.sh && \
      sed -i.bak 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
      echo "PermitUserEnvironment yes" >> /etc/ssh/sshd_config && \
      ( echo ""; \
        echo "export PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:/opt/conda/bin:$PATH"; \
        echo "export LIBRARY_PATH=/usr/local/cuda/lib64/stubs:"; \
        echo "export LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64"; \
      ) >> /root/.bashrc && \
      mkdir /root/.ssh && chmod 700 /root/.ssh && \
      ( echo "PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:/opt/conda/bin:$PATH"; \
        echo "LIBRARY_PATH=/usr/local/cuda/lib64/stubs:"; \
         echo "LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64"; \
      ) >> /root/.ssh/environment

# ssh用パスワードの設定
RUN echo 'root:P@ssw0rd' | chpasswd

# ユーザーの切り替え
RUN groupadd -g 1000 developer && \
    useradd  -u 1000 -g 1000 --groups sudo --create-home --shell /bin/bash developer && \
    echo 'developer:P@ssw0rd' | chpasswd
RUN mkdir -p /home/developer/workspace
RUN mkdir -p /workspace
RUN cp /root/.bashrc /home/developer/
USER developer

# ワーキングスペースの作成
WORKDIR /home/developer/workspace

EXPOSE 22
CMD ["/root/entrypoint.sh"]

