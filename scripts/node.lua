local constants = require("constants")
local uid = require("uid")
local list = require("list")
local logger = require("logger")

local node = {}
local recreate_metatables = false

function node:new(entity_id)
    new_node = {}
    setmetatable(new_node, self)
    self.__index = self
    new_node.id = uid.generate()
    new_node.entity_id = entity_id
    new_node.parent = nil
    new_node.events_id = {}
    new_node.events_params = {}
    new_node.events = {}
    new_node.gui = {}
    new_node.gui_element = nil  -- Non-persistent Factorio element
    new_node.children = {}
    new_node.update_logic = nil
    new_node.updatable = false
    return new_node
end

function node.recreate_metatables()
    if not recreate_metatables then
        for _, entity in pairs(global.entities) do
            if not entity.node.valid then
                node:recursive_create_metatable(entity.node)
            end
        end
        recreate_metatables = true
    end
end

function node:create_metatable(node_param)
    setmetatable(node_param, self)
    self.__index = self
end

function node:recursive_create_metatable(node_param)
    node:create_metatable(node_param)
    node:setup_events(node_param)
    for _, child in pairs(node_param.children) do
        node:recursive_create_metatable(child)
    end
end

function node:recursive_setup_events()
    node:setup_events(self)
    for _, child in pairs(self.children) do
        child:recursive_setup_events()
    end
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
        self.children[id]:clear()
        self.children[id] = nil
    end
end

function node:remove()
    if self.parent then
        self.parent:remove_child(self.id)
    else
        self:clear_children()
        self:clear()
    end
end

function node:clear_children()
    for _, child in pairs(self.children) do
        child:clear_children()
    end
    self:clear()
end

function node:clear()
    self:update_lish_clear()
    self.id = nil
    self.entity_id = nil
    self.parent = nil
    self.events_id = {}
    self.events_params = {}
    self.events = {}
    self.gui = {}
    self.gui_element = nil
    self.children = {}
    self.update_logic = nil
    self.updatable = false
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

function node:valid()
    return true
end

function node:update_lish_push()
    if not self.updatable then
        global.entities[self.entity_id].update_list:push_back({ id = self.id, node_element = self, children = list:new() })
        self.updatable = true
    end
end

function node:update_lish_clear()
    if self.updatable then
        global.entities[self.entity_id].update_list:remove(self.id)
        self.updatable = false
    end
end

function node:debug_print(index)

    local debug_string = ""
    for i=1,index do
        debug_string = debug_string.."   "
    end

    index = index + 1
    logger.print(debug_string.."node_id: "..self.id..", gui_type: "..self.gui.type)

    for _, chilren in pairs(self.children) do
        chilren:debug_print(index)
    end
end


return node