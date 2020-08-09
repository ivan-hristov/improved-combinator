local logger = require("logger")

local function list_node(data)
    return {data = data}
end

local recreate_metatables = false
local list = {}
list.__index = list

function list:new()
    new_list = {}
    setmetatable(new_list, list)
    new_list.length = 0
    new_list.front = nil
    new_list.back = nil
   return new_list
end

function list.deep_copy(root_node, other_list)
    local new_list = list:new()

    for other_element in other_list:iterator() do
        local id = other_element.data.id
        local node_element = root_node:recursive_find(id)
        local children = list:new()

        for other_child in other_element.data.children:iterator() do
            local child_id = other_child.data.id
            local child_node_element = root_node:recursive_find(child_id)
            children:push_back({id = child_id, node_element = child_node_element})
        end

        new_list:push_back({id = id, node_element = node_element, children = children})
    end

    return new_list
end

function list.recreate_metatables()
    if not recreate_metatables then
        for _, entity in pairs(global.entities) do
            if not entity.update_list.valid then
                list:create_metatable(entity.update_list)

                for element in entity.update_list:iterator() do
                    list:create_metatable(element.data.children)
                end
            end
        end
        recreate_metatables = true
    end
end

function list:create_metatable(existing_list)
    setmetatable(existing_list, self)
    self.__index = self
end

function list:push_front(value)
    local node = list_node(value)
    if self.front then
        self.front.prev = node
        node.next = self.front
        self.front = node
    else
        self.front = node
        self.back =  node
    end
    self.length = self.length + 1
end

function list:push_back(value)
    local node = list_node(value)
    if self.back then
        self.back.next = node
        node.prev = self.back
        self.back = node
    else
        self.front = node
        self.back = node
    end
    self.length = self.length + 1
end

function list:get_element(id)
    for element in self:iterator() do
        if element.data.id == id then
            return element.data
        end
    end

    return nil
end

function list:remove(id)
    for element in self:iterator() do
        if element.data.id == id then

            if element == self.back then
                if self.back.prev then
                    self.back = self.back.prev
                    self.back.next = nil
                    element = nil
                else
                    self.front = nil
                    self.back = nil
                end
            elseif element == self.front then
                if self.front.next then
                    self.front = self.front.next
                    self.front.prev = nil
                    element = nil
                else
                    self.front = nil
                    self.back = nil
                end
            else
                local prev = element.prev
                local next = element.next
                
                prev.next = next
                next.prev = prev
                element = nil                
            end

            self.length = self.length - 1
        end
    end
end

function list:iterator()
    local element = self.front
    return function ()
        if element then
            local result = element
            element = element.next
            return result
        end
    end
end

function list:reverse_iterator()
    local element = self.back
    return function ()
        if element then
            local result = element
            element = element.prev
            return result
        end
    end
end

function list:clear()
    local element = self.front
    while element do
        local next = element.next
        element = nil
        element = next
    end
    self.front = nil
    self.back = nil
    self.length = 0
end

function list:valid()
    return true
end

return list