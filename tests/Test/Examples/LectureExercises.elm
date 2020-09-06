module Test.Examples.LectureExercises exposing (..)

import DecisionProcess exposing (..)
import Dict
import Expect
import List.Extra as List
import Maybe.Extra as Maybe
import Test exposing (..)



-- Ecercise 1


type Direction
    = North
    | East
    | South
    | West


{-| A simple drawing of six cells.
![](img/LectureExercise1.png)
-}
sixCells : DecisionProcess ( Int, Int ) Direction
sixCells =
    { states = [ ( 0, 0 ), ( 1, 0 ), ( 2, 0 ), ( 0, 1 ), ( 1, 1 ), ( 2, 1 ) ]
    , actions =
        \state ->
            [ ( ( 0, 0 ), [ East, South ] )
            , ( ( 1, 0 ), [ East, South, West ] )
            , ( ( 2, 0 ), [] )
            , ( ( 0, 1 ), [ North, East ] )
            , ( ( 1, 1 ), [ North, East, West ] )
            , ( ( 2, 1 ), [ North, West ] )
            ]
                |> Dict.fromList
                |> Dict.get state
                |> Maybe.withDefault []
    , transition =
        \state1 action state2 ->
            let
                ( x, y ) =
                    state1

                realState2 =
                    case action of
                        North ->
                            ( x, y - 1 )

                        East ->
                            ( x + 1, y )

                        South ->
                            ( x, y + 1 )

                        West ->
                            ( x - 1, y )
            in
            {- let
                   _ =
                       Debug.log "xy a xy t" { s1 = state1, a = action, s2 = state2, realS2 = realState2, bool = state2 == realState2 }
               in
            -}
            if state2 == realState2 then
                Probability 1

            else
                Probability 0
    , reward =
        \state1 action _ ->
            [ ( ( 0, 0 ), [ ( East, -20 ), ( South, 0 ) ] )
            , ( ( 1, 0 ), [ ( East, 100 ), ( South, 0 ), ( West, 0 ) ] )
            , ( ( 2, 0 ), [] )
            , ( ( 0, 1 ), [ ( North, 0 ), ( East, 0 ) ] )
            , ( ( 1, 1 ), [ ( North, -10 ), ( East, 0 ), ( West, 0 ) ] )
            , ( ( 2, 1 ), [ ( North, 50 ), ( West, 0 ) ] )
            ]
                |> Dict.fromList
                |> Dict.get state1
                |> Maybe.map
                    (List.find (\( a, _ ) -> a == action)
                        >> Maybe.map Tuple.second
                    )
                |> Maybe.join
                |> Maybe.withDefault 0
                |> Utility
    , discount = Discount 0.9
    }


optimalSixCellsPolicy : Policy ( Int, Int ) Direction
optimalSixCellsPolicy =
    Policy
        (\_ state ->
            [ ( ( 0, 0 ), East )
            , ( ( 1, 0 ), East )
            , ( ( 0, 1 ), East )
            , ( ( 1, 1 ), North )
            , ( ( 2, 1 ), West )
            ]
                |> Dict.fromList
                |> Dict.get state
        )


suite : Test
suite =
    describe "exercise 1" <|
        [ test "utility given optimal policy" <|
            \_ ->
                utilityGivenPolicy ( 0, 0 ) optimalSixCellsPolicy sixCells
                    |> Expect.equal
                        (Utility 70)
        , test "value iteration" <|
            \_ ->
                let
                    (Policy optimalPolicy) =
                        valueIteration (Utility 0.1) sixCells

                    calculatedSuccessors =
                        List.map (\state -> optimalPolicy Nothing state) sixCells.states

                    (Policy optimalPolicy_) =
                        optimalSixCellsPolicy

                    expectedSuccessors =
                        List.map (\state -> optimalPolicy_ Nothing state) sixCells.states
                in
                calculatedSuccessors |> Expect.equal expectedSuccessors
        ]
