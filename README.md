
## Prerequests

```
sudo apt install automake build-essential gcc-riscv64-unknown-elf bsdmainutils python3 python-is-python3 verilator
```

## How to build

```
git clone https://github.com/wakuto/proto-v.git
cd proto-v
git submodule update --init --recursive
make
```

## How to run tests

```
make run-regression
make run-functional
```
