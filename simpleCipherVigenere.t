#charset "us-ascii"
//
// simpleCipherVigenere.t
//
//	Vigenere ciphere implementation.
//
//	encode() and decode() take three arguments:  the string to be
//	encoded/decoded; the encryption key; and an optional boolean flag
//	which (if true) will cause the input to be used as-is.  If the
//	third argument is not given, or is not true, then the input
//	string will be stripped of all non-alphabetic characters and
//	converted into upper case.
//
//	As a historical note, the ciphere implemented here, now nearly
//	universally known as the Vigenere cipher is based on work by
//	Giovan Bellaso, not Blaise de Vigenere.  The major cipher designed
//	by Vigenere is, confusingly, not the Vigenere cipher but rather the
//	autokey cipher.
//
//
#include <adv3.h>
#include <en_us.h>

#include "simpleCipher.h"

vigenere: SimpleCipher
	cipherID = 'vigenere'
	alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

	canonicalizeInput(str) {
		local r;

		r = rexReplace('<^Alpha>', str, '');
		return(r.toUpper());
	}

	encode(str, key, useAsIs?, reverse?) {
		local buf, i, off, r;

		if((str == nil) || (key == nil))
			return(nil);

		if(useAsIs != true)
			str = canonicalizeInput(str);
			
		buf = new StringBuffer(str.length);
		while(buf.length < str.length)
			buf.append(key.toUpper());
		buf = toString(buf);

		r = new StringBuffer(str.length);
		for(i = 1; i <= str.length; i++) {
			off = alphabet.find(buf.substr(i, 1));
			if(reverse)
				off *= -1;
			r.append(caesar.encode(str.substr(i, 1), off));
		}

		return(toString(r));
	}

	decode(str, key, useAsIs?, v?) {
		return(encode(str, key, useAsIs, true));
	}
;
