# Use a smaller base image
FROM ubuntu:20.04

RUN apt update && \
    apt install -y --no-install-recommends \
    apt-utils \
    bison \
    ca-certificates \
    ccache \
    check \
    curl \
    flex \
    git \
    git-lfs \
    gperf \
    lcov \
    libbsd-dev \
    libffi-dev \
    libncurses-dev \
    libusb-1.0-0-dev \
    make \
    ninja-build \
    openssh-client \
    python3 \
    python3-pip \
    python3-venv \
    ruby \
    unzip \
    wget \
    xz-utils \
    zip && \
    apt autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Set Python3 as the default Python
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10

# Install Git LFS
RUN git lfs install

# Configure SSH for GitHub and set permissions
RUN mkdir -p /root/.ssh && \
    ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts

# Configure Git settings for large transfers
RUN git config --global http.postBuffer 524288000 && \
    git config --global http.lowSpeedLimit 0 && \
    git config --global http.lowSpeedTime 99999

# Define arguments at the top for easier customization
ARG DEBIAN_FRONTEND=noninteractive
ARG IDF_CLONE_URL=git@github.com:espressif/esp-idf.git
ARG IDF_CLONE_BRANCH_OR_TAG=v5.2.2
ARG IDF_CHECKOUT_REF=v5.2.2
ARG IDF_INSTALL_TARGETS=all

# Define environment variables
ENV IDF_PATH=/opt/esp/idf
ENV IDF_TOOLS_PATH=/opt/esp
ENV MPY_PATH=/micropython
ENV IDF_PYTHON_CHECK_CONSTRAINTS=no
ENV IDF_CCACHE_ENABLE=1

# Use SSH for cloning the repository with build secrets
# The --mount=type=ssh allows SSH forwarding in Docker build
RUN --mount=type=ssh \
    git clone --depth=1 -b $IDF_CLONE_BRANCH_OR_TAG $IDF_CLONE_URL $IDF_PATH && \
    cd $IDF_PATH && \
    if [ -n "$IDF_CHECKOUT_REF" ]; then \
      git fetch origin $IDF_CHECKOUT_REF && \
      git checkout $IDF_CHECKOUT_REF; \
    fi && \
    git submodule update --init --depth=1 --recursive

# Install all the required tools for the specified chip targets
RUN update-ca-certificates --fresh
RUN $IDF_PATH/tools/idf_tools.py --non-interactive install required --targets=${IDF_INSTALL_TARGETS}
RUN $IDF_PATH/tools/idf_tools.py --non-interactive install cmake

# Install Python environment
RUN $IDF_PATH/tools/idf_tools.py --non-interactive install-python-env && \
    rm -rf $IDF_TOOLS_PATH/dist

# Clone MicroPython and additional modules
ARG MPY_CLONE_URL=https://github.com/micropython/micropython.git
ARG MPY_CLONE_BRANCH_OR_TAG=v1.25.0-preview

RUN git clone $MPY_CLONE_URL && \
    cd $MPY_PATH && git checkout $MPY_CLONE_BRANCH_OR_TAG && git pull origin $MPY_CLONE_BRANCH_OR_TAG

ARG MODULES_CLONE_URL=https://github.com/spasea/esp32-modules.git
ARG MODULES_CLONE_BRANCH_OR_TAG=master

RUN chmod 700 -R $IDF_PATH
RUN . $IDF_PATH/export.sh && \
    cd $MPY_PATH/ports/esp32 && \
    rm -rf modules && \
    git clone $MODULES_CLONE_URL modules && \
    cd modules && \
    git checkout $MODULES_CLONE_BRANCH_OR_TAG && \
    git pull origin $MODULES_CLONE_BRANCH_OR_TAG && \
    cd $MPY_PATH && make -C mpy-cross && \
    cd $MPY_PATH/ports/esp32 && make BOARD=ESP32_GENERIC submodules

# Set permissions for shared folders
RUN chmod 777 /opt $MPY_PATH

CMD [ "/bin/bash" ]
