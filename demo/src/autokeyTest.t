#charset "us-ascii"
//
// autokeyTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the simpleCipher library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f autokeyTest.t3m
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
		local r, str, key;

		str = 'There is a small mailbox here.';
		key = 'froboz';

		r = autokey.encode(str, key);
		"encode = <<toString(r)>>\n ";
		r = autokey.decode(r, key);
		"decode = <<toString(r)>>\n ";
	}
;
