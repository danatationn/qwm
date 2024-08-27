class qwmGlockMagazine : Ammo {
	Default {
		Inventory.MaxAmount 20;
	}
}

class qwmGlock : qwmWeapon {

	bool raised;
	int curammo;
	int resammo;

	Default {
		Tag "Glock";
		Weapon.SlotNumber 2;
		Weapon.SelectionOrder 1;
		Weapon.AmmoGive1 20;
		Weapon.AmmoGive2 40;
		Weapon.AmmoType1 "qwmGlockMagazine";
		Weapon.AmmoType2 "Clip";
	}

	action void Q_Fire() {
		A_StartSound("qwm/sweps/glockfire", CHAN_AUTO);
		A_StartSound("qwm/sweps/glockdist", CHAN_AUTO);
		invoker.sps += 10;
		if (invoker.sps > 100) invoker.sps = 100;
		vector2 spread = invoker.GetSpread(8);
		A_FireBullets(spread.x, spread.y, -1, 5);
		Q_TakeInventory("qwmGlockMagazine", 1);
	}
	
	action void Q_SwitchFireMode() {
		// nothing ...
	}
	
	override void Tick() {
		if (sps > 0) --sps;		
	}

	States {
		Spawn:
			PGLC A -1;
			Stop;
		
		Select:
			GLCK A 1 A_Raise();
			Loop;
		Deselect:
			GLCK A 1 A_Lower();
			Loop;
		
		Ready:
			GLCK A 1 A_WeaponReady(WRF_ALLOWRELOAD|WRF_ALLOWZOOM);
			Loop;
		
		Raise:
			TNT1 A 0 { 
				invoker.raised = true; 
				A_StartSound("qwm/sweps/glockraise", CHAN_AUTO);
			}
			GLCK AA 1 A_OverlayOffset(PSP_WEAPON, 0, -4, WOF_ADD);
			GLCK A 1 A_OverlayOffset(PSP_WEAPON, 0, -2, WOF_ADD);
			Goto Fire;
		Fire:
			TNT1 A 0 {
				if (CountInv("qwmGlockMagazine") == 0) return ResolveState("Reload");
				if (!invoker.raised) return ResolveState("Raise");
				Q_Fire();	
				return ResolveState(null);
			}
			GLCK A 1 {
				A_Overlay(PSP_FLASH, "Flash");
				A_Overlay(PSP_HIGHLIGHTS, "Highlights");
				A_WeaponOffset(0, 2, WOF_ADD);
			}
			GLCK C 2 A_WeaponOffset(0, -2, WOF_ADD);
			GLCK B 2 A_WeaponReady(WRF_NOBOB);
			GLCK A 12 A_WeaponReady(WRF_NOBOB);
			Goto Lower;
		Highlights:
			FGLC A 1 Bright;
			Stop;
		Flash:
			FGLC B 1 Bright A_Light1();
			Goto LightDone;
		Lower:
			TNT1 A 0 { 
				invoker.raised = false; 
				A_StartSound("qwm/sweps/glocklower", CHAN_AUTO);
			} 
			GLCK AA 1 A_OverlayOffset(PSP_WEAPON, 0, 4, WOF_ADD);
			GLCK A 1 A_OverlayOffset(PSP_WEAPON, 0, 2, WOF_ADD);
			Goto Ready;
			
		Reload:
			GLCK B 16 {
				if (CountInv("Clip") == 0) return ResolveState("DryFire");
				Q_OverlayOffset(PSP_WEAPON, 0, 2, WOF_ADD);
				A_StartSound("qwm/sweps/glocksliderelease", CHAN_AUTO);			
				return ResolveState(null);
			}
			GLCK E 1 {
				A_OverlayOffset(PSP_WEAPON, 0, 4, WOF_ADD);
				A_StartSound("qwm/sweps/glockclipout", CHAN_AUTO);
				invoker.curammo = CountInv("qwmGlockMagazine");
				Q_TakeInventory("qwmGlockMagazine", 20);
			}
			GLCK EE 1 A_OverlayOffset(PSP_WEAPON, 0, 8, WOF_ADD);
			GLCK EE 1 A_OverlayOffset(PSP_WEAPON, 0, 2, WOF_ADD);
			GLCK E 20 A_OverlayOffset(PSP_WEAPON, 0, 1, WOF_ADD);
			TNT1 A 0 A_StartSound("qwm/sweps/glockclipin", CHAN_AUTO);
			GLCK EE 1;
			GLCK E 1;
			GLCK E 5 {
				Q_TakeInventory("Clip", 20 - invoker.curammo);				
				Q_GiveInventory("qwmGlockMagazine", 20);
			}
			GLCK D 8 {
				A_StartSound("qwm/sweps/glockslideback", CHAN_AUTO);
				A_OverlayOffset(PSP_WEAPON, 0, -8, WOF_ADD);
			}
			Goto Ready;
		DryFire:
			GLCK A 4 {
				A_WeaponReady();
				A_StartSound("qwm/sweps/glockclick", CHAN_AUTO);
			}
			Goto Ready;
	}

}