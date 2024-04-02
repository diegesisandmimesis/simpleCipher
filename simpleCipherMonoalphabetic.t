#charset "us-ascii"
//
// simpleCipherMonoalphabetic.t
//
//	Generic monoalphabetic substitution cipher template module.
//
//	This gives a class instead of a singleton.  To create an instance:
//
//		cipher = new SimpleCipherMonoalphabetic(cipher_alphabet);
//
//	...where cipher_alphabet is the scrambled alphabet to use for
//	the substitution.  The constructor takes an optional second argument
//	if you want to specify the plaintext alphabet as well (by default
//	it's the 26 Latin letters in order).
//
//	To illustrate:
//
//		plaintext alphabet:	ABCDEFGHIJKLMNOPQRSTUVWXYZ
//		ciphertext alphabet:	EKMFLGDQVZNTOWYHXUSPAIBRCJ
//
//	In this example, plaintext "A" would be encoded as "E", "B"
//	as "K", "C" as "M", and so on.
//
//
#include <adv3.h>
#include <en_us.h>

#include "simpleCipher.h"

class SimpleCipherMonoalphabetic: SimpleCipher
	cipherID = 'monoalphabetic'
	_alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

	construct(a?, a0?) {
		alphabet = (a ? a.toUpper() : 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
		if(a0 != nil)
			_alphabet = a0.toUpper();
	}

	setAlphabet(v) { alphabet = v; }

	encode(str, cfg?) {
		return(_convert(str, _alphabet, (cfg ? cfg : alphabet)));
	}

	decode(str, cfg?) {
		return(_convert(str, (cfg ? cfg : alphabet), _alphabet));
	}

	_convert(str, alph0, alph1) {
		local c, chr, i, idx, r;

		if(str == nil)
			return(nil);

		r = new StringBuffer(str.length);
		for(i = 1; i <= str.length; i++) {
			c = str.toUnicode(i);
			chr = str.substr(i, 1);

			// Capital Latin chars.
			if((c >= 65) && (c <= 90)) {
				if((idx = alph0.find(chr)) == nil)
					r.append('?');
				else
					r.append(alph1.substr(idx, 1));
			} else if ((c >= 97) && (c <= 122)) {
				if((idx = alph0.find(chr.toUpper())) == nil)
					r.append('?');
				else
					r.append(alph1.substr(idx, 1));
			
			} else {
				r.append(chr);
			}
		}

		return(toString(r));
	}
;
