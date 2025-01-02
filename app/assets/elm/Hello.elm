module Hello exposing (main)

import Browser
import Class exposing (Class, Gender(..), class_in_range)
import Date exposing (Date)
import Debug exposing (toString)
import Html exposing (Html, br, form, input, label, option, select, text)
import Html.Attributes exposing (disabled, for, id, name, selected, type_, value)
import Html.Events exposing (onInput)
import List exposing (filter, map)
import Maybe exposing (andThen, withDefault)
import TargetFace exposing (TargetFace(..))
import Time exposing (Month(..))


main : Program () Model Msg
main =
    Browser.sandbox { init = init, update = update, view = view }


type alias Model =
    { classes : List Class
    , first_name : String
    , last_name : String
    , dob : Dob
    , selected_class : Maybe Class
    , selected_target_face : Maybe TargetFace
    }


type Dob
    = Invalid String
    | Valid Date


init : Model
init =
    { classes =
        [ { id = "RUE21M"
          , name = "Recurve Herren"
          , restricted_to_gender = Just Male
          , start_dob = Date.fromCalendarDate (2025 - 49) Dec 1
          , end_dob = Date.fromCalendarDate (2025 - 21) Jan 1
          , possible_target_faces = [ M18Spot, M18cm40 ]
          }
        , { id = "RUE21W"
          , name = "Recurve Damen"
          , restricted_to_gender = Just Female
          , start_dob = Date.fromCalendarDate (2025 - 49) Dec 1
          , end_dob = Date.fromCalendarDate (2025 - 21) Jan 1
          , possible_target_faces = [ M18Spot, M18cm40 ]
          }
        ]
    , first_name = ""
    , last_name = ""
    , dob = Invalid ""
    , selected_class = Nothing
    , selected_target_face = Nothing
    }


type Msg
    = SelectClass String
    | SelectTargetFace String
    | UpdateDob String
    | UpdateFirstName String
    | UpdateLastName String


update : Msg -> Model -> Model
update msg model =
    case msg of
        SelectClass cls_id ->
            { model
                | selected_class =
                    model.classes
                        |> filter (\{ id } -> id == cls_id)
                        |> List.head
            }

        SelectTargetFace tf ->
            { model
                | selected_target_face =
                    model.selected_class
                        |> andThen
                            (\cls ->
                                cls.possible_target_faces
                                    |> List.filter (\t -> toString t == tf)
                                    |> List.head
                            )
            }

        UpdateDob dob ->
            let
                new_dob =
                    Date.fromIsoString dob
                        |> Result.map (\d -> Valid d)
                        |> Result.withDefault (Invalid dob)

                m0 =
                    model

                m1 =
                    { m0 | dob = new_dob }

                m2 =
                    { m1 | selected_class = updateSelectedClass m1 }

                m3 =
                    { m2 | selected_target_face = updateSelectedTargetFace m2 }
            in
            m3

        UpdateFirstName n ->
            { model | first_name = n }

        UpdateLastName n ->
            { model | last_name = n }


updateSelectedClass : Model -> Maybe Class
updateSelectedClass model =
    if
        available_classes model
            |> map (\cls -> Just cls)
            |> List.member model.selected_class
    then
        model.selected_class

    else
        Nothing


updateSelectedTargetFace : Model -> Maybe TargetFace
updateSelectedTargetFace model =
    model.selected_class
        |> Maybe.andThen
            (\cls ->
                cls.possible_target_faces
                    |> map (\tf -> Just tf)
                    |> List.filter (\tf -> tf == model.selected_target_face)
                    |> List.head
                    |> withDefault Nothing
            )


name_of_target_face : TargetFace -> String
name_of_target_face tf =
    case tf of
        M18Spot ->
            "18m / Spot"

        M18cm40 ->
            "18m / 40cm"


available_classes : Model -> List Class.Class
available_classes model =
    case model.dob of
        Invalid _ ->
            []

        Valid dob ->
            model.classes |> filter (class_in_range dob)


submittable : Model -> Bool
submittable model =
    not (String.isEmpty model.first_name)
        && not (String.isEmpty model.last_name)
        && (case model.dob of
                Valid _ ->
                    True

                Invalid _ ->
                    False
           )
        && (case model.selected_class of
                Just _ ->
                    True

                Nothing ->
                    False
           )
        && (case model.selected_target_face of
                Just _ ->
                    True

                Nothing ->
                    False
           )


br : Html msg
br =
    Html.br [] []


viewAvailableClasses : Model -> List (Html Msg)
viewAvailableClasses model =
    available_classes model
        |> map
            (\cls ->
                option
                    [ selected
                        (model.selected_class == Just cls)
                    , value cls.id
                    ]
                    [ text cls.name ]
            )


view : Model -> Html Msg
view model =
    form []
        [ label [ for "first_name" ] [ text "Vorname:" ]
        , br
        , input [ id "first_name", onInput UpdateFirstName, value model.first_name ] []
        , br
        , label [ for "last_name" ] [ text "Vorname:" ]
        , br
        , input [ id "last_name", onInput UpdateLastName, value model.last_name ] []
        , br
        , label [ for "dob" ] [ text "Geburtsdatum:" ]
        , br
        , input
            [ type_ "date"
            , onInput UpdateDob
            , value
                (case model.dob of
                    Invalid s ->
                        s

                    Valid d ->
                        Date.toIsoString d
                )
            , id "dob"
            ]
            []
        , br
        , label [ for "class" ] [ text "Klasse:" ]
        , br
        , select
            [ onInput SelectClass
            , value
                (case model.selected_class of
                    Nothing ->
                        "--"

                    Just c ->
                        c.id
                )
            , id "class"
            ]
            (option
                [ name "Class"
                , disabled False
                , selected (model.selected_class == Nothing)
                , value "--"
                ]
                [ text "--" ]
                :: viewAvailableClasses model
            )
        , br
        , label
            [ for "TargetFace" ]
            [ text "Auflage:" ]
        , br
        , select
            [ onInput SelectTargetFace, id "TargetFace" ]
            (option
                [ selected (model.selected_target_face == Nothing)
                , name "TargetFace"
                , disabled False
                , value "--"
                ]
                [ text "--" ]
                :: (case model.selected_class of
                        Nothing ->
                            []

                        Just { possible_target_faces } ->
                            map
                                (\tf ->
                                    option
                                        [ selected (model.selected_target_face == Just tf)
                                        , value (toString tf)
                                        ]
                                        [ text (name_of_target_face tf) ]
                                )
                                possible_target_faces
                   )
            )
        , br
        , input [ type_ "submit", value "Anmelden", disabled <| not <| submittable <| model ] []
        ]
