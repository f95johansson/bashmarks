Bashmarks
=====

Bashmarks is a shell script that allows you to save and jump to commonly used directories with tab completion. Also works with zsh

Extra Features
--------------

* default directory when using `jump` - default `$HOME`.
* Allows placing commands after the the letter e.g `jump webfolder ls` would go the webfolder bookmark then perform `ls`
* `jump -` Goes to the previous directory.
* `marko` command to open the bookmark in Finder (Mac OS X Only).
* `markt` command to open the bookmark in a new tab (Mac OS X Only).
* the `markt` command works with Terminal and ITerm2

Install
-------

##### Either (from terminal):
1. git clone https://github.com/f95johansson/bashmarks.git
2. cd bashmarks
2. make install
3. **source ~/.local/bin/bashmarks.sh** from within your **~.bash\_profile** or **~/.bashrc** file

##### or simply
1. Download the project (zip)
2. move the bashmarks.sh to somewhere in your path `$PATH` and source it
3. **source ~/.local/bin/bashmarks.sh** from within your **~.bash\_profile** or **~/.bashrc** file

Shell Commands
--------------

	mark  <bookmark_name>  - Saves the current directory as "bookmark_name"
	jump  <bookmark_name>  - Goes (cd) to the directory associated
                             with "bookmark_name"
	markd <bookmark_name>  - Deletes the bookmark'

	mark                   - Saves the current directory with its name
	mark -t                - Saves the current directory with as a temp,
                             only for this session
	jump                   - Goes to the $HOME directory
	jump -t                - Goes to the temp bookmark
	jump -                 - Goes to the previous directory
	markl                  - Lists all available bookmarks
	markl -n               - Lists all, only name
	markl -c               - Lists all, without formatting
	markl <prefix>         - Lists the bookmark starting with "prefix"
	markp <bookmark_name>  - Prints the directory associated with "bookmark_name"
	markpd <bookmark_name> - Same as "mark" but uses pushd
	
	# Mac OS X Only
	marko <bookmark_name> - Open the directory associated with "bookmark_name"
                            in Finder
	markt <bookmark_name> - Open the directory associated with "bookmark_name"
	                        in a new tab'


Example Usage
-------------
<pre>
$ cd /var/www/
$ mark webfolder
$ cd /usr/local/lib/
$ mark locallib
$ markl
	<b>webfolder</b>	/var/www/
	<b>locallib</b>		/usr/local/lib/
$ mark web&lt;tab&gt;       # autocomplete
$ mark webfolder	  # cd to /var/www/
$ marko webfolder	  # Open in Finder if on mac
$ markl locallib
	<b>locallib</b>		/usr/local/lib/
</pre>
		
Options
-------

Set `BASHMARKS_ITERM_SESSION` to a session name to change the session that is launched when using `markt` in iTerm2 on `osx` 

        
Where Bashmarks are stored
--------------------------
    
All of your directory bookmarks are saved in a file called `.bashmarks` in your `$HOME` directory by default.

Authors
-------
* Fredrik Johansson
* Bilal Syed Hussain
* Huy Nguyen (original version)

