from ubuntu:24.04 as builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update --fix-missing && apt-get -y upgrade

RUN apt-get install -y \
    make build-essential automake bsdmainutils \
    python3 python-is-python3 verilator autoconf autotools-dev \
    curl python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk bison flex \
    texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev \
    ninja-build git cmake libglib2.0-dev libslirp-dev

# clone riscv toolchain
RUN git clone https://github.com/riscv/riscv-gnu-toolchain

# build riscv toolchain
WORKDIR /riscv-gnu-toolchain
RUN ./configure --prefix=/opt/riscv --enable-multilib
RUN make newlib -j$(nproc)

from ubuntu:24.04 as runner

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update --fix-missing && apt-get -y upgrade
RUN apt-get install -y \
  build-essential automake bsdmainutils \
  python3 python-is-python3 verilator

COPY --from=builder /opt/riscv /opt/riscv

ENV PATH=$PATH:/opt/riscv/bin

# checks
RUN make --version
RUN riscv64-unknown-elf-gcc --version
RUN python3 --version
RUN verilator --version
