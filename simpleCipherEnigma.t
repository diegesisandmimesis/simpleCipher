#charset "us-ascii"
//
// simpleCipherEnigma.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "simpleCipher.h"

class EnigmaRotor: object
	rotorID = nil
	alphabet = nil
	lugSetting = nil

	initializeRotor() {
		if((location == nil) || !location.ofKind(enigma))
			return;
		location.addRotor(self);
	}
;

class EnigmaConfig: object
	alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
	key = nil
	rotorList = nil
	rotors = nil
	offsets = nil
	reflector = nil

	setRotors(lst) {
		local i, r;

		if(lst == nil)
			return(nil);

		if(rotors == nil)
			rotors = new Vector(lst.length);
		else
			rotors.setLength(0);

		for(i = 1; i <= lst.length; i++) {
			if((r = enigma.getRotor(lst[i])) == nil)
				return(nil);
			rotors.append(r);
		}

		return(true);
	}

	setKey(v) { key = v; }

	setReflector(id) {
		local r;

		if(id == nil)
			return(nil);

		if((r = enigma.getRotor(id)) == nil)
			return(nil);

		reflector = r;

		return(true);
		
	}

	initializeConfig() {
		if(initializeKey() != true)
			return(nil);
		initializeOffsets();
		return(true);
	}

	initializeKey() {
		if(key == nil)
			return(nil);
		if(key.length != rotors.length)
			return(nil);
		key = key.toUpper();

		return(true);
	}

	initializeOffsets() {
		local i;

		if(offsets == nil)
			offsets = new Vector(key.length);
		else
			offsets.setLength(0);

		for(i = 1; i <= key.length; i++) {
			offsets.prepend(alphabet.find(key.substr(i, 1)));
		}
	}
;

enigma: SimpleCipher, PreinitObject
	_rotors = perInstance(new LookupTable)

	_config = nil

	execute() {
		initializeRotors();
	}

	initializeRotors() {
		forEachInstance(EnigmaRotor, function(o) {
			o.initializeRotor();
		});
	}

	addRotor(obj) {
		if((obj == nil) || !obj.ofKind(EnigmaRotor))
			return;
		_rotors[obj.rotorID] = obj;
	}

	canonicalizePlaintext(str) {
		local r;

		r = rexReplace('<^Alpha>', str, '');
		return(r.toUpper());
	}

	encode(str, cfg?) {
		local i, r, txt;

		if((cfg != nil) && (setConfig(cfg) != true))
			return(nil);

		if((txt = canonicalizePlaintext(str)) == nil)
			return(nil);

		r = new StringBuffer();
		for(i = 1; i <= txt.length; i++) {
			r.append(encodeLetter(txt.substr(i, 1)));
		}
		return(r);
	}

	encodeLetter(chr) {
		local i, idx, r, rotor, step;

		// First of all, handle all of the rotor stepping.
		i = 1;
		step = true;
		while(step && (i <= _config.rotors.length)) {
			rotor = _config.rotors[i];
			_config.offsets[i] = ((_config.offsets[i] + 1)
				% rotor.alphabet.length) + 1;
			if(_config.alphabet.substr(_config.offsets[i], 1) !=
				_config.rotors[i].lugSetting)
				step = nil;
			i++;
		}

		if((idx = _config.alphabet.find(chr)) == nil)
			return('?');

		r = chr;

		// Right to left through the rotors
		for(i = 1; i <= _config.rotors.length; i++) {
			rotor = _config.rotors[i];
			r = rotor.alphabet.substr(((idx + _config.offsets[i])
				% rotor.alphabet.length) + 1, 1);
			if((idx = _config.alphabet.find(r)) == nil)
				return('?');
		}

		// Reflector
		r = _config.reflector.alphabet.substr(idx, 1);

		// Left to right back through the rotors
		for(i = _config.rotors.length; i >= 1; i--) {
			rotor = _config.rotors[i];
			if((idx = rotor.alphabet.find(r)) == nil)
				return('?');
			idx -= _config.offsets[i] + 1;
			while(idx < 1)
				idx += rotor.alphabet.length;

			r = _config.alphabet.substr(idx, 1);
		}

		return(r);
	}

	getRotor(id) { return(_rotors[id]); }

	setConfig(cfg) {
		if((cfg == nil) || !cfg.ofKind(EnigmaConfig))
			return(nil);
		if(cfg.initializeConfig() != true)
			return(nil);

		_config = cfg;

		return(true);
	}
;
+EnigmaRotor 'I' 'EKMFLGDQVZNTOWYHXUSPAIBRCJ' 'R';
+EnigmaRotor 'II' 'AJDKSIRUXBLHWTMCQGZNPYFVOE' 'F';
+EnigmaRotor 'III' 'BDFHJLCPRTXVZNYEIWGAKMUSQO' 'W';
+EnigmaRotor 'B' 'YRUHQSLDPXNGOKMIEBFZCWVJAT' 'A';
+EnigmaRotor 'C' 'FVPJIAOYEDRZXWGCTKUQSBNMHL' 'A';
