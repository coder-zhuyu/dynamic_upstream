local upstreams_list = {}


local _M = {}


function _M.set()
    -- address maybe in mysql or others storage
    upstreams_list = {}
    table.insert(upstreams_list, {'127.0.0.1', 9001})
    table.insert(upstreams_list, {'127.0.0.1', 9002})
    table.insert(upstreams_list, {'127.0.0.1', 9003})
end


function _M.get()
    local idx, err = ngx.shared.peers_count:incr('count', 1, -1)
    if not idx then
        ngx.log(ngx.ERR, 'failed to incr shared key "count", err: ', err)
        return nil
    end

    local len = #upstreams_list
    if len == 0 then
        ngx.log(ngx.ERR, 'peer list is empty')
        return nil
    end

    return upstreams_list[idx % len + 1]
end

return _M
