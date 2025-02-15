module Types exposing (Children(..), CollabState, Column, Conflict, Direction(..), DropId(..), ExportFormat(..), ExportSelection(..), ExportSettings, Group, HistoryState(..), IncomingMsg(..), Mode(..), Msg(..), Op(..), OutgoingMsg(..), OutsideData, Selection(..), Status(..), Tree, ViewMode(..), ViewState, VisibleViewState, WordCount)

import Debouncer.Basic as Debouncer
import Fonts
import Html5.DragDrop as DragDrop
import Json.Decode as Json
import Time
import Translation


type Msg
    = NoOp
      -- === Card Activation ===
    | Activate String
    | SearchFieldUpdated String
      -- === Card Editing  ===
    | OpenCard String String
    | DeleteCard String
      -- === Card Insertion  ===
    | InsertAbove String
    | InsertBelow String
    | InsertChild String
      -- === Card Moving  ===
    | DragDropMsg (DragDrop.Msg String DropId)
      -- === History ===
    | ThrottledCommit (Debouncer.Msg ())
    | ThrottledBackup (Debouncer.Msg ())
    | CheckoutCommit String
    | Restore
    | CancelHistory
    | Sync
    | SetSelection String Selection String
    | Resolve String
      -- === UI ===
    | TimeUpdate Time.Posix
    | VideoModal Bool
    | FontsMsg Fonts.Msg
    | ShortcutTrayToggle
    | WordcountTrayToggle
      -- === Ports ===
    | Port IncomingMsg
    | LogErr String


type
    OutgoingMsg
    -- === Dialogs, Menus, Window State ===
    = Alert String
    | SaveAndClose (Maybe ( Json.Value, Json.Value ))
    | SetChanged Bool
    | ConfirmCancelCard String String
    | ColumnNumberChange Int
      -- === Database ===
    | CommitWithTimestamp
    | SaveToDB ( Json.Value, Json.Value )
    | SaveBackup
    | SaveLocal Tree
    | Push
    | Pull
      -- === File System ===
    | ExportDOCX String (Maybe String)
    | ExportJSON Tree (Maybe String)
    | ExportTXT Bool Tree (Maybe String)
    | ExportTXTColumn Int Tree (Maybe String)
      -- === DOM ===
    | ActivateCards ( String, Int, List (List String) )
    | FlashCurrentSubtree
    | TextSurround String String
      -- === UI ===
    | UpdateCommits ( Json.Value, Maybe String )
    | SetVideoModal Bool
    | SetFonts Fonts.Settings
    | SetShortcutTray Bool
      -- === Misc ===
    | SocketSend CollabState
    | ConsoleLogRequested String


type
    IncomingMsg
    -- === Dialogs, Menus, Window State ===
    = IntentSave
    | IntentExit
    | IntentExport ExportSettings
    | CancelCardConfirmed
      -- === Database ===
    | Commit Int
    | SetHeadRev String
    | Merge Json.Value
      -- === DOM ===
    | DragStarted String
    | FieldChanged String
    | TextSelected Bool
      -- === UI ===
    | SetLanguage Translation.Language
    | ViewVideos
    | FontSelectorOpen (List String)
    | Keyboard String
      -- === Misc ===
    | RecvCollabState CollabState
    | CollaboratorDisconnected String


type alias OutsideData =
    { tag : String, data : Json.Value }


type alias ExportSettings =
    { format : ExportFormat
    , selection : ExportSelection
    , filepath : Maybe String
    }


type ExportFormat
    = DOCX
    | JSON
    | TXT


type ExportSelection
    = All
    | CurrentSubtree
    | ColumnNumber Int


type alias Tree =
    { id : String
    , content : String
    , children : Children
    }


type Children
    = Children (List Tree)


type alias Group =
    List Tree


type alias Column =
    List (List Tree)


type Op
    = Ins String String (List String) Int
    | Mod String (List String) String String
    | Del String (List String)
    | Mov String (List String) Int (List String) Int


type Selection
    = Original
    | Ours
    | Theirs
    | Manual


type alias Conflict =
    { id : String
    , opA : Op
    , opB : Op
    , selection : Selection
    , resolved : Bool
    }


type Status
    = Bare
    | Clean String
    | MergeConflict Tree String String (List Conflict)


type HistoryState
    = Closed
    | From String


type Direction
    = Forward
    | Backward


type Mode
    = CollabActive String
    | CollabEditing String


type DropId
    = Above String
    | Below String
    | Into String


type alias CollabState =
    { uid : String
    , mode : Mode
    , field : String
    }


type ViewMode
    = Normal
    | Editing


type alias ViewState =
    { active : String
    , activePast : List String
    , descendants : List String
    , ancestors : List String
    , viewMode : ViewMode
    , searchField : Maybe String
    , dragModel : DragDrop.Model String DropId
    , draggedTree : Maybe ( Tree, String, Int )
    , copiedTree : Maybe Tree
    , collaborators : List CollabState
    }


type alias VisibleViewState =
    { active : String
    , viewMode : ViewMode
    , descendants : List String
    , ancestors : List String
    , dragModel : DragDrop.Model String DropId
    , collaborators : List CollabState
    , language : Translation.Language
    }


type alias WordCount =
    { card : Int
    , subtree : Int
    , group : Int
    , column : Int
    , document : Int
    }
