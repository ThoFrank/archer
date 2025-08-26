module Dob exposing (..)

import Date exposing (Date)


type Dob
    = Invalid String
    | Valid Date
