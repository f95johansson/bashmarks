INSTALL_DIR=~/.local/bin

all:
	@echo "Please run 'make install'"

install:
	@echo ""
	mkdir -p $(INSTALL_DIR)
	cp bashmarks.sh $(INSTALL_DIR)
	@echo ""
	@echo "Please add 'source $(INSTALL_DIR)/bashmarks.sh' to your .bashrc file"
	@echo ''
	@echo 'USAGE:'
	@echo '------'
	@echo 'mark  <bookmark_name> - Saves the current directory as "bookmark_name"'
	@echo 'jump  <bookmark_name> - Goes (cd) to the directory associated with "bookmark_name"'
	@echo 'markd <bookmark_name> - Deletes the bookmark'
	@echo 'markl                 - Lists all available bookmarks'
	@echo ''
	@echo 'use --help or -h after any of the commands for more information'
