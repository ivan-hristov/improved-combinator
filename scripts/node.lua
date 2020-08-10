local constants = require("constants")
local uid = require("uid")
local list = require("list")
local logger = require("logger")

local node = {}
local recreate_metatables = false

function node:new(entity_id, gui)
    new_node = {}
    setmetatable(new_node, self)
    self.__index = self
    new_node.id = uid.generate()
    new_node.entity_id = entity_id
    new_node.parent = nil
    new_node.events_id = {}
    new_node.events_params = {}
    new_node.events = {}
    new_node.gui_element = nil  -- Non-persistent Factorio element
    new_node.children = {}
    new_node.update_logic = nil
    new_node.updatable = false

    if gui then
        new_node.gui = gui
        new_node.gui.name = new_node.id
    else
        new_node.gui = {}
    end

    return new_node
end

local function simple_deep_copy(object)
    if type(object) ~= 'table' then
        return object
    end
    local result = {}
    for k, v in pairs(object) do
        result[simple_deep_copy(k)] = simple_deep_copy(v)
    end
    return result
end

function node.deep_copy(entity_id, parent_node, other_node)
    local new_node = node:new(entity_id)

    new_node.id = other_node.id
    new_node.parent = parent_node
    new_node.events_id = simple_deep_copy(other_node.events_id)
    new_node.events_params = simple_deep_copy(other_node.events_params)
    new_node.events = simple_deep_copy(other_node.events)
    new_node.gui = simple_deep_copy(other_node.gui)
    new_node.update_logic = simple_deep_copy(other_node.update_logic)
    new_node.updatable = other_node.updatable

    node:setup_events(new_node)

    for _, children in pairs(other_node.children) do
        local new_child = node.deep_copy(entity_id, new_node, children)
        new_node.children[new_child.id] = new_child
    end

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

function node:add_child(gui)
    new_node = self:new(self.entity_id)
    new_node.parent = self
    if gui then
        new_node.gui = gui
        new_node.gui.name = new_node.id
    end
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
    self:update_list_remove()
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

function node:find_child(id)
    for _, child in pairs(self.children) do
        if child.id == id then
            return child
        end
    end
    return nil
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

function node:update_list_push()
    if not self.updatable then
        global.entities[self.entity_id].update_list:push_back({ id = self.id, node_element = self, children = list:new() })
        self.updatable = true
    end
end

function node:root_parent()
    if self.parent then
        return self.parent:root_parent()
    else
        return self
    end
end

function node:update_list_remove()
    if self.updatable then
        local list_element = global.entities[self.entity_id].update_list:get_element(self.id)
        list_element.children:clear()
        global.entities[self.entity_id].update_list:remove(self.id)
        self.updatable = false
    end
end

function node:update_list_child_push(parent_node)
    if parent_node.updatable then
        local list_element = global.entities[parent_node.entity_id].update_list:get_element(parent_node.id)
        list_element.children:push_back({ id = self.id, node_element = self })
    end
end

function node:update_list_child_remove(parent_node)
    if parent_node.updatable then
        local list_element = global.entities[parent_node.entity_id].update_list:get_element(parent_node.id)
        list_element.children:remove(self.id)
    end
end

function node:debug_print(index)

    local debug_string = ""
    for i=1,index do
        debug_string = debug_string.."   "
    end

    index = index + 1

    for _, chilren in pairs(self.children) do
        chilren:debug_print(index)
    end
end

function node:debug_print_factorio_gui(element, index, max_level)
    local str = ""

    for i=1,index do
        str = str.."    "
    end

    index = index + 1
    if index >= max_level then
        return
    end

    str = str.."name: "..element.name..", type: "..element.type
    if element.type == "label" and element.caption then
        str = str..", caption: "

        for i = 1, #element.caption do
            str = str.." "..element.caption:sub(i,i)
        end
    end
    
    str = str.."\n"

    for _, child in pairs(element.children) do
        str = str..node:debug_print_factorio_gui(child, index, max_level)
    end

    return str
end

return node