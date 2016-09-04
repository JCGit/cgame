--[[
file : PackData.lua
desc : 协议数据处理工具


]]--

local crypt = require("crypt")
require "packages.network.protobuf"
local pb_encode = protobuf.encode
local pb_decode = protobuf.decode

local cspb = require("app.proto.cs")
local req_dict = cspb.req_dict
local res_dict = cspb.res_dict
local rpc_dict = cspb.rpc_dict

local rpc_dict_r = {}
--反转rpc key-value
for k,v in pairs(rpc_dict) do
    rpc_dict_r[v] = k
end

local function pack_line(text)
    return text .. "\n"
end

local function unpack_line(text)
    local from = text:find("\n", 1, true)
    if from then
        return text:sub(1, from-1), text:sub(from+1)
    end
    return nil, text
end

local function pack_request(v)
--    return string.pack(">s2", v)
    local len = #v
    assert(len <= 0xFFFF, 'too large net pack')
    local b1 = math.floor( len / 256 )
    local b2 = len % 256
    return string.char(b1) .. string.char(b2) .. v
end

local function pack_msg(secret)
    return function (msgkey, req_msg)
        assert(rpc_dict[msgkey], string.format('protobuff requests have no:%s.', msgkey))
        
        local msgid = rpc_dict[msgkey]
        assert(req_dict[msgid], string.format('protobuff requests have no:%d.', msgid))
        
        local pb_buf = pb_encode(req_dict[msgid], req_msg)
        local b1 = math.floor(msgid / 256)
        local b2 = msgid % 256
        local buf = string.char(0) .. string.char(0) .. string.char(b1) .. string.char(b2) .. pb_buf
        return crypt.desencode(secret, buf)
    end
end
    

local function unpack_msg(secret)
    return function (data)
        --text = desencode(id + protobuffer)
        local buff = crypt.desdecode(secret, data)
        if #buff <= 2 then
            return nil, data
        end

        local msgid = string.byte(buff, 3) * 256 + string.byte(buff, 4)
        local msgbuff = string.sub(buff, 5)

        local pb = res_dict[msgid]
        assert(pb, string.format('res_dict find no id:%d.', msgid))

        local msgstr = rpc_dict_r[msgid]
        assert(msgstr, string.format('rpc_dict_r find no msg:%d describe.', msgid))

        return msgstr, pb_decode(pb, msgbuff), pb
    end
end

return {
    pack_line = pack_line,
    unpack_line = unpack_line,
    pack_msg = pack_msg,
    unpack_msg = unpack_msg,
    pack_request = pack_request,
}