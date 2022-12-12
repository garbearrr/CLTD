# CLTD
Roblox Command Line Tower Defense Game Demo

**To View/Play Game**

Download Roblox Studio here: https://www.roblox.com/create.

CLTD.rbxl can be opened in Roblox Studio and it contains all code, models, etc.

A free Roblox account is required to use Roblox Studio.

**Studio Tour**

When initially loading up the project you should see a scene with a free camera that you can control. This is the game's environment. We used the outside parts of the scene to store our 3D models. It is much more efficient to clone existing models rather than instance a new one.

Make sure you select these options in the view tab to view models and code:
![image](https://user-images.githubusercontent.com/80983143/207147491-97d3abbd-b8fb-4057-bbc7-c11d9b189e99.png)

If you want to see the models, check out the models folder in workspace. If you can't find them in the scene, select one of the models and press F to teleport to the model. You can use WASD to control the free camera and look around:
![image](https://user-images.githubusercontent.com/80983143/207147679-ef11863c-a9c4-4540-a610-9ae6906f619d.png)

A majority of our code is found in the game's replicated storage. Roblox follows a client-server model. Replicated storage offers storage accessible by both the client and server side. This is not secure storage and sensitive assets should be stored server-side if this were a public game. However, our game has no interaction with server side. Everything is client side. A common use of server scripts is to interface with Roblox's database system for user cloud storage. We did not make the FastCastRedux module. This is an extremely common module included in almost every roblox game. It is a wrapper that allows for fast and accurate raycasting. We used it to track user clicks on the screen.
![image](https://user-images.githubusercontent.com/80983143/207147795-9c20bd76-79f0-4709-9d4a-e12f80d7337b.png)

StarterGui is a place where UI elements can be constructed. These elements are assigned to every user as soon as they join the game. A lot of these elements are invisible by default. If you want access to the debug menu in game, press D and then you can interact with it using the mouse.
![image](https://user-images.githubusercontent.com/80983143/207148291-689f470e-325a-4d2f-8f99-d02d3a1916ed.png)

Finally, we have an entry point script in StarterCharacterScripts. This script is assigned and executed as soon as a player's character is loaded. The reason we want this script to execute when the character is loaded and not when the player joined is because the player's camera is not loaded until the character is loaded. Usually, roblox games include the player's character in a first/third person way. However, it doesn't always have to be this way. We locked the character's movement and placed it below the scene so it can exist without causing trouble. Then, we move the camera above our generated board to give a top down view of our game.
![image](https://user-images.githubusercontent.com/80983143/207148510-4e309cba-2ada-4d59-acd6-3c0fb0f8af1f.png)

When you are ready to play, press the blue play button.
![image](https://user-images.githubusercontent.com/80983143/207148999-754707a1-d31f-41b4-8ca5-7ff53855a5eb.png)

The main code of the game are also in folders above the project file. It is 100% scripted with Lua.

**About**

Command Line Tower Defense is a Roblox-based tower defense game with a terminal theme.

The goal is to stop the enemies from reaching the home base at the end of the randomly generated path by placing various towers to destroy the enemies.

In game, click the tower in the shop on the right side to enable build mode. Then, move your mouse to your desired location and click to place the tower.
