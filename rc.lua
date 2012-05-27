-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- The widget wicked
require("wicked")
-- Battery
require("vicious")
local vicious = vicious




-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
local home   = os.getenv("XDG_CONFIG_HOME")
--local home   = os.getenv("HOME")

-- Themes define colours, icons, and wallpapers
----autiful.init(home .. "/awesome/themes/default/theme.lua")
--beautiful.init("/usr/share/awesome/themes/default/theme.lua")
beautiful.init(home .. "/awesome/themes/zenburn/theme.lua")

-- This is used later as the default terminal and editor to run.
-- terminal = "gnome-terminal"
terminal = "urxvt"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,				--1
    awful.layout.suit.tile,					--2
    awful.layout.suit.tile.left,			--3
    awful.layout.suit.tile.bottom,			--4
    awful.layout.suit.tile.top,				--5
    awful.layout.suit.fair,					--6
    awful.layout.suit.fair.horizontal,		--7
    awful.layout.suit.spiral,				--8
    awful.layout.suit.spiral.dwindle,		--9
    awful.layout.suit.max,					--10
    awful.layout.suit.max.fullscreen,		--11
	awful.layout.suit.magnifier				--12
}
-- }}}



-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
	names = { "1-Terminal", "2-Chrome","3-Office","4-Notes","5-Net","6-VirtualBox","7-Media","8-Other"},
	layout = {  layouts[2] , -- 1-Terminal
				layouts[12], -- 2-Chrome
				layouts[10], -- 3-Office
				layouts[2] , -- 4-Notes
				layouts[10], -- 5-SNS
	            layouts[10] , -- 6-VirtualBox
				layouts[1] , -- 7-Media
				layouts[6] , -- 8-Other
			}
			  }
for s = 1, screen.count() do
    -- Each screen has its own tag table.
	tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}
powermenu = {
	{ "Power Off",		"sudo halt"},
	{ "Reboot",			"sudo reboot"},
	{ "Lock",			"xlock -mode blank"},
	{ "suspend",		"sudo pm-suspend"}
}
myappmenu = {
	{ "VirtualBox",		"VirtualBox"},
	{ "Chrome",			"google-chrome"},
	{ "Office",			"libreoffice"},
	{ "File Manager",		"nautilus"},
	{ "Volume Setting",			"gnome-alsamixer"},
	{ "Media Player",		"gnome-mplayer"},
	{ "Gedit",			"gedit"},
	{ "PDF Viwer",			"xpdf"}
}

mymainmenu = awful.menu({ items = { 
                                    --{ "Terminal", terminal },
									{ "Appilction", myappmenu, beautiful.awesome_icon },
									{ "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Power", powermenu, beautiful.awesome_icon }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })


-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywiboxtop = {}
mywiboxbottom = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

-- widget wicked
--
cpuwidget = widget({
	    type = 'textbox',
		    name = 'cpuwidget'
		})

		wicked.register(cpuwidget, wicked.widgets.cpu,
		    --' <span color="white">CPU:</span> $1%')
		    ' <span color="white">[CPU:</span>$1%<span color="white">]</span>')
--
-- Memery widget
-- {{
 memwidget = widget({
 	type = 'textbox',
 	name = 'memwidget'
 })
 wicked.register(memwidget, wicked.widgets.mem,
	--'<span color="white">Memory :</span> $2Mb/$3Mb <span color="white">||</span>')
	'<span color="white">[</span>$2Mb/$3Mb<span color="white">]</span>')
--}} 

-- Net Widget
-- {{
netwidget = widget({
    type = 'textbox',
    name = 'netwidget'
})

wicked.register(netwidget, wicked.widgets.net,
    --' <span color="white">NET</span>: ${eth0 down} / ${eth0 up} ',
--nil, nil, 3)
    ' <span color="white">[</span>${eth0 down} / ${eth0 up}<span color="white">]</span>',
nil, nil, 3)
-- }}

--}}}

