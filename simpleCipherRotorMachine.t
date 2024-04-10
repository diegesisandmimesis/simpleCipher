#charset "us-ascii"
//
// simpleCipherRotorMachine.t
//
//
//
#include <adv3.h>
#include <en_us.h>

#include "simpleCipher.h"

class RotorMachine: PreinitObject
	_rotors = perInstance(new LookupTable)	// table of all rotors
	rotorClass = nil

	// Run at preinit.
	execute() { initializeRotors(); }

	// Look for all our rotor declarations.
	initializeRotors() {
		if(rotorClass == nil) return;
		forEachInstance(rotorClass, function(o) {
			o.initializeRotor();
		});
	}

	// Add a rotor to our table.
	addRotor(obj) {
		if((obj == nil) || !obj.ofKind(rotorClass))
			return;
		_rotors[obj.rotorID] = obj;
	}
;
