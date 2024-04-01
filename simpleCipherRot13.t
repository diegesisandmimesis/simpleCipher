#charset "us-ascii"
//
// simpleCipherRot13.t
//
//	Rot13 implementation.
//
#include <adv3.h>
#include <en_us.h>

#include "simpleCipher.h"

rot13: object
	encode(buf) {
		local i, c, r;

		if(buf == nil)
			return(nil);

		r = new StringBuffer(buf.length);
		for(i = 1; i <= buf.length; i++) {
			c = buf.toUnicode(i);

			// Capital Latin chars.
			if((c >= 65) && (c <= 90)) {
				// 65 - 13 = 52
				c = ((c - 52) % 26) + 65;
			} else if ((c >= 97) && (c <= 122)) {
				// 97 - 13 = 84
				c = ((c - 84) % 26) + 97;
			}

			r.append(makeString(c));
		}

		return(toString(r));
	}

	// Encoding and decoding are the same process.
	decode(buf) { return(encode(buf)); }
;
