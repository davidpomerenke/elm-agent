# elm-agent 🤖💭

[![Github actions elm-test status](https://github.com/davidpomerenke/elm-agent/workflows/elm-test/badge.svg)](https://github.com/davidpomerenke/elm-agent/actions?query=workflow%3Aelm-test)
[![Gitpod ready-to-code](https://img.shields.io/badge/Gitpod-ready--to--code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/davidpomerenke/elm-agent)

Code lecture notes for _Foundations of Agents_ at the Uni Maastricht, winter semester 2020/21.

## [Documentation 📈](https://elm-doc-preview.netlify.app/?repo=davidpomerenke/elm-agent&version=main)

## What's Elm? 😮

Elm is a nice programming language that you haven't heard of before, so you're lucky encounter it right now.

Elm has two advantages for using it for lecture notes:

1. It is easy to learn and easy to use, because it has a friendly compiler and a friendly community.
2. It forces you to avoid mistakes. This has the effect that there can be no runtime error. More importantly, it enables you to focus on the logic.

## Consider contributing? 👯

It would be great to work together at this!

- You can edit the code online [on Gitpod](https://gitpod.io/#https://github.com/davidpomerenke/elm-agent), or just clone the repository.
- If you have an addition or an uncontroversial improvement, just make a pull request!
- For anything else, don't hesitate to open an issue for discussion.
- If you like, I can add you to the list of contributors.

More tests would be especially nice at the moment.

## Want to understand the code? 🤓

Read the documentation, and, more importantly, have a look at the examples in the `tests/Test` folder! Feel free to start an issue to ask for clarifications.

## Want to apply it? 👩‍🔧

### Run the tests 👨‍💻

`npm install`

`npm test` (which calls _elm-test_)

### Use it in your Elm application 🎆

This is not (yet) published as a package, so it's a bit inconvenient to use.

Clone this repository and then, in the `elm.json` of your Elm application, add the path of the `src` folder of your clone of the repository. Also copy the dependency list from the `elm.json` of this package into the `elm.json` of your package. If this is not clear enough or does not work, open an issue!

## Questions? 😕

Open an issue! 🎈
