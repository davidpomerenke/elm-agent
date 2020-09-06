module Test.Examples.BonusAssignments exposing (..)

import DecisionProcess exposing (..)
import Expect
import List.Extra as List
import Maybe.Extra as Maybe
import Test exposing (..)
import Test.DecisionProcess exposing (equalPolicies, get)


suite : Test
suite =
    describe "bonus assignments"
        [ describe "2"
            [ test "value iteration steps" <|
                \_ ->
                    let
                        v1 =
                            updateValues [] n2

                        v2 =
                            updateValues v1 n2

                        v3 =
                            updateValues v2 n2
                    in
                    v3
                        |> Expect.equal
                            [ ( S1, A2, Utility 7.045999999999999 )
                            , ( S2, A2, Utility 7.045999999999999 )
                            ]
            , test "complete value iteration" <|
                \_ ->
                    n2
                        |> equalPolicies
                            (valueIteration (Utility 0.01) n2)
                            (Policy (\_ _ -> Just A2))
            ]
        ]



-- BONUS ASSIGNMENT 2


type State
    = S1
    | S2


type Action
    = A1
    | A2



n2 : DecisionProcess State Action
n2 =
    { states = [ S1, S2 ]
    , actions = \_ -> [ A1, A2 ]
    , transition =
        get Probability
            [ ( ( S1, A1, S1 ), 0.6 )
            , ( ( S1, A1, S2 ), 0.4 )
            , ( ( S2, A1, S1 ), 0.5 )
            , ( ( S2, A1, S2 ), 0.5 )
            , ( ( S1, A2, S1 ), 0.3 )
            , ( ( S1, A2, S2 ), 0.7 )
            , ( ( S2, A2, S1 ), 0.7 )
            , ( ( S2, A2, S2 ), 0.3 )
            ]
    , reward =
        get Utility
            [ ( ( S1, A1, S1 ), 4 )
            , ( ( S1, A1, S2 ), 0 )
            , ( ( S2, A1, S1 ), 3 )
            , ( ( S2, A1, S2 ), 1 )
            , ( ( S1, A2, S1 ), 4 )
            , ( ( S1, A2, S2 ), 2 )
            , ( ( S2, A2, S1 ), 2 )
            , ( ( S2, A2, S2 ), 4 )
            ]
    , discount = Discount 0.9
    }
