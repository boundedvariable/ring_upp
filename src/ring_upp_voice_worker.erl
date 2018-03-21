-module(ring_upp_voice_worker).

-behaviour(gen_server).


-export([init/1,
				 handle_call/3,
				 handle_cast/2,
				 handle_info/2,
				 terminate/2,
				 code_change/3
				 ]).

-export([start_link/0,
				 send_event/1
				]).

start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

send_event(Event) ->
	wpool:cast(ring_upp_voice_pool, {send_event_to_voice, Event}).

init(_Args) ->
	{ok, []}.

handle_call(_, _From, State) ->
	{noreply, State}.

handle_cast({send_event_to_voice, Event}, State) ->
	zataas_kafka_brod_if:send(Event),
	{noreply, State};

handle_cast(stop, State) ->
		{stop, normal, State};

handle_cast(_Msg, State) ->
		{noreply, State}.

handle_info(_, State) ->
	{noreply, State}.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

terminate(normal, _State) ->
	ok.