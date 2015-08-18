# Copyright (c) 2010, Huy Nguyen, http://www.huyng.com
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are permitted provided 
# that the following conditions are met:
# 
#     * Redistributions of source code must retain the above copyright notice, this list of conditions 
#       and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
#       following disclaimer in the documentation and/or other materials provided with the distribution.
#     * Neither the name of Huy Nguyen nor the names of contributors
#       may be used to endorse or promote products derived from this software without 
#       specific prior written permission.
#       
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED 
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR 
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.


# This is a fork of bashmarks with extra features
# by Bilal Syed Hussain https://github.com/Bilalh/shellmarks
# based of https://github.com/huyng/bashmarks

# Edited by Fredrik Johansson

# USAGE:
# bashmark <bookmark_name> - Saves the current directory as "bookmark_name"
# mark <bookmark_name>     - Goes (cd) to the directory associated with "bookmark_name"
# markd <bookmark_name>    - Deletes the bookmark

# markl                    - Lists all available bookmarks
# markl <prefix>           - Lists the specified bookmarks starting with prefix"
# markpd <bookmark_name>   - pd is the same as `g` but uses pushd
# bashmark                 - Saves the default directory
# mark                     - Goes to the default directory
# mark -                   - Goes to the previous directory
# markp <bookmark_name>    - Prints the directory associated with "bookmark_name"

# Mac only (disabled on other systems)
# marko <bookmark_name>    - Open the directory associated with "bookmark_name" in Finder
# markt <bookmark_name>    - Open the directory associated with "bookmark_name" in a new tab

# There is tab completion for all commands

# setup file to store bookmarks
if [ ! -n "$BASHMARKS_SDIRS" ]; then
	BASHMARKS_SDIRS=~/.bashmarks
fi
touch $BASHMARKS_SDIRS


## Public Functions

# save current directory to bookmarks
function bashmark {
	BASHMARKS_help $1
	BASHMARKS_bookmark_name_valid "$@"
	if [ -z "$BASHMARKS_exit_message" ]; then
		if [ -z "$@" ]; then
			BASHMARKS_purge_line "$BASHMARKS_SDIRS" "export DIR_DEFAULT="
			local CURDIR=$(echo $PWD| sed "s#^$HOME#\$HOME#g")
			echo "export DIR_DEFAULT=\"$CURDIR\"" >> $BASHMARKS_SDIRS
		else
			BASHMARKS_purge_line "$BASHMARKS_SDIRS" "export DIR_$1="
			local CURDIR=$(echo $PWD| sed "s#^$HOME#\$HOME#g")
			echo "export DIR_$1=\"$CURDIR\"" >> $BASHMARKS_SDIRS
		fi
	fi
}

# jump to bookmark
function mark {
	BASHMARKS_help $1
	source $BASHMARKS_SDIRS
	if [ -z $1 ]; then
		cd "$(eval $(echo echo $(echo \$DIR_DEFAULT)))"
		BASHMARKS__print_pwd_on_action; $*
	elif [[ "$1" == "-" ]]; then
		cd $1;
		shift; $*
	elif [[ "$1" == ".."  || "$1" == '~' || "$1" == '/' ]]; then
		cd $1;
		BASHMARKS__print_pwd_on_action; shift; $*
	else
		cd "$(eval $(echo echo $(echo \$DIR_$1)))"
		BASHMARKS__print_pwd_on_action; shift; $*
	fi
	BASHMARKS__unset_dirs
}

# pushd to bookmark
function markpd {
	BASHMARKS_help $1
	source $BASHMARKS_SDIRS
	if [ -z $1 ]; then
		pushd "$(eval $(echo echo $(echo \$DIR_DEFAULT)))"
		BASHMARKS__print_pwd_on_action; $*
	elif [[ "$1" == "-" ]]; then
		pushd $1;
		shift; $*
	elif [[ "$1" == ".."  || "$1" == '~' || "$1" == '/' ]]; then
		pushd $1;
	else
		pushd "$(eval $(echo echo $(echo \$DIR_$1)))"
	fi
	BASHMARKS__unset_dirs
}

# print bookmark
function markp {
	BASHMARKS_help $1
	source $BASHMARKS_SDIRS
	echo "$(eval $(echo echo $(echo \$DIR_$1)))"
	BASHMARKS__unset_dirs
}

