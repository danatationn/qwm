class qwmWeapon : DoomWeapon {
		
	Default {
		Weapon.BobStyle "Smooth";
		Weapon.BobRangeX 0.67;
		+WEAPON.NOAUTOFIRE;
	}
	
	// supposed to be vector2
	// z is only used if there's data inside (is set to 1)
	vector3 oldpos;
	// shots per second
	int sps;
	bool isZoomed;
	
	enum OverlayLayers {
		PSP_WEAPON		= 1,
		PSP_FLASH		= -1,
		PSP_HIGHLIGHTS	= 2,
	};
	
	enum QInvFlags {
		QIF_IGNOREINFAMMO	= 1,
	};
	
	override void PostBeginPlay() {
		// to be filled
	}
	
	override void Tick() {
		if (sps >= 0) --sps;
	}
	
	override string PickupMessage() {
		string weaponTag = GetTag();
		Array<string> pickupMessages;
		pickupMessages.push(String.Format("You picked up a %s.", weaponTag));
		pickupMessages.push(String.Format("Ewww, gross! You got a %s!", weaponTag));
		pickupMessages.push(String.Format("You got the %s. Oh, yes.", weaponTag));
		pickupMessages.push(String.Format("Wow, is that the %s?", weaponTag));
		pickupMessages.push(String.Format("You got the %s!", weaponTag));
		pickupMessages.push(String.Format("You got the %s.", weaponTag));
		pickupMessages.push(String.Format("You got the %s. Hooray.", weaponTag));

		return pickupMessages[random(0, pickupMessages.size() - 1)];
	}
	
	action void Q_TakeInventory(class<Inventory> itemtype, int amount = 0, int flags = 0, int giveto = AAPTR_DEFAULT) {
		/*	infinite ammo is on by default 
			amounts that are 0 now don't take everything, only ones lower than 0	*/
		
		int actual_flags = TIF_NOTAKEINFINITE;
		
		if (amount == 0) return;
		if (amount < 0) amount = 0;
		if (flags & QIF_IGNOREINFAMMO) actual_flags = 0;
		
		DoTakeInventory(self, false, itemtype, amount, actual_flags, giveto);
	}
	
	action void Q_GiveInventory(class<Inventory> itemtype, int amount = 0, int giveto = AAPTR_DEFAULT) {
		/*	currently useless	*/
		
		if (amount == 0) return;
		if (amount < 0) amount = 0;
		
		A_GiveInventory(itemtype, amount, giveto);
	}

	enum QOverlayFlags {
		QOF_START		= 1,
		QOF_END			= 1 << 2,
		QOF_ADD			= 1 << 3,
		QOF_LERP		= 1 << 4,
		QOF_EASEIN		= 1 << 5,
		QOF_EASEOUT		= 1 << 6,
		QOF_EASEINOUT	= 1 << 7,
	};
	
	action void Q_OverlayOffset(int layer = PSP_WEAPON, double wx = 0, double wy = 0, int flags = 0) {
		let player = player;
		let psp = player.GetPSprite(layer);
		
		if (flags & QOF_START) invoker.oldpos = (psp.x, psp.y, 1);
		
		A_OverlayOffset(layer, invoker.oldpos.x, invoker.oldpos.y, flags);
		
		if (flags & QOF_END) invoker.oldpos = (0, 0, 0);
	}

	action void Q_SwitchFireMode() {
		console.printf("switched");
	}
	
	int GetFreelook() {
		return GetCVar("autoaim") < 35 && (GetCVar("m_pitch") > 0 && GetCVar("freelook"));
	}
	
	vector2 GetSpread(float potential = 4, float mouselookPenalty = 0.5) {
		vector2 spread;
		spread.x = Q_Interpolate.EaseOut(sps / 100.0) * potential;
	
		if (GetFreelook()) {
			spread.y = spread.x * mouselookPenalty;  
		} else {
			spread.y = 0.0; // :)
		}
		
		return spread;
	}
	
	action void Q_Fire() {
		invoker.sps += 35;
		vector2 spread = invoker.GetSpread(5, 75);
		A_FireBullets(spread.x, spread.y, -1, 100);
	}
}