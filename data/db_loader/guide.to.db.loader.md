### DB_Loader.gd - An autoload script that will read every JSON/ folder into typed arrays (axes, swords, boots, etc.). Any menu/battle calculations just iterate the relevant array. ###

## To-Do ##

1. Create a system in each subfolder to access the relevant JSON objects and load them individually into typed arrays. This will likely involve creating a function in each subfolder that reads the JSON files, parses the data, and stores it in a structured format (e.g., dictionaries or custom classes) for easy access during gameplay.
2. Test the loading of JSON data into the typed arrays to ensure that the data is being read correctly and stored in the expected format. This will likely involve creating test cases with sample JSON files and verifying that the data is loaded correctly into the arrays.
3. Create a system to access the loaded data from the typed arrays during gameplay, such as when equipping an item or calculating combat effects. This will likely involve creating functions that can retrieve the relevant data from the arrays based on certain criteria (e.g., item ID, type, etc.) and use that data for UI display and combat calculations.
4. Implement error handling for cases where JSON files are missing, corrupted, or contain invalid data. This will likely involve using the print function to log errors and output analysis toensure that the game can reliably access the data, while also providing feedback for debugging purposes if problems arise.

### IMPORTANT ###
 Optimize the loading process to ensure that it does not cause significant delays during game startup. This may involve implementing lazy loading techniques, where data is only loaded when it is first accessed, rather than loading everything at once during startup. This will help to improve the overall performance of the game while still ensuring that all necessary data is available when needed.