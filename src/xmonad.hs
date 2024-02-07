-- -*- coding: utf-8 -*-
--
{-# LANGUAGE NoMonomorphismRestriction #-}
import XMonad
import Data.Monoid
import Data.Char
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

import XMonad.ManageHook
import XMonad.Util.Run
import XMonad.Util.Cursor
import XMonad.Util.XSelection
import XMonad.Util.XUtils
-- import XMonad.Actions.Volume
import XMonad.Layout.PerWorkspace
import XMonad.Layout.NoBorders
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Prompt
import XMonad.Prompt.Input
import System.Posix.Process (createSession, executeFile, forkProcess)
import XMonad.Hooks.EwmhDesktops
import XMonad.Actions.CycleWS
import XMonad.Actions.GridSelect
import XMonad.Hooks.SetWMName
import qualified XMonad.Layout.Hidden as H

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "gnome-terminal"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Width of the window border in pixels.
--
myBorderWidth   = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#000000" -- "#07745f"
myFocusedBorderColor = "#ffffff"

reloadXmonad = "xmonad --recompile; xmonad --restart; " ++
  "xmessage -center -geometry 300x100 'XMonad reloaded'"

gsconfig2 colorizer = (buildDefaultGSConfig colorizer) {
  gs_cellheight = 60, gs_cellwidth = 180 }

greenColorizer = colorRangeFromClassName
                     black            -- lowest inactive bg
                     (0x70,0xFF,0x70) -- highest inactive bg
                     black            -- active bg
                     white            -- inactive fg
                     white            -- active fg
  where black = minBound
        white = maxBound
        
gsKeyBindings modm = [((modm, xK_g), goToSelected $ gsconfig2 greenColorizer)
                     , ((modm, xK_m), spawnSelected (gsconfig2 stringColorizer) apps)]
  where
    apps = ["google-chrome", "code", "emacs", "nautilus","firefox", "calibre"
           ,"gnome-control-center", "XMind", "idea.sh", "FoxitReader"]


------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)
    -- launch dmenu
    , ((modm,               xK_s     ), spawn "dmenu_run")
    -- launch gmrun
    , ((modm .|. shiftMask, xK_m     ), spawn "gmrun")
    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)
     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)
    , ((modm,               xK_minus ), withFocused H.hideWindow)
    , ((modm,               xK_equal ), H.popOldestHiddenWindow)
    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)
    -- Resize viewed windows to the correct size
    , ((modm,               xK_r     ), refresh)
    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)
    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)
    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )
    -- Move focus to the master window
    , ((modm,               xK_o     ), windows W.focusMaster  )
    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)
    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )
    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )
    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)
    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)
    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)
    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))
    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))
    -- screenshot screen
    , ((modm              , xK_Print), spawn "/usr/bin/screenshot scr")
    -- screenshot window or area
    , ((modm .|. shiftMask, xK_Print), spawn "/usr/bin/screenshot win")
    -- , ((modm, xK_F8 ), lowerVolume 3 >> return ())
    -- , ((modm, xK_F9 ), raiseVolume 3 >> return ())
    -- , ((modm, xK_F10), toggleMute    >> return ())

    -- , ((modm              , xK_s),      getSelection  >>= sdcv)
    -- , ((modm .|. shiftMask, xK_s),      getPromptInput ?+ sdcv)
    --, ((modm .|. shiftMask, xK_s),      getDmenuInput >>= sdcv)
    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))
    -- Restart xmonad
    , ((modm              , xK_q     ), spawn reloadXmonad)
   -- 
    , ((modm,               xK_p   ), prevWS)
    -- Move focus to the next window
    , ((modm,               xK_n     ), nextWS)
    , let msg = "xmessage -center -geometry 300x100 'Hello from My XMonad'"
      in ((modm, xK_F1), spawn msg)
    ]
    ++
    -- \\
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_e, xK_r, xK_w] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    ++
    
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_bracketright, xK_backslash, xK_bracketleft] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    
    ++ (gsKeyBindings modm)

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    , ((0, 9), const $ windows W.focusUp  ) -- %! Move focus to the previous window
    , ((0, 8), const $ windows W.focusDown) -- %! Move focus to the next window
    , ((modm, button4), const $ prevWS) 
    , ((modm, button5), const $ nextWS)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = smartBorders $ onWorkspace "1" (Full ||| tiled ||| Mirror tiled ) (tiled ||| Mirror tiled ||| Full)
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = H.hiddenWindows (Tall nmaster delta ratio)
     -- The default number of windows in the master pane
     nmaster = 1
     -- Default proportion of screen occupied by master pane
     ratio   = 1/2
     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll [
      isFullscreen --> doFullFloat
    , isDialog   --> doCenterFloat
    , className =? "mplayer2"       --> doFloat
    , className =? "Gnome-mplayer"  --> doFloat
    , className =? "Gimp"           --> doFloat
    , className  =? "Display"       --> doFloat
    , className  =? "Eog"           --> doFloat
    , className  =? "Xmessage"      --> doFloat
    , className  =? "Dia-gnome"     --> doFloat
    , className  =? "Vlc"           --> doFloat
    , className  =? "OpenCV"        --> doFloat
    --, resource  =? "kdesktop"       --> doIgnore 
    --, className =? "Firefox"        --> doShift "W"
    --, className =? "Pidgin"         --> doShift "I"
    --, className =? "VirtualBox"     --> doShift "X"
    ]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = handleEventHook defaultConfig <+> fullscreenEventHook

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
--myLogHook = return ()
myLogHook = dynamicLog

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
-- 
-- By default, do nothing.
--myStartupHook = return ()
myStartupHook = do
  spawn "fcitx"
  setDefaultCursor xC_left_ptr
  spawn "feh --bg-scale /home/bison/Pictures/desktop.jpg"
  --spawn "trayer --edge top --align right --widthtype percent --width 10 --SetDockType true --SetPartialStrut true --transparent true --alpha 0 --tint 0x000000 --expand true --heighttype pixel --height 25"
  spawn "volti"
  setWMName "LG3D"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
-- not work:
-- main = xmonad =<< xmobar (ewmh defaults)
main = xmonad =<< xmobar defaults

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--

defaults = defaultConfig {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,
      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,
      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }

--getDmenuInput = fmap (filter isPrint) $ runProcessWithInput "dmenu" ["-p", "Dict: "] ""
getPromptInput = inputPrompt def "Dict: "

sdcv word = do
    output <- runProcessWithInput "sdcv" ["-n", word] ""
    mySafeSpawn "notify-send" [word, trString output]

trString = foldl (\s c -> s ++ (trChar c)) ""

trChar c 
    | c == '<' = "&lt;"
    | c == '>' = "&gt;"
    | c == '&' = "&amp;"
    | otherwise = [c]

mySafeSpawn :: MonadIO m => FilePath -> [String] -> m ()
mySafeSpawn prog args = io $ void_ $ forkProcess $ do
    uninstallSignalHandlers
    _ <- createSession
    executeFile prog True args Nothing
        where void_ = (>> return ()) -- TODO: replace with Control.Monad.void / void not in ghc6 apparently

