#charset "us-ascii"
//
// sample.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the simpleCipher library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f makefile.t3m
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
		_testCipher(base64, 'foozle');
		"<.p> ";
		_testCipher(rot13, 'Foozle!');
		"<.p> ";
		_testCipher(caesar, 'Foozle!', -3);
	}

	_testCipher(obj, str, arg?) {
		local v;

		"<<obj.cipherID>>:\n ";
		if(arg)
			v = obj.encode(str, arg);
		else
			v = obj.encode(str);
		"\tencode: <<toString(v)>>\n ";

		if(arg)
			v = obj.decode(v, arg);
		else
			v = obj.decode(v);
		"\tdecode: <<toString(v)>>\n ";
	}
;