# delete bookmark
function markd {
	BASHMARKS_help $1
	BASHMARKS_bookmark_name_valid "$@"
	if [ -z "$BASHMARKS_exit_message" ]; then
		BASHMARKS_purge_line "$BASHMARKS_SDIRS" "export DIR_$1="
		unset "DIR_$1"
	fi
	BASHMARKS__unset_dirs
}

## OS X Specific
if [[ "`uname`" == "Darwin" ]]; then

# open the specifed bookmark
function marko {
	if [ -z $1 ]; then
		open .
		osascript -e 'tell application "Finder"' -e 'activate' -e 'end tell'
	else
		BASHMARKS_help $1
		source $BASHMARKS_SDIRS
		open "$(eval $(echo echo $(echo \$DIR_$1)))"
		cd "$(eval $(echo echo $(echo \$DIR_$1)))"
		BASHMARKS__print_pwd_on_action; shift; $*
		osascript -e 'tell application "Finder"' -e 'activate' -e 'end tell'
	fi
	BASHMARKS__unset_dirs
}

#jump to bookmark in a new tab in the current window
function markt {
	BASHMARKS_help $1
	source $BASHMARKS_SDIRS
	if [ -z $1 ]; then
		local dst="`pwd`"
	elif [[ "$1" == "-" || "$1" == ".." || "$1" == '~' ||  "$1" == '/' ]]; then
		local dst="$1";
		shift
	else
		local dst="$(eval $(echo echo $(echo \$DIR_$1)))"
		shift
	fi

	if [ $BASHMARK_TERM_APP ]; then
		current_app="$BASHMARK_TERM_APP"
	else
		current_app="$(osascript -e 'tell application "System Events" to get item 1 of (get name of processes whose frontmost is true)')"
	fi
	if [ ${current_app:0:5} = "iTerm" ]; then
		osascript > /dev/null 2>&1 <<APPLESCRIPT
			tell application "${current_app}"
				tell the current terminal
					activate current session
					launch session "${BASHMARKS_ITERM_SESSION:-Default}"
					tell current session
						# does not seem to allow multiple commands
						write text "cd $dst;"
					end tell
				end tell
			end tell
APPLESCRIPT
	else
	osascript > /dev/null 2>&1 <<APPLESCRIPT
		tell application "System Events"
				tell process "Terminal" to keystroke "t" using command down
		end tell
		tell application "Terminal"
				activate
				do script with command "cd $dst; $*" in window 1
		end tell
APPLESCRIPT

	fi
	BASHMARKS__unset_dirs
}

fi # end of OS X specific


# list bookmarks with dirname
function markl {
	BASHMARKS_help $1
	source $BASHMARKS_SDIRS
	
	if [ "$1" = "-n" ]; then
		BASHMARKS_markl_only_bookmark_name
	
	elif [ "$1" = "-c" ]; then
		BASHMARKS_markl_no_colour
	
	elif [  -n "$1" ]; then
		# if color output is not working for you, comment out the line below '\033[1;34m' == "bold blue" '\033[1m' == "bold" 
		env | sort | grep "DIR_$1" |  awk '/DIR_.+/{split(substr($0,5),parts,"="); printf("\033[1m%-20s\033[0m %s\n", parts[1], parts[2]);}'
		# uncomment this line if color output is not working with the line above
		# env | grep "^DIR_" | cut -c5-	 | grep "^.*=" | sort
	else
		# if color output is not working for you, comment out the line below '\033[1;34m' == "blue" '\033[1m' == "bold" 
		env | sort | awk '/DIR_.+/{split(substr($0,5),parts,"="); printf("\033[1m%-20s\033[0m %s\n", parts[1], parts[2]);}'
		# uncomment this line if color output is not working with the line above
		# env | grep "^DIR_" | cut -c5-	 | grep "^.*=" | sort
	fi
	BASHMARKS__unset_dirs
}


## Private functions

