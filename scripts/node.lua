local uid = require("scripts.uid")
local logger = require("scripts.logger")

node = {}

function node:new(entity_id)
    new_node = {}
    setmetatable(new_node, self)
    self.__index = self
    new_node.id = uid.generate()
    new_node.entity_id = entity_id
    new_node.parent = nil
    new_node.events = {}
    new_node.gui = {}
    new_node.children = {}
    return new_node
end

function node:add_child()
    new_node = self:new(self.entity_id)
    new_node.parent = self
    self.children[new_node.id] = new_node
    return new_node
end

function node:remove_child(id)
    if self.children[id] then
        self.children[id]:clear_children()
        self.children[id] = nil
    end
end

function node:remove()
    if self.parent then
        self.parent:remove_child(self.id)
    else
        self:clear_children()
        self.id = nil
        self.entity_id = nil
        self.parent = nil
        self.events = {}
        self.gui = {}
        self.children = {}
    end
end

function node:clear_children()
    for _, child in pairs(self.children) do
        child:clear_children()
    end
    self.children = {}
end

function node:recursive_find(id)
    if self.id == id then
        return self
    else
        for _, child in pairs(self.children) do
            local child_node = child:recursive_find(id)
            if child_node then
                return child_node
            end
        end
    end

    return nil
end

function node:debug_print()
    logger.print("id: "..self.id.." gui: "..self.gui.style)
    for _, child in pairs(self.children) do
        child:debug_print()
    end
end

return node