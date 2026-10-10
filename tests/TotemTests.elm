module TotemTests exposing (suite)

import Array
import Expect
import Test exposing (Test, describe, test)
import Totem exposing (adjectives, animals, totem)


suite : Test
suite =
    describe "Totem"
        [ test "is deterministic" <|
            \_ -> totem "alice" |> Expect.equal (totem "alice")
        , test "is case and whitespace sensitive" <|
            \_ ->
                Expect.all
                    [ \_ -> Expect.notEqual (totem "Alice") (totem "alice")
                    , \_ -> Expect.notEqual (totem " alice") (totem "alice")
                    ]
                    ()
        , test "different seeds likely differ" <|
            \_ -> Expect.notEqual (totem "alice") (totem "bob")
        , test "uses a known animal and adjective, both capitalized" <|
            \_ ->
                case String.words (totem "alice") of
                    [ animal, adjective ] ->
                        Expect.all
                            [ \_ -> Expect.equal True (List.member (String.toLower animal) (Array.toList animals))
                            , \_ -> Expect.equal True (List.member (String.toLower adjective) (Array.toList adjectives))
                            , \_ -> Expect.equal (String.toUpper animal |> String.left 1) (String.left 1 animal)
                            , \_ -> Expect.equal (String.toUpper adjective |> String.left 1) (String.left 1 adjective)
                            ]
                            ()

                    words ->
                        Expect.fail ("Expected two words, got " ++ String.join " | " words)
        , test "lists have 32 entries each" <|
            \_ -> ( Array.length animals, Array.length adjectives ) |> Expect.equal ( 32, 32 )

        -- Fixed seeds with their expected totems, so a change in the algorithm shows up.
        , describe "known totems"
            (List.map
                (\( seed, expected ) -> test seed <| \_ -> totem seed |> Expect.equal expected)
                [ ( "alice", "Araignée Célèbre" )
                , ( "bob", "Zèbre Splendide" )
                , ( "Élodie", "Lynx Solide" )
                , ( "hunter2", "Écureuil Sauvage" )
                ]
            )
        ]