# print out help for the forgetful
function BASHMARKS_help {
	if [ "$1" = "-h" ] || [ "$1" = "-help" ] || [ "$1" = "--help" ] ; then
		echo ''
        echo 'Bashmarks by Huy Nguyen © 2010, modified by Bilal Syed Hussain,'
        echo '                                edited by Fredrik Johansson'
        echo ''
		echo 'bashmark <bookmark_name> - Saves the current directory as "bookmark_name"'
		echo 'mark     <bookmark_name> - Goes (cd) to the directory associated'
        echo '                           with "bookmark_name" '
		echo 'markd    <bookmark_name> - Deletes the bookmark'
		if [ "`uname`" = "Darwin" ]; then
			echo 'marko    <bookmark_name> - Open the directory associated with "bookmark_name"'
            echo '                           in Finder'
			echo 'markt    <bookmark_name> - Open the directory associated with "bookmark_name"'
            echo '                           in a new tab'
			echo ''
		fi
		echo 'bashmark                 - Saves the default directory'
		echo 'mark                     - Goes to the default directory'
		echo 'markl                    - Lists all available bookmarks'
        echo 'markl -n                 - Lists all, only name'
        echo 'markl -c                 - Lists all, without formatting'
		echo 'markl <prefix>           - Lists the bookmark starting with "prefix"'
		echo 'markp <bookmark_name>    - Prints the directory associated with "bookmark_name"'
		echo 'markpd <bookmark_name>   - Same as "mark" but uses pushd'
		if [ $BASHMARKS_k ]; then
			echo ''
			echo 'markk <bookmark_name>    - Tries use "g", if the bookmark does not'
            echo "                           exist try autojump's j"
		fi
		kill -SIGINT $$
	fi
}

function BASHMARKS__unset_dirs {
	eval `sed -e 's/export/unset/' -e 's/=.*/;/' $BASHMARKS_SDIRS | xargs`
}

function BASHMARKS__print_pwd_on_action {
	 [ -z "$BASHMARKS_NO_PWD" ] && pwd
}

function BASHMARKS_markl_no_colour {
	source $BASHMARKS_SDIRS
	env | grep "^DIR_" | cut -c5-	 | grep "^.*=" | sort
	BASHMARKS__unset_dirs
}

# list bookmarks without dirname
function BASHMARKS_markl_only_bookmark_name {
	source $BASHMARKS_SDIRS
	env | grep "^DIR_" | cut -c5- | sort | grep "^.*=" | cut -f1 -d "="
	BASHMARKS__unset_dirs
}

# validate bookmark name
function BASHMARKS_bookmark_name_valid {
	BASHMARKS_exit_message=""
	if [ "$1" != "$(echo $1 | sed 's/[^A-Za-z0-9_]//g')" ]; then
		BASHMARKS_exit_message="bookmark name is not valid"
		echo $BASHMARKS_exit_message
	fi
}

# completion command
function BASHMARKS_comp {
	local curw
	COMPREPLY=()
	curw=${COMP_WORDS[COMP_CWORD]}
	COMPREPLY=($(compgen -W '`BASHMARKS_markl_only_bookmark_name`' -- $curw))
	return 0
}

# ZSH completion command
function BASHMARKS_compzsh {
	local reply=($(BASHMARKS_markl_only_bookmark_name))
}

# safe delete line from sdirs
function BASHMARKS_purge_line {
	if [ -s "$1" ]; then
		# safely create a temp file
		local t=$(mktemp -t bashmarks.XXXXXX) || exit 1
		trap "rm -f -- '$t'" EXIT

		# purge line
		sed "/$2/d" "$1" > "$t"
		mv "$t" "$1"

		# cleanup temp file
		rm -f -- "$t"
		trap - EXIT
	fi
}

# bind completion command for marko mark,markp,markd to BASHMARKS_comp
if [ $ZSH_VERSION ]; then
	compctl -K BASHMARKS_compzsh marko
	compctl -K BASHMARKS_compzsh mark
	compctl -K BASHMARKS_compzsh markp
	compctl -K BASHMARKS_compzsh markd
	compctl -K BASHMARKS_compzsh markt
	compctl -K BASHMARKS_compzsh markpd
else
	shopt -s progcomp
	complete -F BASHMARKS_comp marko
	complete -F BASHMARKS_comp mark
	complete -F BASHMARKS_comp markp
	complete -F BASHMARKS_comp markd
	complete -F BASHMARKS_comp markt
	complete -F BASHMARKS_comp markpd
fi

if [ $BASHMARKS_k ]; then
	# Use a bookmark if it is available otherwise try to use autojump j's command
	function markk {
		BASHMARKS_help $1

		if [ -n "$1"  ]; then
			if (grep DIR_$1 .sdirs &>/dev/null); then
				mark "$@"
			else
				markt "$@"
			fi
		else
			mark "$@"
		fi
	}

	if [ $ZSH_VERSION ]; then
		function BASHMARKS_compzsh_k {
			local cur=${words[2, -1]}
			autojump --complete ${=cur[*]} | while read i
			do
				compadd -U "$i"
			done

			for f in `BASHMARKS_markl_only_bookmark_name`;
			do
				compadd  $f
			done
		}
		compdef BASHMARKS_compzsh_k markk
	fi

fi

