#! /usr/bin/env bash
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

set -eux
stage0_PREFIX=${stage0_PREFIX-../stage0}

[ -e bin/M2-Planet ] && rm bin/M2-Planet

# Refresh stage0's M2-Planet_x86.c
# To execute this block ./bootstrap.sh refresh
if [ "refresh" = "${1-NOPE}" ]
then
# Create header to prevent confusion
{
cat <<-EOF
## This file was generated by running:
## cat functions/file.c functions/malloc.c functions/calloc.c functions/exit.c functions/match.c functions/numerate_number.c functions/file_print.c functions/string.c cc.h cc_reader.c cc_strings.c cc_types.c cc_core.c cc.c >| ../stage0/stage3/M2-Planet_x86.c
## inside M2-Planet's repo

EOF
} >| header

# Update the C code in stage0's x86 bootstrap
cat header \
	functions/file.c \
	functions/malloc.c \
	functions/calloc.c \
	functions/exit.c \
	functions/match.c \
	functions/numerate_number.c \
	functions/file_print.c \
	functions/string.c \
	cc.h \
	cc_reader.c \
	cc_strings.c \
	cc_types.c \
	cc_core.c \
	cc.c >| $stage0_PREFIX/stage3/M2-Planet_x86.c

# Clean up temp header
rm header

{
# Create header to prevent confusion
cat <<-EOF
# This file was generated by running:
# ./bin/vm --rom roms/cc_x86 --memory 4M --tape_01 stage3/M2-Planet_x86.c --tape_02 ../M2-Planet/seed.M1
# In stage0
EOF
} >| preseed1

# Create the seed
$stage0_PREFIX/bin/vm --rom $stage0_PREFIX/roms/cc_x86 \
                      --memory 4M \
                      --tape_01 $stage0_PREFIX/stage3/M2-Planet_x86.c \
                      --tape_02 preseed2

# Combine to final seed
cat preseed1 preseed2 >| seed.M1

# Cleanup preseed values
rm preseed1 preseed2
fi


# Make the required bin directry
[ -d bin ] || mkdir bin

# Build debug footer
blood-elf -f seed.M1 \
	-o bin/seed-footer.M1 || exit 1

# Macro assemble with libc written in M1-Macro
M1 -f test/common_x86/x86_defs.M1 \
	-f functions/libc-core.M1 \
	-f seed.M1 \
	-f bin/seed-footer.M1 \
	--LittleEndian \
	--architecture x86 \
	-o bin/seed.hex2 || exit 2

# Resolve all linkages
hex2 -f test/common_x86/ELF-i386-debug.hex2 \
	-f bin/seed.hex2 \
	--LittleEndian \
	--architecture x86 \
	--BaseAddress 0x8048000 \
	-o bin/M2-Planet-seed \
	--exec_enable || exit 2

# self-host
./test/test100/hello.sh
