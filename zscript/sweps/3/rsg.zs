class qwmRShell : Ammo {
	Default {
		Inventory.MaxAmount 2;
	}
}

class qwmRSG : qwmWeapon {
	bool lBarrelEmpty;
	bool rBarrelEmpty;
	
	Default {
		Tag "Random Shotgun";
		Weapon.SlotNumber 3;
		Weapon.SelectionOrder 1;
		Weapon.AmmoGive1 2;
		Weapon.AmmoGive2 8;
		Weapon.AmmoType1 "qwmRShell";
		Weapon.AmmoType2 "Shell";
	}
	
	action void Q_Fire() {
// 		A_StartSound("qwm/sweps/rsgfire", CHAN_AUTO);
		A_StartSound("qwm/sweps/rsgdist", CHAN_AUTO);
	}
	
	States {
		Spawn:
			SGN2 A -1;
			Stop;
			
		Select:
			SHT2 A 1 A_Raise();
			Loop;
		Deselect:
			SHT2 A 1 A_Lower();
			Loop;

		Ready:
			SHT2 A 1 A_WeaponReady(WRF_ALLOWRELOAD);
			Loop;
			
		Fire:
			TNT1 A 0 {
				if (!invoker.lBarrelEmpty) {
					console.printf("wiener");
					Q_Fire();
				}
			}
			Goto Ready;
		AltFire:
			TNT1 A 0 {
				if (!invoker.rBarrelEmpty) {
					console.printf("the second wiener");
				}
			}
			Goto Ready;
	}
	
}