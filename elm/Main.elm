import Gfx exposing (canvas, rings)
import Task
import Random
import Signal
import Mouse
import Graphics.Element exposing (show, Element)
import Time

-- Map signal updates to graphics
seedToPic : (Int, Time.Time) -> Element
seedToPic (mx, t) = 
  let 
    (elem, s0) = rings (Random.initialSeed mx) t
  in
    canvas [elem]

-- Combine the mouse and time signals into a tuple, map the tuple to a graphic
main = Signal.map2 (,) Mouse.x (Time.every Time.millisecond) |> Signal.map seedToPic