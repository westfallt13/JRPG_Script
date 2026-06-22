### How To Install and Use This Framework In Godot ###

## Step 1: Make sure you're using Godot 4.6 or later ##
This framework is built and tested with Godot 4.6, so make sure you have that version or later installed to ensure compatibility. You can download the latest version of Godot from the official website: https://godotengine.org/download 
## Step 2: Clone or download the repository ##
### You can clone the repository using Git or download it as a ZIP file from the GitHub page. ###

## Cloning with Git: ##
- Run the following command in your terminal from the root of your Godot project folder (if you want all the code in a subfolder for code specifically, clone this into a subfolder named "Engine" or something similar):
```git clone https://github.com/westfallt13/JRPG_Script.git
```

2. ## Downloading the ZIP file: ##
- Go to the GitHub repository page: https://github.com/westfallt13/JRPG_Script
- Click on the "Code" button and select "Download ZIP".
- Extract the downloaded ZIP file to your desired location within your Godot project folder (e.g., into a subfolder named "Engine" or something similar).

## Step 3: Open the project in Godot ##
- Launch Godot and open your project. 
- If you cloned the repository into a subfolder, make sure to adjust any file paths in your project settings or scripts to point to the correct location of the framework files.
- If you downloaded the ZIP file and extracted it, ensure that the files are placed in the correct location within your project folder and adjust any file paths as needed.

## Step 4: Set up the autoload for the DB loader ##
- In Godot, go to "Project" > "Project Settings" > "Autoload".
- Click the "Add" button and select the `db_loader.gd` script from the framework (located in `data/db_loader/db_loader.gd`).
- Name the autoload (e.g., "DbLoader") and click "Add". This will allow you to access the database loader from anywhere in your project using `DbLoader`.
## Step 5: Start using the framework :) ##
