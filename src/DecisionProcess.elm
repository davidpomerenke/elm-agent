module DecisionProcess exposing
    ( DecisionProcess, Probability(..), Utility(..), Discount(..)
    , Sequence, History, historyToSequence, Future, futureToSequence
    , expectedReward, utilityGivenFuture
    , Policy(..), ahistoricPolicySpace, utilityGivenPolicy, optimalPolicy
    )

{-| Markov Decision Processes

The _Markov property_ needs to be fulfilled:

  - All relevant information about the environment needs to be encapsulated in the single current state of the environment.
  - For example, if we try to model a soccer match such that a state is an image of the soccer field, the Markov property will not be fulfilled: We do not know about the speed of objects, but that is relevant information. We could change our model and include speed information in the state, or we could use two pictures for one state (but then, acceleration might still be missing relevant information).


# Markov Decision Process

@docs DecisionProcess, Probability, Utility, Discount


# Sequences

@docs Sequence, History, historyToSequence, Future, futureToSequence


# Utility

@docs expectedReward, utilityGivenFuture


# Policies

@docs Policy, ahistoricPolicySpace, utilityGivenPolicy, optimalPolicy

-}

import List
import List.Extra as List



-- LECTURE 1


{-| ∈ [0, 1]
-}
type Probability
    = Probability Float


{-| ∈ ℝ
-}
type Utility
    = Utility Float


{-| ∈ [0, 1)
-}
type Discount
    = Discount Float


{-| Markov Decision Process

_In the slides, the `discount` rate is not part of the 4-Tuple making up a Markov Decision Process, but I think it makes sense to put it in there._

-}
type alias DecisionProcess state action =
    { states : List state
    , actions : state -> List action
    , transition : state -> action -> state -> Probability
    , reward : state -> action -> state -> Utility
    , discount : Discount
    }


