%%%-------------------------------------------------------------------
%% @doc ring_upp top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(ring_upp_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    ring_upp_push_if:start(),
	ElliOpts = [{callback, ring_upp_http_handler}, {port, 3001}],
    ElliSpec = {
        ring_upp_http_handler,
        {elli, start_link, [ElliOpts]},
        permanent,
        5000,
        worker,
        [elli]},

    {ok, { {one_for_one, 5, 10}, [
    		ElliSpec,
    		?CHILD(zataas_kafka,worker,[])
    		]} }.

%%====================================================================
%% Internal functions
%%====================================================================
