%%%-------------------------------------------------------------------
%% @doc ring_upp public API
%% @end
%%%-------------------------------------------------------------------

-module(ring_upp_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    ring_upp_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
