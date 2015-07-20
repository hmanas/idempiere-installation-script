#!/bin/bash
# Created Version 1 Chuck Boecking
# 1.1 - Chuck Boecking - update to run repeatedly in cron to create daily commits
# 1.2 - Chuck Boecking - refactor to run in separate directory

######################################
# The purpose of this script is to help make sure the idempiere server directory only changes when you desire it.
# In other words, you should be able to quick unwind changes caused by accident, hacks, and malicious behavior.
# This script basically adds the server directory to an hg (mercurial) repository. 
# You can then push change logs to a remote mercurial repository like bitbucket.org
# If a hacker compromises your site, just unwind their changes using standard mercurial commands.
######################################

#Bring chuboe.properties into context
source chuboe.properties
INSTALLPATH=$CHUBOE_PROP_IDEMPIERE_PATH
IGNORENAME="$INSTALLPATH/.hgignore"
HGNAME="$INSTALLPATH/.hg/hgrc"
IDEMPIEREUSER=$CHUBOE_PROP_IDEMPIERE_OS_USER
CHUBOE_UTIL=$CHUBOE_PROP_UTIL_PATH
CHUBOE_UTIL_HG=$CHUBOE_PROP_UTIL_HG_PATH
CHUBOE_UTIL_HG_TEMP_HGRC="$CHUBOE_UTIL_HG/chuboe_temp/hgrc"
CHUBOE_UTIL_HG_TEMP_IGNORE="$CHUBOE_UTIL_HG/chuboe_temp/.hgignore"

# Check to see if the repository already exists
cd $INSTALLPATH
RESULT=$(ls -l $HGNAME | wc -l)
if [ $RESULT -ge 1 ];
then
	echo "HERE: $IGNORENAME already exists"
	echo "HERE: perform addremove and commit"
	sudo -u $IDEMPIEREUSER hg addremove
	sudo -u $IDEMPIEREUSER hg commit -m "Regular Commit"
else
	# create repository
	sudo -u $IDEMPIEREUSER hg init
	echo "HERE: creating $HGNAME file"
	echo "[ui]">$CHUBOE_UTIL_HG_TEMP_HGRC
	echo "username = iDempiere Master">>$CHUBOE_UTIL_HG_TEMP_HGRC
	echo "">>$CHUBOE_UTIL_HG_TEMP_HGRC
	echo "[extensions]">>$CHUBOE_UTIL_HG_TEMP_HGRC
	echo "purge =">>$CHUBOE_UTIL_HG_TEMP_HGRC
	echo "hgext.mq =">>$CHUBOE_UTIL_HG_TEMP_HGRC
	echo "extdiff =">>$CHUBOE_UTIL_HG_TEMP_HGRC
	sudo mv $CHUBOE_UTIL_HG_TEMP_HGRC $HGNAME
	sudo chown $IDEMPIEREUSER:$IDEMPIEREUSER $HGNAME

	echo "HERE: creating $IGNORENAME file"
	echo "syntax: glob" > $CHUBOE_UTIL_HG_TEMP_IGNORE
	echo "log" >>  $CHUBOE_UTIL_HG_TEMP_IGNORE
	echo "data/*.jar" >>  $CHUBOE_UTIL_HG_TEMP_IGNORE
	echo "data/*.dmp" >>  $CHUBOE_UTIL_HG_TEMP_IGNORE
	echo "*.tmp*" >>  $CHUBOE_UTIL_HG_TEMP_IGNORE
	sudo mv $CHUBOE_UTIL_HG_TEMP_IGNORE $IGNORENAME
	sudo chown $IDEMPIEREUSER:$IDEMPIEREUSER $IGNORENAME

	cd $INSTALLPATH
sudo -u $IDEMPIEREUSER hg add
	sudo -u $IDEMPIEREUSER hg commit -m "Initial Commit"

fi #end if .hgrc file exists

# (2) when you create a private remote repository, uncommend the below command and update the URL
# sudo -u $IDEMPIEREUSER hg push www.url_to_remote_repository

# to see what has changed since the last commit, issue: hg status
# if you ever want to undo a change that has not been committed, you can issue: hg revert --all (you can also use hg purge)
# if you want to revert to a previous commit, you can use: hg revert --all --rev [xxx]
# for more information, here is a great summary: http://stackoverflow.com/questions/2540454/mercurial-revert-back-to-old-version-and-continue-from-there
