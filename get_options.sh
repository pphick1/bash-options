#+
# NAME:
#	get_options.sh
# PURPOSE:
#	Parses command line options for a bash script
# CATEGORY:
#	general/bash
# CALLING SEQUENCE:
#	get_options $*
# INPUTS:
#	$*			all cmd line arguments
# OUTPUTS:
#	One variable for each of the options defined in array __OPTION__.
#	Variable __ARGV__ contains everything that was not interpreted
#	as an option. The same list of arguments is stored in array
#	__ARGS__.
# EXAMPLE:
#
#	f="get_options.sh"
#	. $f
#	[ -n "$__BIN_DIR__" ] || { echo "$f not found"; exit 1; }
#
#	__MESSAGE__="Version 0.00 --- Paul Hick (UCSD/CAIDA; pphick@caida.org) --- 01-Jan-2222"
#	__OPTION__=(	\
#		[--dummy]=bool-DUMMY	\
#	)
#	__DESCRIPTION__=( \
#		[--dummy]="dummy description"	\
#	)
#	get_options $*
#	unset get_options
#
# PROCEDURE:
#	Variables set by user prior to calling get_options:
#	__CMD_LINE_LOG__
#					if set to a valid filename than a single line is added
#					containing a timestamp and the full cmd line.
#	__DEPTH_CHARGE__		see PROCEDURE
#	__NO_ABBREVIATIONS__	see PROCEDURE
#
#	Variables set by get_options:
#	__NARGS__		number of non-key arguments (i.e. ${#__ARGS__[@]})
#	__ARGS__		array with non-key arguments
#	__ARGV__		all non-key arguments as single string (seperated by space)
#	__NKEYS__		number of keys set on the command line
#	__BIN_DIR__		set to the full path of the caller
#
#	Access individual arguments of __ARGS__ with:
#		ARGV1="${__ARGS__[0]}"
#		ARGV2="${__ARGS__[1]}"
#
#	Short and long options can be combined as
#
#		[-X,--word-x --word-y]=type-VAR_NAME_X:DEFAULT::RESTRICTIONS
#
#	The short option is optional. There must be at least one long
#	option present. Although not strictly necessary, it is
#	recommended to use only one short option, and put it at the
#	start of the definition as shown above] (this will ensure an
#	orderly display of options with the --options keyword).
#
#	The entry between brackets (-X,--letter-x) and the name following the
#	equal sign (VAR_NAME_X or bool-VAR_NAME_X) are mandatory. The components
#	following the single colon (DEFAULT) and double colon (RESTRICTIONS)
#	are optional.
#
#	The entry between brackets is the cmd line option as specified
#	when calling the command (for one-letter options it is permitted
#	to concatenate, i.e. '-xyz' is the same as '-x -y -z').
#
#	The entry VAR_NAME_X is the name of a bash variable that will be set.
#
#	The "type" prefix can be set to 'bool', 'integer', 'array', 'string'
#	or can be left undefined. An undefined type is the same as 'string'.
#
#	'bool' indicates a boolean option (i.e. an option that is 'off' by default,
#	and 'on' only if specified on the cmd line. Boolean options cannot be given
#	an explicit value through the cmd line: the bash variable will always
#	exist and will be set to 0 (not set, 'off') or 1 (set, 'on').
#
#	'integer' indicates an integer option. In this case the input value will be
#	explicitly tested to be a numerical value. The DEFAULT and RESTRICTIONS
#	(if specified) must also be integer.
#
#	'array' indicates an array variable, and is set using a list of key, value
#	pairs for an associative array, or (TODO) as a list of values only for
#	a regular array.
#
#	The entry DEFAULT is an optional default value for VAR_NAME_X if it is not
#	specified. For boolean options the default is ignored.
#	If the default specification is omitted then VAR_NAME_X will not be touched 
#	if the corresponding option is not present on the cmd line. This means that
#	another way to set a default is to set VAR_NAME_X before calling get_options.
#
#	The entry RESTRICTIONS represents a restriction on the allowed value of the
#	key. This can be an integer range specified as a pair of integers separated
#	by a colon, e.g. '1:5'. The lower limit can be set to -Inf to indicate that
#	no limit exists (e.g. -Inf:-5); similarly the upper limit can be set to +Inf
#	(e.g. 5:+Inf). Note that -Inf:+Inf is the same as not specifying a range.
#
#	Instead of a colon, a dash will also work if both upper and lower limit
#	are positive definite. -Inf and +Inf are not allowed if a dash is used
#	(this in only supported for backward compatibility, and should not be used).
#
#	Alternatively, it can be a set of strings specified
#	as a comma-separated list, e.g. 'one,two,three'. An 'exit 1' is executed
#	if the input value does not match the restriction.
#
#	In addition to VAR_NAME the variable var_name (lowercase) is set to the
#	string used on the cmd line to invoke the option, e.g. if --help is used
#	the the bash variable help="--help" is set.
#
#	Two types of options are common:
#	'-x', '--letter-x'
#		boolean on/off switches get an implicit ON value of 1, and must
#		be defined as [-X]=bool-VAR_NAME_X.
#		VAR_NAME_X will be 1 (on) if -x is set, or 0 (off) if not
#
#	'-x value', '-x=value', '--letter-x value', '--letter-x=value'
#		Usually defined as [-X]=VAR_NAME_X
#		VAR_NAME_X is set to the string 'value'. If the option is not used,
#		then VAR_NAME_X will be undefined.
#
#	Array variables are specified as:
#	'--array key1:value1,key2:value2,key3:value3'
#		Defined as [--array]=array-VAR_NAME_X
#		VAR_NAME_X is set using the specified key,value pairs
#			VAR_NAME_X[key1]=value1   , etc.
#		Note that the array needs to be declared explicitly using
#			declare -A VAR_NAME_X
#		(this is due to a limitation in scope for bash arrays, I think)
#
#	Putting -- (double-dash, followed by a space) on the cmd line will
#	terminate the search for options. Everything after the double-dash
#	ends up in __ARGV__
#
#	There are five 'reserved' options which are always available:
#	-h,--help       print the documentation header (everything between
#	                lines "#+" and "#-").
#	                Sets variable __HELP__
#	-n,--dry-run    can be used to define a 'dry run'
#	                Sets variable __DRY_RUN__
#	   --debug <n>  verbose output
#	                Sets variable __DEBUG__
#	-v,--verbose    verbose output; same as --debug 1
#	                Sets variable __VERBOSE__
#	-V,--version    prints the version message in __MESSAGE__
#	                Sets variable __VERSION__
#	--time-tag <s>  sets time format for "tiny message" functions
#			Sets variable __TIME_TAG__
#
#	--debug is an integer option; the other four are boolean.
#
#	By default, unrecognized options results in an abort, with an error
#	message pointing out the error.
#
#	Instead of aborting it is possible to collect these unrecognized
#	options in a single variable. To activate this option set
#		__DEPTH_CHARGE__=1
#	prior to calling get_options. The unrecognized variables are then
#	collected in __depth_charge__. In theory this could be passed as
#	argument to a called script.
#	This is still experimental, so use at your own risk !!
#
#	By default cmd-line keywords can be abbreviated, as long as the
#	abbreviations identifies a unique keyword. To override, and force
#	that keywords must be completely specified set:
#		__NO_ABBREVIATIONS__=1
#
# MODIFICATION HISTORY:
#	JUL-2011, Paul Hick (UCSD/CAIDA)
#	AUG-2011, Paul Hick (UCSD/CAIDA)
#		Added -v (--verbose) as "reserved" option.
#		Substantial rewrite to remove restriction on providing defaults
#		for non-boolean options.
#		Added test for presence of reserved options
#	JUN-2012, Paul Hick (UCSD/CAIDA)
#		Added array __ARGS__ for easier access to remaining
#		(unprocessed) cmd line arguments.
#		--options now prints a list of options sorted alphabetically
#	SEP-2012, Paul Hick (UCSD/CAIDA)
#		Added capability to limit input values for keys to a specific
#		set of strings, or range of integers.
#	OCT-2012, Paul Hick (UCSD/CAIDA)
#		Added __DEPTH_CHARGE__ option to capture unrecognized options
#		into the variable __depth_charge__
#	JAN-2013, Paul Hick (UCSD/CAIDA)
#		Added code to options_set_key to allow for abbreviation
#		of cmd line arguments. __NO_ABBREVIATIONS__ can be set to suppress
#		this (in which case keywords must match exactly).
#		Added reserved option DEBUG
#		Added say_* echo routines.
#		Fair amount of changes to handle number of patological inputs.
#		Long options are now mandatory; a single short option can
#		be used alongside a long option.
#	JAN-2014, Paul Hick (UCSD/CAIDA)
#		Generalized specification of range for integer key to allow
#		negative values, and non-existing lower (-Inf) and upper
#		limits (+Inf).
#	MAY-2013, Paul Hick (UCSD/CAIDA)
#		Some clean up by unsetting some unused variables at the end of
#		get_options.
#		Finally found a solution to consistenly pick up quoted,
#		multiword command line arguments (see __CMD_LINE_PIECES__)
#	MAY-2014,  Paul Hick (UCSD/CAIDA)
#		Improved processing of array keywords.
#	APR-2015,  Paul Hick (UCSD/CAIDA)
#		Expanded initialiation (with . get_options). Renamed a number
#		of global variables.
#	AUG-2018,  Paul Hick (UCSD/CAIDA)
#		Bug fix: failed to process null-string cmd line args correctly.
#	SEP-2018, Paul Hick (UCSD/CAIDA)
#		Added check for already existing control variables as set by caller.
#	FEB-2019, Paul Hick (UCSD/CAIDA; pphick@caida.org)
#		Removed -o as short-hand for --options (conflicts with common use
#		of -o as short-hand for --output-file).
#	MAY-2023, Paul Hick (UCSD/CAIDA; pphick@caida.org)
#		Moved a bunch of functions from libtiny.sh to this script.
#		Changed names from tiny_* to say_*. libtiny.sh still exists
#		unmodified, but must be sourced explicitly now.
#		Added some functions to avoid having to reference any of the
#		reserved keywords explicitly:
#			'say_is_verbose', 'say_is_dry_run', 'say_debug_is'
#			'say_verbose_str', 'say_debug_str', 'say_dry_run_str'
#		Fixed inconsistency with use of --verbose and --debug 0, if
#		both used at the same time (--verbose takes precedence).
#		__VERBOSE__ and __DEBUG__ now always have the same value.
#		Changed reserved variable 'verbose' to '__verbose__', and
#		'debug' to '__debug__'. Kept the old names for backward
#		compatibility.
#		Added __BIN_DIR__. This is set to the absolute path of the
#		script containing '. get_options'. This depends on the
#		availibility of the realpath utility.
#		Added a default for strings and arrays to make sure the
#		(uppercase) control variable ($__one_control__) exists when
#		not specified on the command line.
#	AUG-2023, Paul Hick (UCSD/CAIDA; pphick@caida.org)
#	    Modified options_set_value to make sure the lower case control
#		variable ($__one_argument) exists when not specified on the
#		command line. It should now always be possible to pass the
#		lowercase control variable to another bash script instead of
#		using the uppercase control variable.
#		E.g. pass '$__debug__' instead of '--debug $__DEBUG__'. If
#		called without --debug set (same as --debug 0) then __debug__
#		will be the null string, i.e. same as for the calling script.
#
#		Added type 'count'. This represents a counter that is
#		incremented for each time it is used. Note that type 'bool'
#		is the same is type 'count' with a range of [0-1].
#
#		Added type 'extend'. This represents a string that is
#		appended to each time it is used. Note that type 'string'
#		is the same as a type 'extend' that is used only once.
#
#		Changed __VERBOSE__ to type 'count'.
#		So now -vvv (or --verbose --verbose --verbose) is the same
#		as --debug 3.
#
#		Made some changes to say_add2var to handle values
#		containing spaces better.
#
#		Improved check for conflicts between user-supplied options
#		and reserved options.
#-

