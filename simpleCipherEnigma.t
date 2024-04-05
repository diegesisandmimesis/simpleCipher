#charset "us-ascii"
//
// simpleCipherEnigma.t
//
//	Simple approximation of the M3 Enigma machine.
//
//	The module provides an enigma singlton with an encode() and decode()
//	method.  Like the other algorithms in this module, the first argument
//	is the text to encode or decode.  The second argument must be an
//	instance of the EnigmaConfig class.
//
//
// CONFIGURATION OPTIONS
//
//	Create an EnigmaConfig instance in the usual way:
//
//		cfg = new EnigmaConfig();
//
//	Configuration methods are (with sample arguments):
//
//		setKey('KEY')		sets the initial rotor positions (the
//					encryption key) to be K, E, and Y.  if
//					not specified, defaults to AAA
//
//		padOutput = true	property (not method).  if boolean
//					true, output will be padded to produce
//					full five-character groups (so if
//					the length of the output text isn't
//					a multiple of five, it will be padded
//					with Xs until it is).
//					default is true
//
//		setPlugboard([ 'FI', 'PS' ])	sets the plugboard to swap
//						F and I, and P and S.  valid
//						options are up to thirteen
//						pairs, with no letters repeated.
//						no default
//
//		setRing('ABC')		sets the rotor ring settings to be,
//					from left to right, A, B, and C.  if
//					no ring setting is given, defaults
//					to AAA
//
//		setReflector('B')	sets the reflector, in this case UKW B.
//					no default
//
//		setRotors([ 'I', 'II', 'III' ])	sets the rotors, from left to
//						right, to be I, II, and III.
//						no default, this is required
//
//
#include <adv3.h>
#include <en_us.h>

#include "simpleCipher.h"

class EnigmaObject: object
	_debug(str) {}
;

class EnigmaAlphabet: EnigmaObject
	rotorID = nil		// rotor ID
	alphabet = nil		// cipher alphabet of the rotor
	_alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

	map = nil
	reverseMap = nil

	initializeRotor() {
		if((location == nil) || !location.ofKind(enigma))
			return;
		location.addRotor(self);
		initializeMapping();
	}

	initializeMapping() {
		local i, j;

		if(map == nil)
			map = new Vector(alphabet.length);
		else
			map.setLength(0);

		if(reverseMap == nil)
			reverseMap = new Vector(alphabet.length,
				alphabet.length);
		else
			reverseMap.fillValue(0, 1, alphabet.length);

		for(i = 1; i <= alphabet.length; i++) {
			j = _alphabet.find(alphabet.substr(i, 1));
			map[i] = j - i;
			reverseMap[j] = i - j;
		}
	}

	modAlpha(v) {
		while(v < 1) v += alphabet.length;
		while(v > alphabet.length) v -= alphabet.length;
		return(v);
	}
	mapRL(v) { return(modAlpha(v + map[modAlpha(v)])); }
	mapLR(v) { return(modAlpha(v + reverseMap[modAlpha(v)])); }

	getRL(chr, off?) {
		local v;

		if(off == nil)
			off = 0;

		if((v = _alphabet.find(chr)) == nil)
			return(nil);
		v = mapRL(v + off);
		v = modAlpha(v - off);

		return(_alphabet.substr(v, 1));
	}

	getLR(chr, off?) {
		local v;

		if(off == nil)
			off = 0;

		if((v = _alphabet.find(chr)) == nil)
			return(nil);
		v = mapLR(v + off);
		v = modAlpha(v - off);

		return(_alphabet.substr(v, 1));
	}
;

// Reflectors don't have a lug because they don't step.  Otherwise
// for our purposes (just mapping the alphabets) we treat the reflectors
// like simple rotors.
class EnigmaReflector: EnigmaAlphabet;

// Class for rotor definitions
class EnigmaRotor: EnigmaAlphabet
	turnoverAt = nil	// letter on which the rotor steps
	turnoverIndex = nil

	initializeRotor() {
		local idx;

		inherited();
		if((idx = _alphabet.find(turnoverAt)) != nil)
			turnoverIndex = idx - 1;
	}
;


