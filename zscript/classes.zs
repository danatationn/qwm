class qwmMovement : CustomInventory {
	/*	code referenced from nashmove	
		https://forum.zdoom.org/viewtopic.php?f=37&t=35761	*/
	
	int jumps;
	bool jumping;
	bool last_jump;
	bool doublejumped;
	
	Default {
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE;
		+INVENTORY.UNTOSSABLE;
		+INVENTORY.AUTOACTIVATE;
	}
	
	bool bIsOnFloor() {
		return (owner.pos.z == owner.floorz) || (owner.bOnMObj);
	}
	
	float GetVelocity() {
		return owner.vel.length();
	}
	
	override void Tick() {
	
			last_jump = jumping;
			
			if (bIsOnFloor()) {
				jumping = false;
				doublejumped = false;
				jumps = 0;
			}
			
			if (doublejumped) return;
			
			if (owner.player.buttons & BT_JUMP) {
				jumping = true;
				++jumps;
			} else {
				jumping = false;
			}
			
			if (!last_jump && jumping && (jumps > 2)) {
				owner.AddZ(50);
				doublejumped = true;
			}

// 			console.printf(String.Format("jumps: %d\njumping: %d\nlast_jump: %d\n", jumps, jumping, last_jump));
	}
	
	States {
		Use:
			TNT1 A 0;
			Fail;
		Pickup:
			TNT1 A 0 { return true; }
			Stop;
	}
}