# Load these, if present in PATH, but do not complain if it does not work

f="libtiny.sh"
. $f 2> /dev/null 
unset f

f="libfileset.sh"
. $f 2> /dev/null 
unset f

#+
# NAME:
#	say_note
# PURPOSE:
#	Prints a string to stdout.
# INPUTS:
#	$1		user message
#	$2		positive integer indicating the "verbosity" threshold.
#			If get_options is used then messages with threshold $2=1
#			become visible when --verbose, or --debug=1 is set.
#			(see also say_say below).
#			If the threshold is set to 'n' then the message becomes
#			visible if $2 is set to n or larger ($2 >= n)
#	$3		single char: S,I,E,W. The default is 'I'
# OUTPUTS:
#	Modified string $1 to stdout
# NOTE:
#	A collection of functions implement special cases of say_note:
#
#	For echoing to stdin
#	--------------------
#	Always echo (i.e. ignore __VERBOSE__ or __DEBUG__ setting):
#		say_echo
#
#	For echoing to stderr
#	---------------------
#		say_message		behaves exactly as say_note
#
#	Always echo (i.e. ignore __VERBOSE__ or __DEBUG__ setting):
#		say_yell			used to print informational messages
#							that must always be visible
#		say_warn			used to print warning messages that
#							must always be visible
#		say_die			echos and exits with code 1.
#							used to signal fatal condition
#		say_done			echos and exit with code 0.
#							used to signal normal completion.
#
#	Echo for every non-zero threshold:
#		say_say			used for non-critical messages
#							they become visible by setting --verbose
#							(__VERBOSE__=1) or --debug=1 (or higher;
#							__DEBUG__>=1) when get_options is used.
#
#	For some of the functions above there is a 'bare'
#	version that prints the message under the same conditions
#	as the 'dressed-up' version, but echos the message
#	unmodified except for an optional, fixed, prefix (see PROCEDURE).
#	These are usually used following a call to the non-bare
#	version.
#
#	For echoing to stdin
#	--------------------
#		say_note_bare
#		say_echo_bare
#
#	For echoing to stderr
#	---------------------
#		say_message_bare
#		say_yell_bare
#		say_warn_bare
#		say_say_bare
#
# PROCEDURE:
#	The main intent is to provide a mechanism for
#	echoing a message after adding the name of the
#	calling routine identified in the bash variable
#	__CALLER__.
#
#	Action is controlled by several bash variables:
#
#	__DEBUG__, __VERBOSE__
#
#	These are most easily set by using get_options,
#	which introduces __DEBUG__ as a positive integer,
#	and __VERBOSE__ as a boolean variable. Setting the
#	bool __VERBOSE__ is equivalent to __DEBUG__=1.
#
#	The message is only echoed if
#		max(__DEBUG__,__VERBOSE__) >= $2
#	i.e. if the user-requested "verbosity" level in
#	__DEBUG__ and/or __VERBOSE__ is equal to or larger then the
#	threshold $2 set by the call to say_note.
#
#	__CALLER__
#
#	If this is not set, or is the null string, then
#	the string $1 is printed with the content of
#	__NOTE_PREFIX__ at the start. By default this is
#	a string of four spaces. This is used for the
#	'bare' functions listed above.
#
#	Usually __CALLER__ is set to a string identifying
#	the calling routine. For a top-level script this
#	can be `basename $0 .sh`. Bash functions need
#	to hardcode a string as a local variable:
#		local __CALLER__="function name"
#
#	The string echoed to stdout has the form
#		[__DRY_RUN__ ]%$__CALLER__[-SEIW][-$TIME]-$1
#	where the components between square brackets
#	may not be present.
#
#	The components are:
#
#	'__DRY_RUN__'
#	Is added if the bash variable __DRY_RUN__ is set to a
#	non-zero integer (__DRY_RUN__ is a boolean option defined
#	by get_options).
#
#	__CALLER__
#	identifies the calling function (see above)
#
#	SEIW (from $3; default: 'I')
#	Single character:
#	'S'	success, used by say_done
#	'E'	error, used by say_die
#	'I'	information, used by say_say
#	'W'	warning:, used by say_warn
#
#	TIME
#	The system time. This is added only if variable
#	__TIME_TAG__ is defined. This should be a valid
#	format accepted by the 'date' utility (without
#	the leading plus sign, e.g. "%m/%d %H:%M")
# MODICATION HISTORY:
#	JAN-2013, Paul Hick (UCSD/CAIDA; pphick@caida.org)
#-

