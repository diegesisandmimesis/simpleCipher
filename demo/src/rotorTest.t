#charset "us-ascii"
//
// rotorTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the simpleCipher library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f rotorTest.t3m
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
	rotor = nil

	newGame() {
		local off, v;

		rotor = enigma.getRotor('II');

		off = 11;
		v = _enc('W', off);
		_dec(v, off);

		//v = _enc('W', off);
		//_dec(v, off);
	}

	_enc(v, off?) {
		local r;

		r = rotor.getRL(v, off);
		"<<toString(v)>> -> <<toString(r)>>\n ";
		return(r);
	}

	_dec(v, off?) {
		local r;

		r = rotor.getLR(v, off);
		"<<toString(v)>> -> <<toString(r)>>\n ";
		return(r);
	}
;
