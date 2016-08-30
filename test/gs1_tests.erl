-module(gs1_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TM, gs1).

gs1_test_() ->
    {setup,
        fun disable_output/0, % disable output for ci
        {inparallel,
            [
                {<<"validate_size/3 must work">>,
                    fun() ->
                        ?assertEqual(4, ?TM:validate_size(4,[4],<<"wrong">>)),
                        ?assertEqual({error, <<"wrong">>}, ?TM:validate_size(4,[3],<<"wrong">>)),
                        ?assertEqual({error, <<"wrong">>}, ?TM:validate_size(4,[3,5],<<"wrong">>)),
                        ?assertEqual({error, <<"wrong">>}, ?TM:validate_size(15,[8, 12, 13, 14],<<"wrong">>)),
                        ?assertEqual(15, ?TM:validate_size(15,[8, 12, 13, 14, 15, 16],<<"wrong">>))
                    end
                },
                {<<"ceiling/1 must work for positive floats and integers">>,
                    fun() ->
                        ?assertEqual(1, ?TM:ceiling(1)),
                        ?assertEqual(2, ?TM:ceiling(1.1)),
                        ?assertEqual(2, ?TM:ceiling(1.2)),
                        ?assertEqual(2, ?TM:ceiling(1.3)),
                        ?assertEqual(2, ?TM:ceiling(1.4)),
                        ?assertEqual(2, ?TM:ceiling(1.5)),
                        ?assertEqual(2, ?TM:ceiling(1.6)),
                        ?assertEqual(2, ?TM:ceiling(1.7)),
                        ?assertEqual(2, ?TM:ceiling(1.8)),
                        ?assertEqual(2, ?TM:ceiling(1.9))
                    end
                },
                {<<"ceiling/1 must work for negative floats and integers">>,
                    fun() ->
                        ?assertEqual(-1, ?TM:ceiling(-1)),
                        ?assertEqual(-1, ?TM:ceiling(-1.1)),
                        ?assertEqual(-1, ?TM:ceiling(-1.2)),
                        ?assertEqual(-1, ?TM:ceiling(-1.3)),
                        ?assertEqual(-1, ?TM:ceiling(-1.4)),
                        ?assertEqual(-1, ?TM:ceiling(-1.5)),
                        ?assertEqual(-1, ?TM:ceiling(-1.6)),
                        ?assertEqual(-1, ?TM:ceiling(-1.7)),
                        ?assertEqual(-1, ?TM:ceiling(-1.8)),
                        ?assertEqual(-1, ?TM:ceiling(-1.9))
                    end
                },

                {<<"verify_gs1_checksum/2 must work">>,
                    fun() ->
                        ?assertEqual(ok, ?TM:verify_gs1_checksum(18,"376104250021234569")),
                        ?assertEqual(ok, ?TM:verify_gs1_checksum(18,<<"376104250021234569">>)),
                        ?assertEqual({error,<<"Invalid GS1 checksum">>}, ?TM:verify_gs1_checksum(18,"376104250021234560")),
                        ?assertEqual({error,<<"Invalid GS1 checksum">>}, ?TM:verify_gs1_checksum(18,<<"376104250021234560">>))
                    end
                },
                {<<"by default validate/1 must work with gtin-14 format">>,
                    fun() ->
                       ?assertEqual(ok, ?TM:validate({gtin, "09342336222222"})),
                       ?assertEqual(ok, ?TM:validate({gtin, <<"09342336222222">>})),
                       ?assertEqual(ok, ?TM:validate({gtin, "08883330000009"})),
                       ?assertEqual(ok, ?TM:validate({gtin, <<"08883330000009">>})),
                       ?assertEqual(ok, ?TM:validate({gtin, "00034534555644"})),
                       ?assertEqual(ok, ?TM:validate({gtin, <<"00034534555644">>})),
                       ?assertEqual(ok, ?TM:validate({gtin, "08884441861886"})),
                       ?assertEqual(ok, ?TM:validate({gtin, <<"08884441861886">>})),
                       ?assertEqual(ok, ?TM:validate({gtin, "08884441088405"})),
                       ?assertEqual(ok, ?TM:validate({gtin, <<"08884441088405">>})),
                       ?assertEqual(ok, ?TM:validate({gtin, "08884441093386"})),
                       ?assertEqual(ok, ?TM:validate({gtin, <<"08884441093386">>})),
                       ?assertEqual(ok, ?TM:validate({gtin, "09342336222819"})),
                       ?assertEqual(ok, ?TM:validate({gtin, <<"09342336222819">>})),
                       ?assertEqual(ok, ?TM:validate({gtin, "09342336222239"})),
                       ?assertEqual(ok, ?TM:validate({gtin, <<"09342336222239">>})),

                       ?assertEqual(ok, ?TM:validate({gtin, auto, "09342336222222"})),
                       ?assertEqual(ok, ?TM:validate({gtin, auto, <<"09342336222222">>})),
                       ?assertEqual(ok, ?TM:validate({gtin, auto, "08883330000009"})),
                       ?assertEqual(ok, ?TM:validate({gtin, auto, <<"08883330000009">>})),
                       ?assertEqual(ok, ?TM:validate({gtin, auto, "00034534555644"})),
                       ?assertEqual(ok, ?TM:validate({gtin, auto, <<"00034534555644">>})),
                       ?assertEqual(ok, ?TM:validate({gtin, auto, "08884441861886"})),
                       ?assertEqual(ok, ?TM:validate({gtin, auto, <<"08884441861886">>})),
                       ?assertEqual(ok, ?TM:validate({gtin, auto, "08884441088405"})),
                       ?assertEqual(ok, ?TM:validate({gtin, auto, <<"08884441088405">>})),
                       ?assertEqual(ok, ?TM:validate({gtin, auto, "08884441093386"})),
                       ?assertEqual(ok, ?TM:validate({gtin, auto, <<"08884441093386">>})),
                       ?assertEqual(ok, ?TM:validate({gtin, auto, "09342336222819"})),
                       ?assertEqual(ok, ?TM:validate({gtin, auto, <<"09342336222819">>})),
                       ?assertEqual(ok, ?TM:validate({gtin, auto, "09342336222239"})),
                       ?assertEqual(ok, ?TM:validate({gtin, auto, <<"09342336222239">>})),

                       ?assertEqual({error, <<"Invalid GS1 checksum">>}, ?TM:validate({gtin, "09342336222230"})),
                       ?assertEqual({error, <<"Invalid GS1 checksum">>}, ?TM:validate({gtin, <<"09342336222230">>})),
                       ?assertEqual({error, <<"Invalid GTIN size">>}, ?TM:validate({gtin, "0934233622223"})),
                       ?assertEqual({error, <<"Invalid GTIN size">>}, ?TM:validate({gtin, <<"0934233622223">>}))

                    end
                }
            ]
        }
    }.


disable_output() ->
    error_logger:tty(false).
