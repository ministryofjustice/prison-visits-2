#!/bin/bash

# Usage:
#    $> cd /path/to/repository
#    $> ln -s ../../config/git-hooks/pre-commit.sh .git/hooks/pre-commit
#

################################################################################
# https://github.com/AGWA/git-crypt/issues/45#issuecomment-151985431
# Pre-commit hook to avoid accidentally adding unencrypted files which are
# configured to be encrypted with [git-crypt](https://www.agwa.name/projects/git-crypt/)
# Fix to [Issue #45](https://github.com/AGWA/git-crypt/issues/45)
#
test -d .git-crypt && git-crypt status &>/dev/null
if [[ $? -ne 0 ]]; then
  echo "git-crypt has some warnings"
  git-crypt status -e
  exit 1
fi


################################################################################
# Check for any filenames containing "secret" in the list of files which are not
# encrypted with git-crypt:
#
git-crypt status -u | grep secret
# grep returns 0 if it finds some matches and 1 if there are no matches:
if [[ $? -eq 0 ]]; then
  echo "Found a secrets file which is not encrypted with git-crypt"
  echo "Did you mean to add this file to the git-crypt config in .gitattributes?"
  exit 1
fi
