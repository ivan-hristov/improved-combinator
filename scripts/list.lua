local function list_node(data)
    return {data = data}
end

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

function list:remove(id)
    for element in self:iterator() do
        if element.data.id == id then
            local prev = element.prev
            local next = element.next
            prev.next = next
            next.prev = prev
            element = nil
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

return list