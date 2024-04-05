#charset "us-ascii"
//
// enigmaTest2.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the simpleCipher library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f enigmaTest2.t3m
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
		local cfg, msg, v;

		cfg = new EnigmaConfig();
		cfg.setRing('AAA');
		cfg.setKey('AAA');
		cfg.setRotors([ 'II', 'I', 'III' ]);
		cfg.setReflector('B');
		cfg.padOutput = true;

		enigma.setConfig(cfg);
		//enigma._config._debugOffsets();
		

		msg = 'AAAAAAAAAAAAAAAAAAAAAAAAAA';
		"plaintext = <<msg>>\n ";
		v = enigma.encode(msg, cfg);
		"encode = <<v>>\n ";
		v = enigma.decode(v, cfg);
		"encode reverse = <<v>>\n ";
	}
;