{-| Sequence of state transitions (s, a, s').
-}
type alias Sequence state action =
    List ( state, action, state )


{-| States and actions leading up to the current state.
-}
type alias History state action =
    List ( state, action )


{-| States and actions starting from the current state.
-}
type alias Future state action =
    List ( action, state )


{-| Convert List of (s, a) to List of (s, a, s'), ending with the current state.
-}
historyToSequence : state -> History state action -> Maybe (Sequence state action)
historyToSequence currentState history =
    List.unconsLast history
        |> Maybe.map
            (\( ( lastState, lastAction ), earlierHistory ) ->
                List.scanr
                    (\( state1, action ) ( state2, _, _ ) ->
                        ( state1, action, state2 )
                    )
                    ( lastState, lastAction, currentState )
                    earlierHistory
            )


{-| Convert List of (a, s') to List of (s, a, s'), starting with the current state.
-}
futureToSequence : state -> Future state action -> Maybe (Sequence state action)
futureToSequence currentState future =
    List.uncons future
        |> Maybe.map
            (\( ( nextAction, nextState ), laterFuture ) ->
                List.scanl
                    (\( action, state2 ) ( _, _, state1 ) ->
                        ( state1, action, state2 )
                    )
                    ( currentState, nextAction, nextState )
                    laterFuture
            )


{-| Policy: Defines an action (maybe) for each state.
-}
type Policy state action
    = Policy (Maybe (Sequence state action) -> state -> Maybe action)


{-| Policy space of those policies that do only depend on the current state. Since the optimal policy does only depend on the current state, these are the candidate policies for the optimal policy.
-}
ahistoricPolicySpace : DecisionProcess state action -> List (Policy state action)
ahistoricPolicySpace decisionProcess =
    decisionProcess.states
        |> List.map (\state -> decisionProcess.actions state |> List.map (\action -> ( state, action )))
        |> List.filter (\l -> List.length l > 0)
        |> List.cartesianProduct
        |> List.map
            (\tuples ->
                Policy
                    (\_ state ->
                        tuples
                            |> List.find (\( state_, _ ) -> state_ == state)
                            |> Maybe.map Tuple.second
                    )
            )


{-| Helper function to maximize a list of arguments by some value derived from the arguments.

    argMax String.length [ "a", "bc", "def" ] == "def"

-}
argMax : (a -> comparable) -> List a -> Maybe a
argMax f =
    List.map
        (\argument ->
            let
                value =
                    f argument
            in
            ( argument, value )
        )
        >> List.foldl1
            (\( argument1, value1 ) ( argument2, value2 ) ->
                if value1 > value2 then
                    ( argument1, value1 )

                else
                    ( argument2, value2 )
            )
        >> Maybe.map Tuple.first


{-| Helper function, currently unused.
-}
bestActionBetween : state -> state -> DecisionProcess state action -> Maybe action
bestActionBetween state1 state2 decisionProcess =
    decisionProcess.actions state1
        |> argMax
            (\action ->
                let
                    (Utility u) =
                        decisionProcess.reward state1 action state2

                    (Probability p) =
                        decisionProcess.transition state1 action state2
                in
                u * p
            )


{-| Sums up a list of utilities.
-}
sumUtility : List Utility -> Utility
sumUtility =
    List.foldl (\(Utility u) (Utility us) -> Utility (us + u)) (Utility 0)


{-| Utility of the current state given the future actions and states.
-}
utilityGivenFuture : Sequence state action -> DecisionProcess state action -> Utility
utilityGivenFuture future decisionProcess =
    let
        rewards : List Utility
        rewards =
            List.map
                (\( state1, action, state2 ) -> decisionProcess.reward state1 action state2)
                future

        (Discount gamma) =
            decisionProcess.discount
    in
    rewards
        |> List.indexedMap
            (\i (Utility u) ->
                Utility (gamma ^ toFloat i * u)
            )
        |> sumUtility


{-| Expected reward given a state and an action.
-}
expectedReward : state -> action -> DecisionProcess state action -> Utility
expectedReward state action decisionProcess =
    decisionProcess.states
        |> List.map
            (\nextState ->
                let
                    (Utility u) =
                        decisionProcess.reward state action nextState

                    (Probability t) =
                        decisionProcess.transition state action nextState
                in
                Utility (u * t)
            )
        |> sumUtility


{-| Utility given policy.
_Warning:_ This is not stacksafe and will likely crash.
-}
utilityGivenPolicy : state -> Policy state action -> DecisionProcess state action -> Utility
utilityGivenPolicy state (Policy policy) decisionProcess =
    let
        action =
            policy Nothing state

        (Utility expectedUtility) =
            action
                |> Maybe.map (\a -> expectedReward state a decisionProcess)
                |> Maybe.withDefault (Utility 0)

        (Utility expectedFutureUtility) =
            decisionProcess.states
                |> List.map
                    (\state2 ->
                        let
                            (Probability t) =
                                action
                                    |> Maybe.map (\a -> decisionProcess.transition state a state2)
                                    |> Maybe.withDefault (Probability 0)
                        in
                        if t > 0 then
                            let
                                (Utility u) =
                                    utilityGivenPolicy state2 (Policy policy) decisionProcess
                            in
                            Utility (t * u)

                        else
                            Utility 0
                    )
                |> sumUtility

        (Discount gamma) =
            decisionProcess.discount
    in
    Utility
        (expectedUtility
            + gamma
            * expectedFutureUtility
        )


paretoOptimum : List ( a, List comparable ) -> Maybe ( a, List comparable )
paretoOptimum listOfLists =
    let
        paretoBetter : List comparable -> List comparable -> Bool
        paretoBetter l1 l2 =
            List.zip l1 l2
                |> List.all (\( a, b ) -> a > b)
    in
    List.find
        (\( _, list ) ->
            listOfLists
                |> List.filter (\( _, l ) -> l /= list)
                |> List.all (\( _, l ) -> paretoBetter list l)
        )
        listOfLists


{-| Optimal policy. Very inefficient and not stacksafe, use value iteration instead.
-}
optimalPolicy : DecisionProcess state action -> Maybe (Policy state action)
optimalPolicy decisionProcess =
    ahistoricPolicySpace decisionProcess
        |> List.map
            (\policy ->
                ( policy
                , decisionProcess.states
                    |> List.map
                        (\state ->
                            let
                                (Utility u) =
                                    utilityGivenPolicy state policy decisionProcess
                            in
                            u
                        )
                )
            )
        |> paretoOptimum
        |> Maybe.map Tuple.first



-- LECTURE 2
