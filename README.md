
## Prerequests

- verilator (version 5.002 or higher)
- make
- python3
- riscv-gnu-toolchain

```
sudo pacman -S verilator make python 
yay -S riscv-gnu-toolchain-bin
```

## how to build

```
git clone https://github.com/wakuto/proto-v.git
cd proto-v
git submodule update --init --recursive
make
```

## how to run tests

```
make run-regression
make run-functional
```
