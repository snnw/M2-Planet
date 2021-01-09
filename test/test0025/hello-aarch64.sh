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

set -ex
# Build the test
bin/M2-Planet --architecture aarch64 \
	-f test/common_aarch64/functions/file.c \
	-f test/common_aarch64/functions/malloc.c \
	-f functions/calloc.c \
	-f test/common_aarch64/functions/exit.c \
	-f functions/match.c \
	-f functions/in_set.c \
	-f functions/numerate_number.c \
	-f functions/file_print.c \
	-f test/test0025/getopt.c \
	--debug \
	-o test/test0025/getopt.M1 || exit 1

# Build debug footer
blood-elf --64 -f test/test0025/getopt.M1 \
	--entry _start \
	-o test/test0025/getopt-footer.M1 || exit 2


# Macro assemble with libc written in M1-Macro
M1 -f test/common_aarch64/aarch64_defs.M1 \
	-f test/common_aarch64/libc-core.M1 \
	-f test/test0025/getopt.M1 \
	-f test/test0025/getopt-footer.M1 \
	--LittleEndian \
	--architecture aarch64 \
	-o test/test0025/getopt.hex2 || exit 2

# Resolve all linkages
hex2 -f test/common_aarch64/ELF-aarch64-debug.hex2 \
	-f test/test0025/getopt.hex2 \
	--LittleEndian \
	--architecture aarch64 \
	--BaseAddress 0x400000 \
	-o test/results/test0025-aarch64-binary \
	--exec_enable || exit 3

# Ensure binary works if host machine supports test
if [ "$(get_machine ${GET_MACHINE_FLAGS})" = "aarch64" ]
then
	. ./sha256.sh
	# Verify that the resulting file works
	./test/results/test0025-aarch64-binary > test/test0025/proof || exit 4
	out=$(sha256_check test/test0025/proof.answer)
	[ "$out" = "test/test0019/proof: OK" ] || exit 5
fi
exit 0
