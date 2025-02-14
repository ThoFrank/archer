module TargetFace exposing (..)

import Json.Decode as JD


type TargetFace
    = M18Spot
    | M18cm40


toString : TargetFace -> String
toString tf =
    case tf of
        M18Spot ->
            "M18Spot"

        M18cm40 ->
            "M18cm40"


fromString : String -> Maybe TargetFace
fromString tf =
    case tf of
        "M18Spot" ->
            Just M18Spot

        "M18cm40" ->
            Just M18cm40

        _ ->
            Nothing


targetFaceDecoder : JD.Decoder TargetFace
targetFaceDecoder =
    JD.string
        |> JD.andThen (\str -> fromString str |> Maybe.map JD.succeed |> Maybe.withDefault (JD.fail "Unkown TargetFace"))
