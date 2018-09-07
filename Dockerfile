ARG UBUNTU_VERSION=16.04
FROM ubuntu:${UBUNTU_VERSION}

#FROM ffmpeg_cpu:latest
LABEL maintainer="CVI cvigroup.cfi@gmail.com"

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
        libcurl3-dev \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python-dev \
        rsync \
        software-properties-common \
        unzip \
        zip \
        zlib1g-dev \
        openjdk-8-jdk \
        openjdk-8-jre-headless \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ARG USE_PYTHON_3_NOT_2=True
ARG _PY_SUFFIX=${USE_PYTHON_3_NOT_2:+3}
ARG PYTHON=python${_PY_SUFFIX}
ARG PIP=pip${_PY_SUFFIX}


ENV OPENCV_DIR "$LIB_DIR/opencv"
RUN mkdir -p "$OPENCV_DIR"

# Pick up some dependencies
RUN apt-get update && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# download opencv3
RUN cd "$OPENCV_DIR" && \
    wget https://github.com/opencv/opencv/archive/3.4.0.zip && \
    unzip 3.4.0.zip && \
    rm 3.4.0.zip
    # git clone https://github.com/opencv/opencv.git  <-- don't work anymore : GnuTLS recv error

# download opencv3 contrib
RUN cd "$OPENCV_DIR" && \
    wget https://github.com/opencv/opencv_contrib/archive/3.4.0.zip && \
    unzip 3.4.0.zip && \
    rm 3.4.0.zip
    # git clone https://github.com/opencv/opencv_contrib.git  <-- don't work anymore : GnuTLS recv error

# build opencv3
# warning if we set BUILD_EXAMPLES=OFF cmake don't find IPP anymore (strange)
RUN cd "$OPENCV_DIR/opencv-3.4.0" && mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_C_EXAMPLES=OFF \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D OPENCV_EXTRA_MODULES_PATH="$OPENCV_DIR/opencv_contrib-3.4.0/modules" \
    -D BUILD_EXAMPLES=OFF \
    -D WITH_IPP=ON .. && \
    make -j$(nproc) && \
    make install && \
    /bin/bash -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf' && \
    cd .. && rm -r build && \
    ldconfig

# link ippicv
RUN ln -s "$OPENCV_DIR/opencv-3.4.0/3rdparty/ippicv/unpack/ippicv_lnx/lib/intel64/libippicv.a" "/usr/local/lib/libippicv.a"


RUN apt-get update && apt-get install -y \
    ${PYTHON} \
    ${PYTHON}-pip

RUN ${PIP} install --upgrade \
    pip \
    setuptools

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    openjdk-8-jdk \
    ${PYTHON}-dev \
    swig

# Install bazel
RUN echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list && \
    curl https://bazel.build/bazel-release.pub.gpg | apt-key add - && \
    apt-get update && \
    apt-get install -y bazel

COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc

RUN ${PIP} install jupyter

RUN mkdir /pysangamam && chmod a+rwx /pysangamam 
RUN mkdir /.local && chmod a+rwx /.local
WORKDIR /pysangamam
EXPOSE 8888

WORKDIR /pysangamam
RUN git clone https://github.com/iitmcvg/pysangamam.git /pysangamam/workshop
RUN git clone https://github.com/iitmcvg/Fast-Image-Classification.git /pysangamam/keras-bottlenecks
RUN mkdir /.local && chmod a+rwx /.local
WORKDIR /pysangamam

#CMD ["bash", "-c", "source /etc/bash.bashrc && jupyter notebook --notebook-dir=/notebooks --ip 0.0.0.0 --no-browser --allow-root"]
CMD ["bash"]