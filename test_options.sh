#! /usr/bin/env bash

__DEPTH_CHARGE__=1
__depth_charge__=""

. get_options.sh

declare -A ARRAY1
declare -A ARRAY2
declare -A ARRAY3

__OPTION__=( 						\
	[--array1]=array-ARRAY1:key1:value1,key2:value2	\
	[--array2]=array-ARRAY2:a,b,c	\
	[--array3]=array-ARRAY3			\
	[--jump]=bool-JUMP				\
	[--nr]=integer-NR:1::-Inf:+Inf	\
	[--spaces]=string-SPACES:str	\
	[--char]=CHAR					\
	[-t,--ticker]=count-TICKER		\
	[-e,--extend]=extend-EXTEND		\
)
__DESCRIPTION__=( 					\
	[--array1]="dict test with default"		\
	[--array2]="array test with default"	\
	[--array3]="array test without default"	\
	[--jump]="jump test"			\
	[--nr]="nr test"				\
	[--spaces]="spaces test"		\
	[--char]="string"				\
	[-t,--ticker]="increment count"	\
	[-e,--extend]="extend string"	\
)

get_options $*
unset get_options

say_exists ARRAY1 && echo "ARRAY1 exists" || echo "ARRAY1 does not exist"
say_in_use ARRAY1 && echo "ARRAY1 in use" || echo "ARRAY1 not in use"

say_exists ARRAY2 && echo "ARRAY2 exists" || echo "ARRAY2 does not exist"
say_in_use ARRAY2 && echo "ARRAY2 in use" || echo "ARRAY2 not in use"

ARGV1="${__ARGS__[0]}"
ARGV2="${__ARGS__[1]}"

declare -p __NARGS__ __ARGV__ __ARGS__
declare -p __NKEYS__
declare -p __VERBOSE__ __verbose__
declare -p __DEBUG__ __debug__
declare -p __DRY_RUN__ __dry_run__
declare -p __HELP__ __help__
declare -p ARRAY1 array1
declare -p ARRAY2 array2
declare -p ARRAY3 array3
declare -p JUMP jump
declare -p NR nr
declare -p SPACES spaces
declare -p CHAR char
declare -p TICKER ticker
declare -p EXTEND extend

declare -p __depth_charge__

exit 0
