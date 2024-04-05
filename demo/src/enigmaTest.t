#charset "us-ascii"
//
// enigmaTest.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the simpleCipher library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f enigmaTest.t3m
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
		_testEnigma('SECRET');
	}

	_testEnigma(txt) {
		local cfg, v;

		cfg = new EnigmaConfig();

		cfg.setRing('XMV');
		cfg.setKey('ABL');
		cfg.setRotors([ 'II', 'I', 'III' ]);
		cfg.setReflector('A');
		cfg.setPlugboard([ 'AM', 'FI', 'NV', 'PS', 'TU',
			'WZ' ]);

		"enigma: \n";
		"\tplaintext: <<toString(txt)>>\n ";
		v = enigma.encode(txt, cfg);
		"\tencode = <<toString(v)>>\n ";
		v = enigma.decode(toString(v), cfg);
		"\tdecode = <<toString(v)>>\n ";

		return(true);
	}
;
