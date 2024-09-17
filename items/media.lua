local icons = require("icons")
local colors = require("colors")

local media_cover = sbar.add("item", {
  position = "right",
  background = {
    image = {
      string = "media.artwork",
      scale = 0.85,
    },
    color = colors.transparent,
  },
  label = { drawing = false },
  icon = { drawing = false },
  drawing = false,
  updates = true,
  popup = {
    align = "center",
    horizontal = true,
  }
})

local media_artist = sbar.add("item", {
  position = "center",
  drawing = false,
  padding_left = 3,
  padding_right = 0,
  width = 0,
  icon = { drawing = false },
  label = {
    width = 0,
    font = { size = 9 },
    color = colors.with_alpha(colors.blue, 0.6),
    max_chars = 18,
    y_offset = 6,
  },
})

local media_title = sbar.add("item", {
  position = "right",
  drawing = false,
  padding_left = 3,
  padding_right = 0,
  icon = { drawing = false },
  label = {
    font = { size = 11 },
    width = 0,
    max_chars = 18,
    y_offset = -5,
  },
})

sbar.add("item", {
  position = "popup." .. media_cover.name,
  icon = { string = icons.media.back },
  label = { drawing = false },
  click_script = "nowplaying-cli previous",
})
sbar.add("item", {
  position = "popup." .. media_cover.name,
  icon = { string = icons.media.play_pause },
  label = { drawing = false },
  click_script = "nowplaying-cli togglePlayPause",
})
sbar.add("item", {
  position = "popup." .. media_cover.name,
  icon = { string = icons.media.forward },
  label = { drawing = false },
  click_script = "nowplaying-cli next",
})

local interrupt = 0
local function animate_detail(detail)
  if (not detail) then interrupt = interrupt - 1 end
  if interrupt > 0 and (not detail) then return end

  sbar.animate("tanh", 30, function()
    media_artist:set({ label = { width = detail and "dynamic" or 0 } })
    media_title:set({ label = { width = detail and "dynamic" or 0 } })
  end)
end

local function scroll_title()
  local label_width = media_title:get("label.width")
  local position = label_width
  local function scroll()
    if position <= -label_width then
      position = label_width
    else
      position = position - 1
    end
    media_title:set({ label = { position = position } })
    sbar.delay(0.05, scroll)  -- Adjust the delay for smooth scrolling
  end
  scroll()
end

media_cover:subscribe("media_change", function(env)
  local state = env.INFO.state
  if state == "playing" then
    local artist = env.INFO.artist
    local title = env.INFO.title
    local media_info = title .. " - " .. artist

    media_artist:set({ drawing = true, label = artist })
    media_title:set({ drawing = true, label = media_info })
    media_cover:set({ drawing = true })

    animate_detail(true)
    interrupt = interrupt + 1
    sbar.delay(5, animate_detail)

    scroll_title() -- Start scrolling the title
  else
    media_cover:set({ popup = { drawing = false } })
    media_title:set({ drawing = false })
  end
end)

media_cover:subscribe("mouse.entered", function(env)
  interrupt = interrupt + 1
  animate_detail(true)
end)

media_cover:subscribe("mouse.exited", function(env)
  animate_detail(false)
end)

media_cover:subscribe("mouse.clicked", function(env)
  media_cover:set({ popup = { drawing = "toggle" }})
end)

media_title:subscribe("mouse.exited.global", function(env)
  media_cover:set({ popup = { drawing = false }})
end)