# say_is_verbose && verbose_statement
say_is_verbose () { [ $__VERBOSE__ -ge 1 ] && return 0 || return 1; }
say_is_debug   () { [ $__VERBOSE__ -ge 2 ] && return 0 || return 1; }

# [ `say_debug_is` -gt 1 ] && statement
say_debug_is    () { echo $__VERBOSE__; }

# say_is_dry_run || do_something
say_is_dry_run  () { [ $__DRY_RUN__ -eq 1 ] && return 0 || return 1; }

say_verbose_str      () { echo $__verbose__     ; }
say_debug_str        () { echo $__debug__       ; }
say_dry_run_str      () { echo $__dry_run__     ; }
say_time_tag_str     () { echo $__time_tag__    ; }
say_depth_charge_str () { echo $__depth_charge__; }

say_note () {
	local __debug__
	[ ${__DEBUG__:-0} -gt ${__VERBOSE__:-0} ] && __debug__=${__DEBUG__:-0} || __debug__=${__VERBOSE__:-0}

	# Only if the debug level is higher than the
	# threshold, something is actually printed

	[ $__debug__ -ge ${2:-0} ] || return

	# If __CALLER__ is not defined, then just echo

	if [ -z "$__CALLER__" ]; then

		[ -n "$__NOTE_PREFIX__" ] || local __NOTE_PREFIX__="    "
		echo "$__NOTE_PREFIX__$1"

	else

		local __seiw__
		[ -n "$3" ] && __seiw__="-$3" || __seiw__=""

		local __note_date__
		[ -n "$__TIME_TAG__" ] && __note_date__="`date +\"$__TIME_TAG__\"` " || __note_date=""

		local __dry_run__
		[ ${__DRY_RUN__:-0} -eq 1 ] && __dry_run__="DRY_RUN " || __dry_run__=""

		echo "$__dry_run__$__note_date__%$__CALLER__$__seiw__- $1"

	fi
	return 0
}

#+
# NAME:
#	say_note_bare
# PURPOSE:
#	Print message, obeying verbosity rules from
#	say_note, prefixed by content of __NOTE_PREFIX__
#-

say_note_bare () {
	local __CALLER__=""
	say_note "$1" "$2"
	return 0
}

say_echo () {		# Always echo to stdin
	say_note "$1" "$__VERBOSE__" "$2"
	return 0
}
say_echo_bare () {	# Always echo to stdin
	say_note_bare "$1" "$__VERBOSE__"
	return 0
}

#+
# NAME:
#	say_message
# PURPOSE:
#	Prints message to stderr
# PROCEDURE:
#	Same as say_note, but prints to stderr instead of stdout.
#-

say_message () {
	if [ -z "$__CMD_LINE_LOG__" ]; then
		say_note "$1" "$2" "$3" >&2
	else
		say_note "$1" "$2" "$3" >> $__CMD_LINE_LOG__
	fi
	return 0
}

say_message_bare () {
	if [ -z "$__CMD_LINE_LOG__" ]; then
		say_note_bare "$1" "$2" >&2
	else
		say_note_bare "$1" "$2" >> $__CMD_LINE_LOG__
	fi
	return 0
}

say_warn () {		# Always echo to stderr
	say_message "$1" "$__VERBOSE__" "${2:-W}"
	return 0
}

say_warn_bare () {	# Always echo to stderr
	say_message_bare "$1" "$__VERBOSE__"
	return 0
}

say_die () {		# Always echo to stderr; then quit with error code 1
	[ -n "$1" ] && say_message "$1" "$__VERBOSE__" "${2:-E}"
	exit ${3:-1}
}

say_done () {		# Always echo to STDERR; then quit with error code 0
	[ -n "$1" ] && say_message "$1" "$__VERBOSE__" "${2:-S}"
	exit 0
}

say_yell () {		# Always echo to stderr
	say_message "$1" "$__VERBOSE__" "${2:-I}"
	return 0
}

say_yell_bare () {	# Always echo to stderr
	say_message_bare "$1" "$__VERBOSE__"
	return 0
}

say_say () {		# Echo for every non-zero __VERBOSE__ to stderr
	say_message "$1" "1" "${2:-I}"
	return 0
}

say_say_bare () {	# Echo for every non-zero __VERBOSE__ to stderr
	say_message_bare "$1" "1"
	return 0
}

say_debug () {		# Echo for every non-zero __VERBOSE__ to stderr
	say_message "$1" "2" "${2:-I}"
	return 0
}

say_debug_bare () {	# Echo for every non-zero __VERBOSE__ to stderr
	say_message_bare "$1" "2"
	return 0
}

say_deep_debug () {			# Echo for every non-zero __VERBOSE__ to stderr
	say_message "$1" "3" "${2:-I}"
	return 0
}

say_deep_debug_bare () {		# Echo for every non-zero __VERBOSE__ to stderr
	say_message_bare "$1" "3"
	return 0
}

# $1		name of bash variable
# $2		string to be added
#			(make sure to quote $2 if it contains whitespace)
# $3		if "0" or "" then add to end; anything else add at front
# $4		separator to be used when adding (default is single space)

