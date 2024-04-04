#charset "us-ascii"
//
// simpleCipher.t
//
//	A TADS3/adv3 module providing several simple cipher algorithms.
//
//
// USAGE
//
//	Some of the algorithms are handled by a global singleton which
//	provides an encode() and a decode() method:
//
//		// Rot13
//		//
//		// Result is 'Gurer vf n fznyy znvyobk urer.'
//		enc = rot13.encode('There is a small mailbox here.');
//		//
//		// Result is 'There is a small mailbox here.'
//		dec = rot13.decode(enc);
//
//		// Caesar cipher with an offset of -3
//		//
//		// Result is 'Qebob fp x pjxii jxfiylu ebob.'
//		enc = caesar.encode('There is a small mailbox here.', -3);
//		//
//		// Result is 'There is a small mailbox here.'
//		dec = caesar.decode(enc, -3);
//
//	The enigma cipher (which models a plugboard-less M3 Enigma machine)
//	takes a configuration object defining what encryption key, rotors,
//	and reflector to use:
//
//		// Create the config
//		cfg = new EnigmaConfig();
//
//		// Set the encryption key.  Note that the number of letters
//		// must match the number of rotors used in this config.
//		cfg.setKey('ABC');
//
//		// Set the rotors.  Arg is a list of the rotor IDs, in order
//		// from left to right.  Rotors I, II, and III are defined
//		// in the module, others can be added.
//		cfg.setRotors([ 'III', 'II', 'I' ]);
//
//		// Set the reflector.  Arg is the reflector ID.  The module
//		// provides declarations for reflectors B and C.
//		cfg.setReflector('B');
//
//		// Result will be "XOGNZ BBHUW QRBLQ HURWN PUJRM".  Note
//		// that output is divided into 5-character groups, and the
//		// final group will be padded if the input length isn't
//		// a multiple of five.  In this case the input, after all
//		// spaces and punctuation are removed, is 14 characters, so
//		// the last character is padding.  This will show up
//		// in the decode as a trailing 'X'.
//		// Result will be 'XOGNZ BBHUW QRBLQ HURWN PUJRM'
//		enc = enigma.encode('There is a small mailbox here.', cfg);
//
//		// Result will be 'THERE ISASM ALLMA ILBOX HEREX'.  Messages
//		// are always stripped of non-alphabetic characters and
//		// converted to upper case.  The X is the result of the
//		// padding described above.
//		dec = enigma.decode(enc, cfg);
//
//	There's also an abstract monoalphabetic substitution cipher class.
//	You have to declare an instance in order to use it.  The constructor
//	takes one or two arguments.  The first argument is the ciphertext
//	alphabet, and the optional second argument is the plaintext alphabet,
//	defaulting to 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' if none is given.
//
//		// Declare the cipher instance
//		// This uses the default plaintext alphabet, so the cipher
//		// is:
//		//	plaintext	ABCDEFGHIJKLMNOPQRSTUVWXYZ
//		//	ciphertext	EKMFLGDQVZNTOWYHXUSPAIBRCJ
//		// That is, A -> E, B -> K, C -> M, and so on.
//		cipher = new SimpleCipherMonoalphabetic(
//			'EKMFLGDQVZNTOWYHXUSPAIBRCJ');
//
//		// Result is 'Pqlul vs e soett oevtkyr qlul.'
//		enc = cipher.encode('There is a small mailbox here.');
//
//		// Result is 'There is a small mailbox here.'
//		dec = cipher.decode(enc);
//
//
// DISCLAIMER:
//
//	NONE OF THE CIPHERS IMPLEMENTED IN THIS MODULE ARE SAFE FOR ANY
//	MODERN CRYPTOGRAPHIC USE.
//
//	The specific intent is to make it easier to implement in-game
//	cryptographic puzzles.  Which are, by their nature, intended to
//	be broken/solved.
//
//
#include <adv3.h>
#include <en_us.h>

#include "simpleCipher.h"

// Module ID for the library
simpleCipherModuleID: ModuleID {
        name = 'Simple Cipher Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

class SimpleCipher: object
	cipherID = nil
	encode(str, arg?) { return(str); }
	decode(str, arg?) { return(encode(str, arg)); }

	// Convert string to alphabetic-only, all-caps.
	canonicalizeInput(str) {
		return(rexReplace('<^Alpha>', str, '').toUpper());
	}
;
