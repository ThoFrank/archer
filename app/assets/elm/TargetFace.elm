module TargetFace exposing (..)

import Json.Decode as JD


type alias TargetFace =
    { id : String
    , name : String
    }


targetFaceDecoder : JD.Decoder TargetFace
targetFaceDecoder =
    JD.map2 TargetFace
        (JD.field "id" JD.int |> JD.map String.fromInt)
        (JD.field "name" JD.string)
