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
	_tests = static [
		[ base64, 'There is a small mailbox here.' ],
		[ rot13, 'There is a small mailbox here.' ],
		[ caesar, 'There is a small mailbox here.', -3 ]
	]
	newGame() {
		local err;

		err = 0;
		_tests.forEach(function(o) {
			if(!_testCipher(o[1], o[2],
				((o.length > 2) ? o[3] : nil)))
				err += 1;
			"<.p> ";
		});
		if(err != 0)
			"ERROR:  Failed <<toString(err)>> of
				<<toString(_tests.length)>> tests.\n ";

		_testEnigma('There is a small mailbox here.');

		"<.p> ";

		_testMonoalphabetic('There is a small mailbox here.',
			'EKMFLGDQVZNTOWYHXUSPAIBRCJ');
	}

	_testMonoalphabetic(str, alph0) {
		local obj, v;

		obj = new SimpleCipherMonoalphabetic(alph0);
		"<<obj.cipherID>>:\n ";
		"\talphabet0: <<toString(obj._alphabet)>>\n ";
		"\talphabet1: <<toString(obj.alphabet)>>\n ";
		v = obj.encode(str);
		"\tencode: <<toString(v)>>\n ";
		v = obj.decode(v);
		"\tdecode: <<toString(v)>>\n ";
	}

	_testEnigma(txt) {
		local cfg, v;

		cfg = new EnigmaConfig();
		cfg.setRing('XMV');
		cfg.setKey('ABL');
		cfg.setRotors([ 'III', 'II', 'I' ]);
		cfg.setReflector('B');
		//cfg.setPlugboard([ 'bq', 'cr', 'di', 'ej', 'kw', 'mt', 'os', 'px', 'uz', 'gh' ]);

		"enigma: \n";
		"\tplaintext: <<toString(txt)>>\n ";
		v = enigma.encode(txt, cfg);
		"\tencode = <<toString(v)>>\n ";
		v = enigma.decode(toString(v), cfg);
		"\tdecode = <<toString(v)>>\n ";

		return(true);
	}

	_testCipher(obj, str, arg?) {
		local v;

		"<<obj.cipherID>>";
		if(arg != nil)
			" (<<toString(arg)>>)";
		":\n ";

		"\tplaintext: <<toString(str)>>\n ";
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

		if(v != str) {
			"\tERROR:  plaintext and decode don't match\n ";
			return(nil);
		}

		return(true);
	}
;
