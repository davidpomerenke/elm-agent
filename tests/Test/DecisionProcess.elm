module Test.DecisionProcess exposing (equalPolicies, get, suite)

import DecisionProcess exposing (..)
import Expect
import List.Extra as List
import Maybe.Extra as Maybe
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "general tests"
        [ toSequence
        ]



-- TEST HELPERS


{-| Convert reward/transition list to reward/transition function.
-}
get :
    (Float -> a)
    -> List ( ( state, action, state ), Float )
    -> (state -> action -> state -> a)
get type_ l =
    \state1 action state2 ->
        l
            |> List.find
                (\( ( state1_, action_, state2_ ), _ ) ->
                    state1_
                        == state1
                        && action_
                        == action
                        && state2_
                        == state2
                )
            |> Maybe.map Tuple.second
            |> Maybe.withDefault 0
            |> type_


{-| Comparative policy analysis.
⚠️ Ignores history.
-}
equalPolicies :
    Policy a b
    -> Policy a b
    -> DecisionProcess a b
    -> Expect.Expectation
equalPolicies (Policy p1) (Policy p2) d =
    List.map (p1 Nothing) d.states
        |> Expect.equal
            (List.map (p2 Nothing) d.states)



-- GENERAL TESTS


toSequence : Test
toSequence =
    describe "to Sequence"
        [ test "history to sequence" <|
            \_ ->
                historyToSequence "s5"
                    [ ( "s1", "a1" )
                    , ( "s2", "a2" )
                    , ( "s3", "a3" )
                    , ( "s4", "a4" )
                    ]
                    |> Expect.equal
                        (Just
                            [ ( "s1", "a1", "s2" )
                            , ( "s2", "a2", "s3" )
                            , ( "s3", "a3", "s4" )
                            , ( "s4", "a4", "s5" )
                            ]
                        )
        , test "future to sequence" <|
            \_ ->
                futureToSequence "s1"
                    [ ( "a1", "s2" )
                    , ( "a2", "s3" )
                    , ( "a3", "s4" )
                    , ( "a4", "s5" )
                    ]
                    |> Expect.equal
                        (Just
                            [ ( "s1", "a1", "s2" )
                            , ( "s2", "a2", "s3" )
                            , ( "s3", "a3", "s4" )
                            , ( "s4", "a4", "s5" )
                            ]
                        )
        ]
