local balancer = require "ngx.balancer"
local peers = require "peers"

local get_last_failure = balancer.get_last_failure
local set_current_peer = balancer.set_current_peer
local set_more_tries = balancer.set_more_tries

local state, status = get_last_failure()
if state == 'failed' then
    local last_peer = ngx.ctx.last_peer
    --  the backend connection must be aborted and cannot get reused
    ngx.log(ngx.ERR, "last failure: ", last_peer[1], ":", last_peer[2])
end

local peer = peers.get()

if not peer then
    ngx.log(ngx.ERR, "select peer failed, ", err)
    return
end

ngx.ctx.last_peer = peer

local ok, err
ok, err = set_current_peer(peer[1], peer[2])
if not ok then
    ngx.log(ngx.ERR, "set_current_peer failed, ", err)
    return
end

ok, err = set_more_tries(1)
if not ok then
    ngx.log(ngx.ERR, "set_more_tries failed, ", err)
    return
end
