### Changes in 100200.46-Release:

- Changed: Update Interface version
- Changed: Update quest/item database

### Changes in 100105.45-Release:

- Changed: Update LibEditMode library

### Changes in 100105.44-Release:

- Fixed: Wrong priority of quest items in Hillsbrad Foothills for horde

### Changes in 100105.43-Release:

- Added: Taiwanese translations courtesy of @BlueNightSky
- Fixed: Priority of quest items in Hillsbrad Foothills for horde
- Fixed: Barracks blueprint not working for alliance

### Changes in 100105.42-Release:

- Changed: Update Interface version
- Changed: Certain items are now prioritized over others when there is a collision
- Changed: Update item database

### Changes in 100100.41-Release:

- Fixed: Old LibEditMode version

### Changes in 100100.40-Release:

- Changed: Update Interface version
- Changed: Update quest/item database

### Changes in 100005.39-Release:

- Changed: Update Interface version
- Fixed: Missing library

### Changes in 100002.38-Release:

- Fixed: Taint issues from dropdowns closing

### Changes in 100002.37-Release:

- Changed: Ignore items from Dracthyr starting area
- Fixed: Artwork dropdown not updating

### Changes in 100002.36-Release:

- Changed: Update Interface version

### Changes in 100000.35-Release:

- Fixed: Error generating item link from ID

### Changes in 100000.34-Release:

- Added: Slash command to let people know of the Edit Mode

### Changes in 100000.33-Release:

- Fixed: Button clicking not working
- Fixed: Quick keybind mode not working
- Fixed: Checked status not updating

### Changes in 100000.32-Release:

- Fixed: Button popping up when it shouldn't
- Fixed: Button not updating after leaving EditMode
- Fixed: EditMode overlay getting stuck

### Changes in 100000.31-Release:

- Added: Masque support
- Added: Artwork settings
- Changed: Use EditMode for positioning and settings
- Changed: Savedvariables has been reset because of EditMode integration

### Changes in 100000.30-Release:

- Changed: Update Interface version
- Changed: Dragonflight API updates
- Changed: Update quest/item database
- Fixed: Binding issues
- Removed: Option to change up/down state, this is controlled by a CVar now

### Changes in 90200.29-Release:

- Fixed: Binding not working

### Changes in 90200.28-Release:

- Changed: Actually update Interface version

### Changes in 90200.27-Release:

- Changed: Update Interface version

### Changes in 90105.26-Release:

- Changed: Update Interface version

### Changes in 90100.25-Release:

- Changed: Update quest/item database
- Fixed: Error when entering a zone with bad map data

### Changes in 90100.24-Release:

- Added: Option to activate on button up/down/both
- Added: German translations courtesy of @Nulgar
- Changed: Update quest/item database
- Fixed: Blacklisted items not being ignored

### Changes in 90100.23-Release:

- Changed: Update Interface version
- Changed: Updated quest/item database

### Changes in 90000.22-Release:

- Fixed: Completed quest items not correctly showing when they should
- Fixed: Validation of quest items throwing errors
- Fixed: Quests not correctly being checked against current map
- Changed: Update Interface version
- Changed: Updated quest/item database

### Changes in 90000.21-Release:

- Added: Option to set max distance to quest
- Added: Option to only show when quest is tracked
- Added: Option to only show when quest is in current zone
- Fixed: ExtraQuestButton showing up with no item
- Fixed: Hotkey text escaping the button

### Changes in 90000.20-Release:

- Changed: Bind without needing to change additional options
- Changed: Updated quest/item database
- Fixed: Errors when receiving item that has no distance data

### Changes in 90000.19-Release:

- Fixed: WorldQuest support

### Changes in 90000.18-Release:

- Fixed: Savedvariables not loading properly

### Changes in 90000.17-Release:

- Fixed: XML warnings for missing file

### Changes in 90000.16-Release:

- Fixed: Incorrect Interface version
- Fixed: Error from using removed API
- Removed: Debugging prints

### Changes in 90000.15-Release:

- Added: Support for items used on specific enemies
- Added: Support for decoupling keybinding from ExtraActionButton
- Changed: Decoupled position/scale/binding from ExtraActionButton
- Changed: Update Interface version
- Changed: Updated quest/item database
- Fixed: Shadowlands compatibility

### Changes in 80100.14-Release:

- Changed: Hide items for completed quests unless the game tells us otherwise
- Changed: Cache items for a slight performance gain
- Changed: Database updates
- Changed: Update Interface version
- Fixed: Some items are not properly flagged as part of a quest by Blizzard
- Fixed: Items the player doesn't have showing up as quest items
- Fixed: Button still showing after all the charges of an item has been used
- Fixed: Certain items not showing up after completing the quest objectives

### Changes in 80000.13-Release:

- Changed: Now respects the position of ExtraActionBarFrame (might need a /eqb reset)
- Changed: Updated quest database

### Changes in 80000.12-Release:

- Changed: User is now warned if other addons move ExtraActionButton
- Changed: Added icon texture to anchor button so it doesn't look like size changes when artwork is toggled
- Fixed: Button moving while scaling
- Fixed: Errors when scaling below a 0% (limited to 20% minimum now)
- Fixed: Excessive chat spam when scaling past limits
- Fixed: Scaling not rounded to nearest 10%, ending up at e.g. 89%
- Fixed: Button not following ExtraActionButton positioning from other addons

### Changes in 80000.11-Release:

- Added: Option to hide the artwork (will also hide it for ExtraActionButton)
- Changed: Moving the button also moves the ExtraActionButton
- Changed: Scaling the button also scales the ExtraActionButton
- Changed: New way to move, scale and hide the artwork (use /eqb)
- Fixed: Suramar action showing instead of quest item for Consolidating Power world quest
- Fixed: Missing indication that the item was being used (checked state)
- Fixed: Various errors

### Changes in 80000.10-Release:

- Fixed: Errors when leaving combat
- Fixed: Errors when resetting position

### Changes in 80000.9-Release:

- Added: Option to scale the button
- Added: Option to hide the artwork
- Added: More Darkmoon Faire items
- Added: Fallback slash command (/extraquestbutton)
- Changed: Update Interface version
- Fixed: Map logic for Battle for Azeroth
- Fixed: Toys being mistaken as quest items

### Changes in 70000.8-Release:

- Fixed: Items from other zones showing up

### Changes in 70000.7-Release:

- Added: Support for World Quests
- Changed: Updated quest database
- Fixed: Map not being set correct on login (Blizzard bug)

### Changes in 70000.6-Release:

- Changed: Update Interface version
- Changed: Updated quest database

### Changed in 60200.5-Beta:

- Added: Items that should specifically used on creatures
- Added: Midsummer Festival areas
- Changed: Update Interface version

### Changed in 60100.4-Beta:

- Changed: Updated untracked quest items

### Changed in 60100.3-Beta:

- Added: Item count
- Changed: Updated untracked quest items

### Changed in 60000.2-Beta:

- Added: Support for moving the button (/eqb)
- Changed: Updated untracked quest items

### Changed in 60000.1-Beta:

- First public release
