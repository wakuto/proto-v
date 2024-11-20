all: test src rtl

test:
	make -C test

src:
	make -C src

rtl:
	make -C rtl

run-regression:
	./ci/regression.sh

run-functional:
	./ci/functional.sh

clean:
	make -C test clean
	make -C src clean
	make -C rtl clean
	rm -rf log

.PHONY: all test src rtl run-regression

