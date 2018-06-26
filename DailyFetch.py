#!/usr/bin/python
# *******************************************
# AUTHOR: Li Seven
# MAIL: stoneboy100200@126.com
# BRIEF: Fetch src code from remote everyday
# *******************************************

import os,subprocess,sys

NINCG3_PATH="D:/NavRepoVS2013/nincg3"
if not os.path.exists(NINCG3_PATH):
   print "[Error] %s doesn't exist!" %NINCG3_PATH
   sys.exit()

os.chdir(NINCG3_PATH)
print "Repository:", os.getcwd()
subprocess.call(["git", "fetch", "origin", "rn_aivi_16.3_stabi"])