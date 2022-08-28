local pi = pi

local meta = FindMetaTable("PIP")

--- Debug function that I created for test :>
--- @return void
function meta:Info()
    pi.print("Hey, my name is \"" .. self.Name .. "\"!")
end