say_add2var () {
	local __CALLER__="say_add2var"
	[ -n "$1" ] || say_die "no variable name specified as 1st arg"
	if [ -n "$2" ]; then			# $2 is not empty
		local s=${4:- }
		local v
		eval v=\$$1
		if [ -z "$v" ]; then		# Var empty?
			eval $1=\"\$2\"			# If empty, then initialize it
		else
			if [ -z "$3" ]; then	# No preference: add at end
				eval $1=\"\$v\$s\$2\"
			elif [ $3 = 0 ]; then	# Preference is add at end
				eval $1=\"\$v\$s\$2\"
			else					# Preference is add at front
				eval $1=\"\$2\$s\$v\"
			fi
		fi
		unset v
		unset s
	else
		eval $1+=\"\"
	fi
}

say_prompt () {
	if [ -n "$1" ]; then
		echo
		echo
		echo "$1"
	fi
	echo
	echo
	echo "type 'yes' to continue; everything else will terminate"
	echo -n "   well? "
	read YESNO
	[ "$YESNO" = "yes" ] || say_done "Terminate"
}

# $*		command to be executed on host

say_run() {
	local __CALLER__="say_run"
	say_message "$*" 3 I
	if [ ${__DRY_RUN__:-0} -ne 1 ]; then
		$* || { local x=$?; say_debug "error $x: $*"; exit $x; }
	fi
}

# $*		command to be executed on host

say_run_and_go() {
	local __CALLER__="say_run_and_go"
	say_message "$*" 3 I
	if [ ${__DRY_RUN__:-0} -ne 1 ]; then
		$* || { local x=$?; say_debug "error $x: $*"; return $x; }
	fi
}

# $1		remote host
# $*		command to be executed on host

