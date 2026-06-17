# Version 1:
	- Menu to switch modes.
	- Packaging ui only app for android.

	Complete. App loads, burgermenu popup allows switching between nodes in a menu.

# Version 2:
	- Bare bones Notes mode.
		- Type text.
		- Save text.
		- Show recorded notes with timestamps.
	
	Complete. Notes are saved to memory and not permanent if app is closed.

# Version 3:
	- JSON note saving.
	- Notes save locally to JSON and are persistent if app is closed.
	- Longpress note context menu with delete option.
	- Be careful to think about future proofing for added features like campaigns, SQLite databases, backlinks etc.
	- *Version 2 feedback.*
		- Notes scroll not scrolling on device. (Solved. Notes are now instanced scenes that have singular functionality with tapped/longpressed etc.)
		- Android keyboard interaction like copy paste selection etc not available currently. (Not solved. A can of worms. Native Android keyboard features will have to wait till later.)

	Complete. Notes are saved to JSON locally and are persistant across sessions. User can delete notes by long pressing and selecting delete from the context menu. Notes saving/loading/deleteing logic moved to dedicated NotesStore autoload script.

# Version 4:
	- Newest first sorting. New notes appear at the bottom like a messaging app and older notes float upwards over the top of the screen.
	- Empty state text.
	
	Complete. Empty state reporting + New notes appear at the bottom and old notes float up and off of the screen.

#Version 5:
	- Decide on a syntax for backlinks. (Can we manipulate android keyboard to show specific utility keys?)
	- Show backlinks in notes stack as highlighted normal text.
	- Glossary mode shows a "set" of all backlinks.
	
	Complete. Backlinks created with [square brackets] now show in notes stack as highlighted text and as a list in glossary mode.

#Version 6:
	- Improved glossary items display. Use item cards similar to what we do with notes. 
	- Glossary references should be expandable and later contain more features.
	- The reference itself should be the title on the left side with an arrow on the right side suggesting it is expandable.
	- When expanded it should just say "Features coming soon..."
