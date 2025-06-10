module Participants exposing (main)

import Browser
import Class exposing (Class, class_in_range)
import Date exposing (Date)
import Email
import Html exposing (Html, div, form, input, label, option, select, text)
import Html.Attributes exposing (action, autocomplete, class, disabled, for, id, method, name, property, selected, type_, value)
import Html.Events exposing (onInput)
import I18Next exposing (t, translationsDecoder)
import Json.Decode as JD
import Json.Encode as JE
import List exposing (filter, map)
import Maybe exposing (andThen, withDefault)
import TargetFace exposing (TargetFace)
import Time exposing (Month(..))


main : Program Flags Model Msg
main =
    Browser.element { init = init, subscriptions = subscriptions, update = update, view = view }


type alias ValidModel =
    { flags : Flags
    , translations : I18Next.Translations
    , classes : List Class
    , first_name : String
    , last_name : String
    , email : String
    , dob : Dob
    , selected_class : Maybe Class
    , selected_target_face : Maybe TargetFace
    }


type Model
    = InitializationError String
    | ValidatedModel ValidModel


type Dob
    = Invalid String
    | Valid Date


init : Flags -> ( Model, Cmd msg )
init f =
    let
        decoded_classed =
            JD.decodeValue (JD.list Class.classDecoder) f.classes
                |> Result.mapError JD.errorToString

        decoded_translations =
            JD.decodeValue translationsDecoder f.translations
    in
    ( case ( decoded_translations, decoded_classed ) of
        ( Result.Ok translations, Result.Ok validClasses ) ->
            ValidatedModel
                { flags = f
                , translations = translations
                , classes = validClasses
                , first_name = ""
                , last_name = ""
                , email = ""
                , dob = Invalid ""
                , selected_class = Nothing
                , selected_target_face = Nothing
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
    = SelectClass String
    | SelectTargetFace String
    | UpdateDob String
    | UpdateFirstName String
    | UpdateLastName String
    | UpdateEmail String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg mdl =
    case mdl of
        InitializationError _ ->
            ( mdl, Cmd.none )

        ValidatedModel model ->
            ( ValidatedModel
                (case msg of
                    SelectClass cls_id ->
                        let
                            m0 =
                                model

                            m1 =
                                { m0
                                    | selected_class =
                                        model.classes
                                            |> filter (\{ id } -> id == cls_id)
                                            |> List.head
                                }

                            m2 =
                                { m1 | selected_target_face = updateSelectedTargetFace m1 }
                        in
                        m2

                    SelectTargetFace tf ->
                        { model
                            | selected_target_face =
                                model.selected_class
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

                    UpdateEmail e ->
                        { model | email = e }
                )
            , Cmd.none
            )


updateSelectedClass : ValidModel -> Maybe Class
updateSelectedClass model =
    if
        available_classes model
            |> map (\cls -> Just cls)
            |> List.member model.selected_class
    then
        model.selected_class

    else
        Nothing


updateSelectedTargetFace : ValidModel -> Maybe TargetFace
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


available_classes : ValidModel -> List Class.Class
available_classes model =
    case model.dob of
        Invalid _ ->
            []

        Valid dob ->
            model.classes |> filter (class_in_range dob)


submittable : ValidModel -> Bool
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
        && (case Email.fromString model.email of
                Just _ ->
                    True

                Nothing ->
                    False
           )


viewAvailableClasses : ValidModel -> List (Html Msg)
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
                    if String.isEmpty model.first_name then
                        invalid_input_class

                    else
                        valid_input_class

                last_name_class =
                    if String.isEmpty model.last_name then
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
                    case model.dob of
                        Valid _ ->
                            valid_input_class

                        Invalid _ ->
                            invalid_input_class
            in
            form [ action model.flags.form_action_url, method "post", class "space-y-4 max-w-lg mx-auto p-6 bg-white shadow rounded-lg" ]
                [ input [ type_ "hidden", name "authenticity_token", value model.flags.csrf_token, autocomplete False ] []
                , div [ class "space-y-1" ]
                    [ label [ for "first_name", class input_label_class ] [ text (t model.translations "Given name:") ]
                    , input [ id "first_name", property "autocomplete" (JE.string "given-name"), name "participant[first_name]", class first_name_class, onInput UpdateFirstName, value model.first_name ] []
                    ]
                , div [ class "space-y-1" ]
                    [ label [ for "last_name", class input_label_class ] [ text (t model.translations "Last name:") ]
                    , input [ id "last_name", property "autocomplete" (JE.string "family-name"), name "participant[last_name]", class last_name_class, onInput UpdateLastName, value model.last_name ] []
                    ]
                , div [ class "space-y-1" ]
                    [ label [ for "email", class input_label_class ] [ text (t model.translations "Email address:") ]
                    , input [ id "email", type_ "email", name "participant[email]", class email_class, onInput UpdateEmail, value model.email ] []
                    ]
                , div [ class "space-y-1" ]
                    [ label [ for "dob", class input_label_class ] [ text (t model.translations "Date of birth:") ]
                    , input
                        [ type_ "date"
                        , property "autocomplete" (JE.string "bday")
                        , onInput UpdateDob
                        , value
                            (case model.dob of
                                Invalid s ->
                                    s

                                Valid d ->
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
                        [ onInput SelectClass
                        , value
                            (case model.selected_class of
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
                            , selected (model.selected_class == Nothing)
                            , value "--"
                            ]
                            [ text "--" ]
                            :: viewAvailableClasses model
                        )
                    ]
                , div [ class "space-y-1" ]
                    [ label
                        [ for "target_face", class input_label_class ]
                        [ text (t model.translations "Target:") ]
                    , select
                        [ onInput SelectTargetFace
                        , id "target_face"
                        , name "participant[target_face]"
                        , class valid_input_class
                        ]
                        (option
                            [ selected (model.selected_target_face == Nothing)
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
                                                    , value tf.id
                                                    ]
                                                    [ text tf.name ]
                                            )
                                            possible_target_faces
                               )
                        )
                    ]
                , input
                    [ type_ "submit"
                    , value (t model.translations "Submit")
                    , disabled <| not <| submittable <| model
                    , class "inline-block px-6 py-2 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-gray-300 disabled:cursor-not-allowed"
                    ]
                    []
                ]



-- Flags


type alias Flags =
    { csrf_token : String
    , form_action_url : String
    , classes : JD.Value
    , translations : JD.Value
    }
