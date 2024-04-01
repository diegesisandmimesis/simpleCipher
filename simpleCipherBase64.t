#charset "us-ascii"
//
// simpleCipherBase64.t
//
#include <adv3.h>
#include <en_us.h>

#include "simpleCipher.h"

// Simple, slightly kludgy base64 implementation in TADS3.
base64: object
	// base64 character set.
	_base64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='

	encode(buf) {
		local c0, c1, c2, e0, e1, e2, e3, i, l, r;

		r = '';
		i = 1;
		l = buf.length();
		while(i <= l) {
			c0 = buf.toUnicode(i);
			c1 = buf.toUnicode(i + 1);
			c2 = buf.toUnicode(i + 2);

			if(c1 == nil) c1 = 0;
			if(c2 == nil) c2 = 0;

			i += 3;

			e0 = c0 >> 2;
			e1 = ((c0 & 3) << 4) | ((c1 & 0xf0) >> 4);
			e2 = ((c1 & 15) << 2) | ((c2 & 0xc0) >> 6);
			e3 = c2 & 63;
			if(c1 == 0)
				e2 = e3 = 64;
			if(c2 == 0)
				e3 = 64;
				
			r += _base64.substr(e0 + 1, 1)
				+ _base64.substr(e1 + 1, 1)
				+ _base64.substr(e2 + 1, 1)
				+ _base64.substr(e3 + 1, 1);
		}

		return(r);
	}

	// Decode a base64-encoded string.
	decode(buf) {
		local c0, c1, c2, e0, e1, e2, e3, i, r;

		r = '';
		i = 1;
		buf = rexReplace('[^A-Za-z0-9\+\/\=]', buf, '');
		while(i <= buf.length) {
			e0 = _base64.find(buf.substr(i, 1)) - 1;
			e1 = _base64.find(buf.substr(i + 1, 1)) - 1;
			e2 = _base64.find(buf.substr(i + 2, 1)) - 1;
			e3 = _base64.find(buf.substr(i + 3, 1)) - 1;

			i += 4;

			c0 = (e0 << 2) | (e1 >> 4);
			c1 = ((e1 & 15) << 4) | (e2 >> 2);
			c2 = ((e2 & 3) << 6) | e3;

			r = r + makeString(c0);

			if(e2 != 64) {
				r = r + makeString(c1);
			}
			if(e3 != 64) {
				r = r + makeString(c2);
			}
		}
		return(r);
	}
;
