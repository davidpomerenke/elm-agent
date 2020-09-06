module DecisionProcess exposing
    ( DecisionProcess, Probability(..), Utility(..), Discount(..)
    , Sequence, History, historyToSequence, Future, futureToSequence
    , expectedReward, utilityGivenFuture
    , Policy(..)
    , utilityGivenValues, updateValues, valueIteration
    , utilityGivenPolicy, policyIteration
    )

{-| Markov Decision Process.

The _Markov property_ needs to be fulfilled. This means: All relevant information about the environment needs to be encapsulated in the single current state of the environment.

> For example: If we try to model a soccer match such that a state is an image of the soccer field, the Markov property will not be fulfilled: We do not know about the speed of objects, but that is relevant information. We could change our model and include speed information in the state, or we could use two pictures for one state (but then, acceleration might still be some missing relevant information).


# Markov Decision Process

@docs DecisionProcess, Probability, Utility, Discount


# Sequences

@docs Sequence, History, historyToSequence, Future, futureToSequence


# Utility

@docs expectedReward, utilityGivenFuture


# Policies

@docs Policy


# Algorithms


## Value iteration

@docs utilityGivenValues, updateValues, valueIteration


## Policy iteration

@docs utilityGivenPolicy, policyIteration

-}

import List
import List.Extra as List
import Maybe.Extra as Maybe



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


{-| Policy: Defines an action (maybe) for each state.
-}
type Policy state action
    = Policy (Maybe (Sequence state action) -> state -> Maybe action)


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



-- LECTURE 2


{-| Utility of an action in a state, given some previously approximated utility values of all states. This is part of the Bellman-update (`updateValues`).
-}
utilityGivenValues :
    state
    -> action
    -> List ( state, action, Utility )
    -> DecisionProcess state action
    -> Utility
utilityGivenValues state action values decisionProcess =
    decisionProcess.states
        |> List.map
            (\state2 ->
                let
                    (Probability p) =
                        decisionProcess.transition state action state2

                    (Utility u) =
                        values
                            |> List.find (\( state_, _, _ ) -> state_ == state2)
                            |> Maybe.map (\( _, _, u_ ) -> u_)
                            |> Maybe.withDefault (Utility 0)
                in
                Utility (p * u)
            )
        |> sumUtility


{-| Perform a Bellman-update on the values. This is the main part of an iteration step in the `valueIteration` algorithm.
-}
updateValues :
    List ( state, action, Utility )
    -> DecisionProcess state action
    -> List ( state, action, Utility )
updateValues values decisionProcess =
    decisionProcess.states
        |> List.map
            (\state ->
                let
                    optimalActionAndUtility =
                        decisionProcess.actions state
                            |> List.map
                                (\action ->
                                    let
                                        (Utility e) =
                                            expectedReward state action decisionProcess

                                        (Discount gamma) =
                                            decisionProcess.discount

                                        (Utility futureUtility) =
                                            utilityGivenValues state action values decisionProcess
                                    in
                                    ( action
                                    , Utility
                                        (e
                                            + gamma
                                            * futureUtility
                                        )
                                    )
                                )
                            |> argMax (\( _, Utility u ) -> u)
                in
                Maybe.map (\( action, utility ) -> ( state, action, utility )) optimalActionAndUtility
            )
        |> Maybe.values


{-| Value iteration algorithm. Approximates the optimal policy of a decision process. The algorithm stops iterating once the highest utility improvement for any state has dropped below a specified utility difference epsilon.
-}
valueIteration : Utility -> DecisionProcess state action -> Policy state action
valueIteration (Utility epsilon) decisionProcess =
    let
        iterate : Maybe (List ( state, action, Utility )) -> Policy state action
        iterate values =
            let
                updatedValues =
                    updateValues (Maybe.withDefault [] values) decisionProcess

                stop =
                    values
                        |> Maybe.map
                            (\values_ ->
                                List.map2
                                    (\( _, _, Utility u1 ) ( _, _, Utility u2 ) -> u2 - u1)
                                    values_
                                    updatedValues
                                    |> argMax identity
                                    |> Maybe.map ((>) epsilon)
                            )
                        |> Maybe.join
                        |> Maybe.withDefault False
            in
            if stop then
                Policy
                    (\_ state ->
                        updatedValues
                            |> List.find (\( state_, _, _ ) -> state_ == state)
                            |> Maybe.map (\( _, action, _ ) -> action)
                    )

            else
                iterate (Just updatedValues)
    in
    iterate Nothing



-- Policy iteration


updatePolicy : Policy state action -> DecisionProcess state action -> Policy state action
updatePolicy (Policy old) ({ actions, discount } as decisionProcess) =
    Policy
        (\_ state ->
            actions state
                |> List.map
                    (\action ->
                        let
                            (Utility e) =
                                expectedReward state action decisionProcess

                            (Discount gamma) =
                                discount

                            (Utility futureUtility) =
                                utilityGivenPolicy state (Policy old) decisionProcess

                            utility =
                                e + gamma * futureUtility
                        in
                        ( action, utility )
                    )
                |> argMax (\( _, u ) -> u)
                |> Maybe.map Tuple.first
        )


{-| Policy iteration algorithm. Determines the optimal policy for a decision process. More exact but less efficient than `valueIteration`.

⚠️ Not tested

-}
policyIteration : DecisionProcess state action -> Policy state action
policyIteration ({ states } as decisionProcess) =
    let
        initialPolicy =
            Policy (\_ _ -> Nothing)

        iterate : Policy state action -> Policy state action
        iterate (Policy policy) =
            let
                (Policy updatedPolicy) =
                    updatePolicy (Policy policy) decisionProcess

                unchanged =
                    List.map (policy Nothing) states == List.map (updatedPolicy Nothing) states
            in
            if unchanged then
                Policy updatedPolicy

            else
                iterate (Policy updatedPolicy)
    in
    iterate initialPolicy
