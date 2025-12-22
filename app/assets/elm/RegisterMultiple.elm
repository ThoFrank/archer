module RegisterMultiple exposing (..)

import Browser
import Class exposing (Class)
import Date
import Dob
import Email
import Html exposing (Html, button, datalist, div, form, h3, hr, input, label, option, select, text)
import Html.Attributes exposing (action, autocomplete, class, disabled, for, id, list, method, name, property, selected, tabindex, type_, value)
import Html.Events exposing (onInput)
import I18Next exposing (t, translationsDecoder)
import Json.Decode as JD
import Json.Encode as JE
import List exposing (filter, map)
import List.Extra
import Maybe exposing (andThen)
import Participant exposing (Participant, ParticipantMsgType, available_classes, update_participant)
import TargetFace exposing (TargetFace)
import Time exposing (Month(..))


main : Program Flags Model Msg
main =
    Browser.element { init = init, subscriptions = subscriptions, update = update, view = view }


type alias ValidModel =
    { flags : Flags
    , translations : I18Next.Translations
    , classes : List Class
    , email : String
    , club : String
    , comment : String
    , participants : List Participant
    }


type Model
    = InitializationError String
    | ValidatedModel ValidModel


init : Flags -> ( Model, Cmd msg )
init f =
    let
        decoded_classed =
            JD.decodeValue (JD.list Class.classDecoder) f.classes
                |> Result.mapError JD.errorToString

        decoded_translations =
            JD.decodeValue translationsDecoder f.translations

        email =
            Maybe.withDefault "" (Maybe.map (\a -> a.email) (List.head f.existing_archers))

        comment =
            Maybe.withDefault "" (Maybe.map (\a -> a.comment) (List.head f.existing_archers))
    in
    ( case ( decoded_translations, decoded_classed ) of
        ( Result.Ok translations, Result.Ok validClasses ) ->
            let
                participants : List Participant
                participants =
                    f.existing_archers
                        |> List.map
                            (\fp ->
                                let
                                    selected_class : Maybe Class
                                    selected_class =
                                        validClasses
                                            |> filter (\{ id } -> id == fp.selected_class)
                                            |> List.head

                                    selected_target_face : Maybe TargetFace
                                    selected_target_face =
                                        selected_class
                                            |> andThen
                                                (\cls ->
                                                    cls.possible_target_faces
                                                        |> List.filter (\t -> t.id == fp.selected_target_face)
                                                        |> List.head
                                                )

                                    dob =
                                        Date.fromIsoString fp.dob
                                            |> Result.map (\d -> Dob.Valid d)
                                            |> Result.withDefault (Dob.Invalid fp.dob)
                                in
                                { first_name = fp.first_name
                                , last_name = fp.last_name
                                , club = fp.club
                                , dob = dob
                                , selected_class = selected_class
                                , selected_target_face = selected_target_face
                                , group = fp.group_id
                                }
                            )
            in
            ValidatedModel
                { flags = f
                , translations = translations
                , classes = validClasses
                , participants = participants
                , email = email
                , comment = comment
                , club = Maybe.withDefault "" (List.head f.existing_archers |> Maybe.map (\fp -> fp.club))
                }

        ( Result.Ok _, Result.Err e ) ->
            InitializationError e

        ( Result.Err e, Result.Ok _ ) ->
            InitializationError (JD.errorToString e)

        ( Result.Err e1, Result.Err e2 ) ->
            InitializationError ("multiple errors: " ++ JD.errorToString e1 ++ "\n" ++ e2)
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


type Msg
    = ParticipantMsg Int ParticipantMsgType
    | UpdateEmail String
    | UpdateClub String
    | UpdateComment String
    | AddParticipant
    | RemoveParticipant Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg mdl =
    case mdl of
        InitializationError _ ->
            ( mdl, Cmd.none )

        ValidatedModel model ->
            ( ValidatedModel
                (case msg of
                    ParticipantMsg i pmsg ->
                        let
                            participants =
                                model.participants
                                    |> List.indexedMap
                                        (\j ->
                                            \p ->
                                                if j == i then
                                                    update_participant pmsg p model.classes

                                                else
                                                    p
                                        )
                        in
                        { model | participants = participants }

                    UpdateEmail e ->
                        { model | email = e }

                    UpdateClub c ->
                        { model
                            | participants = List.map (\p -> { p | club = c }) model.participants
                            , club = c
                        }

                    UpdateComment c ->
                        { model | comment = c }

                    AddParticipant ->
                        { model
                            | participants =
                                model.participants
                                    ++ [ { first_name = ""
                                         , last_name = ""
                                         , club = model.club
                                         , dob = Dob.Invalid ""
                                         , selected_class = Nothing
                                         , selected_target_face = Nothing
                                         , group = Nothing
                                         }
                                       ]
                        }

                    RemoveParticipant i ->
                        let
                            m1 =
                                { model | participants = List.Extra.removeAt i model.participants }

                            m2 =
                                if List.isEmpty m1.participants then
                                    { m1
                                        | participants =
                                            [ { first_name = ""
                                              , last_name = ""
                                              , club = model.club
                                              , dob = Dob.Invalid ""
                                              , selected_class = Nothing
                                              , selected_target_face = Nothing
                                              , group = Nothing
                                              }
                                            ]
                                    }

                                else
                                    m1
                        in
                        m2
                )
            , Cmd.none
            )


submittable : ValidModel -> Bool
submittable model =
    let
        ( groups, _ ) =
            List.unzip model.flags.available_groups
    in
    List.all (Participant.submittable groups model.flags.require_club) model.participants
        && (case Email.fromString model.email of
                Just _ ->
                    True

                Nothing ->
                    False
           )


viewAvailableClasses : List Class -> Participant -> List (Html Msg)
viewAvailableClasses classes participant =
    available_classes classes participant
        |> map
            (\cls ->
                option
                    [ selected
                        (participant.selected_class == Just cls)
                    , value cls.id
                    ]
                    [ text cls.name ]
            )


viewParticipant : Int -> Participant -> ValidModel -> List (Html Msg)
viewParticipant i participant model =
    let
        first_name_class =
            if String.isEmpty participant.first_name then
                invalid_input_class

            else
                valid_input_class

        last_name_class =
            if String.isEmpty participant.last_name then
                invalid_input_class

            else
                valid_input_class

        dob_class =
            case participant.dob of
                Dob.Valid _ ->
                    valid_input_class

                Dob.Invalid _ ->
                    invalid_input_class

        ( groups, _ ) =
            List.unzip model.flags.available_groups
    in
    [ hr [] []
    , div [ class "space-y-1 flex w-full max-w-md" ]
        [ h3
            [ class
                ("flex-none text-2xl font-bold mb-4 "
                    ++ (if Participant.submittable groups model.flags.require_club participant then
                            "text-gray-800"

                        else
                            "text-red-800"
                       )
                )
            ]
            [ text ("#" ++ String.fromInt (i + 1)) ]
        , div [ class "flex-1" ] []
        , button [ class "flex-none text-2xl font-bold mb-4 text-gray-800", onClick (RemoveParticipant i) ] [ text "🗑️" ]
        ]
    , div [ class "space-y-1" ]
        [ label [ for ("first_name_" ++ String.fromInt i), class input_label_class ] [ text (t model.translations "Given name:") ]
        , input [ id ("first_name_" ++ String.fromInt i), property "autocomplete" (JE.string "given-name"), name "participants[][first_name]", class first_name_class, onInput (Participant.UpdateFirstName >> ParticipantMsg i), value participant.first_name ] []
        ]
    , div [ class "space-y-1" ]
        [ label [ for ("last_name_" ++ String.fromInt i), class input_label_class ] [ text (t model.translations "Last name:") ]
        , input [ id ("last_name_" ++ String.fromInt i), property "autocomplete" (JE.string "family-name"), name "participants[][last_name]", class last_name_class, onInput (Participant.UpdateLastName >> ParticipantMsg i), value participant.last_name ] []
        ]
    , div [ class "space-y-1" ]
        [ label [ for ("dob_" ++ String.fromInt i), class input_label_class ] [ text (t model.translations "Date of birth:") ]
        , input
            [ type_ "date"
            , property "autocomplete" (JE.string "bday")
            , onInput (Participant.UpdateDob >> ParticipantMsg i)
            , value
                (case participant.dob of
                    Dob.Invalid s ->
                        s

                    Dob.Valid d ->
                        Date.toIsoString d
                )
            , id ("dob_" ++ String.fromInt i)
            , name "participants[][dob]"
            , class
                dob_class
            ]
            []
        ]
    ]
        ++ (if model.flags.require_club then
                [ div [ class "space-y-1" ]
                    [ input [ id ("club_" ++ String.fromInt i), type_ "hidden", autocomplete False, name "participants[][club]", value model.club ] []
                    ]
                ]

            else
                []
           )
        ++ (if List.isEmpty model.flags.available_groups then
                []

            else
                [ div [ class "space-y-1" ]
                    [ label [ for ("group_" ++ String.fromInt i), class input_label_class ] [ text (t model.translations "Group:") ]
                    , select
                        [ onInput ((String.toInt >> Maybe.withDefault -1) >> Participant.SelectGroup >> ParticipantMsg i)
                        , value
                            (case participant.group of
                                Nothing ->
                                    "--"

                                Just g ->
                                    String.fromInt g
                            )
                        , id ("group_" ++ String.fromInt i)
                        , name "participants[][group]"
                        , class valid_input_class
                        ]
                        (option
                            [ name "Group"
                            , disabled False
                            , selected (participant.selected_class == Nothing)
                            , value "--"
                            ]
                            [ text "--" ]
                            :: (model.flags.available_groups
                                    |> List.map
                                        (\( j, g ) ->
                                            option
                                                [ value (String.fromInt j)
                                                , selected (participant.group == Just j)
                                                ]
                                                [ text g ]
                                        )
                               )
                        )
                    ]
                ]
           )
        ++ [ div [ class "space-y-1" ]
                [ label [ for ("class_" ++ String.fromInt i), class input_label_class ] [ text (t model.translations "Class:") ]
                , select
                    [ onInput (Participant.SelectClass >> ParticipantMsg i)
                    , value
                        (case participant.selected_class of
                            Nothing ->
                                "--"

                            Just c ->
                                c.id
                        )
                    , id ("class_" ++ String.fromInt i)
                    , name "participants[][tournament_class]"
                    , class valid_input_class
                    ]
                    (option
                        [ name "Class"
                        , disabled False
                        , selected (participant.selected_class == Nothing)
                        , value "--"
                        ]
                        [ text "--" ]
                        :: viewAvailableClasses model.classes participant
                    )
                ]
           , div [ class "space-y-1" ]
                [ label
                    [ for ("target_face_" ++ String.fromInt i), class input_label_class ]
                    [ text (t model.translations "Target:") ]
                , select
                    [ onInput (Participant.SelectTargetFace >> ParticipantMsg i)
                    , id ("target_face_" ++ String.fromInt i)
                    , name "participants[][target_face]"
                    , class valid_input_class
                    ]
                    (option
                        [ selected (participant.selected_target_face == Nothing)
                        , disabled False
                        , value "--"
                        ]
                        [ text "--" ]
                        :: (case participant.selected_class of
                                Nothing ->
                                    []

                                Just { possible_target_faces } ->
                                    map
                                        (\tf ->
                                            option
                                                [ selected (participant.selected_target_face == Just tf)
                                                , value tf.id
                                                ]
                                                [ text tf.name ]
                                        )
                                        possible_target_faces
                           )
                    )
                ]
           ]


input_label_class : String
input_label_class =
    "block text-sm font-medium text-gray-700"


valid_input_class : String
valid_input_class =
    "block w-full max-w-md border border-gray-300 rounded-lg px-3 py-2 text-gray-900 focus:ring-blue-500 focus:border-blue-500"


invalid_input_class : String
invalid_input_class =
    "block w-full max-w-md border border-red-300 rounded-lg px-3 py-2 text-gray-900 focus:ring-red-500 focus:border-red-500"


onClick : msg -> Html.Attribute msg
onClick msg =
    Html.Events.preventDefaultOn "click" (JD.map alwaysPreventDefault (JD.succeed msg))


alwaysPreventDefault : msg -> ( msg, Bool )
alwaysPreventDefault msg =
    ( msg, True )


view : Model -> Html Msg
view mdl =
    case mdl of
        InitializationError e ->
            div [] [ text e ]

        ValidatedModel model ->
            let
                email_class =
                    case Email.fromString model.email of
                        Just _ ->
                            valid_input_class

                        Nothing ->
                            invalid_input_class

                club_class =
                    if String.isEmpty model.club then
                        invalid_input_class

                    else
                        valid_input_class
            in
            form [ action model.flags.form_action_url, method "post", class "space-y-4 max-w-lg mx-auto p-6 bg-white shadow rounded-lg" ]
                (List.concat
                    [ [ input [ type_ "hidden", name "authenticity_token", value model.flags.csrf_token, autocomplete False ] []
                      ]
                    , if List.isEmpty model.flags.existing_archers then
                        []

                      else
                        [ input [ type_ "hidden", name "_method", value "patch", autocomplete False ] []
                        ]
                    , [ div [ class "space-y-1" ]
                            [ label [ for "email", class input_label_class ] [ text (t model.translations "Email address:") ]
                            , input [ id "email", type_ "email", name "registration[email]", class email_class, onInput UpdateEmail, value model.email ] []
                            ]
                      ]
                    , if model.flags.require_club then
                        [ div [ class "space-y-1" ]
                            [ label [ for "club", class input_label_class ] [ text (t model.translations "Club:") ]
                            , input [ id "club", name "participant[club]", class club_class, onInput UpdateClub, value model.club, list "club_suggestions" ] []
                            ]
                        , datalist [ id "club_suggestions" ]
                            (model.flags.known_clubs |> List.map (\c -> option [ value c ] []))
                        ]

                      else
                        []
                    , [ div [ class "space-y-1" ]
                            [ label [ for "comment", class input_label_class ] [ text (t model.translations "Comment:") ]
                            , input [ id "comment", name "registration[comment]", class valid_input_class, onInput UpdateComment, value model.comment ] []
                            ]
                      ]
                    , List.concat (model.participants |> List.indexedMap (\i -> \p -> viewParticipant i p model))
                    , [ div [ class "space-y-1" ]
                            [ button
                                [ onClick AddParticipant
                                , tabindex 0
                                , class "block w-full max-w-md rounded-lg px-3 py-2 text-white font-medium bg-blue-600 focus:ring-blue-500 focus:border-blue-500"
                                ]
                                [ text "+" ]
                            ]
                      , input
                            [ type_ "submit"
                            , tabindex 0
                            , value (t model.translations "Submit")
                            , disabled <| not <| submittable <| model
                            , class "inline-block px-6 py-2 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-300 disabled:cursor-not-allowed"
                            ]
                            []
                      ]
                    ]
                )



-- Flags


type alias Flags =
    { csrf_token : String
    , form_action_url : String
    , classes : JD.Value
    , translations : JD.Value
    , existing_archers :
        List
            { first_name : String
            , last_name : String
            , club : String
            , email : String
            , dob : String
            , selected_class : String
            , selected_target_face : String
            , comment : String
            , group_id : Maybe Int
            }
    , require_club : Bool
    , known_clubs : List String
    , available_groups : List ( Int, String )
    }
