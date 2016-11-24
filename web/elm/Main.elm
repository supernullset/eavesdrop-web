module Main exposing (..)

--where
import Html exposing (Html, h3, div, text, ul, li, input, form, button, br, table, tbody, tr, td, programWithFlags)
import Platform.Cmd
import Phoenix.Socket
import Phoenix.Channel
import Json.Encode as JE
import Json.Decode as JD exposing (field)


-- MAIN

type alias Flags =
    { userStream : String }


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


-- CONSTANTS
socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"

-- MODEL


type Msg
    =
    SetNewMessage String
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | ReceiveChatMessage JE.Value
    | NoOp


type alias Model =
    { newMessage : String
    , messages : List String
    , phxSocket : Phoenix.Socket.Socket Msg
    , userStream : String
    }


initPhxSocket : String -> Phoenix.Socket.Socket Msg
initPhxSocket stream =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "state_change" ("room:" ++ stream) ReceiveChatMessage


initModel : String -> Model
initModel stream =
    Model "" [] (initPhxSocket stream) stream


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        { userStream } =
            flags
        channel =
            Phoenix.Channel.init ("room:" ++ model.userStream)

        ( phxSocket, phxCmd ) =
            Phoenix.Socket.join channel model.phxSocket

        model = initModel userStream
    in
        ( { model | phxSocket = phxSocket }
        , Cmd.map PhoenixMsg phxCmd
        )

-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg

-- COMMANDS
-- PHOENIX STUFF


type alias ChatMessage =
    {
    body : String
    }


chatMessageDecoder : JD.Decoder ChatMessage
chatMessageDecoder =
    JD.map ChatMessage
        (field "body" JD.string)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        SetNewMessage str ->
            ( { model | newMessage = str }
            , Cmd.none
            )

        ReceiveChatMessage raw ->
            case JD.decodeValue chatMessageDecoder raw of
                Ok chatMessage ->
                    ( { model | messages = (chatMessage.body) :: model.messages }
                    , Cmd.none
                    )

                Err error ->
                    ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [
        h3 [] [ text "Messages:" ]
        , ul [] ((List.reverse << List.map renderMessage) model.messages)
        ]

renderMessage : String -> Html Msg
renderMessage str =
    li [] [ text str ]
