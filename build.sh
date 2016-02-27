#!/bin/bash

if [ "$1" == "TEST" ]
then
	TEST=true
fi

rm -rf work
mkdir work
mkdir work/tools

MAXBUILD=0

for FILE in `find ../DevAudit.Windows-1.1.x/DevAudit-1.1.*.zip -type f`
do
	PATH=(${FILE//\// })
	FNAME=${PATH[2]}
	TOKENS=(${FNAME//-/ })
	TOKEN=${TOKENS[1]}
	VERSION=(${TOKEN//./ })
	MAJOR=${VERSION[0]}
	MINOR=${VERSION[1]}
	BUILD=${VERSION[2]}
	
	if [ $BUILD -gt $MAXBUILD ]
	then
		MAXBUILD=$BUILD
	fi
done

echo "VERSION: $MAJOR.$MINOR.$MAXBUILD"
MD5=`/usr/bin/md5sum ../DevAudit.Windows-1.1.x/DevAudit-$MAJOR.$MINOR.$MAXBUILD.zip | /usr/bin/gawk '{print $1}'`
 
/usr/bin/sed -e "s/{{VERSION}}/$MAJOR.$MINOR.$MAXBUILD/" devaudit.nuspec > work/devaudit.nuspec
/usr/bin/sed -e "s/{{VERSION}}/$MAJOR.$MINOR.$MAXBUILD/g" -e "s/{{MD5}}/$MD5/g" -e 's/#.*$//' -e '/^[[:space:]]*$/d' tools/chocolateyinstall.ps1 > work/tools/chocolateyinstall.ps1

cd work
/c/ProgramData/chocolatey/bin/cpack

# Test the install
if [ "$TEST" != "" ]
then
	/c/ProgramData/chocolatey/bin/cinst -y devaudit -source `pwd`
	/c/ProgramData/chocolatey/bin/cuninst devaudit
else
	echo "BUILD UNTESTED"
fi

cd ..
