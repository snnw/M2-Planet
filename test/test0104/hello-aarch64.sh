#! /bin/sh
## Copyright (C) 2017 Jeremiah Orians
## Copyright (C) 2020 deesix <deesix@tuta.io>
## This file is part of M2-Planet.
##
## M2-Planet is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## M2-Planet is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with M2-Planet.  If not, see <http://www.gnu.org/licenses/>.

set -x
# Build the test
./bin/M2-Planet --architecture aarch64 \
	-f test/common_aarch64/functions/exit.c \
	-f test/common_aarch64/functions/file.c \
	-f functions/file_print.c \
	-f test/common_aarch64/functions/malloc.c \
	-f functions/calloc.c \
	-f functions/match.c \
	-f functions/in_set.c \
	-f functions/numerate_number.c \
	-f test/common_aarch64/functions/fork.c \
	-f test/common_aarch64/functions/execve.c \
	-f test/test0104/kaem.c \
	--debug \
	--bootstrap-mode \
	-o test/test0104/kaem.M1 || exit 1

# Build debug footer
blood-elf --64 -f test/test0104/kaem.M1 \
	--entry _start \
	-o test/test0104/kaem-footer.M1 || exit 2

# Macro assemble with libc written in M1-Macro
M1 -f test/common_aarch64/aarch64_defs.M1 \
	-f test/common_aarch64/libc-core.M1 \
	-f test/test0104/kaem.M1 \
	-f test/test0104/kaem-footer.M1 \
	--LittleEndian \
	--architecture aarch64 \
	-o test/test0104/kaem.hex2 || exit 3

# Resolve all linkages
hex2 -f test/common_aarch64/ELF-aarch64-debug.hex2 \
	-f test/test0104/kaem.hex2 \
	--LittleEndian \
	--architecture aarch64 \
	--BaseAddress 0x400000 \
	-o test/results/test0104-aarch64-binary \
	--exec_enable || exit 4

if [ "$(get_machine ${GET_MACHINE_FLAGS})" = "aarch64" ]
then
	# Verify that the compiled program returns the correct result
	out=$(./test/results/test0104-aarch64-binary --version 2>&1 )
	[ 0 = $? ] || exit 5
	[ "$out" = "kaem version 0.6.0" ] || exit 6

	# Verify that the resulting file works
	out=$(./test/results/test0104-aarch64-binary --file test/test0104/kaem.run)
	[ "$out" = "hello world" ] || exit 7
fi
exit 0
