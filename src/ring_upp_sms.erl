-module(ring_upp_sms).

-export([send_push/1]).

start_workers()->
	{ok,WorkersAmount} = application:get_env(ring_upp,sms_workers_amount),
    wpool:start_pool(
        ring_upp_sms_pool,
        [{workers, WorkersAmount}, {worker, {ring_upp_sms_worker, []}}]
    ).

send_sms(Data)->
	ring_upp_sms_worker:send_event(Data).