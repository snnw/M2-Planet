#! /bin/sh
## Copyright (C) 2017 Jeremiah Orians
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
./bin/M2-Planet --architecture amd64 -f test/common_amd64/functions/exit.c \
	-f test/common_amd64/functions/file.c \
	-f functions/file_print.c \
	-f test/common_amd64/functions/malloc.c \
	-f functions/calloc.c \
	-f functions/match.c \
	-f functions/in_set.c \
	-f functions/numerate_number.c \
	-f functions/string.c \
	-f functions/require.c \
	-f test/test0102/M1-macro.c \
	--debug \
	--bootstrap-mode \
	-o test/test0102/M1-macro.M1 || exit 1

# Build debug footer
blood-elf --64 -f test/test0102/M1-macro.M1 \
	--entry _start \
	-o test/test0102/M1-macro-footer.M1 || exit 2

# Macro assemble with libc written in M1-Macro
M1 -f test/common_amd64/amd64_defs.M1 \
	-f test/common_amd64/libc-core.M1 \
	-f test/test0102/M1-macro.M1 \
	-f test/test0102/M1-macro-footer.M1 \
	--LittleEndian \
	--architecture amd64 \
	-o test/test0102/M1-macro.hex2 || exit 3

# Resolve all linkages
hex2 -f test/common_amd64/ELF-amd64-debug.hex2 \
	-f test/test0102/M1-macro.hex2 \
	--LittleEndian \
	--architecture amd64 \
	--BaseAddress 0x00600000 \
	-o test/results/test0102-amd64-binary \
	--exec_enable || exit 4

# Ensure binary works if host machine supports test
if [ "$(get_machine ${GET_MACHINE_FLAGS})" = "amd64" ]
then
	# Verify that the compiled program returns the correct result
	out=$(./test/results/test0102-amd64-binary --version 2>&1 )
	[ 0 = $? ] || exit 5
	[ "$out" = "M1 1.0.0" ] || exit 6

	# Verify that the resulting file works
	./test/results/test0102-amd64-binary -f \
		test/common_x86/x86_defs.M1 \
		-f test/common_x86/libc-core.M1 \
		-f test/test0100/test.M1 \
		--LittleEndian \
		--architecture x86 \
		-o test/test0102/proof || exit 7

	. ./sha256.sh
	out=$(sha256_check test/test0102/proof.answer)
	[ "$out" = "test/test0102/proof: OK" ] || exit 8
fi
exit 0
