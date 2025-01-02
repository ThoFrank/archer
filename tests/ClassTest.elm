module ClassTest exposing (..)

import Class
import Date
import Expect
import Test exposing (Test)
import Time exposing (Month(..))


testClass : Class.Class
testClass =
    { id = "tC"
    , name = "testClass"
    , restricted_to_gender = Nothing
    , start_dob = Date.fromCalendarDate 2020 Jan 1
    , end_dob = Date.fromCalendarDate 2020 Dec 31
    , possible_target_faces = []
    }


suite : Test
suite =
    Test.describe "Test Class module"
        [ Test.describe "Test Class.class_in_range"
            [ Test.test "Start of range" <|
                \_ ->
                    Class.class_in_range (Date.fromCalendarDate 2020 Jan 1) testClass
                        |> Expect.equal True
            , Test.test "End of range" <|
                \_ ->
                    Class.class_in_range (Date.fromCalendarDate 2020 Dec 31) testClass
                        |> Expect.equal True
            , Test.test "Out of range (too early)" <|
                \_ ->
                    Class.class_in_range (Date.fromCalendarDate 2019 Dec 31) testClass
                        |> Expect.equal False
            , Test.test "Out of range (too late)" <|
                \_ ->
                    Class.class_in_range (Date.fromCalendarDate 2021 Jan 1) testClass
                        |> Expect.equal False
            ]
        ]
