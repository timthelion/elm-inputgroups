module Signal.InputGroups where
{-|
This module provides the ability to have InputGroups or groups of inputs which can be toggled on and off together.  This is essencial to creating mutli-tab or multi-mode applications.

# Classes
@docs InputGroup, makeGroup

Here is some example code(toggle between two mario games by pressing down the left mouse button.):

````
import Keyboard
import Mouse
import Window
import Signal.InputGroups as InputGroups

group1Toggle = Mouse.isDown
group1 = InputGroups.makeGroup group1Toggle

group1Input = group1.add input (0,{x=0,y=0})

group2Toggle = not <~ Mouse.isDown
group2 = InputGroups.makeGroup group2Toggle

group2Input = group2.add input (0,{x=0,y=0})

-- MODEL
mario = { x=0, y=0, vx=0, vy=0, dir="right" }


-- UPDATE -- ("m" is for Mario)
jump {y} m = if y > 0 && m.y == 0 then { m | vy <- 5 } else m
gravity t m = if m.y > 0 then { m | vy <- m.vy - t/4 } else m
physics t m = { m | x <- m.x + t*m.vx , y <- max 0 (m.y + t*m.vy) }
walk {x} m = { m | vx <- toFloat x
                 , dir <- if | x < 0     -> "left"
                             | x > 0     -> "right"
                             | otherwise -> m.dir }

step (t,dir) = physics t . walk dir . gravity t . jump dir


-- DISPLAY
render (w',h') mario =
  let (w,h) = (toFloat w', toFloat h')
      verb = if | mario.y  >  0 -> "jump"
                | mario.vx /= 0 -> "walk"
                | otherwise     -> "stand"
      src  = "http://elm-lang.org/imgs/mario/" ++ verb ++ "/" ++ mario.dir ++ ".gif"
  in collage w' h'
      [ rect w h  |> filled (rgb 174 238 238)
      , rect w 50 |> filled (rgb 74 163 41)
                  |> move (0, 24 - h/2)
      , toForm (image 35 35 src) |> move (mario.x, mario.y + 62 - h/2)
      ]

-- MARIO
input = let delta = lift (\t -> t/20) (fps 25)
        in sampleOn delta (lift2 (,) delta Keyboard.arrows)
        
game inp = lift2 render Window.dimensions <| foldp step mario inp

main  = merge (game group1Input) (game group2Input)
-}

type InputGroup a = -- Arg, why no exticential types in Elm?
 {add: Signal a -> a -> Signal a}

{-| The initializer for InputGroup objects -}
makeGroup: Signal Bool -> InputGroup a
makeGroup toggle =
 {add = (\signal a-> keepWhen toggle a signal)}
