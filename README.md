# elm-agent 🤖💭

Code lecture notes for _Foundations of Agents_ at the Uni Maastricht, winter semester 2020/21.

## [Documentation 📈](https://elm-doc-preview.netlify.app/?repo=davidpomerenke/elm-agent&version=main)

## [<a href="https://glitch.com/edit/?utm_content=project_elm-agent&utm_source=view_source&utm_medium=button&utm_campaign=glitchButton#!/elm-agent">  <img src="https://cdn.glitch.com/2bdfb3f8-05ef-4035-a06e-2043962a3a13%2Fview-source%402x.png?1513093958802" alt="view source" height="33"></a>]()

## What's Elm? 😮

Elm is a nice programming language that you haven't heard of before, so you're lucky encounter it right now.

Elm has two advantages for using it for lecture notes:

1. It is easy to learn and easy to use, because it has a friendly compiler and a friendly community.
2. Its structure forces you to avoid mistakes. This has the effect that there can be no runtime error. More importantly, it enables you to focus on the logic.

✔️ type checking (the good part of Java)

❌ side effects (the bad part of Java)

✔️ pattern matching and functional programming (the good part of Haskell)

❌ complicated concepts or syntax (the bad part of Haskell)

Elm runs in the browser, which comes with advantages and disadvantages. Tests (= the main use case with lecture notes) also run in the command line.

## Consider contributing? 👯

It would be great to work together at this!

- If you have an addition or an uncontroversial improvement, just make a pull request!
- For anything else, don't hesitate to open an issue for discussion.
- If you like, I can add you to the list of contributors.

More tests would be especially nice at the moment.

## Want to understand the code? 🤓

Read the documentation, and, more importantly, have a look at the examples in the `tests/Test` folder! Feel free to start an issue to ask for clarifications.

## Want to apply it? 👩‍🔧

### Run the tests 👨‍💻

- [Install Elm](https://guide.elm-lang.org/install/elm.html)
- Install elm-test: `npm install -g elm-test`
- Run `elm-test` from the root directory of this repository.

### Use it in your Elm application 🎆

This is not (yet) published as a package, so it's a bit inconvenient to use.

Clone this repository and then, in the `elm.json` of your Elm application, add the path of the `src` folder of your clone of the repository. Also copy the dependency list from the `elm.json` of this package into the `elm.json` of your package. If this is not clear enough or does not work, open an issue!

## Questions? 😕

Open an issue! 🎈
