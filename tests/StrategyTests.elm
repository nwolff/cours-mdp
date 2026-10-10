module StrategyTests exposing (suite)

import Expect
import Random
import Strategy exposing (Strategy(..))
import Test exposing (Test, describe, test)


{-| Salts as drawn on the registration page, from fixed seeds.
-}
saltFrom : Int -> Strategy.Salt
saltFrom seed =
    Random.step Strategy.saltGenerator (Random.initialSeed seed) |> Tuple.first


suite : Test
suite =
    describe "Strategy"
        [ describe "every strategy" (List.map roundTrip Strategy.all)
        , test "all strategies, in display order" <|
            \_ ->
                List.map Strategy.name Strategy.all
                    |> Expect.equal [ "plaintext", "rot13", "md5", "salted_md5" ]
        , test "fromName reverses name" <|
            \_ ->
                List.map (Strategy.name >> Strategy.fromName) Strategy.all
                    |> Expect.equal (List.map Just Strategy.all)
        , test "fromName rejects unknown names" <|
            \_ -> Strategy.fromName "sha1" |> Expect.equal Nothing
        , test "plaintext stores password as is" <|
            \_ -> Strategy.encode "" Plaintext "abc" |> Expect.equal "abc"
        , test "rot13 round trip" <|
            \_ ->
                Strategy.encode "" Rot13 "hello"
                    |> Expect.all
                        [ Expect.equal "uryyb"
                        , Strategy.encode "" Rot13 >> Expect.equal "hello"
                        ]
        , test "md5 is deterministic 32 hex" <|
            \_ ->
                Strategy.encode "" Md5 "hello"
                    |> Expect.all
                        [ Expect.equal (Strategy.encode "" Md5 "hello")
                        , String.length >> Expect.equal 32
                        , String.all Char.isHexDigit >> Expect.equal True
                        ]
        , test "salts are 6 lowercase hex characters" <|
            \_ ->
                List.map saltFrom (List.range 1 50)
                    |> List.all (\salt -> String.length salt == 6 && String.all (\c -> Char.isDigit c || (c >= 'a' && c <= 'f')) salt)
                    |> Expect.equal True
        , test "different salts give different encodings of the same password" <|
            \_ ->
                let
                    ( a, b ) =
                        ( Strategy.encode (saltFrom 1) SaltedMd5 "hello", Strategy.encode (saltFrom 2) SaltedMd5 "hello" )
                in
                Expect.all
                    [ \_ -> Expect.notEqual a b

                    -- Both still verify against the same password.
                    , \_ -> Strategy.matches SaltedMd5 "hello" a |> Expect.equal True
                    , \_ -> Strategy.matches SaltedMd5 "hello" b |> Expect.equal True
                    ]
                    ()
        , test "salted md5 format is salt$hash" <|
            \_ ->
                Strategy.encode "abc123" SaltedMd5 "hello"
                    |> String.split "$"
                    |> List.map String.length
                    |> Expect.equal [ 6, 32 ]

        -- Fixed inputs with their expected outputs, so a change in the algorithms shows up.
        , describe "known values"
            [ test "md5" <|
                \_ -> Strategy.encode "" Md5 "hello" |> Expect.equal "5d41402abc4b2a76b9719d911017c592"
            , test "rot13 only rotates latin letters" <|
                \_ -> Strategy.encode "" Rot13 "Hello, Wörld 123" |> Expect.equal "Uryyb, Jöeyq 123"
            , test "salted md5 hashes salt + password" <|
                \_ -> Strategy.hashWithSalt "abc" "hunter2" |> Expect.equal "58916152055d74d5098420c036bd4c83"
            , test "salted md5 matches a stored password" <|
                \_ -> Strategy.matches SaltedMd5 "hunter2" "abc$58916152055d74d5098420c036bd4c83" |> Expect.equal True
            ]
        ]


roundTrip : Strategy -> Test
roundTrip strategy =
    let
        stored =
            Strategy.encode (saltFrom 42) strategy "hunter2"
    in
    describe (Strategy.name strategy)
        [ test "encode then matches" <|
            \_ -> Strategy.matches strategy "hunter2" stored |> Expect.equal True
        , test "wrong password does not match" <|
            \_ -> Strategy.matches strategy "hunter3" stored |> Expect.equal False
        , test "encodeLike reproduces the stored password" <|
            \_ -> Strategy.encodeLike strategy "hunter2" stored |> Expect.equal stored
        ]
