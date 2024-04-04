#charset "us-ascii"
//
// vigenereTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the simpleCipher library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f vigenereTest.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

#include "simpleCipher.h"

versionInfo: GameID;
gameMain: GameMainDef
	newGame() {
		local r;

		r = vigenere.encode('There is a small mailbox here.',
			'foozle');
		"encode = <<toString(r)>>\n ";
		r = vigenere.decode(r, 'foozle');
		"decode = <<toString(r)>>\n ";
	}
;
