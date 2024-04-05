#charset "us-ascii"
//
// simpleCipherAutokey.t
//
//	Autokey cipher implementation.
//
//	encode() and decode() take two arguments:  the string to be
//	encoded/decoded and the encryption key.
//
//	As a historical note, the autokey cipher was devised by
//	Blaise de Vigenère, unlike the Vigenere cipher which bears his name.
//
//
#include <adv3.h>
#include <en_us.h>

#include "simpleCipher.h"

autokey: SimpleCipher
	cipherID = 'autokey'
	alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

	encode(str, key) {
		local buf, i, off, r;

		if((str == nil) || (key == nil))
			return(nil);

		str = canonicalizeInput(str);
		key = canonicalizeInput(key);

		buf = new StringBuffer(str.length + key.length);

		buf.append(key);
		buf.append(str);

		buf = toString(buf);
			
		r = new StringBuffer(str.length);
		for(i = 1; i <= str.length; i++) {
			off = alphabet.find(buf.substr(i, 1)) - 1;
			r.append(caesar.encode(str.substr(i, 1), off));
		}

		return(toString(r));
	}

	decode(str, key) {
		local buf, d, i, off, r;

		str = canonicalizeInput(str);
		key = canonicalizeInput(key);

		r = new StringBuffer(str.length);
		buf = new StringBuffer(str.length + key.length);
		buf.append(key);
		for(i = 1; i <= str.length; i++) {
			off = alphabet.find(toString(buf).substr(i, 1)) - 1;
			d = caesar.encode(str.substr(i, 1), -off);
			buf.append(d);
			r.append(d);
		}
		return(toString(r));
	}
;
