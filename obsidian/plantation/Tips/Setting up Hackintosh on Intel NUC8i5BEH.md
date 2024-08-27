### Important kexts
- Lilu
	- A kext to patch many processes, required for AppleALC, WhateverGreen, VirtualSMC, an many other kexts.
	- https://github.com/acidanthera/Lilu/releases
- VirtualSMC
	- Emulates the SMC chip found on real macs, without this macOS will not boot.
	- https://github.com/acidanthera/VirtualSMC/releases
	- VirtualSMC plugins:
		- SMCProcessor
			- Used for monitoring Intel CPU temperature
		- SMCSuperIO
			- Used for monitoring fan speed
- WhateverGreen
	- Used for graphics patching, DRM fixes, board ID checks, frame buffer fixes, etc.
	- https://github.com/acidanthera/WhateverGreen/releases
- AppleALC
	- Used for AppleHDA patching, allowing support for the majority of on-board sound controllers.
	- https://github.com/acidanthera/AppleALC/releases
- Itlwm
	- Adds support for a large variety of Intel wireless cards.
	- Requires Heliport
		- https://github.com/OpenIntelWireless/HeliPort/releases
	- https://github.com/OpenIntelWireless/itlwm/releases
- IntelMausi
	- Required for the majority of Intel NICs.
	- https://github.com/acidanthera/IntelMausi/releases
- IntelBluetoothFirmware
	- Provides native bluetooth using Intel cards.
	- https://github.com/OpenIntelWireless/IntelBluetoothFirmware
- IntelBTPatcher
	- Adds workarounds for using Intel cards a combo of IntelBluetoothFirmware.
	- Same repo as IntelBluetoothFirmware.
- BlueToolFixup
	- Patches the macOS 12+ Bluetooth stack to support third party cards.
	- Included in the BrcmPatchRAM
		- https://github.com/acidanthera/BrcmPatchRAM/releases
- NVMEFix
	- Used for fixing power management and initialization on Non-Apple NVMe.
	- https://github.com/acidanthera/NVMeFix/releases
- CPUFriend
	- For dynamic power management.
	- https://github.com/acidanthera/CPUFriend/releases
- RealtekCardReader
	- Add Realtek USB-based SD card reader driver.
	- https://github.com/0xFireWolf/RealtekCardReader/releases
- RealtekCardReaderFirend
	- Plugin to recognize Realtek as native one.
	- https://github.com/0xFireWolf/RealtekCardReaderFriend/releases
- RestrictEvents
	- Block unwanted processes causing compatibility issues on different hardware.
	- https://github.com/acidanthera/RestrictEvents/releases
- USBInjectAll
	- Deprecated but still good for allowing more USB ports.
	- https://bitbucket.org/RehabMan/os-x-usb-inject-all/downloads/

#### To make Bluetooth work on macOS Monterey and newer
1. Install *IntelBTPatcher.kext* (depends on **Lilu**).
2. From the same bundle add *IntelBluetoothFirmware.kext*.
3. Lastly, add *BlueToolFixup.kext*.
#### Fix reboot loop on macOS Sonoma 14.6+ second phase installation
1. Edit `config.plist`.
2. Go to `Misc -> Security` and set `SecureBootModel` to `Disabled`.
3. Restart system and it is recommended to ***Reset NVRAM***.
4. On the app store find ***Install Sonoma*** and click install.
