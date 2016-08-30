%% --------------------------------------------------------------------------------
%% File:    gs1.erl
%% @author  Oleksii Semilietov <spylik@gmail.com>
%%
%% @doc Erlang OTP library for GS1 General Specifications 
%% Spec: http://www.gs1.org/barcodes-epcrfid-id-keys/gs1-general-specifications
%% --------------------------------------------------------------------------------

-module(gs1).

-define(NOTEST, true).
-ifdef(TEST).
    -compile(export_all).
-endif.

-export([validate/1]).

-define(GTINAllowed, [8, 12, 13, 14]).
-define(GS1Allowed, [8, 12, 13, 14, 17, 18]).
-define(MP, [3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3]).

-type tag() :: binary() | nonempty_list().
-type error() :: {'error', binary()}.

% @doc Validate GTINs (support GTIN-8, GTIN-12, GTIN-13, GTIN-14).
%  By default validating gtin-14 tags
-spec validate(Something) -> Result when
    Something :: {gtin, Tag} | {gtin, GtinType, Tag},
    GtinType :: 'auto' | 8 | 12 | 13 | 14,
    Tag :: binary() | iolist(),
    Result :: 'ok' | error().

validate({gtin, Tag}) -> validate({gtin, 14, Tag});

validate({gtin, auto, Tag}) ->
    verify_gs1_checksum(validate_size(iolist_size(Tag), ?GTINAllowed, <<"Invalid GTIN size">>), Tag);
validate({gtin, Type, Tag}) ->
    verify_gs1_checksum(validate_size(iolist_size(Tag), [Type], <<"Invalid GTIN size">>), Tag).

% @doc verify checksum for tag

-spec verify_gs1_checksum(SizeOrError, Tag) -> Result when
    SizeOrError :: error() | 8 | 12 | 13 | 14 | 17 | 18,
    Tag :: tag(),
    Result :: 'ok' | error().

verify_gs1_checksum({error, Error}, _) -> {error, Error};
verify_gs1_checksum(Size, Tag) when is_binary(Tag) orelse is_list(Tag) -> 
    Mp = lists:nthtail(18-Size, ?MP),
    F = fun Calc([], Last, Acc) when is_binary(Last) ->
                Summ = lists:sum(Acc), (ceiling(Summ/10)*10) - Summ =:= binary_to_integer(Last);
            Calc([], Last, Acc) when is_list(Last) ->
                Summ = lists:sum(Acc), (ceiling(Summ/10)*10) - Summ =:= list_to_integer(Last);
            Calc([H|T],[First|Rest],Acc) ->
                Calc(T,Rest,[H*binary_to_integer(<<First>>)|Acc]);
            Calc([H|T],<<First,Rest/binary>>,Acc) ->
                Calc(T,Rest,[H*binary_to_integer(<<First>>)|Acc])
    end,
    try F(Mp,Tag,[]) of 
        true -> ok;
        false -> {error, <<"Invalid GS1 checksum">>}
    catch
        _:_ -> {error, <<"GS1 Tag contain not only integers">>}
    end.

% @doc validating size of tag
-spec validate_size(Size, AllowedList, ErrorMsg) -> Result when
    Size :: non_neg_integer(),
    AllowedList :: [non_neg_integer()],
    ErrorMsg :: binary(),
    Result :: Size | error().

validate_size(_, [], Error) -> {error, Error};
validate_size(Size, [Size|_T], _Error) -> Size;
validate_size(Size, [_|T], Error) -> validate_size(Size,T,Error).

% @doc celling solution from 
% https://erlangcentral.org/wiki/index.php?title=Floating_Point_Rounding
-spec ceiling(Number) -> Result when
    Number :: float() | integer(),
    Result :: integer().

ceiling(X) when X < 0 ->
    trunc(X);
ceiling(X) ->
    T = trunc(X),
    case X - T == 0 of
        true -> T;
        false -> T + 1
    end.
