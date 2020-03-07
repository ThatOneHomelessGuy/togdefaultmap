# TOG Defaul Map
(togdefaultmap)

Changes to default map when server is empty


## Installation:
* Put togdefaultmap.smx in the following folder: /addons/sourcemod/plugins/


## CVars:
<details><summary>Click to View CVars</summary>
<p>

* **togdefaultmap_map** - Map to change to when the server is empty.
</p>
</details>


Note: After changing the cvars in your cfg file, be sure to rcon the new values to the server so that they take effect immediately.



## Changelog:
<details>
<summary>Click to Open Spoiler</summary>
<p>
1.0.2
* Added check for if current map is the default to ensure it doesnt try to map change if it is already on the correct map.
* Added timer validation to make sure that timers from the previous map dont fire in the next. They shouldnt due to flag TIMER_FLAG_NO_MAPCHANGE, but there is documentation out there than notes that TIMER_FLAG_NO_MAPCHANGE has some bugs.

1.0.1
* Updated to new syntax.

1.0
* Initial creation.
</p>
</details>






### Check out my plugin list: http://www.togcoding.com/togcoding/index.php
