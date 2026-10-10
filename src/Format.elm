module Format exposing (avatarUrl, dateTime, errorMessage, pluralize)

import MD5
import Time


{-| French rule: singular for 0 and 1, plural for 2+.
-}
pluralize : Int -> String
pluralize count =
    if count <= 1 then
        ""

    else
        "s"


{-| "2026-10-10 14:03:05" in the given time zone.
-}
dateTime : Time.Zone -> Time.Posix -> String
dateTime zone time =
    let
        pad n =
            String.padLeft 2 '0' (String.fromInt n)
    in
    String.fromInt (Time.toYear zone time)
        ++ "-"
        ++ pad (monthNumber (Time.toMonth zone time))
        ++ "-"
        ++ pad (Time.toDay zone time)
        ++ " "
        ++ pad (Time.toHour zone time)
        ++ ":"
        ++ pad (Time.toMinute zone time)
        ++ ":"
        ++ pad (Time.toSecond zone time)


monthNumber : Time.Month -> Int
monthNumber month =
    case month of
        Time.Jan ->
            1

        Time.Feb ->
            2

        Time.Mar ->
            3

        Time.Apr ->
            4

        Time.May ->
            5

        Time.Jun ->
            6

        Time.Jul ->
            7

        Time.Aug ->
            8

        Time.Sep ->
            9

        Time.Oct ->
            10

        Time.Nov ->
            11

        Time.Dec ->
            12


avatarUrl : String -> String
avatarUrl username =
    "https://api.dicebear.com/9.x/bottts/svg?seed=" ++ MD5.hex username


errorMessage : String -> String
errorMessage message =
    "Erreur : " ++ message
