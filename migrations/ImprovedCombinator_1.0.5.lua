local old_entity_update_list = {}

-- Copy the old update_list data and store it in a table
for entity_id, entity in pairs(global.entities) do
    local update_list = {}
    local iter = entity.update_list.front

    while iter do
        local children = {}

        local child_iter = iter.data.children.front
        while child_iter do
            table.insert(children, {id = child_iter.data.node_element.id, data = child_iter.data.node_element})
            child_iter = iter.data.children.next
        end
        table.insert(update_list, {id = iter.data.node_element.id, data = {node = iter.data.node_element, children = children}})

        iter = iter.next
    end

    old_entity_update_list[entity_id] = update_list
end

-- Clear old global update list
for _, entity in pairs(global.entities) do
    local iter = entity.update_list.front
    while iter do
        local child_iter = iter.data.children.front
        while child_iter do
            local next = iter.data.children.next
            child_iter = nil
            child_iter = next
        end
        local next = iter.next
        iter = nil
        iter = next
    end
    entity.update_list = nil
end

-- Copy new array update list into the global data
for entity_id, entity in pairs(global.entities) do
    global.entities[entity_id].update_list = old_entity_update_list[entity_id]
end
