#charset "us-ascii"
//
// simpleCipherEnigma.t
//
//	Simple approximation of the M3 Enigma machine but lacking the
//	plugboard.
//
//
#include <adv3.h>
#include <en_us.h>

#include "simpleCipher.h"

// Class for rotor definitions
class EnigmaRotor: object
	rotorID = nil		// rotor ID
	alphabet = nil		// cipher alphabet of the rotor
	lugSetting = nil	// letter on which the rotor steps

	initializeRotor() {
		if((location == nil) || !location.ofKind(enigma))
			return;
		location.addRotor(self);
	}
;

class EnigmaConfig: object
	alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'	// input/output alphabet
	key = nil				// the encryption key
	rotors = nil				// array of the rotors used
	offsets = nil				// current rotor offsets
	reflector = nil				// reflector rotor

	// Set the rotors.  Arg is a list of rotor IDs.
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

	// Set the key.  Note that the key length must equal the number
	// of rotors, although that's not checked here but at init.
	setKey(v) { key = v; }

	// Set the reflector.
	setReflector(id) {
		local r;

		if(id == nil)
			return(nil);

		if((r = enigma.getRotor(id)) == nil)
			return(nil);

		reflector = r;

		return(true);
		
	}

	// Initialize the configuration.  Returns boolean true if the config
	// is valid, nil otherwise.
	initializeConfig() {
		if(initializeKey() != true)
			return(nil);
		initializeOffsets();
		return(true);
	}

	// Initialize the key, including checking its validity.
	initializeKey() {
		if(key == nil)
			return(nil);

		// Key has to have exactly as many letters as we have rotors.
		if(key.length != rotors.length)
			return(nil);

		// Convert to upper case.
		key = key.toUpper();

		return(true);
	}

	// Compute the initial rotor offsets (due to the key setting).
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
	_rotors = perInstance(new LookupTable)	// table of all rotors
	_config = nil				// our current config

	// Run at preinit.
	execute() { initializeRotors(); }

	// Look for all our rotor declarations.
	initializeRotors() {
		forEachInstance(EnigmaRotor, function(o) {
			o.initializeRotor();
		});
	}

	// Add a rotor to our table.
	addRotor(obj) {
		if((obj == nil) || !obj.ofKind(EnigmaRotor))
			return;
		_rotors[obj.rotorID] = obj;
	}

	// Convert the string into the canonical form:  only alphabetic,
	// no spaces, all upper case.
	canonicalizeInput(str) {
		local r;

		r = rexReplace('<^Alpha>', str, '');
		return(r.toUpper());
	}

	// Encode the given string.
	// Optional second arg is a EnigmaConfig instance.
	encode(str, cfg?) {
		local i, j, r, txt;

		// If we were passed a config object, use it.
		if((cfg != nil) && (setConfig(cfg) != true))
			return(nil);

		// Canonicalize the string we're converting.
		if((txt = canonicalizeInput(str)) == nil)
			return(nil);

		// String buffer to hold the return value.
		r = new StringBuffer();

		// We separate the output into 5-character blocks.  This
		// is our counter for that.
		j = 0;

		// Go through the input.
		for(i = 1; i <= txt.length; i++) {
			// Encode this individial letter.
			r.append(encodeLetter(txt.substr(i, 1)));

			// See if we've completed a five-character block.
			j += 1;
			if(j == 5) {
				r.append(' ');
				j = 0;
			}
		}

		// Pad.
		if(j != 0) {
			while(j < 5) {
				r.append(encodeLetter('X'));
				j += 1;
			}
		}

		return(r);
	}

	// Encode an individual character.
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

	// Returns the given rotor.
	getRotor(id) { return(_rotors[id]); }

	// Set the current config.  Arg is an EnigmaConfig instance.
	setConfig(cfg) {
		if((cfg == nil) || !cfg.ofKind(EnigmaConfig))
			return(nil);

		if(cfg.initializeConfig() != true)
			return(nil);

		_config = cfg;

		return(true);
	}
;
// Rotor definitions.
+EnigmaRotor 'I' 'EKMFLGDQVZNTOWYHXUSPAIBRCJ' 'R';
+EnigmaRotor 'II' 'AJDKSIRUXBLHWTMCQGZNPYFVOE' 'F';
+EnigmaRotor 'III' 'BDFHJLCPRTXVZNYEIWGAKMUSQO' 'W';
+EnigmaRotor 'B' 'YRUHQSLDPXNGOKMIEBFZCWVJAT' 'A';
+EnigmaRotor 'C' 'FVPJIAOYEDRZXWGCTKUQSBNMHL' 'A';
