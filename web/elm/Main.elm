module Main exposing (..)

import Html.App as App
import Html exposing (..)
import Html.Attributes exposing (value, placeholder, class)
import Html.Events exposing (onInput, onClick)
import Json.Decode as JD exposing ((:=), at)
import Dict
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push


type alias Flags =
    { userStream : String }



-- Our model will track a list of messages and the text for our new message to
-- send.  We only support chatting in a single channel for now.


type alias Model =
    { newMessage : String
    , messages : List String
    , phxSocket : Phoenix.Socket.Socket Msg
    , userStream : String
    }


type alias ApiResponse =
    { meta : Dict
    , data : Dict
    }



-- We can either set our new message or join our channel


type Msg
    = JoinChannel
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | ReceiveApiResponse String


initialModel : String -> Model
initialModel stream =
    { newMessage = ""
    , messages = []
    , phxSocket = initPhxSocket
    , userStream = stream
    }


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


initPhxSocket : Phoenix.Socket.Socket Msg
initPhxSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.withDebug
        |> Phoenix.Socket.on "new:msg" "rooms:*" ReceiveApiResponse


apiResponseDecoder : JD.Decoder ApiResponse
apiResponseDecoder =
    JD.object2 ApiResponse
        ("meta" := JD.dict string)
        ("data" := JD.dict string)



-- We'll handle either setting the new message or joining the channel.


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        JoinChannel ->
            let
                channel =
                    Phoenix.Channel.init ("room:" ++ model.userStream)

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.join channel model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )

        PhoenixMsg msg ->
            let
                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.update msg model.phxSocket
            in
                ( { model | phxSocket = phxSocket }
                , Cmd.map PhoenixMsg phxCmd
                )



-- Our view will consist of a button to join the lobby, a list of messages, and
-- our text input for crafting our message


view : Model -> Html Msg
view model =
    div []
        -- Clicking the button joins the lobby channel
        [ button [ onClick JoinChannel ] [ text ("Join " ++ model.userStream ++ "'s lobby") ]
        , div [ class "messages" ]
            -- add loop here to display messages
            --
            [ ul []
                [ li [] [ text "fake incoming message" ]
                ]
            ]
        ]



-- Wire together the program


main : Program Flags
main =
    App.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- No subscriptions yet


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phxSocket PhoenixMsg



-- And here's our init function


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        { userStream } =
            flags
    in
        ( Model "" [] initPhxSocket userStream, Cmd.none )
