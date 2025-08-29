module RegisterOne exposing (main)

import Browser
import Class exposing (Class)
import Date
import Dob
import Email
import Html exposing (Html, div, form, input, label, option, select, text)
import Html.Attributes exposing (action, autocomplete, class, disabled, for, id, method, name, property, selected, tabindex, type_, value)
import Html.Events exposing (onInput)
import I18Next exposing (t, translationsDecoder)
import Json.Decode as JD
import Json.Encode as JE
import List exposing (filter, map)
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
    , comment : String
    , participant : Participant
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

        first_name =
            Maybe.withDefault "" (Maybe.map (\a -> a.first_name) f.existing_archer)

        last_name =
            Maybe.withDefault "" (Maybe.map (\a -> a.last_name) f.existing_archer)

        email =
            Maybe.withDefault "" (Maybe.map (\a -> a.email) f.existing_archer)

        dob_string =
            Maybe.withDefault "" (Maybe.map (\a -> a.dob) f.existing_archer)

        dob =
            Date.fromIsoString dob_string
                |> Result.map (\d -> Dob.Valid d)
                |> Result.withDefault (Dob.Invalid dob_string)

        selected_class_id =
            Maybe.map (\a -> a.selected_class) f.existing_archer

        selected_target_face_id =
            Maybe.map (\a -> a.selected_target_face) f.existing_archer

        comment =
            Maybe.withDefault "" (Maybe.map (\a -> a.comment) f.existing_archer)
    in
    ( case ( decoded_translations, decoded_classed ) of
        ( Result.Ok translations, Result.Ok validClasses ) ->
            let
                selected_class : Maybe Class
                selected_class =
                    Maybe.andThen
                        (\sc ->
                            validClasses
                                |> filter (\{ id } -> id == sc)
                                |> List.head
                        )
                        selected_class_id

                selected_target_face : Maybe TargetFace
                selected_target_face =
                    selected_target_face_id
                        |> Maybe.andThen
                            (\tf ->
                                selected_class
                                    |> andThen
                                        (\cls ->
                                            cls.possible_target_faces
                                                |> List.filter (\t -> t.id == tf)
                                                |> List.head
                                        )
                            )

                participant : Participant
                participant =
                    { first_name = first_name
                    , last_name = last_name
                    , dob = dob
                    , selected_class = selected_class
                    , selected_target_face = selected_target_face
                    }
            in
            ValidatedModel
                { flags = f
                , translations = translations
                , classes = validClasses
                , participant = participant
                , email = email
                , comment = comment
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
    = ParticipantMsg ParticipantMsgType
    | UpdateEmail String
    | UpdateComment String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg mdl =
    case mdl of
        InitializationError _ ->
            ( mdl, Cmd.none )

        ValidatedModel model ->
            ( ValidatedModel
                (case msg of
                    ParticipantMsg pmsg ->
                        { model | participant = update_participant pmsg model.participant model.classes }

                    UpdateEmail e ->
                        { model | email = e }

                    UpdateComment c ->
                        { model | comment = c }
                )
            , Cmd.none
            )


submittable : ValidModel -> Bool
submittable model =
    Participant.submittable model.participant
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


view : Model -> Html Msg
view mdl =
    let
        input_label_class =
            "block text-sm font-medium text-gray-700"

        valid_input_class =
            "block w-full max-w-md border border-gray-300 rounded-lg px-3 py-2 text-gray-900 focus:ring-blue-500 focus:border-blue-500"

        invalid_input_class =
            "block w-full max-w-md border border-red-300 rounded-lg px-3 py-2 text-gray-900 focus:ring-red-500 focus:border-red-500"
    in
    case mdl of
        InitializationError e ->
            div [] [ text e ]

        ValidatedModel model ->
            let
                first_name_class =
                    if String.isEmpty model.participant.first_name then
                        invalid_input_class

                    else
                        valid_input_class

                last_name_class =
                    if String.isEmpty model.participant.last_name then
                        invalid_input_class

                    else
                        valid_input_class

                email_class =
                    case Email.fromString model.email of
                        Just _ ->
                            valid_input_class

                        Nothing ->
                            invalid_input_class

                dob_class =
                    case model.participant.dob of
                        Dob.Valid _ ->
                            valid_input_class

                        Dob.Invalid _ ->
                            invalid_input_class
            in
            form [ action model.flags.form_action_url, method "post", class "space-y-4 max-w-lg mx-auto p-6 bg-white shadow rounded-lg" ]
                (List.concat
                    [ [ input [ type_ "hidden", name "authenticity_token", value model.flags.csrf_token, autocomplete False ] []
                      ]
                    , if model.flags.existing_archer == Nothing then
                        []

                      else
                        [ input [ type_ "hidden", name "_method", value "patch", autocomplete False ] []
                        ]
                    , [ div [ class "space-y-1" ]
                            [ label [ for "first_name", class input_label_class ] [ text (t model.translations "Given name:") ]
                            , input [ id "first_name", property "autocomplete" (JE.string "given-name"), name "participant[first_name]", class first_name_class, onInput (Participant.UpdateFirstName >> ParticipantMsg), value model.participant.first_name ] []
                            ]
                      , div [ class "space-y-1" ]
                            [ label [ for "last_name", class input_label_class ] [ text (t model.translations "Last name:") ]
                            , input [ id "last_name", property "autocomplete" (JE.string "family-name"), name "participant[last_name]", class last_name_class, onInput (Participant.UpdateLastName >> ParticipantMsg), value model.participant.last_name ] []
                            ]
                      , div [ class "space-y-1" ]
                            [ label [ for "email", class input_label_class ] [ text (t model.translations "Email address:") ]
                            , input [ id "email", type_ "email", name "registration[email]", class email_class, onInput UpdateEmail, value model.email ] []
                            ]
                      , div [ class "space-y-1" ]
                            [ label [ for "dob", class input_label_class ] [ text (t model.translations "Date of birth:") ]
                            , input
                                [ type_ "date"
                                , property "autocomplete" (JE.string "bday")
                                , onInput (Participant.UpdateDob >> ParticipantMsg)
                                , value
                                    (case model.participant.dob of
                                        Dob.Invalid s ->
                                            s

                                        Dob.Valid d ->
                                            Date.toIsoString d
                                    )
                                , id "dob"
                                , name "participant[dob]"
                                , class
                                    dob_class
                                ]
                                []
                            ]
                      , div [ class "space-y-1" ]
                            [ label [ for "class", class input_label_class ] [ text (t model.translations "Class:") ]
                            , select
                                [ onInput (Participant.SelectClass >> ParticipantMsg)
                                , value
                                    (case model.participant.selected_class of
                                        Nothing ->
                                            "--"

                                        Just c ->
                                            c.id
                                    )
                                , id "class"
                                , name "participant[tournament_class]"
                                , class valid_input_class
                                ]
                                (option
                                    [ name "Class"
                                    , disabled False
                                    , selected (model.participant.selected_class == Nothing)
                                    , value "--"
                                    ]
                                    [ text "--" ]
                                    :: viewAvailableClasses model.classes model.participant
                                )
                            ]
                      , div [ class "space-y-1" ]
                            [ label
                                [ for "target_face", class input_label_class ]
                                [ text (t model.translations "Target:") ]
                            , select
                                [ onInput (Participant.SelectTargetFace >> ParticipantMsg)
                                , id "target_face"
                                , name "participant[target_face]"
                                , class valid_input_class
                                ]
                                (option
                                    [ selected (model.participant.selected_target_face == Nothing)
                                    , disabled False
                                    , value "--"
                                    ]
                                    [ text "--" ]
                                    :: (case model.participant.selected_class of
                                            Nothing ->
                                                []

                                            Just { possible_target_faces } ->
                                                map
                                                    (\tf ->
                                                        option
                                                            [ selected (model.participant.selected_target_face == Just tf)
                                                            , value tf.id
                                                            ]
                                                            [ text tf.name ]
                                                    )
                                                    possible_target_faces
                                       )
                                )
                            ]
                      , div [ class "space-y-1" ]
                            [ label [ for "comment", class input_label_class ] [ text (t model.translations "Comment:") ]
                            , input [ id "comment", name "registration[comment]", class valid_input_class, onInput UpdateComment, value model.comment ] []
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
    , existing_archer :
        Maybe
            { first_name : String
            , last_name : String
            , email : String
            , dob : String
            , selected_class : String
            , selected_target_face : String
            , comment : String
            }
    }
