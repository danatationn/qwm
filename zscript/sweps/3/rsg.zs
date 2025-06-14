class qwmRShell : Ammo {
	Default {
		Inventory.MaxAmount 2;
	}
}

class qwmRSGPoisonPuff : BulletPuff {
	Default
	{
		PoisonDamage 4, 8;
	}
}

class qwmRSG : qwmWeapon {
	static const string shellTypes[] = {
		"NRML",
		"FIRE",
		"ICEY",
		"POIS",
		"EXPL"
	};
 
	string lBarrelType;
	string rBarrelType;
	
	Default {
		Tag "RSG";
		Weapon.SlotNumber 3;
		Weapon.SelectionOrder 1;
		Weapon.AmmoGive1 2;
		Weapon.AmmoGive2 8;
		Weapon.AmmoType1 "qwmRShell";
		Weapon.AmmoType2 "Shell";
	}
	
	override void BeginPlay() {
		Q_AssignShellTypes();
	}
 	
	action void Q_Fire(bool shootOneBarrel = false) {
		string puff;
		int pellets;
		if (shootOneBarrel == true)
			pellets = 10;
		else
			pellets = 20;
		
		if (invoker.lBarrelType == "POIS" || invoker.rBarrelType == "POIS")
			puff = "qwmRSGPoisonPuff";
		else
			puff = "BulletPuff";
		
		A_StartSound("weapons/sshotf", CHAN_AUTO);
		A_FireBullets(7, 10, pellets, 5, puff);
		Q_TakeInventory("qwmRShell", pellets/10);
	}
	
	string ReturnRandomShellType() {
		int size = shellTypes.Size();
		int index = random(0, size-1);
		return shellTypes[index];
	}
	
	action void Q_AssignShellTypes() {
		invoker.lBarrelType = invoker.ReturnRandomShellType();
		invoker.rBarrelType = invoker.ReturnRandomShellType();
		
		console.printf("%s/%s", invoker.lBarrelType, invoker.rBarrelType);
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
		Check:
			TNT1 A 0 {
				if (CountInv("qwmRShell") == 0 && CountInv("Shell") > CountInv("qwmRShell"))
					return ResolveState("Reload");
				else
					return ResolveState(null);
			}
			
		Fire:
			SHT2 A 7 Q_Fire();
			Goto Reload;
		AltFire:
			SHT2 A 7 Q_Fire(true);
			Goto Reload;
			
		Reload:
			SHT2 B 7;
			SHT2 C 7;
			SHT2 D 7 {
				Q_TakeInventory("qwmRShell", 2);
				A_StartSound("weapons/sshoto", CHAN_AUTO);
			}
			SHT2 E 7;
			SHT2 F 7 {
				A_StartSound("weapons/sshotl", CHAN_AUTO);
				Q_TakeInventory("Shell", 2);
				Q_GiveInventory("qwmRShell", 2);
			}
			SHT2 G 6;
			SHT2 H 6 A_StartSound("weapons/sshotc", CHAN_AUTO);
			SHT2 A 5 A_ReFire;
			TNT1 A 0 Q_AssignShellTypes();
			Goto Ready;
	}
	
}