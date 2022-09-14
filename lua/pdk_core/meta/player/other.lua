local meta = FindMetaTable( "Player" )

--- Returns a unique key for this player. You can override this function to implement different character systems.
--- @return any
meta.GetUID = meta.SteamID64