-- Battery widget
-- {{{
----------------------------
-- {{ Battery Funciton
local limits = {{25, 5},
          {12, 3},
          { 7, 1},
            {0}}

function batclosure ()
    local nextlim = limits[1][1]
    return function (_, args)
        local prefix = "⚡"
        local state, charge = args[1], args[2]
        if not charge then return end
        if state == "-" then
            dirsign = "↓"
            --prefix = "Bat:"
            if charge <= nextlim then
                naughty.notify({title = "⚡ Lystring! ⚡",
                                text = "Battery Low ( ⚡ "..charge.."%)!",
                                timeout = 7,
                                position = "bottom_right",
                                fg = beautiful.fg_focus,
                                bg = beautiful.bg_focus
                               })
                nextlim = getnextlim(charge)
            end
        elseif state == "+" then
            dirsign = "↑"
            nextlim = limits[1][1]
        else
            dirsign = ""
        end
        if dir ~= 0 then charge = charge.."%"  end
        return " "..prefix.." "..dirsign..charge..dirsign.." "
    end
end

-- }}

--{{ Battery Widget config
batterywidget = widget({type = "textbox", name = "batterywidget"})
vicious.register(batterywidget, vicious.widgets.bat, batclosure(),
                    31, "BAT0")
--}}
-----------------------------------------
--}}}


    -- Create the wibox 
	mywiboxtop[s] = awful.wibox({ position = "top",  screen = s }) 
	mywiboxbottom[s] = awful.wibox({ position = "bottom",  screen = s })

    -- Add widgets to the wibox - order matters
	
	-- {{ Bottom wibox
    mywiboxbottom[s].widgets = {
        {
            --mylauncher, // menu
            --mytaglist[s], // tags
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        --mytextclock,
        s == 1 and mysystray or nil,
		batterywidget,
		memwidget,
		cpuwidget,
		netwidget,
        --mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
	-- }}

	-- {{ Top wibox
    mywiboxtop[s].widgets = {
        {
            --mylauncher,
            mytaglist[s],
			mylayoutbox[s],
            --mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
		--mylayoutbox[s],
        mytextclock,
        --s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
	-- }}
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
------------------------- Is My key
	awful.key({ modkey }, "F1",   function () awful.util.spawn_with_shell("urxvt -e ssh -qTfnN -D 7070 -p 7775 hui.lu -v") end),
	awful.key({ modkey }, "F2",   function () awful.util.spawn_with_shell("synclient touchpadoff=1") end),
	awful.key({ modkey }, "F3",   function () awful.util.spawn_with_shell("synclient touchpadoff=0") end),
	-- awful.key({ modkey }, "F11",   function () awful.util.spawn("sudo pm-suspend") end),
	-- xlock
	awful.key({ modkey }, "F12",   function () awful.util.spawn_with_shell("xlock -mode blank") end),
	-- {{ Move mouse
	awful.key({ modkey }, "Left",  function () awful.client.moveresize(-20,   0,   0,   0) end),
	awful.key({ modkey }, "Right", function () awful.client.moveresize( 20,   0,   0,   0) end),
	awful.key({ modkey }, "Up",  function () awful.client.moveresize(-20,   -20,   0,   0) end),
	awful.key({ modkey }, "Down", function () awful.client.moveresize( 0,   20,   0,   0) end),
	-- }}
	-- {{ suspend wicked to save battery
	awful.key({ modkey }, "F10",   function () awful.util.spawn_with_shell("echo 'wicked.suspend()' | awesome-client") end),
	-- activate wicked
	awful.key({ modkey }, "F9",   function () awful.util.spawn_with_shell("echo 'wicked.activate()' | awesome-client") end),
	-- }}
	
------------------------- My key
    --awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    --awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),

    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
	-- Set Chrome to always map on tag number 2 of screen 1
	{ rule = { class = "Google-chrome" },  properties = {tag = tags[1][2]}},
	-- Set VirtualBox to always map on tag number 5 of screen 1
	{ rule = { class = "VirtualBox" },  properties = {tag = tags[1][6]}},
	-- Set Douban fm Chrome expand to always map on tag number 6 of screen 1, and floating
	{ rule = { class = "Google-chrome", instance = "crx_clhojfdjfahpiddojlckmgmanojfdnal" },  properties = {tag = tags[1][7], floating = true}},
	-- Set LibreOffice to always map on tag number 3 of screen 1
	{ rule = { class = "libreoffice-writer" },  properties = {tag = tags[1][3]}},
	{ rule = { class = "libreoffice-startcenter" },  properties = {tag = tags[1][3]}},
	{ rule = { class = "libreoffice-calc" },  properties = {tag = tags[1][3]}},
	-- Set Hotot to always map on tag number 3 of screen 1
	{ rule = { class = "Google-chrome", name = "Hotot | - Google Chrome" },  properties = {tag = tags[1][5]}},
	-- Start windows as slave
	{ rule = { }, properties = { }, callback = awful.client.setslave }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)


    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Autorun programs
autorun = true
autorunApps = 
{ 
	--"killall fcitx",
	"fcitx&",
    "dropboxd&",
	"synclient touchpadoff=1",
	"xmodmap ~/.Xmodmap"
}

if autorun then
    for app = 1, #autorunApps do
        awful.util.spawn_with_shell(autorunApps[app])
    end
end
