module Class exposing (..)

import Date exposing (Date)
import TargetFace exposing (TargetFace)


type Gender
    = Male
    | Female


type alias Class =
    { id : String, name : String, restricted_to_gender : Maybe Gender, start_dob : Date, end_dob : Date, possible_target_faces : List TargetFace }


class_in_range : Date -> Class -> Bool
class_in_range dob cls =
    Date.isBetween cls.start_dob cls.end_dob dob
