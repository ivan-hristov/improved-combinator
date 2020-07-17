queue = {}
queue.__index = queue

function queue:new()
    new_queue = {}
    setmetatable(new_queue, queue)
    new_queue.first = 0
    new_queue.last = -1
    return new_queue
end

function queue:is_empty()
    if self.first > self.last then
        return true
    else
        return false
    end
end

function queue:push_front(value)
    local first = self.first - 1
    self.first = first
    self[first] = value
end

function queue:push_back(value)
    local last = self.last + 1
    self.last = last
    self[last] = value
end

function queue:pop_front()
    local first = self.first
    if self:is_empty() then
        return nil
    end
    local value = self[first]
    self[first] = nil
    self.first = first + 1
    return value
end

function queue:pop_back()
    local last = self.last
    if self:is_empty() then
        return nil
    end
    local value = self[last]
    self[last] = nil
    self.last = last - 1
    return value
end
