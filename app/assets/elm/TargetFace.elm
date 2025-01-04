module TargetFace exposing (..)


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
