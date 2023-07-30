#!/bin/bash
if [ -f "./.bashrc" ] ; then
	cp -i ./.bashrc ~/.bashrc
fi
if [ -f "./.bash_profile" ] ; then
	cp -i ./.bash_profile ~/.bash_profile
fi
if [ -f "./.vimrc" ] ; then
	cp -i ./.vimrc ~/.vimrc
fi

