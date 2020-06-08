local constants = require("constants")
local uid = require("scripts.uid")
local events = require("scripts.events")
local logger = require("scripts.logger")

local node = {}

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
    new_node.children = {}
    return new_node
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
    self.id = nil
    self.entity_id = nil
    self.parent = nil
    self.events_id = {}
    self.events_params = {}
    self.events = {}
    self.gui = {}
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

function node:valid()
    return true
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

function node:create_main_gui(unit_number)
    local root = node:new(unit_number)
    root.gui = {
        type = "frame",
        direction = "vertical",
        name = root.id,
        style = constants.style.main_frame,
        caption = "MAIN FRAME "..unit_number
    }

    local tasks_area = root:add_child()
    tasks_area.gui = {
        type = "frame",
        direction = "vertical",
        name = tasks_area.id,
        style = constants.style.tasks_frame
    }

    local scroll_pane = tasks_area:add_child()
    scroll_pane.gui = {
        type = "scroll-pane",
        direction = "vertical",
        name = scroll_pane.id,
        style = constants.style.scroll_pane
    }

    local new_task_button = scroll_pane:add_child()
    new_task_button.gui = {
        type = "button",
        name = new_task_button.id,
        style = constants.style.large_button_frame,
        caption = "+ Add Task"
    }

    local task_dropdown_frame = scroll_pane:add_child()
    task_dropdown_frame.gui = {
        type = "frame",
        direction = "vertical",
        name = task_dropdown_frame.id,
        style = constants.style.dropdown_options_frame,
        visible = false
    }
    new_task_button.events_id.on_click = "on_click_new_task_button"
    new_task_button.events_params = { task_dropdown_frame_id = task_dropdown_frame.id}

    local task_dropdown_list = task_dropdown_frame:add_child()
    task_dropdown_list.gui = {
        type = "list-box",
        name = task_dropdown_list.id,
        style = constants.style.options_list,
        items = {"Repeatable Timer", "Single Use Timer"}    
    }
    task_dropdown_list.events_id.on_selection_state_changed = "on_selection_changed_task_dropdown"

    root:recursive_setup_events()
    return root
end

function node:setup_events(node_param)
    if not node_param.events_id then
        return
    elseif node_param.events_id.on_click then
        if node_param.events_id.on_click == "on_click_new_task_button" then
            node_param.events.on_click = events.on_click_new_task_button
        elseif node_param.events_id.on_click == "on_click_close_button" then
            node_param.events.on_click = events.on_click_close_button
        end
    elseif node_param.events_id.on_selection_state_changed then
        if node_param.events_id.on_selection_state_changed == "on_selection_changed_task_dropdown" then
            node_param.events.on_selection_state_changed = {}
            node_param.events.on_selection_state_changed[1] = events.on_selection_repeatable_timer
            node_param.events.on_selection_state_changed[2] = events.on_selection_single_timer
        end
    end
end


return node