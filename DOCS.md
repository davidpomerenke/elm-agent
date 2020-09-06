# Modules
- [DecisionProcess](#decisionprocess)

# DecisionProcess
- [DecisionProcess](#decisionprocess)
- [Probability](#probability)
- [Utility](#utility)
- [Discount](#discount)
- [Sequence](#sequence)
- [History](#history)
- [historyToSequence](#historytosequence)
- [Future](#future)
- [futureToSequence](#futuretosequence)
- [expectedReward](#expectedreward)
- [utilityGivenFuture](#utilitygivenfuture)
- [Policy](#policy)
- [ahistoricPolicySpace](#ahistoricpolicyspace)
- [utilityGivenPolicy](#utilitygivenpolicy)
- [utilityGivenValues](#utilitygivenvalues)
- [updateValues](#updatevalues)
- [valueIteration](#valueiteration)
- [policyIteration](#policyiteration)

 Markov Decision Process.
The _Markov property_ needs to be fulfilled. This means: All relevant information about the environment needs to be encapsulated in the single current state of the environment.
> For example: If we try to model a soccer match such that a state is an image of the soccer field, the Markov property will not be fulfilled: We do not know about the speed of objects, but that is relevant information. We could change our model and include speed information in the state, or we could use two pictures for one state (but then, acceleration might still be some missing relevant information).
## Markov Decision Process

### `DecisionProcess`
```elm
type alias DecisionProcess state action =
    { states : List.List state, actions : state -> List.List action, transition : state -> action -> state -> DecisionProcess.Probability, reward : state -> action -> state -> DecisionProcess.Utility, discount : DecisionProcess.Discount }
```
 Markov Decision Process

_In the slides, the `discount` rate is not part of the 4-Tuple making up a Markov Decision Process, but I think it makes sense to put it in there._



---

### `Probability`
```elm
type Probability  
    = Probability Basics.Float
```
 ∈ [0, 1]


---

### `Utility`
```elm
type Utility  
    = Utility Basics.Float
```
 ∈ ℝ


---

### `Discount`
```elm
type Discount  
    = Discount Basics.Float
```
 ∈ [0, 1)


---

## Sequences

### `Sequence`
```elm
type alias Sequence state action =
    List.List ( state, action, state )
```
 Sequence of state transitions (s, a, s').


---

### `History`
```elm
type alias History state action =
    List.List ( state, action )
```
 States and actions leading up to the current state.


---

### `historyToSequence`
```elm
historyToSequence : state -> History state action -> Maybe.Maybe (Sequence state action)
```
 Convert List of (s, a) to List of (s, a, s'), ending with the current state.


---

### `Future`
```elm
type alias Future state action =
    List.List ( action, state )
```
 States and actions starting from the current state.


---

### `futureToSequence`
```elm
futureToSequence : state -> Future state action -> Maybe.Maybe (Sequence state action)
```
 Convert List of (a, s') to List of (s, a, s'), starting with the current state.


---

## Utility

### `expectedReward`
```elm
expectedReward : state -> action -> state action -> Utility
```
 Expected reward given a state and an action.


---

### `utilityGivenFuture`
```elm
utilityGivenFuture : Sequence state action -> state action -> Utility
```
 Utility of the current state given the future actions and states.


---

## Policies

### `Policy`
```elm
type Policy state action 
    = Policy Maybe.Maybe (DecisionProcess.Sequence state action) -> state -> Maybe.Maybe action
```
 Policy: Defines an action (maybe) for each state.


---

### `ahistoricPolicySpace`
```elm
ahistoricPolicySpace : state action -> List.List (Policy state action)
```
 Policy space of those policies that do only depend on the current state. Since the optimal policy does only depend on the current state, these are the candidate policies for the optimal policy.


---

### `utilityGivenPolicy`
```elm
utilityGivenPolicy : state -> Policy state action -> state action -> Utility
```
 Utility given policy.
_Warning:_ This is not stacksafe and will likely crash.


---

## Algorithms
## Value iteration

### `utilityGivenValues`
```elm
utilityGivenValues : state -> action -> List.List ( state, action, Utility ) -> state action -> Utility
```
 Utility of an action in a state, given some previously approximated utility values of all states. This is part of the Bellman-update (`updateValues`).


---

### `updateValues`
```elm
updateValues : List.List ( state, action, Utility ) -> state action -> List.List ( state, action, Utility )
```
 Perform a Bellman-update on the values. This is the main part of an iteration step in the `valueIteration` algorithm.


---

### `valueIteration`
```elm
valueIteration : Utility -> state action -> Policy state action
```
 Value iteration algorithm. Approximates the optimal policy of a decision process. The algorithm stops iterating once the highest utility improvement for any state has dropped below a specified utility difference epsilon.


---

## Policy iteration

### `policyIteration`
```elm
policyIteration : state action -> Policy state action
```
 Policy iteration algorithm. Determines the optimal policy for a decision process. More exact but less efficient than `valueIteration`.


---


> Generated with elm: 0.19.1 and elm-docs: 0.4.0
