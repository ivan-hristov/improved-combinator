local uid = require("scripts.uid")
local logger = require("scripts.logger")

local node = {}

function node.new(entity_id)
    local self = {}
    self.id = uid.generate()
    self.entity_id = entity_id
    self.event_ids = {}
    self.events = {}
    self.parent = nil
    self.gui = {}
    self.children = {}
    return self
end

function node.add_child(node_param)
    new_node = node.new(node_param.entity_id)
    new_node.parent = node_param
    node_param.children[new_node.id] = new_node
    return new_node
end

function node.remove_child(node_param, id)
    if node_param.children[id] then
        node.clear_children(node_param.children[id])
        node.clear_events(node_param.children[id])
        node_param.children[id] = nil
    end
end

function node.remove(node_param)
    if node_param.parent then
        node.remove_child(node_param.parent, node_param.id)
    else
        node.clear_children(node_param)
        node.clear_events(node_param)
        node_param.id = nil
        node_param.entity_id = nil
        node_param.event_ids = nil
        node_param.events = nil
        node_param.parent = nil
        node_param.gui = nil
        node_param.children = nil
    end
end

function node.clear_children(node_param)
    for _, child in pairs(node_param.children) do
        node.clear_children(child)
        node.clear_events(child)
    end
    node_param.children = {}
end

function node.clear_events(node_param)
    node_param.event_ids = {}
    node_param.events = {}
end

function node.recursive_find(node_param, id)
    if node_param.id == id then
        return node_param
    else
        for _, child in pairs(node_param.children) do
            local child_node = node.recursive_find(child, id)
            if child_node then
                return child_node
            end
        end
    end
    return nil
end

return node