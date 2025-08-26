module Participant exposing (..)

import Class exposing (Class)
import Dob exposing (Dob)
import TargetFace exposing (TargetFace)


type alias Participant =
    { first_name : String
    , last_name : String
    , dob : Dob
    , selected_class : Maybe Class
    , selected_target_face : Maybe TargetFace
    }
