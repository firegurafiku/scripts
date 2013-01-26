#!/bin/sh
HELP_MSG='''
Helper script for removing last commits from SVN repository.
Usage:

  $ svn-filter-commits.sh RANGE SVNDIR
  $ svn-filter-commits.sh --help

where
    RANGE is a colon-separated revision range like 0:42;
    SVNDIR is a path where SVN repository resides.
--
Written by Firegurafiku, Feb 2012.
Licensed under the terms of WTFPL of any version.
'''

if [ \( $# -ne 2 \) -o \( "$1" == "--help" \) ]
then
    echo "$HELP_MSG"
    exit
fi

REVS="$1"
REPO="$2"
TMPFILE=`mktemp`

{
    echo "*** Dumping existing repository to $TMPFILE (revisions $REVS) ..."
    svnadmin dump "${REPO}" -r "${REVS}" --incremental >"${TMPFILE}" 
} && { 
    REPO_BACKUP="${REPO}-backup-"`date +%F-%s`
    echo "*** Backing up existing repository to $REPO_BACKUP ..."
    mv "${REPO}" "$REPO_BACKUP"
} && {
    echo "*** Re-creating repository with old name ..."
    svnadmin create "${REPO}"
} && {
    echo "*** Loading dumped revisions back ..."
    svnadmin load "${REPO}" <"${TMPFILE}"
}

if [ -f "$TMPFILE" ]
then
    echo "*** Removing temporary file $TMPFILE ..."
    rm "${TMPFILE}"
fi

