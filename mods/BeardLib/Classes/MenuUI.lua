MenuUI = MenuUI or class()
function MenuUI:init( config )
	local ws = managers.gui_data:create_fullscreen_workspace()   
 	ws:connect_keyboard(Input:keyboard())  
    ws:connect_mouse(Input:mouse())  
	self._fullscreen_ws = ws
    self._fullscreen_ws_pnl = ws:panel():panel({alpha = 0})
    self._options = {}
    self._menus = {}
    self._panel = self._fullscreen_ws_pnl:panel({
        name = "menu_panel",
        halign = "center", 
        align = "center",
        layer = config.layer or 100,
        h = config.h or self._fullscreen_ws_pnl:h(),
        w = config.w or self._fullscreen_ws_pnl:w(),
    })      
    if config.position == "right" then
        self._panel:set_right(self._fullscreen_ws_pnl:right())
    elseif config.position == "center" then     
        self._panel:set_center(self._fullscreen_ws_pnl:center())
    end
    self._scroll_panel = self._panel:panel({
        name = "scroll_panel",
        halign = "center", 
        align = "center",
        y = config.tabs and 35 or 0,
        h = self._panel:h() - (config.tabs and 35 or 0),
    })	
    local bar_h = self._scroll_panel:top() - self._scroll_panel:bottom()
    self._scroll_panel:panel({
        name = "scroll_bar",
        halign = "center", 
        align = "center",
        w = 4,
        layer = 20,
    }):rect({
		name = "rect",
		color = Color.black,
		layer = 4,
		alpha = 0.5,
		h = bar_h,
    })
    self._fullscreen_ws_pnl:rect({
      	name = "crosshair_vertical", 
      	w = 2,
      	h = 6,
      	alpha = 0.8, 
        layer = 999 
    }):set_center(self._fullscreen_ws_pnl:center())        
    self._fullscreen_ws_pnl:rect({
      	name = "crosshair_horizontal", 
      	w = 6,
      	h = 2,
      	alpha = 0.8, 
        layer = 999 
    }):set_center(self._fullscreen_ws_pnl:center())
    self._panel:rect({
      	name = "menu_bg", 
      	halign="grow", 
      	valign="grow", 
      	alpha = 0.8, 
        layer = 19 
    })      
	self._help_panel = self._panel:panel({
        name = "help_panel",
        x = 30,
	    y = 10,
	    w = self._panel:w() - 100,
        layer = 20,
     })   
    self._help_panel:rect()
    self._help_panel:rect({
    	name = "line",
    	w = 2,
    	color = Color(0, 0.5, 1),
    })
	self._help_text = self._help_panel:text({
	    name = "help_text",
	    text = "",
	    layer = 1,
	    wrap = true,
	    x = 4,
	    word_wrap = true,
	    valign = "left",
	    align = "left",
	    vertical = "top",	    
	    color = Color.black,
	    font = "fonts/font_large_mf",
	    font_size = 16
	})      
    table.merge(self, config)
	local _,_,w,h = self._help_text:text_rect()
	self._help_panel:set_size(w + 10,h)
	if config.create_items then
		config.create_items(self)
	else
		BeardLib:log("No create items callback found")
	end
    self._menu_closed = true    

    self._fullscreen_ws_pnl:key_press(callback(self, self, "key_press"))    
    self._fullscreen_ws_pnl:key_release(callback(self, self, "key_release"))    
    return self
end

function MenuUI:NewMenu(params)
	return Menu:new(self, params)
end

function MenuUI:AlignMenus() 
    for i, menu in pairs(self._menus) do
        if menu.panel then
            menu.panel:set_left(self._menus[i - 1] and self._menus[i - 1].panel:right() + 2 or 5)
        end
    end
end

function MenuUI:enable()
	self._fullscreen_ws_pnl:set_alpha(1)
	self._menu_closed = false
	managers.mouse_pointer:use_mouse({
		mouse_move = callback(self, self, "mouse_moved"),
		mouse_press = callback(self, self, "mouse_pressed"),
		mouse_release = callback(self, self, "mouse_release"),
		id = self._mouse_id
	}) 	
    self._fullscreen_ws_pnl:key_press(callback(self, self, "key_press"))    
    self._fullscreen_ws_pnl:key_release(callback(self, self, "key_release"))    	
end

function MenuUI:disable()
	self._fullscreen_ws_pnl:set_alpha(0)
	self._menu_closed = true
	self._highlighted = nil
	if self._current_menu then
		for _, item in pairs(self._current_menu._items) do
			item.highlight = false
		end	
	end
	if self._openlist then
	 	self._panel:child(self._openlist.name .. "list"):set_visible(false)
	 	self._openlist = nil
	end		
	self._fullscreen_ws_pnl:key_press(nil)    
    self._fullscreen_ws_pnl:key_release(nil)    
	managers.mouse_pointer:remove_mouse(self._mouse_id)
end

function MenuUI:key_release( o, k )
	self.key_pressed = nil
    if self.keyrelease then
        self.keyrelease(o, k)
    end
end
 
function MenuUI:key_press( o, k )
    if self._menu_closed then
        return
    end
	self.key_pressed = k 
	for _, menu in ipairs(self._menus) do
		menu:key_press( o, k )		
	end		
    if self.keypress then
        self.keypress(o, k)
    end	
end

function MenuUI:set_help(help)
	self._help_text:set_text(help)
	local _,_,w,h = self._help_text:text_rect()
	self._help_panel:set_size(w + 10,h)
end
function MenuUI:mouse_release( o, button, x, y )
	self._slider_hold = nil
	self._grabbed_scroll_bar = nil
    if self.mouserelease then
        self.mouserelease(o, k)
    end    
end

function MenuUI:mouse_pressed( o, button, x, y )
	for _, menu in ipairs(self._menus) do
		if menu:mouse_pressed( o, button, x, y ) then
		    return
		end
	end	
    if self.mousepressed then
        self.mousepressed(button, x, y)
    end      	
end
function MenuUI:mouse_moved( o, x, y )
	for _, menu in ipairs( self._menus ) do
		menu:mouse_moved( o, x, y )
	end
	self._old_x = x	
	self._old_y = y	
end
function MenuUI:SwitchMenu( Menu )  
    self._current_menu:SetVisible(false)
    Menu:SetVisible(true)
    self._current_menu = Menu
end
function MenuUI:GetItem( name )  
	for _,menu in pairs(self._menus) do
		if menu.name == name then			
			return menu
		else
			local item = menu:GetItem(name) 
			if item and item.name then
				return item
			end 
		end
	end
end  
 