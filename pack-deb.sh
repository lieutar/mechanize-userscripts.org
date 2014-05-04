#!/bin/bash

HERE="`pwd`"

DIR="`pwd | sed "s/.*\///g"`"   # relative paths
DIR_PACKING="$DIR-deb-packing"

VERSION="`grep "^version" Makefile.PL | sed "s/.*'\([\.0-9]*\)'.*/\1/g"`"
PACKAGE="`grep "^name" Makefile.PL | sed "s/.*'\([\.0-9A-Za-z-]*\)'.*/\1/g"`"

(
    cd ..

    mkdir "$DIR_PACKING" || exit 1
    cp -r "$DIR" "$DIR_PACKING/" || exit 1
    cd "$DIR_PACKING/$DIR"

    rm -rf .git
    rm -rf debian
    
) || (

    cd "$HERE"
    echo "Error when moving"
    echo "Maybe you want to do 'rm -rf ../$DIR_PACKING'"
    exit 1
)

if [ $? -eq 1 ]; then exit 1; fi

#sudo apt-get install dh-make-perl
# ?
#sudo cpan DhMakePerl

#sudo apt-get install apt-file
#sudo apt-file update

(
    #pwd
    
    cd ..
    cd "$DIR_PACKING/$DIR"

    make dist || exit 1
    mv "$PACKAGE-$VERSION.tar.gz" "../${PACKAGE}_${VERSION}.orig.tar.gz"
    dh-make-perl -p "$PACKAGE" --source-format 1 --arch i386 || exit 1
    
) || (

    cd "$HERE"
    echo "Error when generating dist or 'debian/*' files"
    exit 1
)

if [ $? -eq 1 ]; then exit 1; fi

(
    cd ..
    cd "$DIR_PACKING/$DIR"
    mv .git ../git-backup
    
    dpkg-buildpackage -ai386 -uc -us
    
    cd ..
    
    echo   
    echo "$ ls -1 `pwd`"
    ls -1

) || (

    cd "$HERE"
    echo "Error when generating .deb files"
    exit 1

)

if [ $? -eq 1 ]; then exit 1; fi

echo
echo "$ pwd"
pwd
echo

