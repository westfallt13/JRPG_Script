# DEVLOGS (Thomas Westfall) #
## Note: This document is intended to track the development progress and changes made to the JRPG framework. It will be updated regularly with new entries detailing the work done on the project, including additions, modifications, and any relevant notes or observations.

### Note To Self: After any changes, please build up the habit of writing down your work rather solely relying on commit history to be more efficient ###

### Notes ###
-/data/item_database/equipment/ - These subfolders are well organized for specific types of equipment to shorten the time it takes to find and edit specific items. This structure will also make it easier to expand the item database in the future with new categories of equipment.
-/data/stats/ This folder will contain files for character stats, enemy stats, and any other relevant statistics for the game. Keeping these organized in a separate folder will help maintain clarity and ease of access when making adjustments to game balance or character progression.

-There are various subfolders throughout everything to keep things organized and easy to navigate. This structure will help ensure that as the project grows, it remains manageable and that specific files can be quickly located when needed.

## 2026, June 17th ##
1. Added data folder, with item database and stats subfolders. Created initial item database and stats files with basic structure and placeholder content.
2. Updated README.md with project overview, structure, and systems descriptions. Added license information and usage guidelines.
3. Committed initial framework files and README.md to repository. Excluded game-specific content with .gitignore.
4. Created DEVLOGS.md to track development progress and changes. Will update with future edits and additions to the framework.
5. Broke up large files into smaller, more manageable ones for better organization and maintainability. This will help improve readability and make it easier to navigate the codebase as it grows in complexity.


##2026, June 18th ##
1. Laid out placeholder scheme definitions in dictionaries for both weapon and armor types. This will serve as a template for future item entries and help ensure consistency across the item database.
2. Renamed all .gd files in the weapon_types with a "dict." before declaring the armor type, so that dictionary files are easily identifiable and distinguishable from other script files. This will improve organization and make it easier to locate specific item definitions when needed. 
### Note: This is not currently fully implemented across all dictionaries, please do so as this naming convention will be applied to all future item definition files to maintain consistency and clarity in the project structure. ###
3. Added extra guides, all guides and some dictionaries still need fleshed out with actual content, but the structure is now in place to easily add new items and stats as development progresses. This will allow for a more efficient workflow when expanding the game's content in the future.
4. Updated README.md and DATA_FOLDER_STRUCTURE.md to reflect the new structure and added notes on the purpose of each folder and file. This will help ensure that anyone building upon the project has a clear understanding of where to find specific files and how the overall structure is organized. It will also serve as a reference for future development and help maintain consistency as the project evolves.


