/* Copyright (C) 2020 deesix <deesix@tuta.io>
 * This file is part of M2-Planet.
 *
 * M2-Planet is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * M2-Planet is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with M2-Planet.  If not, see <http://www.gnu.org/licenses/>.
 */

void exit(int value);

void _exit(int value)
{
	exit(value);
}

int waitpid(int pid, int* status_ptr, int options)
{
	asm("SET_X0_TO_MINUS_1"
	    "SET_X3_FROM_X0"
	    "SET_X0_FROM_BP" "SUB_X0_48" "DEREF_X0"
	    "SET_X2_FROM_X0"
	    "SET_X0_FROM_BP" "SUB_X0_32" "DEREF_X0"
	    "SET_X1_FROM_X0"
	    "SET_X0_FROM_BP" "SUB_X0_16" "DEREF_X0"
	    "SET_X8_TO_SYS_WAIT4"
	    "SYSCALL");
}

int execve(char* file_name, char** argv, char** envp)
{
	asm(
	    "SET_X0_FROM_BP" "SUB_X0_48" "DEREF_X0"
	    "SET_X2_FROM_X0"
	    "SET_X0_FROM_BP" "SUB_X0_32" "DEREF_X0"
	    "SET_X1_FROM_X0"
	    "SET_X0_FROM_BP" "SUB_X0_16" "DEREF_X0"
	    "SET_X8_TO_SYS_EXECVE"
	    "SYSCALL");
}