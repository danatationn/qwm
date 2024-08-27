class SwapWeaponsHandler : EventHandler {
	
	override void CheckReplacement(ReplaceEvent e) {
		if (e.Replacee == 'Pistol') e.Replacement = 'qwmTierTwoSpawner';
		if (e.Replacee == 'SuperShotgun') e.Replacement = 'qwmTierThreeSpawner';
	}
	
	override void PlayerEntered(PlayerEvent e) {
		let player = players[e.playernumber];
		let mo = player.mo;
		if (mo.GetCVar("q_pistolstart")) mo.ClearInventory();
		
		if (mo.FindInventory("Pistol")) mo.TakeInventory("Pistol", 1);
		if (!mo.FindInventory("qwmGlock")) mo.GiveInventory("qwmGlock", 1);
		
		// when pistol starting there's no selected weapon
		if (!player.ReadyWeapon && mo.FindInventory("qwmGlock")) mo.A_SelectWeapon("qwmGlock");
	}
}