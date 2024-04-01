#charset "us-ascii"
//
// simpleCipher.t
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
;
