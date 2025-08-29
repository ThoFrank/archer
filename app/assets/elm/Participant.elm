module Participant exposing (..)

import Class exposing (Class, class_in_range)
import Date
import Dob exposing (Dob)
import List exposing (filter, map)
import Maybe exposing (andThen, withDefault)
import TargetFace exposing (TargetFace)


type alias Participant =
    { first_name : String
    , last_name : String
    , dob : Dob
    , selected_class : Maybe Class
    , selected_target_face : Maybe TargetFace
    }


type ParticipantMsgType
    = SelectClass String
    | SelectTargetFace String
    | UpdateDob String
    | UpdateFirstName String
    | UpdateLastName String


available_classes : List Class -> Participant -> List Class.Class
available_classes classes participant =
    case participant.dob of
        Dob.Invalid _ ->
            []

        Dob.Valid dob ->
            classes |> filter (class_in_range dob)


updateSelectedClass : List Class -> Participant -> Maybe Class
updateSelectedClass classes participant =
    if
        available_classes classes participant
            |> map (\cls -> Just cls)
            |> List.member participant.selected_class
    then
        participant.selected_class

    else
        Nothing


updateSelectedTargetFace : Participant -> Maybe TargetFace
updateSelectedTargetFace participant =
    participant.selected_class
        |> Maybe.andThen
            (\cls ->
                cls.possible_target_faces
                    |> map (\tf -> Just tf)
                    |> List.filter (\tf -> tf == participant.selected_target_face)
                    |> List.head
                    |> withDefault Nothing
            )


update_participant : ParticipantMsgType -> Participant -> List Class -> Participant
update_participant msg participant classes =
    case msg of
        SelectClass cls_id ->
            let
                p0 =
                    participant

                p1 =
                    { p0
                        | selected_class =
                            classes
                                |> filter (\{ id } -> id == cls_id)
                                |> List.head
                    }
            in
            { p1 | selected_target_face = updateSelectedTargetFace p1 }

        SelectTargetFace tf ->
            { participant
                | selected_target_face =
                    participant.selected_class
                        |> andThen
                            (\cls ->
                                cls.possible_target_faces
                                    |> List.filter (\t -> t.id == tf)
                                    |> List.head
                            )
            }

        UpdateDob dob ->
            let
                new_dob =
                    Date.fromIsoString dob
                        |> Result.map (\d -> Dob.Valid d)
                        |> Result.withDefault (Dob.Invalid dob)

                p0 =
                    participant

                p1 =
                    { p0 | dob = new_dob }

                p2 =
                    { p1 | selected_class = updateSelectedClass classes p1 }
            in
            { p2 | selected_target_face = updateSelectedTargetFace p2 }

        UpdateFirstName n ->
            { participant | first_name = n }

        UpdateLastName n ->
            { participant | last_name = n }


submittable : Participant -> Bool
submittable participant =
    not (String.isEmpty participant.first_name)
        && not (String.isEmpty participant.last_name)
        && (case participant.dob of
                Dob.Valid _ ->
                    True

                Dob.Invalid _ ->
                    False
           )
        && (case participant.selected_class of
                Just _ ->
                    True

                Nothing ->
                    False
           )
        && (case participant.selected_target_face of
                Just _ ->
                    True

                Nothing ->
                    False
           )
