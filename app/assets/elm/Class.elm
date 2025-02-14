module Class exposing (..)

import Date exposing (Date)
import Json.Decode as JD
import TargetFace exposing (TargetFace)


type alias Class =
    { id : String
    , name : String
    , start_dob : Date
    , end_dob : Date
    , possible_target_faces : List TargetFace
    }


class_in_range : Date -> Class -> Bool
class_in_range dob cls =
    Date.isBetween cls.start_dob cls.end_dob dob


classDecoder : JD.Decoder Class
classDecoder =
    JD.map5 Class
        (JD.field "id" JD.string)
        (JD.field "name" JD.string)
        (JD.field "start_dob" JD.string
            |> JD.andThen
                (\s ->
                    Date.fromIsoString s
                        |> Result.map JD.succeed
                        |> Result.withDefault (JD.fail "start_dob not a date")
                )
        )
        (JD.field "end_dob" JD.string
            |> JD.andThen
                (\s ->
                    Date.fromIsoString s
                        |> Result.map JD.succeed
                        |> Result.withDefault (JD.fail "end_dob not a date")
                )
        )
        (JD.field "possible_target_faces" (JD.list TargetFace.targetFaceDecoder))
