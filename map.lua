-- Map class

Map = {}

-- Utility
local function copy(tbl)
    local result = {}
    for k, v  in pairs(tbl) do
        result[k] = v
    end
    return result
end

function Map:new(tbl_map, tbl_tiles, tile_w, tile_h)
    local instance = {
        data = copy(tbl_map),
        tiles = copy(tbl_tiles),
        height = #tbl_map,
        width = tbl_map[1] and #tbl_map[1] or 0,
        tile_w = tile_w,
        tile_h = tile_h,
    }
    return setmetatable(instance, { __index = Map })
end

function Map:draw()
    local x, y = 1, 1
    for raw_i, raw in ipairs(self.data) do
        for col_i, tile_index in ipairs(raw) do
            self.tiles[tile_index].draw(x, y)
            x = x + self.tile_w
        end
        x = 1
        y = y + self.tile_h
    end
end

return Map
