# elm-agent 🤖💭

Code lecture notes for _Foundations of Agents_ at the Uni Maastricht, winter semester 2020/21.

## Want to understand the code? 🤓

Read the [documentation](https://elm-doc-preview.netlify.app/?repo=davidpomerenke/elm-agent&version=main), and have a look at the examples in the [`tests/Test/Examples`](tests/Test/Examples/) folder! Feel free to start an issue to ask for clarifications.

## What's Elm? 😮

[Elm](https://elm-lang.org/) is a really nice language similar to Haskell. Three arguments in favour of it:

1. Elm is focused very much on friendliness and usability. Users can just run it in the browser, like Javascript. The language and the ecosystem are simple, just as perhaps for Python.
2. Elm is a functional language (like Haskell or Scala), which is convenient for mathematical lecture notes. Don't worry, the syntax is small.
3. Elm is the only language where the compiler detects all possible errors for us, so that we can focus completely on the logic.

You can learn Elm quickly by reading through the [guide](https://guide.elm-lang.org/), by skimming the [core documentation](https://package.elm-lang.org/packages/elm/core/latest/), and by playing around with [Ellie](https://ellie-app.com/new).

## Consider contributing? 👯

It would be great to work together on this, especially if you're also following the lecture!

- You can edit the code online [on Gitpod](https://gitpod.io/#https://github.com/davidpomerenke/elm-agent), or just clone the repository.
- If you have an addition or an uncontroversial improvement, just make a pull request!
- For anything else, don't hesitate to open an issue for discussion.
- If you like, I can add you to the list of contributors.

More tests would be specifically nice at the moment.

### Running tests

`npm install`

`npm test` (which calls _elm-test_)

[![Github actions elm-test status](https://github.com/davidpomerenke/elm-agent/workflows/elm-test/badge.svg)](https://github.com/davidpomerenke/elm-agent/actions?query=workflow%3Aelm-test)

## Want to use it in your own application? 👩‍🔧

This is not (yet) published as an official package, so it's a bit inconvenient to use.

Clone this repository and then, in the `elm.json` of your Elm application, add the path of the `src` folder of your clone of the repository. Also copy the dependency list from the `elm.json` of this package into the `elm.json` of your package. If this is not clear enough or does not work, open an issue!

## Questions? 😕

Open an issue! 🎈
