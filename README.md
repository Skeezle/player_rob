# skeezle_rob

A lightweight FiveM player robbery script that lets players rob nearby players through **ox_target** and an optional **/steal** command.

This resource is built around:
- **ox_target** for interaction
- **ox_inventory** for opening the target player's inventory
- **ox_lib** for notifications and progress UI

It is designed to work with hands-up detection and supports downed targets through state checks.

---

## Features

- Rob nearby players with **ox_target**
- Optional **/steal** command
- Distance checks to prevent abuse
- Cooldown between robbery attempts
- Optional unarmed-only requirement
- Robbery animation and progress circle
- Hands-up animation detection
- Downed / last stand support
- ox_lib notifications with fallback printing

---

## Dependencies

Make sure these are installed and started before this resource:

- `ox_lib`
- `ox_target`
- `ox_inventory`

---

## Installation

1. Place the resource in your server resources folder.
2. Make sure the folder name matches your intended resource name.
3. Ensure dependencies are started before this script.
4. Add this to your `server.cfg`:

```cfg
ensure ox_lib
ensure ox_target
ensure ox_inventory
ensure skeezle_rob

## License

This project is licensed under the MIT License. You are free to use, modify, and distribute this script, including for commercial use, as long as the original license notice is included.
