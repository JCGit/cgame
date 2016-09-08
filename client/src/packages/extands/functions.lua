local cc = cc or {}

function cc.size2p(size, factor)
    return { x = size.width * factor, y = size.height * factor}
end

function cc.size2pMid(size)
	return cc.size2p(size, 0.5)
end

function cc.sizeSub2p(size, subSize)
    return { x = size.width - subSize.width, y = size.height - subSize.height}
end

function cc.rgb2str(rgb)
    local r = rgb.r
    local g = rgb.g
    local b = rgb.b
    return string.format("%02x%02x%02x", r, g, b)
end


