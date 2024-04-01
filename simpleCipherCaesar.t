#charset "us-ascii"
//
// simpleCipherCaesar.t
//
//	Caesar cipher implementation.
//
//	encode() and decode() take two arguments:  string to be
//	encoded/decoded, and the offset to use.  Offset can be positive or
//	negative.  Use the same offset for both encoding and decoding.  So
//	if you encrypt using:
//
//		ciphertext = encode('foo', 10);
//
//	...then the decode should be:
//
//		plaintext = decode(ciphertext, 10);
//
#include <adv3.h>
#include <en_us.h>

#include "simpleCipher.h"

caesar: object
	cipherID = 'caesar'

	encode(buf, shift) {
		local i, c, r;

		if(buf == nil)
			return(nil);

		r = new StringBuffer(buf.length);
		for(i = 1; i <= buf.length; i++) {
			c = buf.toUnicode(i);

			// Capital Latin chars.
			if((c >= 65) && (c <= 90)) {
				c = (c - 65 + shift) % 26;
				while(c < 0) c += 26;
				c += 65;
			} else if ((c >= 97) && (c <= 122)) {
				c = (c - 97 + shift) % 26;
				while(c < 0) c += 26;
				c += 97;
			}

			r.append(makeString(c));
		}

		return(toString(r));
	}

	decode(buf, shift) { return(encode(buf, -shift)); }
;