say_exec () {
	local __CALLER__="say_exec"
	local user=$1				# Could contain username
	local host=${user##*@}		# Strip username if present
	shift
	say_message "$* on $user from $HOSTNAME" 3 I
	if [ ${__DRY_RUN__:-0} -eq 0 ]; then
		if [ ${HOSTNAME%%.*} = ${host%%.*} ]; then	# Strip everything after first dot
			bash -c "$*"
			local x=$?
		else
			. ssh-hook.sh stop > /dev/null
			ssh $user "$*"
			local x=$?
		fi
		if [ $x -ne 0 ]; then
			say_debug "error $x: $* on $user from $HOSTNAME"
			return $x
		fi
	fi
}

# Bash does not distinguish between scalars and 1-element arrays.
# Unlike perl and python X and X[0] are effectively equivalent.
# This means that when testing whether a variable X exists (is set) you
# have to decide what it is you need to know:
#	(1) is the element X[0] set already:
#	(2) is the name X in use already
# The difference becomes clear if X is a numeric array that does not
# have the element X[0] set, or for an associative array.
# In both cases X (i.e. X[0]) is NOT set, while the name X IS in use.
#
# The expression ${X+defined) is one way to test for (1). It returns
# the null-string if X is NOT set, or else it returns the string 'defined'. See
# http://www.gnu.org/software/bash/manual/bashref.html#Shell-Parameter-Expansion
# This is implemented in say_exists.
#
# Probably the most straightforward way to test for (2) is to use
# 'declare -p X'. The return status is 1 if the name X is NOT in use (with an
# an error message to stderr), or 0 if it is (and prints to stdout).
#
# A second solution is to check the number of elements ${#X[@]}. This will be
# zero if X is NOT in use, and non-zero if it is. 
#
# The first solution is more direct, but the output may need to be redirected
# to the null device. It might also gum up the works if stdout and sterr
# are redefined. So say_in_use implements the second solution.
#
# $1	name of variable to be tested
#
# Most obvious way to use these, is like this:
#	if say_exists X; then echo "X exists and has value '$X'"; else echo 'X does not exist'; fi

say_in_use () {		# Returns 1 if var in use (even if is set to null string)
	local status
	eval local n=\${#$1[@]}
	[ $n -eq 0 ] && status=1 || status=0
	return $status
}

say_exists () {
	local status
	eval local v=\${$1+a}
	[ -z "$v" ] && status=1 || status=0
	return $status
}

options_set_value () {
	#+
	# NAME:
	#	options_set_value
	# PURPOSE:
	# CALLING SEQUENCE:
	#	options_set_value <cmd-line-chunk>
	# INPUTS:
	#	<cmd-line-chunk>	piece of cmd line following
	#						an equal sign or a space, and
	#						representing the value for an option
	#	'set'				forces setting of lower case control
	#
	#	In addition, up to 6 global bash variables set
	#	by the last call to options_set_key are available:
	#		__one_name__, __one_control__, __one_argument__, __one_type__, __one_range__, __one_default__
	#
	# MODIFICATION HISTORY:
	#	JAN-2013, Paul Hick (UCSD/CAIDA; pphick@caida.org)
	#		Added documentation.
	#-

	local __CALLER__="options_set_value"

	if [ -z "$__one_type__" ]; then

		[ -n "$1" ] && say_die "syntax error: value '$1' cannot be assigned"

	elif [ $__one_type__ = "__depth_charge__" ]; then

		#if [ -n "$2" ]; then
			say_add2var __depth_charge__ "$__one_name__${1:+=}$1"
			#say_add2var __depth_charge__ "$__one_name__"
			#say_add2var __depth_charge__ "$1"
		#fi

	else		# Valid option

		#if [ $__NO_OVERWRITE__ -eq 1 ] && say_in_use $__one_control__; then
		#	say_die "control variable is set already: `declare -p $__one_control__`"
		#fi

		local value=$1

		if [ $__one_type__ = a ]; then		# Type: 'array'

			# This section has not been tested very well
			# The 'declare' does not work for some reason.
			# The array is created correctly, but it looks like it
			# has local scope only. To make this work the array needs to
			# be explicitly declared by the calling script

			# declare -A $__one_control__

			# If $value contains a colon it should be a comma-separated
			# list of key:value pairs. If there is no colon than
			# it should be a comma-separated list of values

			if [[ $value =~ : ]]; then		# Construct an associative array of key-value pairs

				local looking_for_key=1
				local is_key
				local to_colon
				local to_comma
				local field
				local key

				while [[ $value =~ (:|,) ]]; do
					to_colon=${value%%:*}
					to_comma=${value%%,*}

					if [ ${#to_colon} -lt ${#to_comma} ]; then
						field=$to_colon
						[ $looking_for_key -eq 0 ] && say_die "expected to find value at start of '$value'; found key '$field' instead"
						[ -n "$field" ] || say_die "found empty key at start of '$value'"
						is_key=1
						value=${value#*:}
						looking_for_key=0
					else
						field=$to_comma
						[ $looking_for_key -eq 1 ] && say_die "expected to find key at start of '$value'; found value '$field' instead"
						is_key=0
						value=${value#*,}
						looking_for_key=1
					fi

					[ $is_key -eq 1 ] && key=$field || eval $__one_control__["\$key"]="\$field"
				done

				if [ $looking_for_key -eq 1 ]; then
					field=$value
					[ -n "$field" ] || say_die "found empty key at end of '$1'"
					say_die "missing value for key '$field' at end of '$1'"
				fi

				eval $__one_control__[\$key]="\$value"

			else			# Construct a regular array from comma-separated list of values

				local to_comma
				local key=-1

				while [[ $value =~ , ]]; do
					((key++))
					to_comma=${value%%,*}
					value=${value#*,}
					eval $__one_control__["\$key"]="\$to_comma"
				done

				((key++))
				eval $__one_control__["\$key"]="\$value"

			fi

		else

			# Some sanity checks:
			# - if a range is specified, make sure it is respected
			# - Check that integer type only receives a numerical value

			local atype=${__valid_types__[$__one_type__]}

			if [ -n "$__one_range__" ]; then

				if [[ $__one_range__ =~ ^([0-9]+)-([0-9]+)$ ]]; then	# Numerical range: min and max

					# For backward compatibility: this only works for positive-definite ranges and values

					local lower_limit=${BASH_REMATCH[1]}
					local upper_limit=${BASH_REMATCH[2]}
					[[ sa =~ $__one_type__ ]] && say_die "cannot restrict '$atype' key '$__one_name__' to numerical range '$__one_range__', must be 'integer'"
					[[ $1 =~ ^[0-9]+$ ]] || say_die "illegal value '$1' for '$atype' key '$__one_name__', need numerical value in range '$__one_range__'"
					[ $1 -lt $lower_limit -o $1 -gt $upper_limit ] && say_die "illegal value '$1' for key '$__one_name__', value must be in range '$__one_range__'"
				elif [[ $__one_range__ =~ ^([\-,0-9]+|-Inf):([\-,0-9]+|\+Inf)$ ]]; then

					# This should handle all integer ranges, incl. setting either lower_limit to -Inf
					# or upper_limit to +Inf. At least one must be a number though.

					local lower_limit=${BASH_REMATCH[1]}
					local upper_limit=${BASH_REMATCH[2]}

					[[ sa =~ $__one_type__ ]] && say_die "cannot restrict '$atype' key '$__one_name__' to numerical range '$__one_range__', must be 'integer'"
					[[ $1 =~ ^[\-,0-9]+$ ]] || say_die "illegal value '$1' for '$atype' key '$__one_name_', need numerical value in range '$__one_range__'"

					if [ "$lower_limit" != "-Inf" -a "$upper_limit" != "+Inf"  ]; then
						[ $1 -lt $lower_limit -o $1 -gt $upper_limit ] && say_die "illegal value '$1' for key '$__one_name__', value must be in range '$__one_range__'"
					elif [ "$lower_limit" = "-Inf" ]; then
						if [ $upper_limit != "+Inf" ]; then		# $upper_limit is valid number
							[ $1 -gt $upper_limit ] && say_die "illegal value '$1' for key '$__one_name__', need value less/equal '$upper_limit'"
						fi
					elif [ "$upper_limit" = "+Inf" ]; then
						if [ $lower_limit != "-Inf" ]; then		# $lower_limit is valid number
							[ $1 -lt $lower_limit ] && say_die "illegal value '$1' for key '$__one_name__', need value greater/equal '$lower_limit'"
						fi
					fi
				else			# Set of strings
					[[ $1 =~ ^($__one_range__)$ ]] || say_die "illegal value '$1' for key '$__one_name__', allowed values are '$__one_range__'"
				fi
			elif [ $__one_type__ = i ]; then
				[[ $1 =~ ^[0-9]+$ ]] || say_die "illegal value '$1' for '$atype' key '$__one_name__', numerical value required"
			fi

			if [ $__one_type__ = e ]; then
				[[ "$1" =~ \ |^$ ]] && val="\"$1\"" || val="$1"
				eval say_add2var $__one_control__ \"\$val\"
			else
				eval $__one_control__="\$1"			# Assign value to control variable
			fi

		fi

		# We just assigned the value $1 to the control variable $__one_control__
		# (containing the name of the bash variable used to store the input value).
		# We still need to set the lower case version of the control variable.
		# E.g. for the boolean option [--help]=bool-__HELP__. if --help is
		# used on the command line, then the bash variable '__HELP__' is set to 1,
		# and the variable '__help__' is set to '--help'
		# For the string option --allow-dups]=ALLOW_DUPS:no
		# the bash variable 'ALLOW_DUPS is set to 'yes', and the variable 'allow-dups'
		# is set to '--allow_dups yes'.

		options_base_arg "$__one_name__"		# Sets base_arg
		if   [ $__one_type__ = b ]; then		# Boolean
			[ $1 -eq 0 ] && base_arg=""
		elif [ $__one_type__ = c ]; then		# Counter
			eval val="\$$__one_argument__"
			[ $1 -eq 0 ] && base_arg="" || say_add2var base_arg "$val" 1
		elif [ $__one_type__ = i ]; then		# Integer
			base_arg+="=$1"
		elif [ $__one_type__ = e ]; then		# Extend string
			[[ "$1" =~ \ |^$ ]] && base_arg+="=\"$1\"" || base_arg+="=$1"
			eval val="\$$__one_argument__"
			say_add2var base_arg "$val" 1
		else									# String and array
			# If $1 is null-string or contains spaces then must use quotes
			[[ "$1" =~ \ |^$ ]] && base_arg+="=\"$1\"" || base_arg+="=$1"
		fi
		eval $__one_argument__="\$base_arg"

	fi

	#options_show_key
	options_clear_key
}

options_base_arg () {
	# -v,--verbose	--> --verbose
	# --verbose,-v	--> --verbose
	# -v,-w			--> -v
	# Remove everything before the first -- or first -
	#local __CALLER__="$__CALLER__[base_arg]"
	[[ $1 =~ -- ]] && base_arg="--${1#*--}" || base_arg="-${1#*-}"
	base_arg=${base_arg%%,*}	# Remove everything after the first ,
}

options_clear_key () {
	#local __CALLER__="$__CALLER__[clear_key]"
	unset __one_name__
	unset __one_type__
	unset __one_control__
	unset __one_argument__
	unset __one_default__
	unset __one_range__
}

options_show_key () {
	local __CALLER__="$__CALLER__[show_key]"
	local val
	say_yell "__one_name__='$__one_name__'"
	say_yell "__one_type__='$__one_type__'"
	eval val=\$$__one_control__
	say_yell "__one_control__='$__one_control__'='$val'"
	eval val=\$$__one_argument__
	say_yell "__one_argument__='$__one_argument__'='$val'"
	say_yell "__one_default__='$__one_default__'"
	say_yell "__one_range__='$__one_range__'"
	[ $__DEPTH_CHARGE__ -eq 1 ] && say_yell "__depth_charge__='$__depth_charge__'"
	say_yell "================================"
}

options_reserved () {
	local __CALLER__="$__CALLER__[reserved]"
	local A
	for A in __one_name__ __one_type__ __one_control__ __one_argument__ __one_default__ __one_range__; do
		say_in_use $A && say_die "reserved variable '$A' is set already: `declare -p $A`"
	done
}

options_set_key () {
	#+
	# NAME:
	#	options_set_key
	# PURPOSE:
	#	Process a piece of the options specified on the
	#	command line.
	# CALLING SEQUENCE:
	#	options_set_key <cmd-line-chunk>
	# INPUTS:
	#	cmd-line-chunk	piece of cmd line (e.g. '--dry-run').
	#					The piece starts with '-' or '--',
	#					and continues upto the next space or '='.
	# OUTPUTS:
	#	Up to 6 global bash variables are set:
	#		__one_name__, __one_control__, __one_argument__, __one_type__,
	#		__one_range__, __one_default__.
	#
	#	__one_name__
	#
	#	If the cmd line chunk is not recognized as a valid
	#	key in __OPTION__ it is set to the whole input chunk
	#	(this becomes a 'depth_charge' option)
	#	In this case __one_type__='__depth_charge__'.
	#
	#	If the chunk is recognized as a valid option,
	#	it is set to the matching __OPTION__ key.
	#	example: '--dry-run,-n'.
	#	In this case __one_type__ is one of 'b'(ool), 'i'(nteger),
	#	's'(tring) or 'a'(rray)
	#
	#	__one_type__
	#
	#	one of: 'b','i','s','a' or '__depth_charge__'
	#	See description of '__one_name__' above.
	#
	#	For an unrecognized 'depth_charge' chunk no other global vars
	#	are set.
	#
	#	For a recognized option from __OPTION__, two additial
	#	global var are always set:
	#
	#	__one_control__
	#
	#	the bash control variable that will be assigned the value
	#	specified on the cmd line
	#	example: __DRY_RUN__ (must contain at least one uppercase char
	#	to differentiate it from '__one_argument__')
	#
	#	__one_argument__
	#
	#	The lowercase version of '__one_control__'. This receives
	#	a string describing the option as specified on the cmd line,
	#	example: '--dry-run', '--verbose 2'.
	#
	#	Two more global vars may or may not be defind:
	#
	#	__one_range__
	#
	#	An integer range of values if __one_type__='i', or a
	#	list of string, separated by a comma or vertical bar,
	#	if __one_type__='s'.
	#
	#	__one_default__
	#
	#	Default value for 'string' or 'array' types.
	#	The default for 'integer' is zero. This is used if the
	#	option is not specified on the cmd line.
	#
	# RESTRICTIONS:
	#	The function will abort if one of these conditions is met:
	#	- the specified chunk matches more than one valid option
	#	- if the chunk cannot be matched to a valid option
	#	  (unless __DEPTH_CHARGE__ is set).
	#	- if the chunk matches a valid option for which no control
	#	  variable is specified in __OPTION__
	#	- if the chunk matches a valid option for which an invalid
	#	  type is specified in __OPTION__.
	#	- if the control variable does not contain any uppercase chars
	# MODIFICATION HISTORY:
	#	JAN-2013, Paul Hick (UCSD/CAIDA; pphick@caida.org)
	#		Added documentation.
	#-

	local __CALLER__="$__CALLER__[set_key]"

	# This cannot happen. If it does there is a bug somewhere
	# All global __one_*__ vars should be unset at this point

	[ -n "$__one_type__" ] && say_die "oops, '__one_type__' still defined to '$__one_type__'"

	local match=""
	local match_count=0

	# Check for $1="-". Abort for now.
	# TODO:
	# Should be possible to do something more useful
	# if __OPTION__[-] existed.
	# Also $1="--" if "--=xyz" on cmd line might be
	# useful if __NO_ABBREVIATIONS__ is set (otherwise it
	# $1 would match every long option!

	[ "$1" = "-" -o "$1" = "--" ] && say_die "standalone dash(es) specified, '$1'"

	if [ $__NO_ABBREVIATIONS__ -eq 1 ]; then

		local A;
		for A in "${!__OPTION__[@]}"; do
			[[ ,$A, =~ ,$1, ]] && { say_add2var match "$A"; ((match_count++)); }
		done

	else
		# Loop over all valid key names (keys of associative array __OPTION__)

		local A;
		for A in "${!__OPTION__[@]}"; do
			[[ $A =~ ^$1|,$1 ]] && { say_add2var match "$A"; ((match_count++)); }
		done

	fi

	# Never happens if __NO_ABBREVIATIONS__ is set

	[ $match_count -gt 1 ] && say_die "option not unique: '$1' matches '$match'"

	if [ $match_count -eq 0 ]; then

		# No match found; abort unless __DEPTH_CHARGE__ is set

		[ $__DEPTH_CHARGE__ -eq 0 ] && say_die "unrecognized option '$1' encountered"

		__one_name__=$1				# Keyname from cmd line
		__one_type__="__depth_charge__"

	else

		[[ $match =~ -- ]] || say_die "option defs like '$match', containing short options only are not allowed"

		__one_name__=$match
		local one_option=${__OPTION__[$match]}

		if [[ "$one_option" =~ ::: ]]; then		# Missing default between : and ::
			__one_range__=${one_option#*:::}	# Part after triple colon
			one_option=${one_option%:::*}		# Part before triple colon
		elif [[ "$one_option" =~ :: ]]; then	# Missing default (no :, only ::)
			__one_range__=${one_option#*::}		# Part after double colon
			one_option=${one_option%::*}		# Part before double colon
		fi

		if [ -n "$__one_range__" ]; then
			[[ $__one_range__ =~ , ]] && __one_range__=${__one_range__//,/|}	# Replace , by | (makes a regex)
		fi

		# Look for colon separating control var and default value

		if [[ "$one_option" =~ : ]]; then		# Colon present
			__one_control__=${one_option%%:*}	# Part before colon (deletes everything after first colon)
			__one_default__=${one_option#*:}	# Part after colon (deletes everything before first colon)
		else									# No default specified
			__one_control__=$one_option
		fi

		# Look for dash in keyname, defining type

		if [[ "$__one_control__" =~ - ]]; then
			__one_type__=${__one_control__%-*}		# Part before dash
			__one_type__=${__one_type__:0:1}		# Just retain first char
			__one_control__=${__one_control__#*-}	# Part after dash
		else
			__one_type__="s"						# Default is string
		fi

		# Boolean type is same as integer with range 0-1
		# (and implicit default 0)

		[ $__one_type__ = b ] && __one_range__="0-1"

		# Setting default for type 'a' results in 1-element arrsy ([0]="")

		[[ bic =~ $__one_type__ ]] && [ -z "$__one_default__" ] && __one_default__=0
		[[ sae =~ $__one_type__ ]] && [ -z "$__one_default__" ] && __one_default__=""

		[ -n "$__one_control__" ] || say_die "missing control variable in '$__one_name__'"

		__one_argument__=${__one_control__,,}			# Convert to lowercase

		[ $__one_argument__ = $__one_control__ ] && say_die "control var '$__one_control__' for option '$__one_name__' contains no uppercase chars"

		[ -n "$__one_type__" ] || say_die "missing type specification in '$__one_name__'"

		[[ bisace =~ $__one_type__ ]] || say_die "invalid type '$__one_type__' for '$__one_name__'; must be 'bool', 'integer', 'string' or 'array'"

	fi
}

options_set_missing_value () {

	local __CALLER__="options_set_missing_value"

	if [ -n "$__one_type__" ]; then
		if [ $__one_type__ = "__depth_charge__" ]; then
			options_set_value "" set
		else
			[[ 'isae' =~ $__one_type__ ]] && say_die "missing value for ${__valid_types__[$__one_type__]} option '$__one_name__'"
			if [ $__one_type__ = 'b' ]; then
				 options_set_value "1" set
			elif [ $__one_type__ = 'c' ]; then
				local val
				eval val=\$$__one_control__
				((val+=1))
				options_set_value "$val" set
			fi
		fi
	#else
	#	say_warn "redundant call"
	fi
}

options_help () {
	ff="doc_head.sh"
	which $ff > /dev/null && $ff --count 1 $0 || echo "'$ff' not available"
	unset ff

	echo "OPTIONS:"

	local A
	local sorted_options=`for A in ${!__OPTION__[*]}; do echo $A; done | sort`
	local message

	for A in $sorted_options; do
		message=""
		[ ${A:0:2} = -- ] && message+="   "
		options_set_key $A
		message+="$A"
		if [ $__one_type__ != b ]; then
			message+=" $__one_control__"
			[ -n "$__one_default__" ] && message+=" [$__one_default__]"
		fi
		options_clear_key
		say_warn_bare "$message"
		[ -n "${__DESCRIPTION__[$A]}" ] && say_yell_bare "        ${__DESCRIPTION__[$A]}"
	done

	exit 0
}

options_version () {
	[ -n "$__MESSAGE__" ] && echo "$__MESSAGE__" || echo "(no version message available; please, set __MESSAGE__)"
	exit 0
}

options_cleanup () {
	unset options_reserved
	unset options_set_key
	unset options_set_value
	unset __valid_types__
	unset options_base_arg
	unset options_clear_key
	unset options_set_missing_value
	unset __CMD_LINE_PIECES__
	unset __MESSAGE__
	unset __DESCRIPTION__
	unset __OPTION__

	unset options_help
	unset options_version
}

get_options () {

	#local __CALLER__="get_options"

	local search_terminated=0
	local key
	local value
	local base_arg
	local A
	local B
	local PIECE_I
	local OPTION_I

	# Make sure reserved options are not being used already.

	for A in ${!__OPTION__[*]}; do		# User-defined options
		for B in ${A//,/ }; do			# Loop over short/long options
			[ ${B:0:1} = "-" ] || say_die "'$A' is not a valid option (must start with '-' or '--')"
			# Compare against all reserved long/short options. Stop on match
			for key in --options -h --help -n --dry-run -v --verbose --debug --time-tag; do
				[ $B = $key ] && say_die "'$A' conflicts with reserved option '$key'"
			done
		done
	done

	# Define reserved options

	A="-h,--help"
		 __OPTION__[$A]=bool-__HELP__
	__DESCRIPTION__[$A]="print documentation header"

	A="--time-tag"
		 __OPTION__[$A]=string-__TIME_TAG__
	__DESCRIPTION__[$A]="time tag for messages"

	A="-v,--verbose"
#		 __OPTION__[$A]=bool-__VERBOSE__
		 __OPTION__[$A]=count-__VERBOSE__
	__DESCRIPTION__[$A]="verbose output; same as '--debug 1'"

	A="--debug"
		 __OPTION__[$A]=integer-__DEBUG__:::0:+Inf
	__DESCRIPTION__[$A]="debug level"

	A="-n,--dry-run"
		 __OPTION__[$A]=bool-__DRY_RUN__
	__DESCRIPTION__[$A]="make 'dry run'"

	if [ -n "$__MESSAGE__" ]; then
		A="-V,--version"
			 __OPTION__[$A]=bool-__VERSION__
		__DESCRIPTION__[$A]="print version message"
	fi

	# NOT GOOD ENOUGH.
	# Sometimes control variables are set intentionally to initialize them.
	# Need a way to distinguish that from unintentional cases.

	# Make sure that none of the control variable are set already
	# (e.g. env var defined by caller)

	#for A in ${__OPTION__[*]}; do
	#	B=${A%%:*}
	#	B=${B#*-}
	#	eval value=\$$B
	#	if [ -n "$value" ]; then
	#		say_die "control variable '$B' already set to '$value'"
	#	fi
	#	B=${B,,}
	#	eval value=\$$B
	#	if [ -n "$value" ]; then
	#		say_die "control variable '$B' already set to '$value'"
	#	fi
	#done

	declare -A __valid_types__
	__valid_types__=(	\
		[b]="bool"		\
		[i]="integer"	\
		[s]="string"	\
		[a]="array"		\
		[c]="counter"	\
		[e]="extend"	\
	)

	((OPTION_I=-1))

	__DEPTH_CHARGE__=${__DEPTH_CHARGE__:-0}
	__NO_ABBREVIATIONS__=${__NO_ABBREVIATIONS__:-0}
	#__NO_OVERWRITE__=${__NO_OVERWRITE__:-0}

	# Loop over all command line options

	for ((PIECE_I=0;PIECE_I<${#__CMD_LINE_PIECES__[@]};PIECE_I++)); do
		A=${__CMD_LINE_PIECES__[$PIECE_I]}

		if [ "$A" = "--" ]; then				# Terminate search for option
												# (everything following this goes into __ARGV__)
			options_set_missing_value
			search_terminated=1

		elif [ $search_terminated -eq 1 ]; then	# Everything after '--' is non-option

			if [ "$A" != "--" ]; then
				((OPTION_I++))
				__ARGS__[$OPTION_I]=$A			# ?? what if this contains white space
				say_add2var __ARGV__ "$A"
			fi

		elif [[ $A =~ ^-- ]]; then				# Start of long option

			options_set_missing_value			# For preceeding keyword

			# Check for cmd-line syntax with equal sign separating
			# key and value: key=value

			key="${A%=*}"						# Part before equal sign (if present)
			options_set_key "$key"
			((__NKEYS__++))
			if [[ "$A" =~ = ]]; then			# Equal sign present
				[ $__one_type__ = b ] && say_die "boolean option '$__one_name__' followed by '=' sign"
				options_set_value "${A#*=}" set	# Value is part following = sign
			elif [[ bc =~ $__one_type__ ]]; then	# Boolean and counter never has a value
				options_set_missing_value
			fi

		elif [[ $A =~ ^- ]]; then				# Start of short option

			options_set_missing_value			# For preceeding keyword

			# The first char in $key is the dash (-).
			# If $key is more than two chars long, it is a concatenation
			# of multiple short options. Process $key one char at a time.
			# All except the last char in the concatenation must be boolean.

			local c=${A%=*}						# Part before equal sign
												# (whole $A if no equal sign present)
			local c=${#c}						# Number of chars in $A before equal sign
			((c--))								# Do not process the last char just yet

			local p=0
			if [ $c -eq 0 ]; then				# No char after dash
				key="-"
			else								# At least one char after dash
				local p=1						# Start at 2nd char (after dash)
				while [ $p -lt $c ]; do			# Process all short options in $key
					key="-${A:$p:1}"
					options_set_key "$key"
					((__NKEYS__++))
					[[ sae =~ $__one_type__ ]] && say_die "'${__valid_types__[$__one_key__]}' option '$__one_name__' cannot be bundled in '$A'"
					options_set_missing_value
					((p++))
				done
				key="-${A:$p:1}"				 # Last short option in $A
			fi

			options_set_key "$key"		 		# Part before equal sign
			((__NKEYS__++))
			if [[ "$A" =~ = ]]; then			# Equal sign present
				[ $__one_type__ = b ] && say_die "boolean option '$__one_name__' followed by '=' sign"
				options_set_value "${A#*=}" set	# Value is part following = sign
			elif [[ bc =~ $__one_type__ ]]; then	# Boolean and counter never has a value
				options_set_missing_value
			fi

		else

			# $A does not start with a dash or double-dash so is either
			# a value or a part of argv

			if [ -z "$__one_type__" ]; then
				((OPTION_I++))
				__ARGS__[$OPTION_I]=$A
				say_add2var __ARGV__ "$A"
			elif [ $__one_type__ = __depth_charge__ ]; then
				say_die "unable to unambiguously assign '$A' as value of depth-charge '$__one_name__'"
			else
				options_set_value "$A" set
			fi

		fi

	done

	#[ -n "$__one_type__" ] && say_warn "cleanup of '$__one_type__' option '$__one_name__'"
	options_set_missing_value

	# Loop over all options looking for options for which the control
	# variable has not been set yet. This means that the option was
	# not specified on the cmd line.
	# Set the control variable to '$__one_default__'. This should
	# always exist; it is set in options_set_key.

	for A in ${!__OPTION__[*]}; do
		options_base_arg "$A"
		options_set_key "$base_arg"
		# Should never happen
		[ $__one_type__ = "__depth_charge__" ] && say_die "'$base_arg' is depth charge?"
		say_in_use $__one_control__ && options_clear_key || options_set_value "$__one_default__"
	done

	__NARGS__=${#__ARGS__[@]}

	[ ${__HELP__:-0}    -eq 1 ] && options_help		# Exits if --help is set
	[ ${__VERSION__:-0} -eq 1 ] && options_version	# Exits if --version is set

	# Resolve inconsistencies between --verbose and --debug
	# --verbose takes precedence if it is set

	if [ $__VERBOSE__ -eq 0 ]; then		# --verbose not set
		if [ $__DEBUG__ -gt 0 ]; then	# --debug is set
			__VERBOSE__=$__DEBUG__
			__verbose__=""
			for ((PIECE_I=0;PIECE_I<$__VERBOSE__;PIECE_I++)); do
				say_add2var __verbose__ --verbose
			done
		fi
	else								# --verbose is set
		__DEBUG__=$__VERBOSE__
		__debug__="--debug $__DEBUG__"
    fi

	[ $__VERBOSE__ -eq $__DEBUG__ ] || say_die "__VERBOSE__=$__VERBOSE__ different from __DEBUG__=$__DEBUG__"
	# From here on $__VERBOSE__ equal $__DEBUG__.

	# To see the output from the print messages set --debug 2 or 3

	__CMD_LINE__=`basename $0`

	say_message ">>>>>>>>>>" 4

	local key_found=0
	local arg
	for A in ${!__OPTION__[*]}; do
		options_set_key $A
		eval arg=\$$__one_argument__
		local message
		#if [ -n "$arg" ]; then
			((key_found++))
			if [ $__one_type__ = a ]; then
				eval local keys=\${!$__one_control__[*]}
				for B in $keys; do
					eval message=\"$__one_control__[$B]=\${$__one_control__[$B]}\"
					say_message_bare "    $message" 4
				done
				eval message=\"$__one_control__ has \${#$__one_control__[@]} elements set \($one_argument=\'\$arg\'\)\"
			else
				eval message=\"\$__one_control__=\$$__one_control__ \($__one_argument__=\'\$arg\'\)\"
			fi
			say_message_bare "$message" 4
			say_message_bare "    ${__DESCRIPTION__[$A]}" 4
			say_add2var __CMD_LINE__ "$arg"
		#else
		#	if [ $__one_type__ = a ]; then
		#		eval local keys=\${!$__one_control__[*]}
		#		for B in $keys; do
		#			eval message=\"$__one_control__[$B]=\${$__one_control__[$B]}\"
		#			say_message_bare "    $message" 5
		#		done
		#		message=$__one_control__
		#		eval arg=\${#$__one_control__[@]}
		#		[ $arg -ne 0 ] && message+=" has $arg element(s) set ($A)" || message+=" not set ($A)"
		#	else
		#		message=$__one_control__
		#		eval arg=\$$__one_control__
		#		[ -n "$arg" ] && message+="=$arg ($A)" || message+=" not set ($A)"
		#	fi
		#	say_message_bare "$message" 5
		#	say_message_bare "   *${__DESCRIPTION__[$A]}" 5
		#fi
		options_clear_key
	done
	[ $key_found -eq 0 ] && say_message_bare "no options set" 4 || say_message_bare "$key_found option(s) set" 4
	say_message_bare "" 4
	say_message_bare "remaining (unprocessed) arguments returned in __ARGV__:" 4
	[ -n "$__ARGV__" ] && say_message_bare "    __ARGV__='$__ARGV__'" 4 || say_message_bare "    (none)" 4
	if [ $__DEPTH_CHARGE__ -eq 1 ]; then
		say_message_bare "" 4
		[ -n "$__depth_charge__" ] && say_message_bare "__depth_charge__='$__depth_charge__'" 4 || say_message_bare "__depth_charge__='(none)'" 4
	fi

	say_message "<<<<<<<<<<" 4
	say_add2var __CMD_LINE__ "$__ARGV__"
	say_message "$__CMD_LINE__" 4
	say_message "<<<<<<<<<<" 4

	if [ -n "$__CMD_LINE_LOG__" ]; then
		[ ! -f $__CMD_LINE_LOG__ -o -w $__CMD_LINE_LOG__ ] && echo "`date +\"%Y-%m-%d %H:%M:%S\"`  $__CMD_LINE__" >> $__CMD_LINE_LOG__
	fi

	# For backward compatibility
	VERBOSE=$__VERBOSE__
	DEBUG=$__DEBUG__
	DRYRUN=$__DRY_RUN__
	verbose=$__verbose__
	debug=$__debug__
	dryrun=$__dry_run__

	options_cleanup
	unset options_cleanup
	# get_options needs to unset by caller
}

# These lines get executed when the calling script sources this script using
#	. get_options
# This is the only way I could figure out to retain quoted, multi-word
# cmd line argument as a single entity

__DRY_RUN__=0
__VERBOSE__=0
__DEBUG__=0
__verbose__=""
__dry_run__=""
__debug__=""

if [ "$0" = "-bash" -o "$0" = "bash" ]; then
	__CALLER__="bash"
	__BIN_DIR=""

	options_cleanup
	unset options_cleanup
	unset get_options

else
	__CALLER__=`basename $0 .sh`

	# Set full absolute path to this script to __BIN_DIR__

	__BIN_DIR__=`dirname $0`
	__BIN_DIR__=`realpath $__BIN_DIR__`

fi
__BINDIR__=$__BIN_DIR__		# backward compatibility

declare -i __NARGS__=0
declare -i __NKEYS__=0
declare -a __ARGS__
__ARGV__=""

declare -A __OPTION__
declare -A __DESCRIPTION__

declare -a __CMD_LINE_PIECES__

i=-1
v=$1
shift		# Will exit with 1 if there was no $1
while [ $? -eq 0 ]; do
	((i++))
	 __CMD_LINE_PIECES__[$i]=$v
	v=$1
	shift
done
unset i
unset v