class EnigmaConfig: EnigmaObject
	alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'	// input/output alphabet
	key = nil				// the encryption key
	rotors = nil				// array of the rotors used
	offsets = nil				// current rotor offsets
	reflector = nil				// reflector rotor
	plugboard = nil				// plugboard settings
	ring = nil				// ring settings

	padOutput = true			// pad output to multiple of 5
	doubleStepAnomaly = true		// implement the double step
						// anomaly

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

	setPlugboard(lst) {
		local a, b, i;

		if(plugboard == nil)
			plugboard = new LookupTable();
		else
			plugboard.keysToList().forEach(function(o) {
				plugboard.removeElement(o);
			});

		for(i = 1; i <= lst.length; i++) {
			if(lst[i].length != 2)
				return(nil);

			a = lst[i].substr(1, 1).toUpper();
			b = lst[i].substr(2, 1).toUpper();
			if((plugboard[a] != nil) || (plugboard[b] != nil))
				return(nil);
			plugboard[a] = b;
			plugboard[b] = a;
		}

		return(true);
	}

	// Set the key.  Note that the key length must equal the number
	// of rotors, although that's not checked here but at init.
	setKey(v) { key = v; }

	setRing(v) { ring = v; }


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
		if(initializeRingSetting() != true)
			return(nil);
		initializeRotorOffsets();
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

	initializeRingSetting() {
		local buf;

		if(ring == nil) {
			buf = new StringBuffer(rotors.length);
			while(buf.length < rotors.length)
				buf.append('A');
			ring = toString(buf);
		}
		if(ring.length != rotors.length)
			return(nil);

		ring = ring.toUpper();

		return(true);
	}

	modAlpha(v) {
		while(v > alphabet.length)
			v -= alphabet.length;
		while(v < 1)
			v += alphabet.length;
		return(v);
	}

	// Compute the initial rotor offsets (due to the key setting).
	// A has an offset of zero.
	initializeRotorOffsets() {
		local i, v;

		if(offsets == nil)
			offsets = new Vector(key.length);
		else
			offsets.setLength(0);

		for(i = 1; i <= key.length; i++) {
			v = 26 - (alphabet.find(key.substr(i, 1)) - 1);
			v += alphabet.find(ring.substr(i, 1)) - 1;
			offsets.append(v % alphabet.length);
		}
	}

	_debugRotorOffsets() {
		local i;

		_debug('rotor offsets:');
		for(i = 1; i <= rotors.length; i++) {
			_debug('\t<<toString(i)>>: <<rotors[i].rotorID>> =
				<<toString(offsets[i])>>');
		}
	}
;

enigma: SimpleCipher, PreinitObject, EnigmaObject
	_rotors = perInstance(new LookupTable)	// table of all rotors
	_config = nil				// our current config

	// Run at preinit.
	execute() { initializeRotors(); }

	// Look for all our rotor declarations.
	initializeRotors() {
		forEachInstance(EnigmaAlphabet, function(o) {
			o.initializeRotor();
		});
	}

	// Add a rotor to our table.
	addRotor(obj) {
		if((obj == nil) || !obj.ofKind(EnigmaAlphabet))
			return;
		_rotors[obj.rotorID] = obj;
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
		if((_config.padOutput == true) && (j != 0)) {
			while(j < 5) {
				r.append(encodeLetter('X'));
				j += 1;
			}
		}

		return(toString(r));
	}

	// Advance the rotors.
	advanceRotors() {
		local i, rotor, step, t;

		step = true;
		i = _config.rotors.length;

		t = new Vector(i, i);

		while(step && (i > 0)) {
			// Step the rotor
			_config.offsets[i] += 1;

			// Remember we stepped this rotor.
			t[i] = true;

			rotor = _config.rotors[i];

			// Canonicalize the offsets.  Result is 0 - 25.
			_config.offsets[i] =
				_config.offsets[i] % rotor.alphabet.length;

			if(rotor.turnoverIndex == nil)
				step = nil;
			else if(_config.offsets[i] != rotor.turnoverIndex)
				step = nil;

			if(i != _config.rotors.length)
				_debug('stepping rotor <<toString(i)>>
					(<<_config.rotors[i].rotorID>>)');

			i--;
		}

		// Double-stepping anomaly
		if((_config.doubleStepAnomaly == true)
			&& (_config.rotors.length == 3) && t[2] && t[3]) {
			_config.offsets[2] += 1;
			_debug('double-stepping middle rotor');
			}
	}

	applyPlugboard(chr) {
		local r;

		if(_config.plugboard == nil)
			return(chr);

		r = (_config.plugboard[chr] ? _config.plugboard[chr] : chr);
		_debug('\t<<toString(chr)>> -> <<toString(r)>>: plugboard');

		return(r);
	}

	applyReflector(chr) {
		local r;

		r = _config.reflector.alphabet.substr(
			_config.alphabet.find(chr), 1);

		_debug('\t<<toString(chr)>> -> <<toString(r)>>: reflector');

		return(r);
	}

	applyRotorRL(chr, idx) {
		local r;

		r = _config.rotors[idx].getRL(chr, _config.offsets[idx]);

		_debug('\t<<toString(chr)>> -> <<toString(r)>>:
			<<_config.rotors[idx].rotorID>>');

		return(r);
	}

	applyRotorLR(chr, idx) {
		local r;

		r = _config.rotors[idx].getLR(chr,
			_config.offsets[idx]);

		_debug('\t<<toString(chr)>> -> <<toString(r)>>:
			<<_config.rotors[idx].rotorID>>');

		return(r);
	}

	encodeLetter(chr) {
		local i, r;

		advanceRotors();
		r = applyPlugboard(chr);

		for(i = _config.rotors.length; i > 0; i--) {
			r = applyRotorRL(r, i);
		}

		r = applyReflector(r);

		for(i = 1; i <= _config.rotors.length; i++) {
			if((r = applyRotorLR(r, i)) == nil)
				return('?');
		}

		r = applyPlugboard(r);

		_debug('<<toString(chr)>> -> <<toString(r)>>');

		return(r);
	}

	// Returns the given rotor.
	getRotor(id) { return(_rotors[id]); }

	indexToLetter(idx) { return(_config.alphabet.substr(idx, 1)); }


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
+EnigmaRotor 'I' 'EKMFLGDQVZNTOWYHXUSPAIBRCJ' 'R';	// Enigma I, 1930
+EnigmaRotor 'II' 'AJDKSIRUXBLHWTMCQGZNPYFVOE' 'F';	// Enigma I, 1930
+EnigmaRotor 'III' 'BDFHJLCPRTXVZNYEIWGAKMUSQO' 'W';	// Enigma I, 1930
+EnigmaRotor 'IV' 'ESOVPZJAYQUIRHXLNFTGKDCMWB' 'K';	// M3, 1938
+EnigmaRotor 'V' 'VZBRGITYUPSDNHLXAWMJQOFECK' 'A';	// M3, 1938
+EnigmaRotor 'test' 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' '?';	// testing
//
// Un-implemented multi-lug rotors
//+EnigmaRotor 'VI' 'JPGVOUMFYQBENHZRDKASXLICTW' [ 'Z', 'M' ];	// M3, 1939/M4, 1942
//+EnigmaRotor 'VII' 'NZJHGRCXMYSWBOUFAIVLPEKQDT' [ 'Z', 'M' ];	// M3, 1939/M4, 1942
//+EnigmaRotor 'VIII' 'FKQHTLXOCBJSPDZRAMEWNIUYGV' [ 'Z', 'M' ];// M3, 1939/M4, 1942
//
// Reflector Definitions
+EnigmaReflector 'A' 'EJMZALYXVBWFCRQUONTSPIKHGD';
+EnigmaReflector 'B' 'YRUHQSLDPXNGOKMIEBFZCWVJAT';	// standard wartime
+EnigmaReflector 'C' 'FVPJIAOYEDRZXWGCTKUQSBNMHL';	// standard wartime
+EnigmaReflector 'Beta' 'LEYJVCNIXWPBQMDRTAKZGFUHOS';	// M4, 1941
+EnigmaReflector 'Gamma' 'FSOKANUERHMBTIYCWLQPZXVGJD';	// M4, 1942
+EnigmaReflector 'ThinB' 'ENKQAUYWJICOPBLMDXZVFTHRGS';
+EnigmaReflector 'ThinC' 'RDOBJNTKVEHMLFCWZAXGYIPSUQ';


#ifdef ENIGMA_DEBUG
modify EnigmaObject _debug(str) { aioSay('\n<<toString(str)>>\n '); };
#endif // ENIGMA_DEBUG
